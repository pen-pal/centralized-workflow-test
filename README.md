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

Deploy sends `repository_dispatch` back to this repo with `GITHUB_TOKEN`;
`receive-dispatch.yml` stands in for the GitOps repo and asserts the payload.

Runs on every push to `main` and on manual dispatch.
