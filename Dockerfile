# Minimal image for exercising the workflows: two targets, build args, a build
# secret, and a small HTTP server (final) for the DAST scan. Runs as non-root.
FROM alpine:3.22 AS base
ARG ARCH
ARG GITHUB_ORGANIZATION
ARG GREETING
# Fails the build if the github_token secret was not passed; never prints it.
RUN --mount=type=secret,id=github_token \
    test -s /run/secrets/github_token && \
    apk add --no-cache busybox-extras && \
    mkdir -p /www && \
    echo "${GREETING} from ${GITHUB_ORGANIZATION} on ${ARCH}" > /www/index.html
USER 65534:65534
EXPOSE 8080

FROM base AS final
HEALTHCHECK --interval=5s --timeout=3s --retries=5 CMD wget -qO /dev/null http://127.0.0.1:8080/ || exit 1
CMD ["busybox-extras", "httpd", "-f", "-p", "8080", "-h", "/www"]

FROM base AS debug
USER root
RUN apk add --no-cache curl
USER 65534:65534
CMD ["cat", "/www/index.html"]
