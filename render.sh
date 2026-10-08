#!/bin/sh
# Entrypoint for the resume-pandoc Docker image: renders an .md resume to a
# same-named .pdf. Template defaults to fangpath; override with the
# TEMPLATE env var (e.g. -e TEMPLATE=resume or coverletter).
set -eu

if [ "$#" -ne 1 ]; then
  echo "usage: docker run --rm -v \"\$(pwd):/data\" -w /data resume-pandoc <resume.md>" >&2
  exit 1
fi

md_file="$1"
template="${TEMPLATE:-fangpath}"
pdf_file="${md_file%.md}.pdf"

exec pandoc "$md_file" -o "$pdf_file" \
  --pdf-engine=typst \
  --pdf-engine-opt=--font-path --pdf-engine-opt=/resume/fonts \
  --template="/resume/${template}.typst" \
  --lua-filter=/resume/skills.lua
