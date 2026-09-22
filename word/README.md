# SAUS Word templates: letterhead and theses

The Word versions of the LaTeX letterhead (`../latex/saus-letter.cls`) and
thesis class (`../latex/saus-thesis.cls`) for **The Shaikh Ayaz University,
Shikarpur**, with the same layout, typefaces and details.

| File | What it is |
| --- | --- |
| `SAUS-letterhead.dotx` | Letterhead for any office: department and e-mail are fill-in fields. |
| `SAUS-letterhead-CS.dotx` | Department of Computer Science, with hod.cs@saus.edu.pk in the footer. |
| `SAUS-letter-demo.docx` | The LaTeX demo circular rebuilt in Word. |
| `SAUS-thesis-FYP.dotx` | Final year project report (BS): "project report", group of students. |
| `SAUS-thesis.dotx` | MS, MPhil or PhD thesis: "thesis", one student. |
| `SAUS-thesis-demo.docx` | The LaTeX demo report rebuilt in Word. |
| `source/` | The build scripts, a PDF export script and a field-update script. |

## Setting up

1. **Install the fonts.** They are a download, not part of the repository:
   [`../fonts/README.md`](../fonts/README.md) lists the five families and where
   to get them. Without them Word substitutes other fonts.
2. **Start a letter:** double-click the `.dotx` file. Word opens a new, untitled
   document; the template itself is not changed.
3. **Make it the office's template:** copy it to
   *Documents\Custom Office Templates*; it then appears under **File > New >
   Personal**. For a department, fill in the department and e-mail once in a
   copy of `SAUS-letterhead.dotx` (double-click the header or footer) and save
   it as that office's template, as `SAUS-letterhead-CS.dotx` does for Computer
   Science.

## The letter

- **Page 1** carries the letterhead — crest, university name, motto, office,
  and the Sindhi and Urdu names — and the contact footer. **Later pages** get a
  slim running head: small crest and name on the left, the reference number
  and "Page 2 of 3" on the right. Nothing needs setting up; Word switches
  automatically when the letter runs onto a second page.
- **Fill-in fields** (grey text): click one and type. The date field opens a
  calendar and writes the date as "21 September 2026".
- **Reference line:** "Ref. No." on the left and "Dated" on the right, on one
  line above the addressee. The reference number is repeated in the running
  head of later pages. If a letter has no reference number, delete the
  "Ref. No." text and its field; the running head then shows only the page.
- **Signature:** the space above the signatory's name is for a pen signature.
  To sign electronically, put a transparent PNG of the signature in that space
  (**Insert > Pictures**, then **Wrap Text > In Front of Text**). Keep
  signature images out of shared templates.
- **Closing on the right:** select the closing, the signatory lines and the
  space between them, and set **Layout > Indent > Left** to about 10 cm.
- **Enclosure / Copy to:** delete the lines you don't need.

## Styles

Use these from the **Styles** gallery rather than formatting by hand:

| Style | For |
| --- | --- |
| Normal | Body text: Fira Sans 11 pt, justified, with hyphenation. |
| List Bullet / List Number | Maroon square bullets (blue, then gold, when indented) and maroon numbers. |
| SAUS Table (table style) | Rules above and below and under the header row, as in the LaTeX letter. |
| SAUS Table Text | Paragraphs inside tables, without body spacing. |
| SAUS Subject | The "Subject:" line. |
| SAUS Key Term / SAUS Code | Maroon bold terms; file names and code in Fira Mono. |
| SAUS Notice Title | A centred title, for notifications and office orders. |

For a **notification or office order** (no addressee), delete the addressee
and put a *SAUS Notice Title* paragraph ("Notification") under the reference
line.

# Theses and final year projects

`SAUS-thesis-FYP.dotx` and `SAUS-thesis.dotx` follow the LaTeX thesis class:
A4 with a 38 mm binding margin, 1.5 line spacing, EB Garamond text and Fira
Sans headings. Double-click one to start a report; every field to fill in is
grey.

- **Front matter** (numbered i, ii, iii ...): title page with the crest and the
  Sindhi and Urdu names; certificate of approval with signature lines;
  declaration signed by each student; dedication; acknowledgements; abstract
  and keywords; an Urdu abstract (delete the page if not required); contents,
  list of figures, list of tables and list of abbreviations.
- **Chapters** (numbered 1, 2, 3 ... from the first chapter): apply
  **Heading 1** and Word adds "CHAPTER 1" in gold and starts a new page;
  **Heading 2** and **Heading 3** are numbered 1.1 and 1.1.1. The running head
  shows "Chapter 1 · Title" and the page number.
- **References** and **appendices** have their own running heads. Apply
  **SAUS Reference** to each reference to number it [1], [2] ...; apply
  **SAUS Appendix Heading** for "APPENDIX A".
- The certificate of approval and the declaration repeat the title and degree
  from the title page automatically.

## Working in the thesis

| To add | Do this |
| --- | --- |
| A chapter or section | Type the title and apply **Heading 1**, **2** or **3**. |
| A figure | Insert the picture in a **SAUS Figure** paragraph, then **References > Insert Caption**, label *Figure*, with **Numbering > Include chapter number** (gives "Figure 3.1"). |
| A table | **References > Insert Caption** above it (label *Table*), then insert the table and choose the **SAUS Table** style. |
| An equation | **Insert > Equation** in a **SAUS Equation** paragraph: Tab, the equation, Tab, "(3.1)". |
| Code | One **SAUS Code** paragraph per line. |
| A definition or theorem | A **SAUS Theorem** paragraph starting with a **SAUS Label** run, e.g. "Definition 3.1 (Contrast ratio)." |
| Bullets and numbered lists | **List Bullet** and **List Number**. |
| An abbreviation | A **SAUS Abbreviation** paragraph: abbreviation, Tab, meaning. |
| Urdu or Sindhi text | The **SAUS Urdu** (Nastaliq) or **SAUS Sindhi** (Lateef) style, right to left. |

**Update the contents and cross-references** before printing or making a PDF:
press **Ctrl+A**, then **F9** (if asked, choose *Update entire table*). This
refreshes the contents, the lists of figures and tables, the caption numbers,
and the title and degree repeated from the title page.

For references, Word's own **References > Insert Citation** (style IEEE) or a
reference manager such as Zotero or Mendeley both work with the SAUS Reference
style.

## Rebuilding

The files are generated; change `source/build_docx.py` rather than editing
them by hand:

```bash
pip install -r ../requirements.txt
python source/build_docx.py                 # letterhead
python source/build_thesis_docx.py          # thesis templates and demo
powershell -File source/finalize.ps1 SAUS-thesis-demo.docx SAUS-thesis-FYP.dotx SAUS-thesis.dotx
```

`finalize.ps1` opens each file in Word, updates the contents, lists and
fields, saves it, and puts the university back as the file's last author —
saving stamps in whoever is signed in to Windows, and these files are shared.
Close any Word document based on these templates first.
The architecture diagram in the thesis demo is `source/art/architecture.png`,
rendered from `source/art/architecture.tex`.

`source/render.ps1 <file.docx> <out.pdf>` exports through Word for checking,
with the brand fonts loaded only for that session. The Sindhi and Urdu names
are the images in `../powerpoint/source/art`.
