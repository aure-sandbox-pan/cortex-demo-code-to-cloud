# Cortex Cloud - Code to Cloud Visibility & Vulnerability Tracing

Demo repo for the 30-minute live workshop: "the life of a vulnerability, from
Git commit to Kubernetes runtime." Ties together IDE scanning, IaC/secrets
scanning, SCA + SBOM, CI/CD guardrails, Kubernetes admission control, and
code-to-cloud tracing in Cortex Cloud.

## Structure

- `app/` - minimal Flask app with an intentionally outdated dependency
  (`requests==2.25.1`, CVE-2023-32681, fixed in 2.31.0) for the SCA demo.
- `Dockerfile` - packages the app.
- `terraform/main.tf` - baseline, compliant S3 bucket for app assets.
- `terraform/snippets/vulnerable-bucket.tf.snippet` - the "bake": paste this
  into `main.tf` live during Phase 1 to introduce a public ACL + hardcoded
  AWS credentials and trigger the Cortex IDE extension.
- `k8s/deployment.yaml`, `k8s/service.yaml` - compliant baseline deployment.
- `k8s/bad-pod.yaml` - non-compliant pod (privileged, root, hostNetwork, no
  resource limits, mutable tag) for the live Admission Control rejection.
- `.github/workflows/ci.yml` - PR pipeline: Cortex Cloud scan + SBOM
  generation.
- `scripts/bootstrap.sh` / `scripts/teardown.sh` - one-command AWS↔GitHub
  setup and teardown, see below. This is what makes the repo reusable by
  another CSE against their own AWS account/GitHub fork with near-zero
  manual steps.

## Prerequisites

1. **Provision a sandbox AWS account via Torque**
   ([laas.paloaltonetworks.com/GCS](https://laas.paloaltonetworks.com/GCS),
   blueprint "Provision AWS Account"). You'll get an email with the new
   account ID and a switch-role link into `TorqueUserRole`
   (`AdministratorAccess`). Note the account's expiry date - it's torn down
   automatically by Torque, so time the rest of this list accordingly.

2. **Get AWS CLI credentials for that account**, via the AWS Console +
   CloudShell (Torque access is an Okta SAML app tile, not IAM Identity
   Center - there's no SSO portal URL to point a CLI tool at):
   - Log in via Okta (GlobalProtect VPN required) → switch role into
     `TorqueUserRole` in the AWS Console for your provisioned account.
   - Open **CloudShell** (top nav bar) - it inherits that session's
     credentials automatically, no extra auth needed.
   - Run `aws configure export-credentials --format env` and copy the three
     `export AWS_...` lines into your local shell. These are short-lived
     (session-length) - re-run this whenever they expire, e.g. before
     re-running `bootstrap.sh`.
   - Note: this account's org-wide SCPs block `iam:CreateUser` and a few
     other actions - don't try to create a static-credential IAM user
     instead, it will be denied.

3. **AWS↔GitHub CI/CD wired up** - see "Reusing this repo" below
   (`./scripts/bootstrap.sh`, then push to `main`).

4. **AWS account onboarded to Cortex Cloud** (for the Terraform IaC scan and
   the code-to-cloud graph tracing in Phase 3). In the Cortex Cloud console:
   - **Settings > Data Sources & Integrations > Add New > AWS > Add Another
     Instance**.
   - **Scope: `Account`**.
   - **Scan Mode: `Cloud Scan`** (recommended default).
   - Under **Show advanced settings > Log Collection Configuration >
     Collect Audit Logs**: choose **`Use Automated collection`**, not
     `Custom (user defined)`. Custom expects a CloudTrail bucket + SNS topic
     ARN to already exist in the account (it only subscribes to them, it
     doesn't create them) - our Terraform doesn't provision any CloudTrail
     infra, so Custom would get stuck asking for values that don't exist.
     Automated collection creates its own dedicated CloudTrail/S3/SNS/SQS as
     part of the onboarding stack instead.
   - Leave "Collect data events" unchecked - it's CloudTrail data-level
     events (S3 object access, Lambda invocations); nothing in this demo
     needs it, and it's the more expensive/higher-volume log type.
   - Under **Cloud Tags**, add a tag (e.g. Key `Project`, Value
     `Cortex-demo-Code-to-Cloud`) so resources Cortex creates are
     identifiable - then **Save**.
   - Choose **Automated - Execute in AWS** - this
     opens a pre-filled CloudFormation "Quick create stack" page in a new
     tab/step, with all of Cortex's own parameters already populated.
   - On that CloudFormation page: give the stack a name (e.g.
     `cortex-demo-code-to-cloud`), optionally add the same `Project` tag
     under "Tags - optional", scroll to **Capabilities** and check **"I
     acknowledge that AWS CloudFormation might create IAM resources with
     custom names"**, then **Create stack**.
   - Wait for the stack to reach `CREATE_COMPLETE` (a couple of minutes),
     then go back to the Cortex Cloud tab - it should show "Instance
     Created Successfully / Your AWS instance has been successfully
     connected".
   - Note: this CloudFormation stack is separate from `terraform/` and is
     **not** destroyed by `scripts/teardown.sh` - delete it by hand
     (CloudFormation > Stacks > Delete) if you want a full cleanup, or just
     leave it since the whole Torque account gets torn down at expiry
     anyway.

5. **Cortex Cloud Kubernetes agent and admission controller** installed and
   enforcing (not just monitoring) on the EKS cluster once `cd.yml` has
   created it - this is a manual step from the Cortex Cloud console, not
   something Terraform provisions.

6. **VS Code with the Cortex Cloud extension** installed and signed in.

7. **GitHub repo secrets** configured: `CORTEX_API_URL`,
   `CORTEX_ACCESS_KEY_ID`, `CORTEX_SECRET_KEY`.

8. **Replace the placeholder step** in `.github/workflows/ci.yml` (currently
   `exit 1`) with the exact CI/CD integration snippet from your tenant:
   Cortex Cloud console > Settings > Integrations > Pipelines > GitHub
   Actions. Test it on a throwaway PR before recording - a forgotten
   placeholder will fail the pipeline even on clean code in Phase 4.

9. **Let one full `cd.yml` run complete once** before recording (EKS cluster
   creation alone takes ~15-20 min) so `k8s/deployment.yaml`'s image
   resolves and the live rebuild in Phase 4 is fast.

## Reusing this repo for your own demo session

Designed so a different CSE can fork this repo, point it at their own AWS
sandbox, and be demo-ready with two commands - once you have AWS credentials
in your shell:

1. `./scripts/bootstrap.sh` - detects your GitHub org/repo from `git remote`,
   applies `terraform-bootstrap/` (state bucket, GitHub OIDC provider, CD
   IAM role scoped to your fork), and sets the required GitHub Actions
   variables automatically via `gh` CLI (falls back to printing the values
   for manual entry if `gh` isn't authenticated).
2. Commit and push to `main` - `.github/workflows/cd.yml` takes it from
   there: provisions the EKS cluster, ECR repo and app bucket, builds and
   deploys the app. Budget ~15-20 min for the EKS cluster on first run.
3. After your recording/session: `./scripts/teardown.sh` destroys the EKS
   cluster, ECR repo and app bucket so nothing keeps billing between
   sessions. It does *not* touch the OIDC provider/CD role/state bucket, so
   the next `git push` alone re-provisions everything.

Nothing in `terraform/` or `terraform-bootstrap/` has your org/account
hardcoded - `bootstrap.sh` passes your repo/region as `-var` overrides.

## Getting `kubectl` access to the cluster yourself

`cd.yml` deploys via the `github-actions-cortex-demo-cd` role, which is the
only principal granted access to the cluster's Kubernetes API (via an EKS
access entry in `terraform/eks.tf` - the cluster uses `authentication_mode =
"API"`, not the legacy `aws-auth` ConfigMap). Your own IAM identity
(`TorqueUserRole` or otherwise) is *not* automatically able to run `kubectl`
against it, even with full `AdministratorAccess` - EKS access is a separate
grant from IAM permissions under API mode.

To debug the cluster directly (e.g. `kubectl apply -f k8s/bad-pod.yaml`
during Phase 3, or just checking pod status), grant yourself an access entry
once per Torque session (get AWS credentials first, see prerequisites
above):

```bash
aws eks create-access-entry --cluster-name cortex-demo-eks --region eu-west-1 \
  --principal-arn arn:aws:iam::<ACCOUNT_ID>:role/TorqueUserRole

aws eks associate-access-policy --cluster-name cortex-demo-eks --region eu-west-1 \
  --principal-arn arn:aws:iam::<ACCOUNT_ID>:role/TorqueUserRole \
  --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy \
  --access-scope type=cluster

aws eks update-kubeconfig --name cortex-demo-eks --region eu-west-1
kubectl get pods
```

This is intentionally done by hand via the CLI, not added to Terraform: it's
tied to your personal principal (`TorqueUserRole` is shared/regenerated per
Torque environment, not a stable identity worth encoding into shared infra
code), and it only matters for interactive debugging - the actual demo flow
never needs you to run `kubectl` outside of what's already scripted.

## Suggested flow (matches the 30-min agenda)

| Time | Phase | What to do here |
|---|---|---|
| 0-5 | Intro | Show this repo structure + the EKS/GKE cluster + Cortex Cloud console side by side. |
| 5-12 | IDE / IaC & secrets | Open `terraform/main.tf`, paste in `terraform/snippets/vulnerable-bucket.tf.snippet` live, show the extension flag it, push to a new branch. |
| 12-19 | CI/CD guardrails | Open a PR from that branch, watch `ci.yml` run and block the merge, show the PR comment (secret + `requests` SCA finding + SBOM). |
| 19-26 | Code to Cloud & Admission Control | `kubectl apply -f k8s/bad-pod.yaml` and show the live rejection, then switch to Cortex Cloud console and trace an existing alert back to this repo/commit. |
| 26-30 | Remediation | Remove the pasted snippet from `main.tf`, bump `requests` to `>=2.31.0`, push the fix, show the PR go green and the Cortex alerts auto-resolve. |

## Live-demo tips

- Pre-run the CI pipeline once before recording so you know the real
  runtime, and keep a second run queued in the background to cut to if a
  live run is slow.
- Keep the terminal/IDE on one side of the screen and the browser
  (GitHub / Cortex Cloud) on the other.
- Have a fallback screenshot/clip of the `kubectl apply` rejection and the
  Cortex Cloud graph trace in case the live cluster or network misbehaves
  during recording.
