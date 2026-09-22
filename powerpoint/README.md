# SAUS PowerPoint template

The PowerPoint version of the Beamer theme in `../latex` for **The Shaikh Ayaz
University, Shikarpur**, with the same colours, typefaces, crest placement,
title rule and footer. Measurements are taken from the Beamer theme and scaled
to PowerPoint's 16:9 slide.

| File | What it is |
| --- | --- |
| `SAUS-template.potx` | The template: slide master, 16 layouts, brand colours and fonts. |
| `SAUS-slides-demo.pptx` | The Beamer demo rebuilt in PowerPoint, showing the layouts. |
| `source/` | The script that builds both files, and the Sindhi/Urdu name images. |

## Setting up

1. **Install the fonts** (the same ones the Word and Excel templates use).
   They are a free download rather than part of the repository —
   [`../fonts/README.md`](../fonts/README.md) lists the five families and where
   to get them. Put the files in `../fonts`, select them, right-click,
   **Install**. Without them PowerPoint substitutes other fonts and the slides
   lose their look.
2. **Use the template:** double-click `SAUS-template.potx` to start a new
   presentation from it. To make it the default in PowerPoint, save it as
   *Documents\Custom Office Templates\SAUS.potx*; it then appears under
   **File > New > Personal**.
3. **Apply it to an existing deck:** **Design > Themes > Browse for Themes**, and
   pick `SAUS-template.potx`.

## Layouts

**Home > Layout** (or right-click a slide > Layout):

| Layout | Use |
| --- | --- |
| Title Slide (photo) | Campus aerial photograph under a maroon wash. The default. |
| Title Slide (solid) | Deep maroon with a large ghosted crest. |
| Title Slide (split) | Light upper field, maroon band with the presenter. |
| Title and Content | The everyday slide: title, rule, bullets. |
| Title, Subtitle and Content | As above, with a subtitle under the title. |
| Key Figures | Three large numbers with labels, then text. |
| Two Content | Two columns. |
| Comparison (blocks) | Two blocks with maroon and blue headers, like Beamer blocks. |
| Title Only | For tables, charts and diagrams. |
| Picture with Caption | A picture with a numbered caption, text beside it. |
| Section Header | Full-bleed maroon divider: "Section 1" and the section name. |
| Statement | One sentence, set large on maroon. |
| Quote | A pull quote in EB Garamond italic with an attribution. |
| Photo | A full-bleed photograph with a caption band. |
| Closing | Thank-you slide with the crest, names and contact details. |
| Blank | Only the footer band. |

- **Footer:** **Insert > Header & Footer**, tick *Slide number* and *Footer*,
  type a short title, then **Apply to All**. The university name in the
  footer is built in. Title, section, statement, quote, photo and closing
  slides have no footer, as in Beamer.
- **Bullets:** maroon squares, blue on the second level and gold on the third;
  **Increase List Level** (Tab) moves down a level.
- **Colours:** the theme colours are the brand palette — maroon, royal blue,
  gold, green, red and slate — so charts, SmartArt and shapes pick them up.
- **Photos:** in the Photo and Picture with Caption layouts, click the picture
  icon; PowerPoint crops the photograph to fill the frame.

## Sindhi and Urdu

The university's Sindhi and Urdu names on the title and closing slides are
pictures rendered with LaTeX (Lateef and Noto Nastaliq Urdu), so they appear
correctly on every computer, whatever fonts it has. The files are in
`source/art/` (maroon and white versions) for use on other slides.

For your own Sindhi or Urdu text, the theme sets Lateef as the font for
Arabic script; set the paragraph direction with **Home > Right-to-Left**.

## Sharing

A deck opened on a computer without the fonts falls back to other typefaces.
When sending slides outside the university, send a PDF (**File > Export >
PDF**) as well.

## Rebuilding

The template and demo are generated, so design changes go into
`source/build_pptx.py` rather than being made by hand:

```bash
pip install -r ../requirements.txt
python source/build_pptx.py
```

`source/render.ps1 <file.pptx> <folder>` exports every slide to PNG through
PowerPoint for checking, with the brand fonts loaded only for that session.
`source/native-names.tex` renders the Sindhi and Urdu name images
(see the comment at its top).
