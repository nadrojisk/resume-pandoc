# Changelog

Update this by hand before bumping `VERSION`. The section matching
`VERSION` becomes the GitHub release notes. When you add a version, add its
compare link at the bottom and update `[Unreleased]`.

## [0.2.0] - 2026-10-08

- Add a `coverletter` template (fangpath-style header, `recipient`, `date`,
  `salutation` and `closing` frontmatter).

## [0.1.0] - 2026-09-25

- Initial release: pandoc + Typst image that renders Markdown resumes to PDF
  with the `fangpath` and `resume` templates.
- Regression tests and CI that publish the image to ghcr.io.

[Unreleased]: https://github.com/nadrojisk/resume-pandoc/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/nadrojisk/resume-pandoc/releases/tag/v0.1.0
