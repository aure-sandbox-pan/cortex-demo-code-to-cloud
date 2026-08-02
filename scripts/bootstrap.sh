#!/usr/bin/env bash
# One-time setup: wires up AWS<->GitHub OIDC federation and points the repo's
# CI/CD at this AWS account. Safe to re-run - terraform apply is idempotent
# and gh variable set overwrites existing values.
#
# Prerequisites:
#   - AWS credentials for the target sandbox account active in this shell
#     (`aws sts get-caller-identity` must already return the right account).
#   - `gh auth login` already done, OR run this script and follow the manual
#     fallback instructions it prints.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

echo "==> Checking AWS credentials"
if ! aws sts get-caller-identity >/tmp/bootstrap-caller-identity.json 2>/tmp/bootstrap-caller-identity.err; then
  echo "ERROR: no valid AWS credentials in this shell." >&2
  cat /tmp/bootstrap-caller-identity.err >&2
  echo "Authenticate first (aws sso login / aws configure / assume-role), then re-run this script." >&2
  exit 1
fi
AWS_ACCOUNT_ID=$(python3 -c "import json;print(json.load(open('/tmp/bootstrap-caller-identity.json'))['Account'])")
echo "    Target AWS account: $AWS_ACCOUNT_ID"

echo "==> Detecting GitHub org/repo from git remote"
ORIGIN_URL=$(git remote get-url origin)
# handles both git@github.com:org/repo.git and https://github.com/org/repo.git
GITHUB_SLUG=$(echo "$ORIGIN_URL" | sed -E 's#(git@github\.com:|https://github\.com/)##; s#\.git$##')
GITHUB_ORG=$(echo "$GITHUB_SLUG" | cut -d/ -f1)
GITHUB_REPO=$(echo "$GITHUB_SLUG" | cut -d/ -f2)
AWS_REGION="${AWS_REGION:-eu-west-1}"
echo "    Repo:   $GITHUB_ORG/$GITHUB_REPO"
echo "    Region: $AWS_REGION"

echo "==> terraform-bootstrap: state bucket + GitHub OIDC provider + CD role"
terraform -chdir=terraform-bootstrap init -input=false
terraform -chdir=terraform-bootstrap apply \
  -var="github_org=$GITHUB_ORG" \
  -var="github_repo=$GITHUB_REPO" \
  -var="aws_region=$AWS_REGION"
# (interactive approval on purpose - this creates real AWS resources)

TFSTATE_BUCKET=$(terraform -chdir=terraform-bootstrap output -raw tfstate_bucket)
CD_ROLE_ARN=$(terraform -chdir=terraform-bootstrap output -raw github_actions_role_arn)
echo "    State bucket: $TFSTATE_BUCKET"
echo "    CD role ARN:  $CD_ROLE_ARN"

echo "==> Configuring GitHub Actions repo variables"
if gh auth status >/dev/null 2>&1; then
  gh variable set AWS_REGION --body "$AWS_REGION" --repo "$GITHUB_ORG/$GITHUB_REPO"
  gh variable set EKS_CLUSTER_NAME --body "cortex-demo-eks" --repo "$GITHUB_ORG/$GITHUB_REPO"
  gh variable set AWS_CD_ROLE_ARN --body "$CD_ROLE_ARN" --repo "$GITHUB_ORG/$GITHUB_REPO"
  gh variable set TFSTATE_BUCKET --body "$TFSTATE_BUCKET" --repo "$GITHUB_ORG/$GITHUB_REPO"
  echo "    Done via gh CLI."
else
  cat <<EOF
    gh CLI not authenticated. Set these manually:
    GitHub repo > Settings > Secrets and variables > Actions > Variables

    AWS_REGION       = $AWS_REGION
    EKS_CLUSTER_NAME = cortex-demo-eks
    AWS_CD_ROLE_ARN  = $CD_ROLE_ARN
    TFSTATE_BUCKET   = $TFSTATE_BUCKET
EOF
fi

cat <<EOF

==> Bootstrap complete. Next steps:
    1. Commit and push to main - this triggers cd.yml, which provisions the
       EKS cluster, ECR repo and app bucket (~15-20 min for the cluster).
    2. Once the cluster exists, install the Cortex Cloud Kubernetes agent +
       admission controller on it (manual, from the Cortex Cloud console).
    3. Set the CORTEX_API_URL / CORTEX_ACCESS_KEY_ID / CORTEX_SECRET_KEY
       repo secrets and replace the placeholder step in .github/workflows/ci.yml
       (see README).
    4. Run scripts/teardown.sh after each recording session to stop paying
       for the EKS cluster between sessions.
EOF
