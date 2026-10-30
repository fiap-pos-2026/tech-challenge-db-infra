# tech-challenge-db-infra

Infraestrutura como código do **banco de dados gerenciado** da Fase 3 (The Java Garage).

Provisiona via **Terraform**:

- VPC com subnets públicas e privadas (compartilhada com o EKS via remote state)
- **Amazon RDS PostgreSQL** em subnets privadas
- Security group restringindo acesso à porta 5432
- Outputs: endpoint, porta, VPC/subnet IDs, JDBC URL

## Stack

| Item | Escolha |
|---|---|
| Nuvem | AWS Academy Learner Lab (`us-east-1`) |
| Banco | RDS PostgreSQL **18.6** (console: `18.6-R1`) |
| IaC | Terraform ≥ 1.6 |
| Backend | S3 + DynamoDB (lock) |
| Auth CI | Chaves temporárias Academy (`AWS_SESSION_TOKEN`); OIDC não é permitido no `voclabs` |

Repositórios irmãos: [core](https://github.com/fiap-pos-2026/tech-challenge-core) · [k8s-infra](https://github.com/fiap-pos-2026/tech-challenge-k8s-infra) · [auth-lambda](https://github.com/fiap-pos-2026/tech-challenge-auth-lambda)

```text
┌─────────────┐     ┌──────────────────┐
│  EKS / App  │────►│  RDS PostgreSQL  │
│  Lambda     │     │  (private subnet)│
└─────────────┘     └──────────────────┘
        ▲                     ▲
        └──── VPC (este repo) ┘
```

## Homolog — como obter outputs (sem expor no Git)

Repos AWS Academy é **efêmera** e os repositórios são **públicos**. **Não** versione IDs de VPC/subnet/SG, endpoints RDS/JDBC, usuários ou senhas no README.

Após o `apply` (CI ou local), leia o state:

```bash
terraform output
# principais: vpc_id, private_subnet_ids, public_subnet_ids,
# rds_endpoint, rds_port, rds_db_name, rds_security_group_id, jdbc_url
```

No Actions: job **Apply (homolog)** → log → seção `Outputs:`.

Compartilhe JDBC/usuário/senha com o time só por **canal privado** (não em issue/PR/README).

Consumidor EKS: [tech-challenge-k8s-infra](https://github.com/fiap-pos-2026/tech-challenge-k8s-infra) (remote state + regra de SG dos nodes na 5432).

## Pré-requisitos

1. Lab Academy ativo + chaves CLI (renovar a cada Start Lab).
2. Terraform ≥ 1.6.
3. Bucket S3 + tabela DynamoDB de lock (`backend.hcl.example`).

## Uso local

```bash
cp terraform.tfvars.example terraform.tfvars
cp backend.hcl.example backend.hcl
# edite bucket / tabela / region / db_password

terraform init -backend-config=backend.hcl
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

**Não commitar** `terraform.tfvars`, `backend.hcl` nem `*.tfstate`.

## CI/CD

Workflow `.github/workflows/terraform.yml`:

- **PR → main:** `fmt` + `validate` + `plan`
- **Push `main`:** `apply` (environment `homolog`)

Secrets do repositório (valores só no GitHub Secrets, nunca no Git):
`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`, `TF_STATE_BUCKET`, `TF_LOCK_TABLE`, `TF_VAR_DB_PASSWORD`.

## Custos / budget

RDS + **NAT Gateway** são os maiores custos deste repo. Fora de demo:

```bash
terraform destroy -var-file=terraform.tfvars
```

Acompanhe o crédito do Learner Lab no portal Academy. Detalhes no plano Fase 3 (seção budget).
