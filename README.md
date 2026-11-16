# centralized-workflow-test

End-to-end test caller for
[pen-pal/centralized-workflow](https://github.com/pen-pal/centralized-workflow).

`.github/workflows/build.yml` calls `build.yml@v1` with two Dockerfile targets
(`final`, `debug`) and then checks that:

- `:<sha>` and `:<sha>-debug` exist on GHCR as linux/amd64 + linux/arm64 manifests
- each is cosign-signed by `.../build.yml@refs/tags/v1` (keyless, GitHub OIDC)
- build args and the `github_token` build secret reached the image
- the `build_duration` output reaches the caller

Runs on every push to `main` and on manual dispatch.
