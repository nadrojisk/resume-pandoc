# Bundled fonts

All fonts here are used via `--font-path fonts` (see the Makefile's
`pdf`/`docker-pdf` targets) so the templates render correctly without
requiring each font to be installed separately — notably inside the Docker
image, which otherwise has only Typst's own bundled fonts.

All three families are released under the [SIL Open Font License
1.1](https://scripts.sil.org/OFL), which permits redistribution.

- **`FontAwesome6Brands-Regular-400.otf`**, **`FontAwesome6Free-Regular-400.otf`**,
  **`FontAwesome6Free-Solid-900.otf`** — copied from the [fontawesome6 TeX
  Live package](https://ctan.org/pkg/fontawesome6). Used for the contact-line
  icons in both templates. See https://fontawesome.com.
- **`Lato-{Regular,Bold,Italic,BoldItalic}.ttf`** — designed by Łukasz
  Dziedzic. `resume.typst`'s default body/meta font. See
  https://fonts.google.com/specimen/Lato.
- **`Montserrat-{Regular,Bold,Italic,BoldItalic}.otf`** — designed by Julieta
  Ulanovsky. `resume.typst`'s default heading font. See
  https://fonts.google.com/specimen/Montserrat.

Only the four weights/styles actually used by the templates (regular, bold,
italic, bold italic) are included, not every weight the families ship.
