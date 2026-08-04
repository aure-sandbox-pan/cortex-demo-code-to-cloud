# Cortex Cloud - Code to Cloud Visibility & Vulnerability Tracing

![Cortex Cloud v2.2](https://img.shields.io/badge/Cortex_Cloud_v2.2-000000?style=for-the-badge&logo=data%3Aimage%2Fpng%3Bbase64%2CiVBORw0KGgoAAAANSUhEUgAAAC8AAAA8BAMAAAAES%2F6qAAAAGFBMVEUAzWYAAAAA4moAs2YAzWYA%2FwAAzWYAf38u8PqcAAAACHRSTlP8ABQFogFeAmMSNhYAAAIvSURBVHjanZMxb9NAFMf%2Fd2e5NIHGjpQIoSg4HVAHlIYNFak4EWJjqFgqhGjVz9WBfoT2A7RZulKECpEYqBMihIJILi3UbhLbDHdOLubCgBef%2Fz%2Ffe%2B%2Fe%2Bx%2BxIR5a9gqb%2B3jkNAEAMZU6edN%2B%2BXkfs8eQr9JBVZUBueN2u9qEBpDLtC6AkXuR1gV4ffUWOmAePIQWvCo3tcA4sqAFT4bKhjhZsGWQsjcDN%2B0Kl4D%2B%2BqhEuLf0ve6JUIPMrD97q1%2B%2Bbp3UAYDYTi5J0TgD6QNm1uKIWZa3kjoG1H7cAsKNTgywDL2WcVZsP%2FB8ABfbAQdbi0QV2OkNQOADwHkAUO4I3TysTouYrHOQfF981D0OEIgv805I5QiRrymnGeUtI5IlNSO1U6UBK4rcrh8ASXKg4ycu6Vqp3lJXrH54c2BiUSEYLDUOl0lgCrckOWARGbMwEqCfMhwirX2gn%2Fl%2FAroAGOP0OeTJI5ICDhVzmoQp0ExiF5w53eBUeqfE50AEZgiTdGis9soNKE1%2BcdUdXRgTuay%2BV3SzH7K7NdH4b2qozSXObC7Shts9PwEG52B0LC16Hg1vSbATcLBMLAuJNgYNUmsBoG3%2Bj2tA8Xzqj%2BPfWxaMvSzhAIhNWU8pdDXm9RMAMVuOy2uqp24qZ8k8Kl1Fv%2F%2F0Yjqo03UFEGWCo3fOgpkPr1w9iFe6C1xy%2FXNXD0aNo7%2BCiSt4zD8t8FUxW3S1YHQ5%2FrCrtWhEcocPningD9LdtpDSa0zBAAAAAElFTkSuQmCC)
![Terraform](https://img.shields.io/badge/Terraform_%3E%3D1.10-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Amazon Web Services](https://img.shields.io/badge/Amazon_Web_Services-000000?style=for-the-badge&logo=data%3Aimage%2Fpng%3Bbase64%2CiVBORw0KGgoAAAANSUhEUgAAAGQAAAA8BAMAAABiEQL9AAAAMFBMVEX%2FoAD%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FfQD%2F%2F%2F%2F%2FmQD%2FmQD%2FmgD%2F%2FwD%2FAAAAAAD%2F%2F%2F%2F%2F%2F%2F%2F%2FmQD%2FogAY3St5AAAAEHRSTlMTXp8sA9CfYc8BAQD7BPv%2FaU3DRQAABlNJREFUeNqVln1oVecdxz%2FPk8yrUcjJXjRWOHt6nGPEf0IHWztK0YEVZ5ra0SS%2BlOQqmL5Y6InQROdQC8a8rJQ4WmNyQS5CFh1luy1jobnMhra0Y39I%2FmjCytjZs8OsSQu7R5d7k6PJc%2FbHOdfWbtb4%2FHXuc7%2Bf83v%2F3SvyoHTn3I%2Fd8Jlx30g6uYgGFk5WHQdQC%2Bmq4zi66WcuzbfOK43II2kaB6C0Hr%2F4AGdOeqC25njqskaqE27pFmbvGAD7Bwwij%2FpJ%2FBF6XqD4AMVFg6Qa2nIaObeB4qIq3owVYa3REim3JwRHlYpAAJSACz4gQMLeRJFqBQkaCJubB4BG1kCFAkyCsRGG1cdZON30%2BB4AKgE3bPzzELV7spzT9lPZVGtWIxLMFvNcMZsDin0a2T4MSIzd3HnRd5yZ0xBBEJvdSOLhFrDYAnul49h9qZOaStBDOMbDoUDFLSYCrPjlVKzXYBFmsQjfMxrpeIAEHOVp8EyalC2n4SFgC0VSaYVfz5IPoDUYz0kQTwMgA4DvQrsPFgdAI0suEUBKKYCyFcBxHGWANH4cdj0rB7DAwBoAGn0nSbQEkI7neb4EMHUDCKTvcmOSehDQamPB4HHPUbcRaXvOEcf2ADCTVNjMgR1w2Lc3wg38Tqjq2e1pp4zYfsuJoUJXe2zXIpVWEGYVc%2FAsXIYHgap3zp70VFxK6beNA79IXB2aRyNY8rOBAE3pumHljhxwLNydja3Y38nxxfH%2FDpapI2I6thkp8AfTAKnftzogkbIfCPvKTAQPkUYSUWX7WaQG84PuNACjsZUpF5pqe2sOxrdroF1rhpGQLsE5G%2FDrzjw%2BAFQ9ppDY%2FVAc9jyv3wIwdhqDxRVVBdrABIDx7Usvp4GLftL8LziO4zi3m0DIegJjp7EExMUwvvPZmV1goBIs%2BKbR5e8wE0HFdRcFAReqg%2FBCUi%2FPMW%2BUJ64ezgNIK07ZJ6RsyAKU0izpcl48v26ACqOk9MutY%2Brjh0XYSsnXTGDiWSNuLyMnY6ENHADUtBtPl4RvEYH%2FCcJiGCBuL2nqWZJawiR40nG8Q0ksdQOMIoElqrJcsYEjnu84jpp2iaASArjowdoc8NO4MaHqJvGgBCAZahr3gEM5JIi8EgE0BWIcoLhoUFtz0JbTkmqgGi2pptQW8O1RaMtpkZdzG5IEHMwQLhiUCODJCY16xaV0K9mDX159pi6d7MpXYQnwp8uCydg5o9Llm%2Be0RoLsjjdyr72LPXY8%2FuF7SRxrFGB%2BMxATxd%2FZIPKgWupcmsZ95l7MGkA16zVZA3IuTV1WA6x9ehTCZ8Z9EyPSyM7fetLWSisNSANKA0ojDYDjUdvq1x2XhhjB8cAxGqnifnLi7YNUGJ3ceMSaBEGqWPM1x0m2WBm5r1N5H9pw16MTlY%2Fuuw8rfV1xogUZtTyi%2B1jxowLUvC7yxVvWsrxKNfR0AMyI9pGRZTH60GwUP4nCwveWw4QVD1sUqCmAWDnfe%2BrStXvGU1wx%2BU%2Brj651aUTu3ZPnTo1k3GWm7YlPqcwcqn6OfZca376H1vQwkQ8b%2FmjNiHd%2B%2FUNXzG%2FKvXb4XtG8cbihsnvt7gWRv2r9o03M9%2B8Mz3Z8bSFT7s7Z639p%2FTSUbMiMEa3qHZnv6NZ3BWb7ug7%2BaTaiZgVDEp5%2Fud%2BKSuf%2FtuPY%2BrtAszvWdTVc7omszJMd4nMJqasPuxbB8%2F96s%2BXY%2Bu7XvqqPprrXjU3lZwYK4sAjIoiyIg%2FsGnn3BFBzrT%2BTYyr3wdkHy%2Fp%2FD1Z%2BlKP7R7UdBcTCx42jj618X%2BQB8%2FM3%2F9oGiOqZV4byQHflxBZY5IMxYFtnbUcBxPymPvWfFn8ybv7w2oszEYCwCueu962%2B%2FeO5jc4bp2sKgJjfNLI6lI%2F8UifzUlzd0PtSAEANhZvntbCAgvx%2BuiYKSIjP1cD7eu32ZCpXX%2F1DQ%2BQGAAVYcbRspUCBhLg06EJHmEvdnsqpzYtjZwp3KYvVd%2BpSS45ouu3VSfeLQb66ofjh0erg%2FwAiPLLzGxkXzPzYE6nyPyVgQ3HftlpX%2FM%2FoCGuwdt%2BqjAvI1U8P3rmUzK%2B6ih%2FW7rcKX9ZHvZ%2FtpPtQ8qZt%2Ba%2Fusb6UW2zZf5oaCknuTqzarMLmt%2B4we%2BdSMtszim2plwIHjBarMjmKrz97p7P%2FBfv8pjAAP19KAAAAAElFTkSuQmCC)

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
   something Terraform provisions. Note: the AWS-side "Kubernetes security"
   capability enabled during onboarding (prerequisite 4) only gives
   agentless, read-only visibility into cluster objects via the EKS API
   (CSPM-style) - it cannot block anything. The live rejection in Phase 3
   needs this separate in-cluster agent (CWPP-style runtime enforcement).

   **Step-by-step (tested and working end to end):**

   1. **Settings > Data Sources & Integrations > Add New > Kubernetes.**
   2. In "Kubernetes Connect", enable **`Posture Management`** only - leave
      `Realtime Protection` off. Posture Management (KSPM) is what includes
      the admission controller (confirmed via its "Read more": *"An
      admission controller ensures all new resources meet required security
      and governance standards... intercepts requests to the Kubernetes API
      server before they are persisted"*). `Realtime Protection` deploys the
      full Cortex XDR agent with a host kernel module for deep runtime
      telemetry - unnecessary complexity/compatibility risk for this demo,
      which only needs admission-time blocking.
   3. Click **Edit** on Posture Management and confirm **"Policy Enforcement
      by the Admission Controller"** is toggled on (it is, by default) -
      this is what makes the rejection actually blocking rather than
      alert-only. Leave Scan Cadence, Failure Policy (`Fail`), and Registry
      Scanning (OpenShift-only, N/A here) at their defaults. Click **Apply**.
   4. Click **Generate**. Download the two files it offers: `values.yaml` and
      `auth.json`.
   5. Get AWS CLI credentials for the account (see prerequisite 2) and
      `kubectl` access to the cluster (see "Getting `kubectl` access to the
      cluster yourself" below - the same EKS access entry works for this).
      You also need **`helm`** installed locally.
   6. Log in to the chart registry using the downloaded auth token, then
      install the chart (commands are also shown in the Cortex Cloud UI,
      adjust the filenames to whatever you downloaded):
      ```bash
      cat auth.json | helm registry login us-central1-docker.pkg.dev \
        --username _json_key --password-stdin

      helm upgrade --install konnector \
        oci://us-central1-docker.pkg.dev/<project-id>/agent-docker/helm/konnector-launcher \
        --wait-for-jobs --create-namespace --namespace panw \
        --values values.yaml \
        --set-file konnector-upgrader.rawValuesContent=values.yaml
      ```
      (`<project-id>` is the `project_id` field inside `auth.json`, e.g.
      `xdr-us-1002151708645` - it's also in the `oci://` path the UI gives
      you, just copy that verbatim instead of retyping it.)
   7. **Known issue #1 - bootstrap deadlock, needs a manual fix every time
      you install fresh:** the Helm install creates 3 Deployments
      (`cortex-admission`, `cortex-manager`, `cortex-monitoring`) in
      namespace `panw`, gated by the very admission webhook they're
      registering. Since `failurePolicy: Fail` and no admission-control pod
      exists yet, the webhook rejects the pods that would let it start -
      a chicken-and-egg lockout. You'll see `kubectl get deployments -n
      panw` stuck at `0/3`, `0/1`, `0/1` and events like `FailedCreate ...
      no endpoints available for service "admission-control"`. Fix:
      ```bash
      kubectl patch validatingwebhookconfigurations \
        admission-control-validating-config \
        --type='json' \
        -p='[{"op": "replace", "path": "/webhooks/0/failurePolicy", "value": "Ignore"}]'

      kubectl rollout restart deployment cortex-admission cortex-manager \
        cortex-monitoring -n panw

      # wait ~1 min, then confirm all 3 are ready:
      kubectl get deployments -n panw

      # once ready, restore strict enforcement:
      kubectl patch validatingwebhookconfigurations \
        admission-control-validating-config \
        --type='json' \
        -p='[{"op": "replace", "path": "/webhooks/0/failurePolicy", "value": "Fail"}]'
      ```
      This only recurs on a fresh install (deleting and reinstalling the
      release) - it's a one-time bootstrap issue, not something that comes
      back once the deployments are healthy.
   8. **Known issue #2 - cluster identity resolution fails on this
      cluster's auth mode:** the `cortex-admission` pods crash-loop
      (`CrashLoopBackOff`, startup probe failing on `/healthz`) with logs
      showing `failed to resolve account ID from ConfigMap: configmaps
      "aws-auth" not found`, then a fallback IMDS attempt that also fails
      (`context deadline exceeded` - EKS managed node groups block pod-level
      IMDS access by default). Our cluster uses
      `authentication_mode = "API"` only (see `terraform/eks.tf`), so no
      `aws-auth` ConfigMap exists. Fix - create a standard one (this is
      the same content AWS itself documents for node role mapping; it's
      inert for actual authentication since API mode is authoritative, but
      satisfies this agent's identity-resolution check):
      ```bash
      cat << 'EOF' | kubectl apply -f -
      apiVersion: v1
      kind: ConfigMap
      metadata:
        name: aws-auth
        namespace: kube-system
      data:
        mapRoles: |
          - rolearn: arn:aws:iam::<ACCOUNT_ID>:role/cortex-demo-eks-nodes
            username: system:node:{{EC2PrivateDNSName}}
            groups:
              - system:bootstrappers
              - system:nodes
      EOF
      ```
      Do this **before** step 7's rollout restart if you're following these
      steps in order fresh - the pods will otherwise crash-loop on identity
      resolution even after the webhook deadlock (step 7) is cleared.
   9. Verify: `kubectl get deployments -n panw` shows `cortex-admission`
      3/3, `cortex-manager` 1/1, `cortex-monitoring` 1/1, all `AVAILABLE`.
      `kubectl get validatingwebhookconfigurations` shows
      `admission-control-validating-config`. Check **Data Sources >
      Kubernetes > Kubernetes Connectors** in Cortex Cloud for the connector
      to appear as connected.
   10. **Test the actual block** before recording:
       `kubectl apply -f k8s/bad-pod.yaml` - if it's still admitted instead
       of rejected, the admission controller infrastructure is up but the
       specific compliance rule(s) may be set to **Alert** instead of
       **Block** in Cortex Cloud's policy configuration (a separate setting
       from the connector-level "Policy Enforcement" toggle in step 3 -
       that one only governs fail-open/fail-closed behavior when the
       webhook is unreachable, not the per-rule response action). Check the
       Kubernetes admission control policies in Cortex Cloud (Posture
       Management / Modules) and confirm the relevant rules (privileged
       container, root user, hostNetwork, etc.) are set to block, not just
       alert.

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
