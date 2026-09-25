#!/bin/sh
# Regression tests for the resume-pandoc image.
#
#   tests/run.sh                 build-less run against $IMAGE (default resume-pandoc:test)
#   tests/run.sh --update-golden rewrite tests/expected/*.txt from current output
#
# For each fixture in tests/fixtures/<template>.md it renders a PDF with the
# image and checks that: it is a valid 1+ page PDF, the bundled fonts were
# embedded, and the extracted text matches tests/expected/<template>.txt.
set -eu

cd "$(dirname "$0")/.."
IMAGE="${IMAGE:-resume-pandoc:test}"
update=0
[ "${1:-}" = "--update-golden" ] && update=1

out="$(mktemp -d)"
trap 'rm -rf "$out"' EXIT

# pdftotext/pdffonts locally if present, otherwise via a throwaway container.
poppler() {
  tool="$1"; shift
  if command -v "$tool" >/dev/null 2>&1; then
    (cd "$out" && "$tool" "$@")
  else
    docker run --rm -v "$out:/w" -w /w debian:bookworm-slim sh -c \
      "apt-get update -qq >/dev/null && apt-get install -y -qq poppler-utils >/dev/null && $tool $*"
  fi
}

fail=0
for fixture in tests/fixtures/*.md; do
  tpl="$(basename "$fixture" .md)"
  cp "$fixture" "$out/$tpl.md"
  echo "== $tpl"

  if ! docker run --rm -e TEMPLATE="$tpl" -v "$out:/data" "$IMAGE" "$tpl.md"; then
    echo "FAIL: render failed"; fail=1; continue
  fi

  head -c 5 "$out/$tpl.pdf" | grep -q '%PDF-' || { echo "FAIL: not a PDF"; fail=1; continue; }

  fonts="$(poppler pdffonts "$tpl.pdf" 2>&1 || true)"
  for f in FontAwesome6; do
    echo "$fonts" | grep -q "$f" || { echo "FAIL: font $f not embedded"; fail=1; }
  done
  if [ "$tpl" = resume ]; then
    for f in Lato Montserrat; do
      echo "$fonts" | grep -q "$f" || { echo "FAIL: font $f not embedded"; fail=1; }
    done
  fi

  poppler pdftotext -layout "$tpl.pdf" "$tpl.txt"
  if [ "$update" = 1 ]; then
    cp "$out/$tpl.txt" "tests/expected/$tpl.txt"
    echo "updated tests/expected/$tpl.txt"
  elif ! diff -u "tests/expected/$tpl.txt" "$out/$tpl.txt"; then
    echo "FAIL: text differs from golden"; fail=1
  else
    echo "ok"
  fi
done

exit "$fail"
