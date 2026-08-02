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

## Prerequisites before recording

1. **AWS account onboarded to Cortex Cloud** (for the Terraform IaC scan and
   the code-to-cloud graph tracing in Phase 3).
2. **EKS or GKE cluster** with the Cortex Cloud Kubernetes agent and
   admission controller installed and enforcing (not just monitoring).
3. **VS Code with the Cortex Cloud extension** installed and signed in.
4. **GitHub repo secrets** configured: `CORTEX_API_URL`,
   `CORTEX_ACCESS_KEY_ID`, `CORTEX_SECRET_KEY`.
5. **Replace the placeholder step** in `.github/workflows/ci.yml` (currently
   `exit 1`) with the exact CI/CD integration snippet from your tenant:
   Cortex Cloud console > Settings > Integrations > Pipelines > GitHub
   Actions. Test it on a throwaway PR before recording - a forgotten
   placeholder will fail the pipeline even on clean code in Phase 4.
6. **Build and push the base image once** so `k8s/deployment.yaml`'s pinned
   tag resolves, and the container registry exists for the live rebuild in
   Phase 4.

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
