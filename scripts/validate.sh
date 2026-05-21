#!/usr/bin/env bash
set -euo pipefail

echo "Running Terraform module validation..."

terraform fmt -check -recursive
terraform init -backend=false
terraform validate

for example in examples/*; do
  if [ -d "${example}" ]; then
    echo "Validating ${example}..."
    terraform -chdir="${example}" init -backend=false
    terraform -chdir="${example}" validate
  fi
done
