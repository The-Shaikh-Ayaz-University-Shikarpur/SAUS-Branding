# Bundled fonts

Only the Arabic-script fonts are bundled here, because TeX distributions don't
ship them. Fira Sans, Fira Math, Fira Mono and EB Garamond come from TeX Live
(or MiKTeX / Overleaf) — see the main README.

Both bundled fonts are licensed under the **SIL Open Font License 1.1**
(https://openfontlicense.org), which allows them to be bundled with, embedded in
and redistributed alongside other material. They may not be sold on their own.
The licence text, with both copyright notices, is in `OFL.txt` beside them.

| Family | Files | Copyright | Upstream |
| --- | --- | --- | --- |
| Lateef | `Lateef-Regular.ttf`, `Lateef-Bold.ttf` | Copyright (c) 1994-2025 SIL Global | https://software.sil.org/lateef/ |
| Noto Nastaliq Urdu | `NotoNastaliqUrdu-Regular.ttf`, `NotoNastaliqUrdu-Bold.ttf` | Copyright 2014-2022 Google LLC | https://github.com/notofonts/nastaliq |

## Modified versions

Lateef is an unmodified copy of SIL's static release.

Noto Nastaliq Urdu v3.009 is published only as a variable font
(`NotoNastaliqUrdu[wght].ttf`, from https://github.com/google/fonts). The Regular
(wght 400) and Bold (wght 700) files here are static instances cut from it with
`fontTools.varLib.instancer`, because XeLaTeX cannot reliably select weights
inside a variable font. As Modified Versions under the OFL, their internal family
name is **"SAUS Nastaliq Urdu"**, so they cannot be mistaken for Google's
originals. "Noto" is a trademark of Google LLC.
