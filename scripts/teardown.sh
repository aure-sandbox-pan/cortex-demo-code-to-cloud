#!/usr/bin/env bash
# Destroys the EKS cluster, ECR repo and app bucket (terraform/) after a
# demo session, so the cluster isn't left running (and billing) between
# sessions. Does NOT touch terraform-bootstrap/ (state bucket, OIDC
# provider, CD role) - those cost nothing idle and are needed for the next
# bootstrap.sh / cd.yml run.
#
# Prerequisites: same AWS credentials as bootstrap.sh, active in this shell.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

if [ ! -d terraform/.terraform ]; then
  echo "==> terraform/ not initialized here - initializing against the remote state"
  TFSTATE_BUCKET=$(terraform -chdir=terraform-bootstrap output -raw tfstate_bucket)
  GITHUB_REPO=$(basename -s .git "$(git remote get-url origin)")
  terraform -chdir=terraform init -input=false \
    -backend-config="bucket=$TFSTATE_BUCKET" \
    -backend-config="key=$GITHUB_REPO/terraform.tfstate" \
    -backend-config="region=${AWS_REGION:-eu-west-1}"
fi

echo "==> Destroying terraform/ (EKS cluster, ECR repo, app bucket)"
terraform -chdir=terraform destroy
# (interactive approval on purpose)

echo "==> Done. Re-run scripts/bootstrap.sh's last step (push to main, or"
echo "    'gh workflow run cd.yml') before the next recording session to"
echo "    recreate everything - budget ~15-20 min for the EKS cluster."
