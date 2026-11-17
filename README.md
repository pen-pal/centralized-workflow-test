# centralized-workflow-test

End-to-end test caller for
[pen-pal/centralized-workflow](https://github.com/pen-pal/centralized-workflow).
It pins `@main`, the staging line: a `vX.Y.Z` release is cut only from a
commit that passes here.

`.github/workflows/build.yml` (E2E test) chains `build.yml` →
`container-scan.yml` → `deploy.yml`, then checks that:

- `:<sha>` and `:<sha>-debug` exist on GHCR as linux/amd64 + linux/arm64 manifests
- each is cosign-signed by `.../build.yml@refs/heads/main` (keyless, GitHub OIDC)
- the `digest` output is the signed manifest of the first target
- SBOM and provenance attestations exist for both archs
- build args and the `github_token` build secret reached the image
- anchore and trivy (CRITICAL/HIGH gate) pass on both archs, sbom on amd64,
  each scanning by digest
- build, scan and deploy duration outputs reach the caller

Deploy sends `repository_dispatch` back to this repo; `receive-dispatch.yml`
stands in for the GitOps repo and asserts the payload, digest included. That
needs a `DISPATCH_PAT` repo secret: a fine-grained PAT limited to this repo
with Contents read and write. `GITHUB_TOKEN` cannot be used, because
`deploy.yml` runs with `permissions: {}`.

| Workflow | Calls (at `@main`) | Runs on |
| --- | --- | --- |
| `build.yml` (E2E test) | build, container-scan, sarif-upload, dast, deploy | weekly, dispatch, push touching the Dockerfile or its workflows |
| `rust.yml` | test (all targets), precommit, audit, coverage (min 80%) | weekly, dispatch, push, pull request |
| `security.yml` | gitleaks, codeql, iac-scan, ossf-scorecard | weekly, dispatch, push |
| `infra.yml` | terraform (`infra/terraform`), k8s-validate (`infra/k8s`, `infra/chart`) | weekly, dispatch, push touching `infra/` |
| `pr.yml` | pr-title, dep-review, cleanup | pull requests |
| `app-release.yml` | app-release (release-please) | dispatch only |

The first four gate every centralized-workflow release. Fixtures: a small
crate in `src/`, a non-root HTTP image (`Dockerfile`), and hardened
Terraform, Kubernetes and Helm under `infra/`. "Allow GitHub Actions to
create and approve pull requests" is on so release-please can open its PR.

GitHub disables schedules in a repo with no activity for 60 days; re-enable
them from the Actions tab.

This repo is step 4 of the release checklist in
[RELEASING.md](https://github.com/pen-pal/centralized-workflow/blob/main/RELEASING.md#release-checklist).
