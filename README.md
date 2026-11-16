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

`.github/workflows/rust.yml` runs `test.yml`, `precommit.yml` and
`audit.yml` against the small crate in `src/`.

Both run weekly, on manual dispatch, and on pushes to `main` (E2E only when
the Dockerfile or its workflows change). GitHub disables schedules in a repo
with no activity for 60 days; re-enable them from the Actions tab.

This repo is step 4 of the release checklist in
[RELEASING.md](https://github.com/pen-pal/centralized-workflow/blob/main/RELEASING.md#release-checklist).
