# Backend remoto — valores concretos via `terraform init -backend-config=backend.hcl`
# (ver backend.hcl.example). Não versionar backend.hcl.

terraform {
  backend "s3" {}
}
