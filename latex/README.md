# SAUS LaTeX templates — slides, posters, letters, certificates and theses

Beamer slides, research posters, official letterhead, certificates and
final year project reports and theses for
**The Shaikh Ayaz University, Shikarpur** — *Revival of Educational Glory of Shikarpur*.

All five templates load one shared brand layer, `saus-brand.sty`, which holds the
colours (sampled from the university crest), the typography, the institutional
details and the Sindhi/Urdu support. Change it once and every template
changes with it.

## Contents

| File | What it is |
| --- | --- |
| `saus-brand.sty` | Shared brand layer: colours, fonts, identity, helpers. |
| `beamerthemeSAUS.sty` | The Beamer theme. |
| `saus-poster.cls` | The poster class (A0–A3, portrait or landscape). |
| `saus-letter.cls` | The letterhead class, built on KOMA-Script `scrlttr2`. |
| `saus-certificate.cls` | The certificate class (classic and modern layouts). |
| `saus-thesis.cls` | Final year project reports and theses, built on KOMA-Script `scrbook`. |
| `saus-slides-starter.tex` | Minimal slide deck — copy this to start. |
| `saus-slides-demo.tex` | Feature tour of every slide type. |
| `saus-poster-starter.tex` | Minimal three-column poster — copy this to start. |
| `saus-poster-demo.tex` | Feature tour, set as a brand-guidelines poster. |
| `saus-letter-starter.tex` | Blank letter, plus a notification example. |
| `saus-letter-demo.tex` | Two-page letter showing every letter element. |
| `saus-certificate-starter.tex` | One certificate, plus a commented CSV batch. |
| `saus-certificate-demo.tex` | A CSV batch (classic) and a modern certificate. |
| `saus-certificate-demo.csv` | The names list used by the certificate demo. |
| `saus-thesis-starter.tex` | Skeleton report: every field, the front matter and chapter headings. |
| `saus-thesis-demo.tex` | A complete sample report showing every element. |
| `saus-thesis-demo.bib` | The references used by the thesis demo (and the starter). |
| `assets/` | Crest (colour and white line-art), campus photographs, and `fonts/`. |
| `.latexmkrc` | Makes `latexmk` build with LuaLaTeX. |

## Requirements

A current TeX distribution with these packages:

```bash
tlmgr install fira firamath firamath-otf ebgaramond fontaxes garamond-math biblatex-ieee biblatex-apa
```

A full TeX Live installation already includes them, MiKTeX installs them on
first use, and Overleaf has them. The poster, letter and certificate also use
`tcolorbox`, `enumitem`, `caption`, `qrcode`, `eso-pic`, `csvsimple` and
KOMA-Script, which every standard installation includes (on a minimal TeX Live,
`tlmgr install csvsimple`). The thesis uses `biblatex` with **Biber**, which
`latexmk` runs automatically. The Sindhi
and Urdu fonts aren't in any TeX distribution, so they are bundled in
`assets/fonts`.

If a font package is missing, the document still builds: a TeX Gyre font is
substituted and a warning names the package to install.

## Compiling

```bash
latexmk saus-slides-demo.tex
latexmk saus-poster-demo.tex
latexmk saus-letter-demo.tex
latexmk saus-certificate-demo.tex
latexmk saus-thesis-demo.tex
```

The bundled `.latexmkrc` selects **LuaLaTeX**, the recommended engine. XeLaTeX
works equally well (`latexmk -xelatex ...`).

pdfLaTeX also compiles, using the Type 1 versions of Fira Sans and EB Garamond,
but it has no Fira Math (maths falls back to Computer Modern) and cannot set
Sindhi or Urdu — `\saussindhi` and `\sausurdu` print a placeholder and a warning.

Two passes are needed because the templates position full-bleed elements with
TikZ `remember picture`. `latexmk` handles this; if you run the engine by hand,
run it twice.

The poster demo includes two pages of the slide demo's PDF, so build the slides
first (it shows a note instead if the PDF is missing).

## Starting a new document

Copy `.latexmkrc`, `saus-brand.sty`, the whole `assets/` folder, and the
template you need — `beamerthemeSAUS.sty`, `saus-poster.cls`,
`saus-letter.cls`, `saus-certificate.cls` or `saus-thesis.cls` — with its
starter file into a new directory, then edit the starter.

Alternatively keep one shared copy and point LaTeX at it:

```bash
export TEXINPUTS="/path/to/SAUS-Branding/latex;"
```

and tell the template where the images live:

```latex
\usetheme[assets=/path/to/SAUS-Branding/latex/assets/]{SAUS}
\documentclass[assets=/path/to/SAUS-Branding/latex/assets/]{saus-poster}
```

To install for every user on a machine, copy the six `.sty`/`.cls` files into
`TEXMFLOCAL/tex/latex/saus/` and run `mktexlsr`.

# Slides

## Theme options

```latex
\usetheme[titlestyle=split,logo=none,numbering=fraction]{SAUS}
```

| Option | Values | Default | Effect |
| --- | --- | --- | --- |
| `titlestyle` | `photo`, `solid`, `split` | `photo` | Title slide treatment. |
| `titleimage` | any filename in `assets/` | `saus-title-bg.jpg` | Background for `titlestyle=photo`. |
| `assets` | path **with trailing slash** | `assets/` | Where the crest and photos live. |
| `logo` | `corner`, `none` | `corner` | Small crest in the top-right of content slides. |
| `numbering` | `counter`, `fraction`, `none` | `counter` | Frame number in the footer. |
| `align` | `top`, `center` | `top` | Vertical placement of slide content. |
| `progressbar` | `true`, `false` | `true` | Thin gold progress rule above the footer. |
| `sectionpages` | `true`, `false` | `true` | Automatic divider slide at each `\section`. |
| `fonts` | `true`, `false` | `true` | Use the theme's typefaces. `false` leaves fonts to you. |
| `raggedright` | `true`, `false` | `true` | Ragged-right body text; `false` restores justification. |
| `native` | `sindhi`, `urdu`, `both`, `none` | `sindhi` | University name in Sindhi and/or Urdu under the motto on title and closing slides. |
| `transparentcovered` | `true`, `false` | `false` | Grey out overlay-covered material instead of hiding it. |

Note that `align=top` overrides the `t`/`c` class options — pass
`align=center` if you want Beamer's vertical centring back.

## Institutional details

The university's own details are already the defaults. Override them for a
faculty, campus or partner deck:

```latex
\sausdepartment{Department of Computer Science}   % gold line on the title slide
\sausevent{Faculty Development Seminar}           % occasion or venue
\sausuniversity{...}   \sausshortuniversity{...}  % name, and the footer form
\sausmotto{...}   \sausweb{...}   \sausaddress{...}   \sausphone{...}
\sausnativename{...}                              % replaces the native= name line
```

The official names are built in:

| Script | Name | Command |
| --- | --- | --- |
| Sindhi | شيخ اياز يونيورسٽي، شڪارپور | `\sausnamesindhi` |
| Urdu | شیخ ایاز یونیورسٹی، شکارپور | `\sausnameurdu` |

The footer shows the short title, so give long titles a short form:
`\title[Digital Transformation]{Digital Transformation of Campus Services}`.

## Slide commands

Each of these fills a whole slide — put it in `\begin{frame}[plain,noframenumbering]`.

| Command | Result |
| --- | --- |
| `\titlepage` | Title slide in the configured style. |
| `\sausstatement{text}` | Full-bleed maroon slide for a single sentence. |
| `\sausquote{quotation}{attribution}` | Pull quote on the mist background. |
| `\sausphotoslide{file}{caption}` | Full-bleed photograph with a caption band. |
| `\sausthankyou` / `\sausthankyou[Questions?]` | Closing slide with crest and contact details. |

Divider slides appear automatically at every `\section`; `\sectionpage` places
one by hand.

Inline helpers, usable anywhere:

| Command | Result |
| --- | --- |
| `\sausstat{815}{label}` | Large maroon figure over a gold rule and a caption. |
| `\sauskey{term}` | Key term in maroon bold. |
| `\saushl{text}` | Light gold highlight wash. |
| `\sausrulesep` | Divider rule matching the one under frame titles. |
| `\sausrule[width]` | The signature rule on its own, at any width. |
| `\saussindhi{text}` | Right-to-left Sindhi in Lateef (Naskh). |
| `\sausurdu{text}` | Right-to-left Urdu in Noto Nastaliq Urdu. |
| `\sausnamesindhi`, `\sausnameurdu` | The university's official name in each script. |
| `\sauslogo`, `\sauslogowhite` | Paths to the crest, for your own `\includegraphics`. |
| `\sausasset{file}` | Path to any file in the assets folder. |

# Posters

```latex
\documentclass[size=a0]{saus-poster}
\title{Your poster title}
\subtitle{An optional subtitle}
\author{First Author, Second Author}
\affiliation{Department of ..., The Shaikh Ayaz University, Shikarpur}
\sausevent{Conference or event, 2026}
\sauscontact{First Author\\ name@example.org}
\sausqr{https://doi.org/...}{Read the paper}

\begin{document}
\begin{sausposter}
  \sausbox{name=intro,column=1,below=top}{Introduction}{...}
  \sauscard{name=aims,column=1,below=intro}{Aims}{...}
  \sausbox{name=method,column=1,between=aims and bottom}{Method}{...}
  ...
\end{sausposter}
\end{document}
```

The header mirrors the title slide — campus photograph under a maroon wash, the
white crest, the university name in Sindhi and the motto in Garamond. The footer
carries the crest, contact details and a vector QR code.

## Class options

| Option | Values | Default | Effect |
| --- | --- | --- | --- |
| `size` | `a0`, `a1`, `a2`, `a3` | `a0` | Paper size. |
| `landscape` | flag | portrait | Landscape orientation (defaults to 4 columns). |
| `header` | `photo`, `solid`, `light` | `photo` | Header treatment, matching the slide title styles. |
| `headerimage` | any file in `assets/` | `saus-title-bg.jpg` | Photograph for `header=photo`. |
| `native` | `sindhi`, `urdu`, `both`, `none` | `sindhi` | University name in the header. |
| `assets` | path **with trailing slash** | `assets/` | Where the crest, photos and fonts live. |
| `fonts` | `true`, `false` | `true` | Use the brand typefaces. |
| `grid` | flag | off | Outline the column/row grid while arranging boxes. |

Every dimension — margins, gaps, type sizes, the header — is a multiple of 1% of
the paper's short side, so an A1 poster is an exact scaled copy of the A0 one.
Body text is 28.6 pt on A0, and `\small` … `\Huge` form a modular scale around
it.

## Boxes

All four take `[tcolorbox options]{placement}{title}{content}`. An empty title
gives a box without a heading.

| Command | Look | Use for |
| --- | --- | --- |
| `\sausbox` | Maroon title over the signature rule, white ground | Most sections |
| `\sauscard` | The same on a mist card | Grouped or secondary material |
| `\sausaccent` | Deep maroon card, white text, gold rule | The key finding; `\sausstat` figures turn white |
| `\sausblock` | Maroon title bar over a mist body | Matches a slide `block` |

Placement uses the tcolorbox poster keys:

- `column=2` puts the box in column 2; `span=2` makes it two columns wide.
- `below=top` starts a column; `below=intro` stacks under the box named `intro`.
- `between=intro and bottom` stretches a box from `intro` down to the footer —
  use it for the last box in each column so the columns end level.
- A box can only refer to boxes **declared earlier in the file**, so write each
  column top to bottom.

If content doesn't fit, the class says which box is too full and by how much
(`Class saus-poster Warning: Box 'results' is too full by 42pt`). Content never
spills silently over the footer. The `grid` option shows the layout grid.

`\begin{sausposter}[columns=4,rows=6]` passes grid settings straight to
tcolorbox.

## Poster helpers

| Command | Result |
| --- | --- |
| `\sausfigure[width]{file}{caption}` | Image with a numbered caption (floats cannot live in boxes). |
| `\captionof{table}{...}` | Numbered caption for a table. |
| `\sausstat{815}{Students enrolled}` | Large figure over a gold rule, as on the slides. |
| `\sausqr{url}{label}` | QR code in the footer; `\sausqr{}{}` removes it. |
| `\sausrule` | The signature maroon–gold–hairline rule at any width. |

Lists use the slide bullets (maroon, royal blue, gold squares). Body text is
ragged-right without hyphenation, which reads best at poster distance.

# Letters

```latex
\documentclass{saus-letter}
\sausdepartment{Department of Computer Science}   % office name under the motto
\sausemail{hod.cs@saus.edu.pk}                    % footer, as a mail link
\setkomavar{signature}{Head of Department\\ Department of Computer Science}
\setkomavar{myref}{SAUS/CS/2026/01}           % printed as "Ref. No."; 0 hides it
\setkomavar{subject}{...}                     % printed as "Subject: ..."

\begin{document}
\begin{letter}{Recipient\\ Designation\\ Address}
\opening{Dear Sir/Madam,}
...
\closing{Yours sincerely,}
\encl{...}                                    % "Enclosure: ..."
\cc{...}                                      % "Copy to: ..."
\end{letter}
\end{document}
```

`saus-letter.cls` is KOMA-Script's `scrlttr2` with the university letterhead, so
everything in the KOMA-Script manual applies — several letters in one file,
`\KOMAoptions`, `\setkomavar` for any field.

- **Letterhead:** crest, name, motto and office on the left; the name in Sindhi
  and Urdu on the right; the maroon–gold signature rule beneath.
- **Reference line:** one line directly under the letterhead and above the
  addressee — "Ref. No." (`myref`) on the left, "Dated" on the right, and
  "Your ref." (`yourref`) between them when it is set. Setting a reference to
  `0` (or leaving it out) hides it: `\setkomavar{myref}{0}` drops "Ref. No."
  from this line and from the continuation-page header.
- **Footer:** address, telephone, website and (with `\sausemail{...}`) e-mail.
- **Continuation pages:** small crest and name, with the reference number and
  "Page 2 of 3".
- **Date:** today by default, as "21 September 2026";
  `\setkomavar{date}{...}` overrides it.
- **Print-safe:** nothing is placed within 12 mm of the edge, so office printers
  don't clip the letterhead.

## Class options

| Option | Values | Default | Effect |
| --- | --- | --- | --- |
| `native` | `both`, `sindhi`, `urdu`, `none` | `both` | Names in the letterhead. |
| `mono` | flag | off | Greyscale letterhead and crest, for black-and-white printers. |
| `foldmarks` | flag | off | DIN fold and punch marks in the left margin. |
| `sign` | `1`, `0` | `0` | `1` places the signature image above the signature block. |
| `closing` | `left`, `right` | `left` | Side of the page for the closing, signature and name. |
| `assets` | path **with trailing slash** | `assets/` | Where the crest and fonts live. |
| `fonts` | `true`, `false` | `true` | Use the brand typefaces. |

## Closing on the right

```latex
\documentclass[closing=right]{saus-letter}   % every letter in the file
\sausclosing{right}                          % or one letter (before \closing)
```

The closing words, signature image and name move to the right as one block
whose right edge sits on the margin; their lines stay left-aligned with each
other. The block is as wide as its longest line (or the signature image, if
wider), so nothing overhangs the margin. Enclosure and copy lists stay on the
left. `\sausclosing{left}` switches a single letter back.

## Signature image

```latex
\documentclass[sign=1]{saus-letter}      % 1 = signed, 0 = unsigned
\saussignimage[17mm]{signature-trans.png} % optional: other file or height
```

- With `sign=1` the image is placed in the signing space above the name, its
  tail just touching the name as a pen signature would. `sign=0` leaves the
  same space empty for signing by hand; nothing else on the page moves.
- `\saussign{0}` or `\saussign{1}` inside a `letter` environment switches
  that letter only, so one file can hold signed and unsigned letters.
- Use a transparent PNG. The default is `signature-trans.png`, looked up next to
  the `.tex` file.
- If signing is on and the image is missing, the build stops with an error
  rather than silently producing an unsigned letter.

**Keep signature images out of this folder.** The templates are meant to be
shared with every department; a signature stored in `assets/` would travel with
every copy. Keep it with the signatory's own letters and point to it with
`\saussignimage`. The demos sign with `assets/signature-specimen.png`, an
invented scrawl that belongs to nobody, so that the demo PDFs can be shared. Remember too that anyone who receives a signed PDF can lift
the image from it — for sensitive correspondence, sign by hand or digitally.

## Notifications and office orders

For documents without an addressee, `\sausnotice{<title>}` removes the address
field, moves the reference line up under the letterhead and sets a centred title:

```latex
\begin{letter}{}
  \sausnotice{Notification}
  \opening{}
  ...
  \closing{}
\end{letter}
```

# Certificates

`saus-certificate.cls` makes landscape certificates — participation,
achievement, appreciation, completion — one page per recipient.

```latex
\documentclass[style=classic,sign=1]{saus-certificate}

\sausdepartment{Department of Computer Science}
\signatory[hod-signature.png]{Head of Department}{Department of Computer Science}
\signatory{Director}{IT Directorate}          % no image: space for a pen

\certificatetitle{Certificate}{of Participation}
\certificatebody{has participated in the training session \textbf{...}}
\certificateserial{SAUS/CS/TR/2026/\thecertificate}   % 0 hides the number

\begin{document}
\makecertificate{Recipient Name}
\makecertificatesfromcsv{participants.csv}   % one page per row
\end{document}
```

- **Classic** is centred and framed: crest, university name, motto, Sindhi
  and Urdu names, the title in wide capitals, the recipient's name in
  EB Garamond italic, the crest as a faint watermark and a gold seal between
  the signatures. **Modern** puts the crest, names and contact details on a
  maroon band over a campus photograph, with the text left-aligned beside it.
- **Signatories:** up to three, left to right. With one they sit on the right,
  with two on either side of the seal. `\clearsignatories` starts a new list.
- **Numbers:** `\thecertificate` counts certificates in the file (001, 002, …),
  so a batch numbers itself. `\certificateserial{0}` or `serial=0` hides it;
  the date line (`Issued …`) always shows.
- **Too much text** doesn't overlap the signatures silently: the build warns
  `The certificate for <name> is too full by …`. Long names shrink to fit.

## Class options

| Option | Values | Default | Effect |
| --- | --- | --- | --- |
| `style` | `classic`, `modern` | `classic` | Layout; `\makecertificate[style=...]` overrides it for one page. |
| `size` | `a4`, `letter` | `a4` | Paper, always landscape. |
| `native` | `both`, `sindhi`, `urdu`, `none` | `both` | Names on the certificate. |
| `sign` | `1`, `0` | `0` | `1` prints the signatories' images; `0` leaves space for pen signatures. |
| `seal` | `true`, `false` | `true` | Gold seal (classic, one or two signatories). |
| `bandimage` | `default`, `none`, a file | `default` | Photograph behind the modern band. |
| `assets` | path **with trailing slash** | `assets/` | Where the crest and fonts live. |
| `fonts` | `true`, `false` | `true` | Use the brand typefaces. |

## Certificate commands

| Command | Sets |
| --- | --- |
| `\certificatetitle{Certificate}{of Achievement}` | Title and the line under it (empty to omit). |
| `\certificatecertify{Presented to}` | Line above the name (default *This is to certify that*). |
| `\certificatebody{...}` | Text under the name. |
| `\certificatedate{1 October 2026}` | Issue date (default today). |
| `\certificateserial{...}` | Certificate number; `0` or empty hides it. |
| `\certificateverify{url}` | QR code in the corner; `\certificatenumber` inside the URL inserts this certificate's number. |
| `\signatory[image]{Name}{Designation}` | Adds a signatory; `\saussignheight{14mm}` sizes the images. |
| `\makecertificate[keys]{Name}` | One certificate. Keys: `title`, `subtitle`, `certify`, `body`, `date`, `serial`, `verify`, `style`. |
| `\makecertificatesfromcsv{file.csv}` | One certificate per row. |

The CSV file needs a header row with the columns `name` and `serial`. An empty
`serial` uses the numbering from `\certificateserial`; wrap names containing
commas in braces. For other columns (say, a different course per person), use
`\csvreader` from `csvsimple-l3` directly with `\makecertificate[body=...]`.

The verification QR code should point to a page the university actually runs;
the demo uses the main website. Characters `%`, `#` and `&` in the URL must be
written `\%`, `\#` and `\&`.

The same advice as for letters applies to signature images: keep them out of
this folder, and remember that a signature in a PDF can be copied.

# Theses and final year projects

`saus-thesis.cls` sets final year project reports, MS/MPhil theses and PhD
theses in the order Pakistani universities expect, from title page to
appendices.

```latex
\documentclass[degree=bs,bib=ieee]{saus-thesis}
\addbibresource{references.bib}

\title{Title of the Project}
\student{Student Name}{Roll No. ...}      % once per group member
\supervisor{Supervisor Name}{Designation}
\discipline{Computer Science}             % "Bachelor of Science in Computer Science"
\sausdepartment{Department of Computer Science}
\session{2022--2026}
\approvedby{External Examiner}{Name and designation}
\approvedby{Head of Department}{Department of ...}

\begin{document}
\frontmatter
\maketitlepage  \makeapproval  \makedeclaration
\begin{abstract} ... \end{abstract}
\tableofcontents  \listoffigures  \listoftables
\mainmatter
\chapter{Introduction} ...
\printreferences
\appendix
\chapter{...}
\end{document}
```

- **Front matter:** `\makecover` (a full-page maroon cover for the PDF copy),
  `\maketitlepage`, `\makeapproval` (signature blocks for the supervisor,
  co-supervisor and every `\approvedby`, two to a row), `\makedeclaration`
  (signed by each student; it reports the similarity index when `\similarity`
  is set), `\dedication{...}`, and the `acknowledgements`, `abstract` (with
  `\keywords` after it) and `abbreviations` (`\abbr{HEC}{...}`) environments.
- **Urdu or Sindhi abstract:** the `urduabstract` and `sindhiabstract`
  environments set a right-to-left abstract in Nastaliq or Lateef. They need
  LuaLaTeX; other engines leave them out with a warning.
- **Wording follows the options:** `degree=bs` gives "A project report
  submitted in partial fulfilment of the requirements for the degree of
  Bachelor of Science in ..." and a *Final Year Project* label; `ms`, `mphil`
  and `phd` give a *thesis*. One student reads "I hereby declare", a group
  "We hereby declare".
- **Pages:** A4, 38 mm binding margin, 1.5 line spacing, chapters opening with
  a gold "CHAPTER 3", the title in Fira Sans and the signature rule. Running
  heads carry the chapter (and, two-sided, the section); numbering is roman in
  the front matter and arabic from Chapter 1.
- **Text:** EB Garamond with Garamond-Math by default; `body=sans` switches to
  Fira Sans and Fira Math. Theorem-style environments (`theorem`, `lemma`,
  `proposition`, `corollary`, `definition`, `example`, `remark`), code
  listings in Fira Mono and captions in the style of the slides are built in.

## Class options

| Option | Values | Default | Effect |
| --- | --- | --- | --- |
| `degree` | `bs`, `ms`, `mphil`, `phd` | `bs` | Degree named on the title page and approval. `\degreename{...}` overrides it. |
| `type` | `project`, `thesis` | `project` for BS, else `thesis` | "Project report" or "thesis" throughout. |
| `body` | `serif`, `sans` | `serif` | EB Garamond or Fira Sans for the text. |
| `spacing` | `single`, `onehalf`, `double` | `onehalf` | Line spacing of the text (tables, figures and code stay single). |
| `bib` | `ieee`, `apa`, `numeric`, `authoryear`, `none` | `ieee` | Citation and reference style (biblatex). |
| `twoside` | flag | off | Mirrored margins; chapters open on right-hand pages. |
| `print` | flag | off | Black links for the printed copy (on screen they are maroon and blue). |
| `status` | `final`, `draft` | `final` | `draft` puts "Draft · date" at the top of every page. |
| `native` | `both`, `sindhi`, `urdu`, `none` | `both` | Names on the title page. |
| `assets` | path **with trailing slash** | `assets/` | Where the crest and fonts live. |
| `fonts` | `true`, `false` | `true` | Use the brand typefaces. |

Other details: `\subtitle`, `\cosupervisor{Name}{Designation}`, `\faculty`,
`\submissiondate` (default: the current month), `\similarity{9\%}` and
`\keywords`. For long reports, put each chapter in its own file and
`\include` it.

# Brand

## Brand palette

Every colour is a normal `xcolor` name, so `\color{sausmaroon}`,
`fill=sausgold` and `sausblue!20` all work.

| Name | Hex | Role | Contrast on white |
| --- | --- | --- | --- |
| `sausmaroon` | `#6B2A4C` | Primary. Crest script and border. | 10.2:1 |
| `sausmaroondark` | `#4A1C34` | Large fields: title, dividers, closing. | 13.9:1 |
| `sausmaroonlight` | `#8E4166` | Tints, the unfilled progress track. | 6.8:1 |
| `sausblue` | `#1A1A91` | Secondary. The crest's ring band. | 13.1:1 |
| `sausbluedark` | `#131368` | Deep secondary, for text on light grounds. | 15.9:1 |
| `sausgold` | `#C39B3E` | Accent only — rules, small caps on dark. | 2.6:1 |
| `sausmist` | `#F4EDF1` | Tinted surface, from the crest's field. | — |
| `sausink` | `#231C21` | Body text. | 16.7:1 |
| `sausslate` | `#6A626B` | Muted and secondary text. | 5.9:1 |
| `sausrule` | `#D9C9D2` | Hairlines and dividers. | — |
| `sausgreen` | `#2E6B4F` | Semantic: positive. | 6.3:1 |
| `sausred` | `#B3261E` | Semantic: alert. | 6.5:1 |

`SAUSprimary`, `SAUSsecondary` and `SAUSaccent` are aliases for maroon, blue
and gold.

**Gold is not a text colour on light backgrounds.** At 2.6:1 on white it fails
WCAG AA. On the deep maroon fields (`sausmaroondark`) it reaches 5.4:1, which
passes AA at any size — that is where the theme uses it for labels and the motto.
On the mid maroon (`sausmaroon`, 3.9:1) keep it to large text and rules.

Ratios were computed with the WCAG 2.x relative-luminance formula.

## Typography

All fonts are open-licence (SIL OFL):

| Role | Typeface | Where | Source |
| --- | --- | --- | --- |
| Text and headings | **Fira Sans** — Regular, SemiBold, Light, Medium | Body, titles, subtitles, labels, big figures | TeX Live `fira` |
| Maths | **Fira Math** via `unicode-math` | All mathematics | TeX Live `firamath` |
| Code | **Fira Mono** | `\texttt`, verbatim | TeX Live `fira` |
| Accent | **EB Garamond** Italic | The motto and pull quotes | TeX Live `ebgaramond` |
| Sindhi | **Lateef** | `\saussindhi`, `\sausnamesindhi` | bundled |
| Urdu | **Noto Nastaliq Urdu** | `\sausurdu`, `\sausnameurdu` | bundled |

The choices:

- **One text family.** Fira Sans was designed for screens and has the full range
  of weights, so headings, subtitles and labels come from one family rather than
  a pairing.
- **Matching maths.** Fira Math is drawn to match Fira Sans, so equations don't
  switch to a serif mid-slide — the usual weak point of sans-serif Beamer themes.
- **Garamond for the motto.** The only serif, used sparingly, gives the motto and
  quotations a classical voice.
- **The right style for each script.** Sindhi is written in Naskh, and Lateef is
  SIL's Naskh face designed for Sindhi (ڪ ٻ ٽ ڏ ...). Urdu is written in
  Nastaliq, so it gets a true Nastaliq face; LuaLaTeX shapes both with HarfBuzz.

Headings never hyphenate, and body text is ragged-right by default.

`\saussindhi` and `\sausurdu` are for short runs — a name, a motto, a phrase in
an English slide. For slides written entirely in Sindhi or Urdu, load
`polyglossia` or `babel` for full right-to-left layout.

All of the theme's typography goes through five role macros —
`\sausdisplayfamily`, `\sausdisplayseries`, `\sauslightfont`, `\sauslabelfont`
and `\sausmottofont` — so you can use them in your own slides, and swapping a
typeface means changing it in one place.

Pass `fonts=false` to choose your own fonts instead. Licences for the bundled
fonts are in `assets/fonts/LICENSES.md`.

## Assets

| File | Source |
| --- | --- |
| `saus-logo.png` | The crest, trimmed, full colour. Use on light backgrounds. |
| `saus-logo-white.png` | White line-art crest for maroon and photographic backgrounds. |
| `saus-logo-gray.png` | Greyscale crest, used by the letterhead's `mono` option. |
| `saus-title-bg.jpg` | Aerial view of the campus — the default title background. |
| `saus-campus-gate.jpg` | The main gate. |
| `saus-campus-courtyard.jpg` | Courtyard between the teaching blocks. |
| `saus-monument.jpg` | The rock monument. |
| `signature-specimen.png` | A drawn placeholder signature, used by the demos. Nobody's signature. |
| `fonts/` | Lateef and Noto Nastaliq Urdu (SIL OFL 1.1). |

The white crest is generated from the colour original, so if the university
issues a revised logo, replace `saus-logo.png` and regenerate:

```bash
magick saus-logo.png -trim +repage -background white -alpha remove -alpha off \
  -colorspace Gray -negate -linear-stretch 2%x2% \( +clone \) \
  -compose CopyOpacity -composite -colorspace sRGB saus-logo-white.png
```

Title and full-bleed backgrounds are cover-cropped to the slide, so supply them
at 16:9 or wider — 1920×1080 is ample.
