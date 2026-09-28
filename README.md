# SAUS Branding

Brand templates for **The Shaikh Ayaz University, Shikarpur** — *Revival of
Educational Glory of Shikarpur*. Slides, posters, letterhead, certificates and
theses and examination papers in LaTeX, and matching PowerPoint, Word and Excel templates, so that
anything the university issues looks like it came from the same place.

saus.edu.pk · Main Road, Shikarpur, Sindh · +92 726 512039
شيخ اياز يونيورسٽي، شڪارپور · شیخ ایاز یونیورسٹی، شکارپور

## What is here

| | Template | Start from |
| --- | --- | --- |
| **LaTeX** | Beamer slides | [`latex/saus-slides-starter.tex`](latex/saus-slides-starter.tex) |
| | Research poster, A0–A3 | [`latex/saus-poster-starter.tex`](latex/saus-poster-starter.tex) |
| | Official letterhead | [`latex/saus-letter-starter.tex`](latex/saus-letter-starter.tex) |
| | Certificates, singly or from a CSV list | [`latex/saus-certificate-starter.tex`](latex/saus-certificate-starter.tex) |
| | Final year project report or thesis | [`latex/saus-thesis-starter.tex`](latex/saus-thesis-starter.tex) |
| | Examination paper, mid-term or final | [`latex/saus-exam-starter.tex`](latex/saus-exam-starter.tex) |
| **PowerPoint** | Deck, 16 slide layouts | `powerpoint/SAUS-template.potx` |
| **Word** | Letterhead, any office | `word/SAUS-letterhead.dotx` |
| | FYP report and thesis | `word/SAUS-thesis-FYP.dotx`, `word/SAUS-thesis.dotx` |
| **Excel** | Workbook: brand theme, tables, charts | `excel/SAUS-workbook.xltx` |

Every template has a demo next to it — a feature tour with the built file
committed, so you can see what you get before compiling anything:
[slides](latex/saus-slides-demo.pdf) · [poster](latex/saus-poster-demo.pdf) ·
[letter](latex/saus-letter-demo.pdf) · [certificate](latex/saus-certificate-demo.pdf) ·
[thesis](latex/saus-thesis-demo.pdf) · [exam paper](latex/saus-exam-demo.pdf) ·
`powerpoint/SAUS-slides-demo.pptx` ·
`word/SAUS-letter-demo.docx` · `word/SAUS-thesis-demo.docx` ·
`excel/SAUS-workbook-demo.xlsx`.

Each folder has its own guide, and that is where the detail lives:
**[latex/README.md](latex/README.md)** · [powerpoint](powerpoint/README.md) ·
[word](word/README.md) · [excel](excel/README.md).

## Getting started

**Office (PowerPoint, Word, Excel).** Install the brand fonts first, or Office
will substitute something else: [`fonts/README.md`](fonts/README.md) says which
five families and where to get them — they are a download rather than part of
this repository. Then double-click a `.dotx`, `.potx` or `.xltx`:
Windows opens a new untitled document and leaves the template alone. To keep one
handy, copy it to *Documents\Custom Office Templates*; it then appears under
**File > New > Personal**.

**LaTeX.** Copy a `*-starter.tex` next to the `.cls`/`.sty` files and compile
with LuaLaTeX — `.latexmkrc` already selects it:

```bash
cd latex && latexmk saus-letter-starter.tex
```

You need a current TeX distribution; on a minimal one,
`tlmgr install fira firamath firamath-otf ebgaramond fontaxes garamond-math biblatex-ieee biblatex-apa csvsimple`.
The Sindhi and Urdu fonts are bundled in `latex/assets/fonts`, so nothing needs
installing for them. Everything builds on Overleaf too: upload the `latex`
folder and set the compiler to LuaLaTeX.

## The brand in one place

All six LaTeX templates load one shared layer,
[`latex/saus-brand.sty`](latex/saus-brand.sty) — colours, typography, the
university's details, Sindhi and Urdu support. Change it there and every
template follows. The Office templates carry the same palette in their document
themes.

| | |
| --- | --- |
| Maroon `#6B2A4C` | primary — the crest's script and border |
| Blue `#1A1A91` | secondary — the crest's ring |
| Gold `#C39B3E` | accent — rules and ornaments, never text on white |
| Ink `#231C21`, slate `#6A626B`, mist `#F4EDF1` | text and surfaces |

Fira Sans for headings and Office body text, EB Garamond for long reading (the
thesis), Fira Mono for code, Lateef for Sindhi and Noto Nastaliq Urdu for Urdu.
Templates never name a font directly: they use the role macros
`\sausdisplayfamily`, `\sauslightfont`, `\sauslabelfont` and `\sausmottofont`.

## Layout

```
latex/          the five templates, the shared brand layer, starters, demos
  assets/       crest, campus photographs, bundled Sindhi/Urdu fonts
powerpoint/     .potx + demo, built by source/build_pptx.py
word/           letterhead and thesis .dotx + demos, built by source/build_*.py
excel/          .xltx + demo, built by source/build_xlsx.py
fonts/          where to put the Office fonts on your own machine (not committed)
brand-source/   the original crest and photographs the artwork comes from
```

The Office files are **generated**. Change the script in that folder's
`source/`, never the `.dotx`, `.potx` or `.xltx` by hand:

```bash
pip install -r requirements.txt
python powerpoint/source/build_pptx.py
python word/source/build_docx.py && python word/source/build_thesis_docx.py
powershell -File word/source/finalize.ps1 word/SAUS-thesis-demo.docx word/SAUS-thesis-FYP.dotx word/SAUS-thesis.dotx
python excel/source/build_xlsx.py
```

Each `source/` also has a PowerShell script that renders the result through
Office for checking. Those load the brand fonts for that Windows session only
and install nothing — put the font files in `fonts/` first, where they stay
out of the repository. Close any document based on a template before rebuilding
it, or the file stays locked.

## Signatures

The letter and certificate demos are signed with
`latex/assets/signature-specimen.png`, a drawn scrawl that belongs to nobody.
**Keep real signatures out of this repository** — out of `latex/assets`, out of
the templates, and out of any committed PDF. Put the signer's transparent PNG
outside the repository (or at its root, where `.gitignore` excludes
`signature-trans.png`) and point one document at it:

```latex
\saussignimage{../signature-trans.png}          % letter
\signatory[../signature-trans.png]{Name}{Title} % certificate
```

## Licence

MIT for the classes and build scripts, CC BY 4.0 for the templates and
documentation, SIL OFL for the Sindhi and Urdu fonts in `latex/assets/fonts`,
which are the only fonts here. The crest, the photographs and the
university's name are the university's and are not licensed for reuse — another
institution is welcome to the machinery, with its own identity in place of ours.
See [LICENSING.md](LICENSING.md).

Questions: itmanager@saus.edu.pk
