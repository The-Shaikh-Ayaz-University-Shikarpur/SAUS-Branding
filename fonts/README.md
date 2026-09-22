# Fonts for the Office templates

This folder is a drop box, not part of the repository: the font files
themselves are git-ignored, because five families come to about 9 MB and every
one of them is a click away. Put the `.otf` and `.ttf` files here and the render
scripts in `../powerpoint/source`, `../word/source` and `../excel/source` will
load them for that Windows session.

**To use the `.potx`, `.dotx` and `.xltx` templates you must also install the
fonts**, on every machine that opens them — select the files, right-click,
**Install**. Without them Word, PowerPoint and Excel quietly substitute
something else and the layouts drift.

| Family | Used for | Where to get it |
| --- | --- | --- |
| Fira Sans (Light, Regular, Medium, SemiBold, Bold + italics) | Headings everywhere, and body text in the Office templates | [github.com/mozilla/Fira](https://github.com/mozilla/Fira) · [Google Fonts](https://fonts.google.com/specimen/Fira+Sans) |
| Fira Mono (Regular, Bold) | Code and file names | [github.com/mozilla/Fira](https://github.com/mozilla/Fira) · [Google Fonts](https://fonts.google.com/specimen/Fira+Mono) |
| EB Garamond (Regular, SemiBold + italics) | Long reading: the thesis body text | [github.com/octaviopardo/EBGaramond12](https://github.com/octaviopardo/EBGaramond12) · [Google Fonts](https://fonts.google.com/specimen/EB+Garamond) |
| Lateef (Regular, Bold) | Sindhi | [software.sil.org/lateef](https://software.sil.org/lateef/) |
| SAUS Nastaliq Urdu (Regular, Bold) | Urdu | already in the repository, in [`../latex/assets/fonts`](../latex/assets/fonts) |

All five are under the **SIL Open Font License 1.1**, so they may be installed,
bundled and redistributed freely, but not sold on their own. Each download
carries its own licence text; the two in `../latex/assets/fonts` carry theirs in
`OFL.txt` there.

## From a TeX installation

If you have TeX Live or MiKTeX, four of the five are already on the machine and
can be copied here instead of downloaded:

```powershell
$tex = "C:\texlive\2026\texmf-dist\fonts\opentype\public"
Copy-Item "$tex\fira\Fira{Sans,Mono}-*.otf", "$tex\ebgaramond\EBGaramond-*.otf" .
Copy-Item ..\latex\assets\fonts\*.ttf .
```

The last line takes the Sindhi and Urdu fonts, which no TeX distribution ships;
this repository carries them in `../latex/assets/fonts` because the LaTeX
templates load them from there at build time.

## Why they are not committed

The LaTeX templates need no font installed: they pick Fira and EB Garamond up
from TeX Live and the Arabic-script fonts out of `../latex/assets/fonts`. Only
the Office templates need fonts on the system, and a font a user must install
anyway is not worth 9 MB in everyone's clone.
