# tech-challenge-db-infra

Infraestrutura como código do **banco de dados gerenciado** da Fase 3 (The Java Garage).

Provisiona via **Terraform**:

- VPC com subnets públicas e privadas (compartilhada com o EKS via remote state)
- **Amazon RDS PostgreSQL** em subnets privadas
- Security group restringindo acesso à porta 5432
- Outputs: endpoint, porta, VPC/subnet IDs, secret ARN (senha)

## Stack

| Item | Escolha |
|---|---|
| Nuvem | AWS (`sa-east-1` por padrão) |
| Banco | RDS PostgreSQL 16 |
| IaC | Terraform ≥ 1.6 |
| Backend | S3 + DynamoDB (lock) — configurar antes do primeiro `apply` |

Repositórios irmãos: [core](https://github.com/fiap-pos-2026/tech-challenge-core) · [k8s-infra](https://github.com/fiap-pos-2026/tech-challenge-k8s-infra) · [auth-lambda](https://github.com/fiap-pos-2026/tech-challenge-auth-lambda)

```text
┌─────────────┐     ┌──────────────────┐
│  EKS / App  │────►│  RDS PostgreSQL  │
│  Lambda     │     │  (private subnet)│
└─────────────┘     └──────────────────┘
        ▲                     ▲
        └──── VPC (este repo) ┘
```

## Pré-requisitos

1. Conta AWS com créditos estudante e credenciais configuradas (`aws configure` ou OIDC no CI).
2. Terraform ≥ 1.6.
3. Bucket S3 + tabela DynamoDB para o backend (criar uma vez; ver `backend.hcl.example`).

## Uso local

```bash
cp terraform.tfvars.example terraform.tfvars
# edite db_password (forte) e project_name se quiser

cp backend.hcl.example backend.hcl
# edite bucket / dynamodb_table / region

terraform init -backend-config=backend.hcl
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

**Não commitar** `terraform.tfvars`, `backend.hcl` nem `*.tfstate`.

## Outputs úteis para outros repos

| Output | Consumidor |
|---|---|
| `vpc_id`, `private_subnet_ids`, `public_subnet_ids` | `tech-challenge-k8s-infra` (EKS na mesma VPC) |
| `rds_endpoint`, `rds_port`, `db_name` | `tech-challenge-core` / Lambda (conexão JDBC) |
| `rds_security_group_id` | liberar SG do EKS/Lambda na porta 5432 |

## CI/CD

Workflow em `.github/workflows/terraform.yml`:

- **PR → main:** `fmt` + `validate` + `plan`
- **Push main / workflow_dispatch:** `apply` (ambiente homolog; prod via environment GitHub)

Secrets necessários no repositório: `AWS_ROLE_ARN` (OIDC) ou access keys; `TF_VAR_db_password`.

## Custos

RDS + NAT Gateway consomem créditos. Use `terraform destroy` fora de períodos de demo e configure **AWS Budgets**.
