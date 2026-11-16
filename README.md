# centralized-workflow-test

End-to-end test caller for
[pen-pal/centralized-workflow](https://github.com/pen-pal/centralized-workflow).

`.github/workflows/build.yml` (E2E test) chains `build.yml@v1` →
`container-scan.yml@v1` → `deploy.yml@v1`, then checks that:

- `:<sha>` and `:<sha>-debug` exist on GHCR as linux/amd64 + linux/arm64 manifests
- each is cosign-signed by `.../build.yml@refs/tags/v1` (keyless, GitHub OIDC)
- build args and the `github_token` build secret reached the image
- anchore, sbom and trivy (CRITICAL/HIGH gate) pass on the image
- build, scan and deploy duration outputs reach the caller

Deploy sends `repository_dispatch` back to this repo; `receive-dispatch.yml`
stands in for the GitOps repo and asserts the payload. That needs a
`DISPATCH_PAT` repo secret: a fine-grained PAT limited to this repo with
Contents read and write. `GITHUB_TOKEN` cannot be used, because `deploy.yml`
runs with `permissions: {}`.

Runs on every push to `main` and on manual dispatch.
