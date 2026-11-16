# Minimal image for exercising build.yml: two targets, build args and a build secret.
FROM alpine:3.22 AS base
ARG ARCH
ARG GITHUB_ORGANIZATION
ARG GREETING
# Fails the build if the github_token secret was not passed; never prints it.
RUN --mount=type=secret,id=github_token \
    test -s /run/secrets/github_token && \
    echo "${GREETING} from ${GITHUB_ORGANIZATION} on ${ARCH}" > /info

FROM base AS final
CMD ["cat", "/info"]

FROM base AS debug
RUN apk add --no-cache curl
CMD ["cat", "/info"]
