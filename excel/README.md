# SAUS Excel workbook

An Excel template for **The Shaikh Ayaz University, Shikarpur**, matching the
slides, letterhead and PowerPoint/Word templates: the same colours, typefaces,
crest and Sindhi/Urdu names.

| File | What it is |
| --- | --- |
| `SAUS-workbook.xltx` | A report sheet: letterhead, title, a branded table with a total row, footer. |
| `SAUS-workbook-demo.xlsx` | Key figures, an enrolment model with a chart, and a delivery schedule. |
| `source/` | The build script and two checking scripts. |

## Setting up

1. **Install the fonts.** They are a download, not part of the repository:
   [`../fonts/README.md`](../fonts/README.md) lists them and where to get them.
   Put the files in `../fonts`, select them, right-click, **Install**.
2. **Start a workbook:** double-click `SAUS-workbook.xltx`; Excel opens a new,
   untitled copy. To keep it at hand, copy it to
   *Documents\Custom Office Templates* (it then appears under **File > New >
   Personal**).
3. Select cell C4 (the grey "DEPARTMENT OR OFFICE") and type the office's
   name in capitals; replace "Report title" (B8) and the subtitle (B9).

## What's built in

- **Theme colours and fonts.** The workbook theme is the brand: accent 1 is
  maroon, then royal blue, gold, green, red and slate; headings are Fira Sans
  SemiBold and text Fira Sans. So anything Excel draws from the theme is on
  brand without extra work:
  - **Tables** (**Insert > Table**): *Table Style Medium 2* gives the maroon
    header and light banding used here; *Light 9* is the plainer version.
  - **Charts** take maroon first, then blue and gold.
  - Colour pickers show the brand palette in their top row.
- **Cell styles** (**Home > Cell Styles**, under *Custom*):

  | Style | For |
  | --- | --- |
  | SAUS Title / SAUS Subtitle | The sheet title and the line under it. |
  | SAUS Heading | Section headings, with a hairline under them. |
  | SAUS Key Figure / SAUS Key Label | Large headline numbers and their labels (as on the slides). |
  | SAUS Label | Maroon labels for inputs and fields. |
  | SAUS Input | Shaded cells people are meant to change. |
  | SAUS Total | Totals, with a rule above. |
  | SAUS Note | Notes and sources in small grey text. |

- **Letterhead** across the top of each sheet: the crest, the university's
  name, motto and office, the Sindhi and Urdu names, and the maroon-gold rule.
  To use it on a new sheet, right-click the sheet tab > **Move or Copy** >
  *Create a copy*, then clear the content below row 10.
- **Printing:** A4 portrait, fitted to the page width, gridlines off, with a
  footer showing the university's name, the sheet name and "Page 1 of 2".

## PDFs from Excel

Excel's own **File > Save As > PDF** does not embed the Fira Sans and EB
Garamond font files (Word and PowerPoint do). The PDF looks right on
computers that have the fonts installed; elsewhere a reader substitutes other
fonts, and Excel may fall back to Calibri for text containing curly quotes or
dashes. For PDFs that go outside the university, check the result on a
computer without the fonts, or paste the table into the Word letterhead.

## Rebuilding

The files are generated; change `source/build_xlsx.py` rather than editing them:

```bash
pip install -r ../requirements.txt
python source/build_xlsx.py
```

For checking, with the brand fonts loaded only for that session:

- `source/preview.ps1 <file.xlsx> <folder>` saves a PNG of each sheet as Excel
  draws it on screen (the reliable way to check the look).
- `source/render.ps1 <file.xlsx> <out.pdf>` exports a PDF (to check page
  layout).
