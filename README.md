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

## Reusing this repo for your own demo session

Designed so a different CSE can fork this repo, point it at their own AWS
sandbox, and be demo-ready with two commands:

1. Fork/clone the repo, get AWS credentials for your sandbox account active
   in your shell (`aws sts get-caller-identity` must return the target
   account - see your sandbox's onboarding email for how, e.g. `aws sso
   login` or `aws configure`).
2. `./scripts/bootstrap.sh` - detects your GitHub org/repo from `git remote`,
   applies `terraform-bootstrap/` (state bucket, GitHub OIDC provider, CD
   IAM role scoped to your fork), and sets the required GitHub Actions
   variables automatically via `gh` CLI (falls back to printing the values
   for manual entry if `gh` isn't authenticated).
3. Commit and push to `main` - `.github/workflows/cd.yml` takes it from
   there: provisions the EKS cluster, ECR repo and app bucket, builds and
   deploys the app. Budget ~15-20 min for the EKS cluster on first run.
4. After your recording/session: `./scripts/teardown.sh` destroys the EKS
   cluster, ECR repo and app bucket so nothing keeps billing between
   sessions. It does *not* touch the OIDC provider/CD role/state bucket, so
   the next `git push` alone re-provisions everything.

Nothing in `terraform/` or `terraform-bootstrap/` has your org/account
hardcoded - `bootstrap.sh` passes your repo/region as `-var` overrides.

## Prerequisites before recording

1. **AWS account onboarded to Cortex Cloud** (for the Terraform IaC scan and
   the code-to-cloud graph tracing in Phase 3).
2. **AWS↔GitHub CI/CD wired up** - see "Reusing this repo" above.
3. **Cortex Cloud Kubernetes agent and admission controller** installed and
   enforcing (not just monitoring) on the EKS cluster once `cd.yml` has
   created it - this is a manual step from the Cortex Cloud console, not
   something Terraform provisions.
4. **VS Code with the Cortex Cloud extension** installed and signed in.
5. **GitHub repo secrets** configured: `CORTEX_API_URL`,
   `CORTEX_ACCESS_KEY_ID`, `CORTEX_SECRET_KEY`.
6. **Replace the placeholder step** in `.github/workflows/ci.yml` (currently
   `exit 1`) with the exact CI/CD integration snippet from your tenant:
   Cortex Cloud console > Settings > Integrations > Pipelines > GitHub
   Actions. Test it on a throwaway PR before recording - a forgotten
   placeholder will fail the pipeline even on clean code in Phase 4.
7. **Let one full `cd.yml` run complete once** before recording (EKS cluster
   creation alone takes ~15-20 min) so `k8s/deployment.yaml`'s image
   resolves and the live rebuild in Phase 4 is fast.

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
