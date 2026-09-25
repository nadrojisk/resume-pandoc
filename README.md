# resume-pandoc

Docker image that renders a Markdown resume to PDF with pandoc + Typst.

```sh
docker run --rm -v "$(pwd):/data" ghcr.io/nadrojisk/resume-pandoc resume.md
# other template:
docker run --rm -e TEMPLATE=resume -v "$(pwd):/data" ghcr.io/nadrojisk/resume-pandoc resume.md
```

Templates: `fangpath` (default) and `resume`. See `skills.lua` for the
`skills`, `skills-table` and `job` fenced-div helpers. Bundled fonts are in
`fonts/`. The image is linux/amd64 only.

## Development

```sh
make test           # build + regression tests (needs docker)
make update-golden  # accept intentional output changes
```

Tests render `tests/fixtures/*.md` and compare the extracted PDF text with
`tests/expected/*.txt`, and check the bundled fonts are embedded. Pandoc and
Typst versions are pinned in the `Dockerfile`. CI builds and tests on every
push/PR.

## Releases

To release: add a section for the new version (and its compare link) to
`CHANGELOG.md`, bump `VERSION`, and push to `main`. If the tests pass, the
pipeline publishes `ghcr.io/nadrojisk/resume-pandoc` as `X.Y.Z`, `X.Y`, `X`
and `latest`, then creates the git tag and GitHub release using that
`CHANGELOG.md` section as the notes.

To patch an existing version, leave `VERSION` as is and push: the image tags,
git tag and release are overwritten.
