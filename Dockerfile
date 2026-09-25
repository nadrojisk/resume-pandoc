FROM debian:bookworm-slim

# Pinned so builds (and the regression tests) are reproducible. Bump
# deliberately: update these, run `make test`, and refresh goldens with
# `make update-golden` if the output change is intended.
ARG PANDOC_VERSION=3.11
ARG TYPST_VERSION=v0.15.1

RUN apt-get update && apt-get install -y --no-install-recommends \
      curl ca-certificates xz-utils \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    curl -fsSL "https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-linux-amd64.tar.gz" \
      | tar xz -C /usr/local --strip-components=1

RUN set -eux; \
    curl -fsSL "https://github.com/typst/typst/releases/download/${TYPST_VERSION}/typst-x86_64-unknown-linux-musl.tar.xz" \
      | tar xJ -C /tmp; \
    mv /tmp/typst-x86_64-unknown-linux-musl/typst /usr/local/bin/typst; \
    rm -rf /tmp/typst-x86_64-unknown-linux-musl

WORKDIR /resume
COPY resume.typst fangpath.typst skills.lua render.sh ./
COPY fonts ./fonts

WORKDIR /data
ENTRYPOINT ["/resume/render.sh"]
