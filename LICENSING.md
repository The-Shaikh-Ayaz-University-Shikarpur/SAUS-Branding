# Licensing

Four different things live in this repository, under three licences, and the
university's marks are reserved. In short: **take the machinery, not the
identity.**

| Part | Files | Licence |
| --- | --- | --- |
| The machinery | `latex/*.cls`, `latex/*.sty`, `latex/.latexmkrc`, every `*/source/*.py` and `*/source/*.ps1`, `brand-source/make-signature-specimen.py` | [MIT](LICENSE) |
| Templates and documentation | `latex/*.tex`, `latex/*.bib`, `latex/*.csv`, the generated `.dotx`, `.potx`, `.xltx`, the demo files and every `README.md` | [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/legalcode) |
| Fonts | `latex/assets/fonts/` (Lateef and SAUS Nastaliq Urdu, the only fonts in the repository) | SIL Open Font License 1.1 — see [`LICENSES.md`](latex/assets/fonts/LICENSES.md) and `OFL.txt` there |
| University marks and photographs | `latex/assets/saus-logo*.png`, `latex/assets/*.jpg`, `powerpoint/source/art/`, everything in `brand-source/` except the script, the university's name in English, Sindhi and Urdu, and the motto | **All rights reserved** by The Shaikh Ayaz University, Shikarpur |

## What that means in practice

- **Another institution** may take the classes, the build scripts and the
  structure of the templates, under MIT and CC BY 4.0, and is welcome to.
  Replace the crest, the photographs, the colours, the names and the motto with
  its own before using them. The brand is set in one place,
  `latex/saus-brand.sty`, and in the theme of each Office builder.
- **SAUS staff and students** may use everything here as it stands for
  university work.
- **Nobody** may use the crest, the photographs or the university's name to
  present material as issued by The Shaikh Ayaz University, Shikarpur without
  the university's permission.
- **CC BY 4.0** asks for attribution: "Based on the brand templates of
  The Shaikh Ayaz University, Shikarpur" and a link back is enough. Documents
  *produced with* the templates are yours; attribution applies to redistributing
  the templates themselves.
- **The fonts.** Only the Sindhi and Urdu ones are in the repository, because the
  LaTeX build loads them and no TeX distribution ships them; they are
  redistributed under the SIL OFL, which permits bundling but not selling them
  on their own, and the Noto Nastaliq Urdu instances are renamed as the OFL
  requires of modified copies. The Office templates' fonts are a download —
  [`fonts/README.md`](fonts/README.md) says which and from where.

Contact: itmanager@saus.edu.pk · saus.edu.pk
