"""Build the Word examination papers from the same brand as saus-exam.cls.

    python word/source/build_exam_docx.py
    powershell -File word/source/finalize.ps1 word/SAUS-exam-demo.docx word/SAUS-exam.dotx

Writes SAUS-exam.dotx (a paper to fill in) and SAUS-exam-demo.docx (the LaTeX
demo paper rebuilt in Word). Styles, colours and measurements come from
build_docx.py, so the paper matches the letterhead and the thesis.

What differs from the LaTeX class, and why:
  * marks sit at the end of a question, right-aligned on a tab, not in the
    margin: Word has no dependable margin note that survives editing;
  * the model answers are hidden text ("SAUS Answer"), so one file prints as
    the paper and, with Print hidden text turned on, as the answer key;
  * the marks and CLO table cannot collect itself from the questions, so the
    template carries the table to fill in -- its total is a SUM field.
"""
import os

from docx import Document
from docx.enum.style import WD_STYLE_TYPE
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.enum.text import WD_ALIGN_PARAGRAPH, WD_TAB_ALIGNMENT
from docx.oxml import parse_xml
from docx.oxml.ns import qn
from docx.shared import Mm, Pt, RGBColor
from PIL import Image, ImageDraw

import build_docx as L
from build_docx import W, add_runs, field, run, sdt_inline, border
from build_thesis_docx import normalise_all   # the schema-order sort, shared

HERE, OUT, ASSETS = L.HERE, L.OUT, L.ASSETS
ART = os.path.join(L.ROOT, "powerpoint", "source", "art")
MAROON, MAROON_LIGHT, GOLD = L.MAROON, L.MAROON_LIGHT, L.GOLD
INK, SLATE, RULE, MIST = L.INK, L.SLATE, L.RULE, "F4EDF1"
GREEN, BLUE = "2E6B4F", "1A1A91"
SANS, SEMIBOLD, MEDIUM, SERIF, MONO = L.SANS, L.SEMIBOLD, L.MEDIUM, L.SERIF, L.MONO
LIGHT = "Fira Sans Light"
UNIVERSITY, MOTTO = L.UNIVERSITY, L.MOTTO
SEP = " · "

LEFT_M, RIGHT_M = 20, 25
TEXT_W = 210 - LEFT_M - RIGHT_M             # 165 mm
TW = int(TEXT_W * 56.6929)                  # text width in twips
Q_INDENT = int(13 * 56.6929)                # hanging indent of a question
P_INDENT = int(8 * 56.6929)                 # extra indent of a part

PAPERS = ["Mid-Term Examination", "Final-Term Examination", "Sessional Examination",
          "Quiz", "Make-Up Examination", "Supplementary Examination",
          "Practical Examination"]


# ---- Small helpers ---------------------------------------------------------------
def rule_png(width_mm):
    """The maroon-gold-hairline brand rule as a 600 dpi image."""
    path = os.path.join(HERE, f"exam-rule-{width_mm}.png")
    dpmm = 600 / 25.4
    w, h = round(width_mm * dpmm), round(0.78 * dpmm)
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    m, g = round(5.67 * dpmm), round(2.48 * dpmm)
    d.rectangle([0, 0, m - 1, h - 1], fill="#" + MAROON)
    d.rectangle([m, 0, m + g - 1, h - 1], fill="#" + GOLD)
    hl = max(2, round(0.21 * dpmm))
    d.rectangle([m + g, (h - hl) // 2, w - 1, (h - hl) // 2 + hl - 1], fill="#" + RULE)
    img.save(path, dpi=(600, 600))
    return path


def style(doc, name, kind=WD_STYLE_TYPE.PARAGRAPH, base="Normal", font=None, size=None,
          color=None, bold=None, italic=None, caps=None, align=None, before=None, after=None,
          left=None, hanging=None, keep_next=None, keep_lines=None, spacing=None, shade=None,
          tabs=(), next_style=None, hidden=False, line=None):
    styles = doc.styles
    try:
        st = styles[name]
    except KeyError:
        st = styles.add_style(name, kind)
    if kind == WD_STYLE_TYPE.PARAGRAPH and base:
        st.base_style = styles[base]
    st.quick_style = True
    f = st.font
    if font:
        f.name = font
        rfonts = st.element.get_or_add_rPr().get_or_add_rFonts()
        rfonts.set(qn("w:cs"), font)
        for attr in ("asciiTheme", "hAnsiTheme", "eastAsiaTheme", "cstheme"):
            rfonts.attrib.pop(qn("w:" + attr), None)
    if size:
        f.size = Pt(size)
    if color:
        f.color.rgb = RGBColor.from_string(color)
    for attr, val in (("bold", bold), ("italic", italic), ("all_caps", caps)):
        if val is not None:
            setattr(f, attr, val)
    rpr = st.element.get_or_add_rPr()
    if spacing:
        rpr.append(parse_xml(f'<w:spacing {W} w:val="{spacing}"/>'))
    if hidden:                                  # answers print only on request
        rpr.append(parse_xml(f"<w:vanish {W}/>"))
    if kind != WD_STYLE_TYPE.PARAGRAPH:
        return st
    pf = st.paragraph_format
    if align is not None:
        pf.alignment = align
    if before is not None:
        pf.space_before = Pt(before)
    if after is not None:
        pf.space_after = Pt(after)
    if line is not None:
        pf.line_spacing = line
    for attr, val in (("keep_with_next", keep_next), ("keep_together", keep_lines)):
        if val is not None:
            setattr(pf, attr, val)
    ppr = st.element.get_or_add_pPr()
    if left is not None:
        ind = f'<w:ind {W} w:left="{left}"'
        ind += f' w:hanging="{hanging}"/>' if hanging else "/>"
        ppr.append(parse_xml(ind))
    if shade:
        ppr.append(parse_xml(f'<w:shd {W} w:val="clear" w:color="auto" w:fill="{shade}"/>'))
    if tabs:
        xml = f"<w:tabs {W}>"
        for pos, kind_ in tabs:
            xml += f'<w:tab w:val="{kind_}" w:pos="{pos}"/>'
        ppr.append(parse_xml(xml + "</w:tabs>"))
    if next_style:                      # resolved once every style exists
        PENDING_NEXT.append((name, next_style))
    return st


PENDING_NEXT = []


def resolve_next_styles(doc):
    for name, following in PENDING_NEXT:
        doc.styles[name].next_paragraph_style = doc.styles[following]
    PENDING_NEXT.clear()


def para(doc, text="", style_name="Normal", **fmt):
    p = doc.add_paragraph(style=style_name)
    if text:
        add_runs(p, (text, fmt))
    return p


def fill(p, text, alias, tag, filled, **fmt):
    """A fill-in field: grey placeholder in the template, real text in the demo."""
    sdt_inline(p, alias, tag, text, placeholder=not filled, **fmt)


def cell_text(cell, parts, style_name="SAUS Table Text", align=None):
    p = cell.paragraphs[0]
    p.style = style_name
    if align is not None:
        p.alignment = align
    for part in parts:
        if isinstance(part, tuple):
            add_runs(p, part)
        else:
            part(p)
    return p


def shade(cell, color):
    cell._tc.get_or_add_tcPr().append(
        parse_xml(f'<w:shd {W} w:val="clear" w:color="auto" w:fill="{color}"/>'))


def borders(table, color=RULE, size=4, inside=True):
    kinds = ["top", "left", "bottom", "right"] + (["insideH", "insideV"] if inside else [])
    xml = f"<w:tblBorders {W}>"
    for k in kinds:
        xml += f'<w:{k} w:val="single" w:sz="{size}" w:space="0" w:color="{color}"/>'
    xml += "</w:tblBorders>"
    tbl_pr = table._tbl.tblPr
    for old in tbl_pr.findall(qn("w:tblBorders")):
        tbl_pr.remove(old)
    tbl_pr.append(parse_xml(xml))


def grid(doc, rows, cols, widths):
    t = doc.add_table(rows=rows, cols=cols)
    t.alignment = WD_TABLE_ALIGNMENT.CENTER
    t.autofit = False
    for col, w in zip(t._tbl.tblGrid.findall(qn("w:gridCol")), widths):
        col.set(qn("w:w"), str(int(w * 56.6929)))
    for r in t.rows:
        for c, w in zip(r.cells, widths):
            c.width = Mm(w)
    return t


def dropdown(p, alias, tag, items, chosen):
    """A content control the user picks the paper from, e.g. the kind of paper."""
    entries = "".join(f'<w:listItem w:displayText="{i}" w:value="{i}"/>' for i in items)
    sdt = parse_xml(f'<w:sdt {W}><w:sdtPr><w:alias w:val="{alias}"/><w:tag w:val="{tag}"/>'
                    f'<w:dropDownList>{entries}</w:dropDownList></w:sdtPr><w:sdtContent/></w:sdt>')
    sdt.find(qn("w:sdtContent")).append(run(chosen, style="SAUSPaperTitleRun"))
    p._p.append(sdt)


def marks(p, text, clo=None):
    """The marks at the end of a question, right-aligned on the style's tab.
    The spaces inside are no-break spaces, so "[5 marks · CLO 2]" is never
    split across two lines."""
    nb = text.replace(" ", " ")
    tail = f" · CLO {clo}" if clo else ""
    add_runs(p, ("\t", {}), (f"[{nb}{tail}]", dict(style="SAUSMarks")))


# ---- Styles ----------------------------------------------------------------------
def setup_styles(doc):
    styles = doc.styles
    rpr = styles.element.find(qn("w:docDefaults")).find(qn("w:rPrDefault")).find(qn("w:rPr"))
    for child in list(rpr):
        rpr.remove(child)
    rpr.append(parse_xml(f'<w:rFonts {W} w:ascii="{SANS}" w:hAnsi="{SANS}" w:eastAsia="{SANS}" '
                         f'w:cs="Lateef"/>'))
    rpr.append(parse_xml(f'<w:color {W} w:val="{INK}"/>'))
    rpr.append(parse_xml(f'<w:sz {W} w:val="22"/>'))
    rpr.append(parse_xml(f'<w:lang {W} w:val="en-GB"/>'))

    normal = styles["Normal"]
    normal.font.name, normal.font.size = SANS, Pt(11)
    pf = normal.paragraph_format
    pf.space_after, pf.space_before, pf.line_spacing = Pt(6), Pt(0), 1.08
    pf.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY

    # ---- the heading of the paper
    style(doc, "SAUS Head Name", font=SEMIBOLD, size=11.5, color=MAROON, caps=True,
          spacing=20, after=1, line=1.0)
    style(doc, "SAUS Head Motto", font=SERIF, size=11, color=MAROON_LIGHT, italic=True,
          after=1, line=1.0)
    style(doc, "SAUS Head Office", font=LIGHT, size=8.5, color=SLATE, bold=True, caps=True,
          spacing=20, after=0, line=1.0)
    style(doc, "SAUS Head Native", font=SANS, size=11, color=MAROON, after=0, line=1.15,
          align=WD_ALIGN_PARAGRAPH.RIGHT)
    style(doc, "SAUS Rule", after=2, before=2, line=1.0)
    style(doc, "SAUS Paper Title", font=SEMIBOLD, size=15, color=MAROON, caps=True, spacing=30,
          align=WD_ALIGN_PARAGRAPH.CENTER, before=8, after=2, line=1.0)
    style(doc, "SAUS Paper Session", font=LIGHT, size=10.5, color=SLATE,
          align=WD_ALIGN_PARAGRAPH.CENTER, before=0, after=8, line=1.0)
    style(doc, "SAUS Paper Title Run", kind=WD_STYLE_TYPE.CHARACTER, font=SEMIBOLD, size=15,
          color=MAROON, caps=True, spacing=30)

    # ---- labels, panels and tables
    style(doc, "SAUS Label", kind=WD_STYLE_TYPE.CHARACTER, font=LIGHT, size=7.5, color=MAROON,
          bold=True, caps=True, spacing=16)
    style(doc, "SAUS Course Code", kind=WD_STYLE_TYPE.CHARACTER, font=SANS, size=11, color=INK)
    style(doc, "SAUS Marks", kind=WD_STYLE_TYPE.CHARACTER, font=SEMIBOLD, size=10.5, color=MAROON)
    # marks the total in the details grid, which the footer repeats
    style(doc, "SAUS Total Marks", kind=WD_STYLE_TYPE.CHARACTER, font=SANS, size=11, color=INK)
    style(doc, "SAUS Table Text", size=10.5, align=WD_ALIGN_PARAGRAPH.LEFT, after=2, before=2,
          line=1.0)
    style(doc, "SAUS Table Head", base="SAUS Table Text", font=SEMIBOLD, size=10.5)
    style(doc, "SAUS Centred", align=WD_ALIGN_PARAGRAPH.CENTER, after=4)

    # ---- instructions
    style(doc, "SAUS Instruction", size=10.5, after=2, left=int(6.5 * 56.6929),
          hanging=int(6.5 * 56.6929), align=WD_ALIGN_PARAGRAPH.LEFT, line=1.05)

    # ---- the paper itself
    style(doc, "SAUS Section", font=SEMIBOLD, size=11, color="FFFFFF", caps=True, spacing=20,
          shade=MAROON, before=12, after=8, keep_next=True, line=1.0,
          tabs=((TW - 120, "right"),), next_style="SAUS Question")
    style(doc, "SAUS Question", before=8, after=4, left=Q_INDENT, hanging=Q_INDENT,
          keep_lines=True, tabs=((TW, "right"),), next_style="SAUS Question")
    style(doc, "SAUS Part", base="SAUS Question", before=4, after=4,
          left=Q_INDENT + P_INDENT, hanging=P_INDENT, tabs=((TW, "right"),),
          next_style="SAUS Part")
    style(doc, "SAUS Choices", size=11, left=Q_INDENT, align=WD_ALIGN_PARAGRAPH.LEFT,
          before=2, after=4, next_style="SAUS Question",
          tabs=tuple((Q_INDENT + int(n * (TW - Q_INDENT) / 4), "left") for n in (1, 2, 3)))
    style(doc, "SAUS Answer Line", after=0, before=0, line=1.0, left=Q_INDENT,
          next_style="SAUS Answer Line")
    doc.styles["SAUS Answer Line"].paragraph_format.space_after = Pt(14)
    style(doc, "SAUS Answer", size=10.5, color=GREEN, left=Q_INDENT, before=2, after=6,
          hidden=True, align=WD_ALIGN_PARAGRAPH.LEFT, next_style="SAUS Question")
    style(doc, "SAUS Answer Label", kind=WD_STYLE_TYPE.CHARACTER, font=LIGHT, size=7.5,
          color=GREEN, bold=True, caps=True, spacing=16)
    # the tick beside the right choice: hidden, so only the answer key shows it
    style(doc, "SAUS Answer Tick", kind=WD_STYLE_TYPE.CHARACTER, font=SANS, size=11,
          color=GREEN, bold=True, hidden=True)
    style(doc, "SAUS Code", font=MONO, size=9.5, color=INK, left=Q_INDENT, before=0, after=0,
          line=1.0, align=WD_ALIGN_PARAGRAPH.LEFT)
    style(doc, "SAUS Paper End", font=LIGHT, size=9, color=SLATE, bold=True, caps=True,
          spacing=20, align=WD_ALIGN_PARAGRAPH.CENTER, before=10, after=4, line=1.0)

    # ---- right-to-left runs, for a paper set in Sindhi or Urdu
    for name, font, size in (("SAUS Urdu", "SAUS Nastaliq Urdu", 12),
                             ("SAUS Sindhi", "Lateef", 14)):
        st = style(doc, name, font=font, size=size, align=WD_ALIGN_PARAGRAPH.RIGHT, line=1.6)
        st.element.get_or_add_pPr().append(parse_xml(f"<w:bidi {W}/>"))
        st.element.get_or_add_rPr().append(parse_xml(f"<w:rtl {W}/>"))

    # ---- header and footer
    style(doc, "SAUS Header", size=8, color=SLATE, after=2, line=1.0,
          align=WD_ALIGN_PARAGRAPH.LEFT, tabs=((TW, "right"),))
    style(doc, "SAUS Footer", size=8, color=SLATE, before=2, after=0, line=1.0,
          align=WD_ALIGN_PARAGRAPH.LEFT,
          tabs=((TW // 2, "center"), (TW, "right")))
    resolve_next_styles(doc)


def numbering(doc):
    """Q1., Q2. on the question style and (a), (b) on the part style."""
    num = doc.part.numbering_part.element
    label = (f'<w:rPr><w:rFonts w:ascii="{SEMIBOLD}" w:hAnsi="{SEMIBOLD}"/>'
             f'<w:color w:val="{MAROON}"/></w:rPr>')
    questions = (
        f'<w:abstractNum {W} w:abstractNumId="60"><w:multiLevelType w:val="multilevel"/>'
        f'<w:lvl w:ilvl="0"><w:start w:val="1"/><w:numFmt w:val="decimal"/>'
        f'<w:pStyle w:val="SAUSQuestion"/><w:lvlText w:val="Q%1."/><w:lvlJc w:val="left"/>'
        f'<w:pPr><w:ind w:left="{Q_INDENT}" w:hanging="{Q_INDENT}"/></w:pPr>{label}</w:lvl>'
        f'<w:lvl w:ilvl="1"><w:start w:val="1"/><w:numFmt w:val="lowerLetter"/>'
        f'<w:pStyle w:val="SAUSPart"/><w:lvlText w:val="(%2)"/><w:lvlJc w:val="left"/>'
        f'<w:pPr><w:ind w:left="{Q_INDENT + P_INDENT}" w:hanging="{P_INDENT}"/></w:pPr>'
        f'{label}</w:lvl></w:abstractNum>')
    instr = (f'<w:abstractNum {W} w:abstractNumId="61"><w:multiLevelType w:val="singleLevel"/>'
             f'<w:lvl w:ilvl="0"><w:start w:val="1"/><w:numFmt w:val="decimal"/>'
             f'<w:pStyle w:val="SAUSInstruction"/><w:lvlText w:val="%1."/><w:lvlJc w:val="left"/>'
             f'<w:pPr><w:ind w:left="{int(6.5 * 56.6929)}" w:hanging="{int(6.5 * 56.6929)}"/>'
             f'</w:pPr>{label}</w:lvl></w:abstractNum>')
    bullet = f'<w:abstractNum {W} w:abstractNumId="62"><w:multiLevelType w:val="hybridMultilevel"/>'
    for lvl, color in enumerate((MAROON, BLUE, GOLD)):
        bullet += (f'<w:lvl w:ilvl="{lvl}"><w:start w:val="1"/><w:numFmt w:val="bullet"/>'
                   f'<w:lvlText w:val=""/><w:lvlJc w:val="left"/><w:pPr>'
                   f'<w:ind w:left="{397 * (lvl + 1)}" w:hanging="397"/></w:pPr><w:rPr>'
                   f'<w:rFonts w:ascii="Wingdings" w:hAnsi="Wingdings" w:hint="default"/>'
                   f'<w:color w:val="{color}"/><w:sz w:val="{18 - 2 * lvl}"/></w:rPr></w:lvl>')
    bullet += "</w:abstractNum>"
    first = num.find(qn("w:num"))
    for xml in (questions, instr, bullet):
        el = parse_xml(xml)
        (first.addprevious(el) if first is not None else num.append(el))
    for i in (60, 61, 62):
        num.append(parse_xml(f'<w:num {W} w:numId="{i}"><w:abstractNumId w:val="{i}"/></w:num>'))
    for name, num_id, ilvl in (("SAUS Question", 60, 0), ("SAUS Part", 60, 1),
                               ("SAUS Instruction", 61, 0), ("List Bullet", 62, 0)):
        ppr = doc.styles[name].element.get_or_add_pPr()
        for old in ppr.findall(qn("w:numPr")):
            ppr.remove(old)
        ppr.insert(0, parse_xml(f'<w:numPr {W}><w:ilvl w:val="{ilvl}"/>'
                                f'<w:numId w:val="{num_id}"/></w:numPr>'))


# ---- The blocks of the paper -------------------------------------------------------
def heading_block(doc, department, filled):
    """Crest, university name, motto, department and the names in Sindhi and Urdu."""
    t = grid(doc, 1, 3, [24, 97, 44])
    borders(t, color="FFFFFF", size=0, inside=True)
    t.rows[0].cells[0].paragraphs[0].style = "SAUS Centred"
    t.rows[0].cells[0].paragraphs[0].paragraph_format.space_after = Pt(0)
    t.rows[0].cells[0].paragraphs[0].add_run().add_picture(
        os.path.join(ASSETS, "saus-logo.png"), width=Mm(20))

    c = t.rows[0].cells[1]
    p = c.paragraphs[0]
    p.style = "SAUS Head Name"
    add_runs(p, (UNIVERSITY, {}))
    para_motto = c.add_paragraph(style="SAUS Head Motto")
    add_runs(para_motto, (MOTTO, {}))
    office = c.add_paragraph(style="SAUS Head Office")
    fill(office, department, "Department or office", "department", filled)

    c = t.rows[0].cells[2]
    for name in ("sindhi-maroon.png", "urdu-maroon.png"):
        p = c.paragraphs[0] if name.startswith("sindhi") else c.add_paragraph()
        p.style = "SAUS Head Native"
        p.paragraph_format.space_after = Pt(1)
        p.add_run().add_picture(os.path.join(ART, name), width=Mm(38))

    p = doc.add_paragraph(style="SAUS Rule")
    p.add_run().add_picture(rule_png(TEXT_W), width=Mm(TEXT_W))


def title_block(doc, paper, session, filled):
    p = doc.add_paragraph(style="SAUS Paper Title")
    dropdown(p, "Paper", "paper", PAPERS, paper)
    p = doc.add_paragraph(style="SAUS Paper Session")
    fill(p, session, "Session", "session", filled, size=10.5, color=SLATE, font=LIGHT)


def details_block(doc, fields, filled):
    """The course and paper details, two to a row, in a hairline grid."""
    rows = (len(fields) + 1) // 2
    t = grid(doc, rows, 4, [26, 56.5, 26, 56.5])
    borders(t)
    for i, (label, value, tag) in enumerate(fields):
        cell = t.rows[i // 2].cells[(i % 2) * 2]
        cell_text(cell, [(label, dict(style="SAUSLabel"))])
        value_cell = t.rows[i // 2].cells[(i % 2) * 2 + 1]
        p = value_cell.paragraphs[0]
        p.style = "SAUS Table Text"
        if tag == "date":
            fill(p, value, "Date of the paper", tag, filled, date="")
        else:
            char = {"code": "SAUSCourseCode", "marks": "SAUSTotalMarks"}.get(tag)
            fill(p, value, label, tag, filled, style=char)
    if len(fields) % 2:                        # tidy last cell of an odd row
        t.rows[-1].cells[2].paragraphs[0].style = "SAUS Table Text"


def student_block(doc):
    t = grid(doc, 1, 3, [58, 62, 45])
    borders(t, inside=False)
    for cell, label, room in ((t.rows[0].cells[0], "Roll No.", 20),
                              (t.rows[0].cells[1], "Name", 22),
                              (t.rows[0].cells[2], "Signature", 10)):
        shade(cell, MIST)
        p = cell_text(cell, [(label, dict(style="SAUSLabel")),
                             ("  " + "_" * room, dict(color=SLATE))])
        p.paragraph_format.space_before = Pt(4)
        p.paragraph_format.space_after = Pt(4)


def instructions_block(doc, items, filled):
    t = grid(doc, 1, 1, [TEXT_W])
    borders(t, inside=False)
    cell = t.rows[0].cells[0]
    shade(cell, MIST)
    head = cell.paragraphs[0]
    head.style = "SAUS Table Text"
    head.paragraph_format.space_before = Pt(3)
    add_runs(head, ("Instructions", dict(style="SAUSLabel")))
    for text in items:
        p = cell.add_paragraph(style="SAUS Instruction")
        if filled:
            add_runs(p, (text, {}))
        else:
            fill(p, text, "Instruction", "instruction", filled, size=10.5)
    cell.paragraphs[-1].paragraph_format.space_after = Pt(4)


def examiner_grid(doc, questions):
    """For the examiner: a column per question, a total, and a signature line."""
    t = grid(doc, 1, 1, [TEXT_W])
    borders(t, inside=False)
    outer = t.rows[0].cells[0]
    head = outer.paragraphs[0]
    head.style = "SAUS Table Text"
    head.paragraph_format.space_before = Pt(3)
    add_runs(head, ("For the examiner only", dict(style="SAUSLabel")))

    inner_w = [30] + [(TEXT_W - 30 - 18 - 6) / questions] * questions + [18]
    inner = grid(outer, 2, questions + 2, inner_w)
    borders(inner)
    shade(inner.rows[0].cells[0], MIST)
    cell_text(inner.rows[0].cells[0], [("Question", dict(style="SAUSLabel"))])
    for i in range(questions):
        cell = inner.rows[0].cells[i + 1]
        shade(cell, MIST)
        cell_text(cell, [(str(i + 1), dict(size=9))], align=WD_ALIGN_PARAGRAPH.CENTER)
    shade(inner.rows[0].cells[-1], MIST)
    cell_text(inner.rows[0].cells[-1], [("Total", dict(style="SAUSLabel"))],
              align=WD_ALIGN_PARAGRAPH.CENTER)
    cell_text(inner.rows[1].cells[0], [("Marks awarded", dict(style="SAUSLabel"))])
    for cell in inner.rows[1].cells:
        cell.paragraphs[0].paragraph_format.space_before = Pt(7)
        cell.paragraphs[0].paragraph_format.space_after = Pt(7)

    sign = outer.add_paragraph(style="SAUS Table Text")
    sign.paragraph_format.tab_stops.add_tab_stop(Mm(TEXT_W - 12), WD_TAB_ALIGNMENT.RIGHT)
    add_runs(sign, ("Examiner's signature  " + "_" * 28, dict(size=8, color=SLATE)),
             ("\t", {}), ("Date  " + "_" * 20, dict(size=8, color=SLATE)))
    sign.paragraph_format.space_after = Pt(4)


def marks_table(doc, rows, filled):
    """The marks and CLO distribution, for the setter and the examination office."""
    p = doc.add_paragraph(style="SAUS Table Text")
    p.paragraph_format.space_before = Pt(6)
    add_runs(p, ("Marks and CLO distribution", dict(style="SAUSLabel")))
    t = grid(doc, len(rows) + 2, 5, [22, 63, 20, 32, 28])
    borders(t)
    heads = ("Question", "Topic", "CLO", "Level", "Marks")
    for i, h in enumerate(heads):
        shade(t.rows[0].cells[i], MIST)
        cell_text(t.rows[0].cells[i], [(h, dict(style="SAUSLabel"))],
                  align=WD_ALIGN_PARAGRAPH.CENTER if i in (0, 4) else None)
    for r, row in enumerate(rows, start=1):
        for c, value in enumerate(row):
            align = WD_ALIGN_PARAGRAPH.CENTER if c == 0 else (
                WD_ALIGN_PARAGRAPH.RIGHT if c == 4 else None)
            if filled or c == 0:
                cell_text(t.rows[r].cells[c], [(value, dict(size=10.5))], align=align)
            else:
                cell = t.rows[r].cells[c]
                p = cell.paragraphs[0]
                p.style, p.alignment = "SAUS Table Text", align
                fill(p, value, heads[c], f"mk{r}{c}", filled, size=10.5)
    total = t.rows[-1]
    for i in range(4):
        shade(total.cells[i], MIST)
    shade(total.cells[4], MIST)
    total.cells[0].merge(total.cells[3])
    cell_text(total.cells[0], [("Total", dict(style="SAUSLabel"))],
              align=WD_ALIGN_PARAGRAPH.RIGHT)
    p = total.cells[-1].paragraphs[0]
    p.style, p.alignment = "SAUS Table Text", WD_ALIGN_PARAGRAPH.RIGHT
    cached = str(sum(int(r[4]) for r in rows if r[4].isdigit())) if filled else "0"
    for r in field("=SUM(ABOVE)", cached, font=SEMIBOLD, size=10.5):
        p._p.append(r)


def paper_end(doc, text="End of question paper"):
    p = doc.add_paragraph(style="SAUS Centred")
    p.paragraph_format.space_before = Pt(10)
    p.paragraph_format.space_after = Pt(0)
    p.add_run().add_picture(rule_png(16), width=Mm(16))
    para(doc, text, "SAUS Paper End")


# ---- Head and foot -----------------------------------------------------------------
def section_setup(sec):
    sec.page_width, sec.page_height = Mm(210), Mm(297)
    sec.left_margin, sec.right_margin = Mm(LEFT_M), Mm(RIGHT_M)
    sec.top_margin, sec.bottom_margin = Mm(15), Mm(16)
    sec.header_distance, sec.footer_distance = Mm(9), Mm(9)
    sec.different_first_page_header_footer = True


def code_and_sep(cached, **fmt):
    """{ IF "{ STYLEREF "SAUS Course Code" }" = "?*" "{ STYLEREF ... } · " "" }:
    the course code and a separator, or nothing at all until one is typed --
    the same trick the letterhead uses for a letter with no reference."""
    rp = L.rpr_xml(**fmt)

    def instr(t):
        return parse_xml(f'<w:r {W}>{rp}<w:instrText xml:space="preserve">{t}</w:instrText></w:r>')

    def char(kind):
        return parse_xml(f'<w:r {W}>{rp}<w:fldChar w:fldCharType="{kind}"/></w:r>')

    def code():
        return field('STYLEREF "SAUS Course Code"', cached, **fmt)

    shown = cached + SEP if cached else ""
    out = [char("begin"), instr(' IF "')] + code() + [instr('" = "Error*" "" "')]
    out += code() + [instr(f'{SEP}" '), char("separate")]
    out += [parse_xml(f'<w:r {W}>{rp}<w:t xml:space="preserve">{shown}</w:t></w:r>'), char("end")]
    return out


def footer(hf, cached_code):
    p = hf.paragraphs[0]
    p.style = "SAUS Footer"
    border(p, "top", size=4, space=6)
    fmt = dict(size=8, color=SLATE)
    for r in code_and_sep(cached_code, **fmt):
        p._p.append(r)
    for r in field('STYLEREF "SAUS Paper Title Run"', "Examination", **fmt):
        p._p.append(r)
    add_runs(p, ("\t", {}), ("Page ", fmt))
    for r in field("PAGE", "1", **fmt):
        p._p.append(r)
    add_runs(p, (" of ", fmt))
    for r in field("NUMPAGES", "1", **fmt):
        p._p.append(r)
    add_runs(p, ("\t", {}), ("Total marks: ", fmt))
    for r in field('STYLEREF "SAUS Total Marks"', "50", **fmt):
        p._p.append(r)


def running_head(sec):
    p = sec.header.paragraphs[0]
    p.style = "SAUS Header"
    border(p, "bottom", size=4, space=4)
    p.add_run().add_picture(os.path.join(ASSETS, "saus-logo.png"), height=Mm(6))
    add_runs(p, ("  ", {}),
             (UNIVERSITY, dict(font=LIGHT, size=8, bold=True, caps=True, color=MAROON,
                               spacing=16)),
             ("\t", {}),
             ("Roll No.  " + "_" * 22, dict(size=8, color=SLATE)))


# ---- The documents -----------------------------------------------------------------
DEMO_DETAILS = [("Course code", "CSC-201", "code"),
                ("Course title", "Data Structures and Algorithms", "title"),
                ("Programme", "BS Computer Science", "programme"),
                ("Semester", "III", "semester"),
                ("Credit hours", "3 (3-0)", "credits"),
                ("Date", "16 June 2026", "date"),
                ("Time allowed", "3 hours", "duration"),
                ("Total marks", "50", "marks")]

DEMO_INSTRUCTIONS = [
    "Attempt all questions. Section A is answered on this paper; Sections B and C in "
    "the answer book provided.",
    "The marks for each question are shown at the end of the question, with the course "
    "learning outcome it assesses.",
    "Programmable calculators, mobile telephones and smart watches are not allowed in "
    "the examination hall.",
    "Write your roll number on every sheet of the answer book."]


def build(kind):
    demo = kind == "demo"
    doc = Document()
    setup_styles(doc)
    numbering(doc)
    L.setup_settings(doc)
    sec = doc.sections[0]
    section_setup(sec)
    for hf in (sec.first_page_footer, sec.footer):
        hf.is_linked_to_previous = False
        footer(hf, "CSC-201" if demo else "")
    sec.header.is_linked_to_previous = False
    running_head(sec)

    heading_block(doc, "Department of Computer Science", demo)
    title_block(doc, "Final-Term Examination" if demo else "Mid-Term Examination",
                "Spring 2026", demo)
    details = DEMO_DETAILS if demo else [
        (label, f"[{label.lower()}]", tag)
        for label, _, tag in DEMO_DETAILS]
    details_block(doc, details, demo)
    student_block(doc)
    instructions_block(doc, DEMO_INSTRUCTIONS if demo else [
        "Attempt all questions in the answer book provided.",
        "The marks for each question are shown at the end of the question.",
        "Programmable calculators and mobile telephones are not allowed."], demo)
    examiner_grid(doc, 12 if demo else 8)

    (demo_paper if demo else template_paper)(doc)
    paper_end(doc)

    doc.add_page_break()
    p = para(doc, "", "SAUS Table Text")
    add_runs(p, ("For the department's file: delete this page before the candidates' "
                 "copies are printed.", dict(size=9, color=SLATE, italic=True)))
    marks_table(doc, DEMO_MARKS if demo else [(str(i + 1), "", "", "", "") for i in range(8)],
                demo)
    normalise_all(doc)
    return doc


def run_nocaps(text, **fmt):
    """w:caps is a toggle property: a character style cannot switch off the
    capitals the paragraph style asks for, but direct formatting can."""
    r = run(text, **fmt)
    r.find(qn("w:rPr")).append(parse_xml(f'<w:caps {W} w:val="0"/>'))
    return r


def section_band(doc, title, marks_text):
    p = doc.add_paragraph(style="SAUS Section")
    add_runs(p, (title, {}), ("\t", {}))
    p._p.append(run_nocaps(marks_text, font=LIGHT, size=10.5, color=GOLD))
    return p


def question(doc, text, mark_text, clo=None, style_name="SAUS Question"):
    p = doc.add_paragraph(style=style_name)
    add_runs(p, (text, {}))
    if mark_text:
        marks(p, mark_text, clo)
    return p


def answer(doc, text):
    p = doc.add_paragraph(style="SAUS Answer")
    add_runs(p, ("Answer  ", dict(style="SAUSAnswerLabel")), (text, {}))
    return p


def indent(table, mm):
    table._tbl.tblPr.append(parse_xml(
        f'<w:tblInd {W} w:w="{int(mm * 56.6929)}" w:type="dxa"/>'))


def choices(doc, options, correct=None):
    """The options in a borderless table: they keep their columns when one of
    them wraps, which tab stops do not. The right one is marked with a tick in
    hidden text, so the paper gives nothing away and the answer key does."""
    cols = 4 if max(len(o) for o in options) <= 16 else 2
    rows = (len(options) + cols - 1) // cols
    width = (TEXT_W - 13) / cols
    t = grid(doc, rows, cols, [width] * cols)
    borders(t, color="FFFFFF", size=0, inside=True)
    indent(t, 13)
    for i, option in enumerate(options):
        cell = t.rows[i // cols].cells[i % cols]
        p = cell_text(cell, [(f"({chr(97 + i)}) {option}", dict(size=11))], "SAUS Choices")
        p.paragraph_format.left_indent = Mm(0)
        if i == correct:
            add_runs(p, (" ✔", dict(style="SAUSAnswerTick")))
    return t


def answer_lines(doc, count):
    """Ruled lines to write an answer on. Word treats a run of paragraphs with
    the same border as one box and draws only its outer edges, so each line
    also carries a "between" border -- that is the edge it draws inside the
    box, and every line appears."""
    for _ in range(count):
        p = doc.add_paragraph(style="SAUS Answer Line")
        border(p, "bottom", size=4, space=1)
        border(p, "between", size=4, space=1)


DEMO_MARKS = [("1", "Complexity", "CLO 1", "Remember", "2"),
              ("2", "Stacks and queues", "CLO 1", "Understand", "2"),
              ("3", "Trees", "CLO 1", "Understand", "2"),
              ("4", "Hashing", "CLO 2", "Apply", "2"),
              ("5", "Graphs", "CLO 2", "Apply", "2"),
              ("6", "Recursion", "CLO 2", "Apply", "5"),
              ("7", "Sorting", "CLO 2", "Analyse", "5"),
              ("8", "Complexity", "CLO 3", "Analyse", "5"),
              ("9", "Data structure choice", "CLO 3", "Evaluate", "5"),
              ("10", "Sorting", "CLO 3", "Analyse", "10"),
              ("11", "Hashing", "CLO 4", "Create", "10"),
              ("12", "Open question", "CLO 4", "Create", "+3")]


def demo_paper(doc):
    section_band(doc, "Section A: Multiple choice", "10 marks")
    question(doc, "What is the worst-case time complexity of binary search on a sorted "
                  "array of n elements?", "2 marks", "1")
    choices(doc, ["O(1)", "O(log n)", "O(n)", "O(n log n)"], correct=1)
    answer(doc, "O(log n). Every comparison halves the interval that may still hold the key.")
    question(doc, "Which structure serves its items in last-in, first-out order?",
             "2 marks", "1")
    choices(doc, ["Queue", "Stack", "Priority queue", "Circular buffer"], correct=1)
    question(doc, "A binary search tree holding n keys has height h. Searching it takes "
                  "time proportional to:", "2 marks", "1")
    choices(doc, ["n in every case", "h, which is log n only when the tree is balanced",
                  "log n in every case", "n log n in the worst case"], correct=1)
    question(doc, "Separate chaining resolves a collision by:", "2 marks", "2")
    choices(doc, ["probing the next free slot",
                  "keeping a list of the entries that share a slot",
                  "enlarging the table on every insertion",
                  "rehashing with a second function"], correct=1)
    question(doc, "Breadth-first search on an unweighted graph finds:", "2 marks", "2")
    choices(doc, ["the minimum spanning tree",
                  "the shortest path in edges from the source",
                  "the strongly connected components", "a topological order"], correct=1)

    section_band(doc, "Section B: Short questions", "20 marks")
    question(doc, "Write a recursive function that returns the height of a binary tree, "
                  "and state its running time in terms of the number of nodes.",
             "5 marks", "2")
    answer(doc, "One more than the greater of the subtrees' heights, and -1 for an empty "
                "tree. Every node is visited once: O(n) time, O(h) stack space.")
    question(doc, "Name the best, average and worst-case running times of insertion sort, "
                  "merge sort and quicksort, and say which you would choose for an array "
                  "that is already nearly sorted.", "5 marks", "2")
    question(doc, "The running time of a divide-and-conquer algorithm satisfies "
                  "T(n) = 2 T(n/2) + Θ(n), with T(1) = Θ(1). Solve the recurrence "
                  "and name an algorithm whose running time it describes.", "5 marks", "3")
    question(doc, "A campus application keeps the 815 enrolled students in memory and "
                  "looks a student up by roll number thousands of times a minute, while "
                  "enrolments are added only a few times a day. Recommend a data structure "
                  "and justify the choice in terms of the operations' costs.", "5 marks", "3")
    answer_lines(doc, 6)

    section_band(doc, "Section C: Long questions", "20 marks")
    question(doc, "Consider the array [38, 27, 43, 3, 9, 82, 10].", "10 marks", "3")
    question(doc, "Trace merge sort on it, showing the contents of the array after every "
                  "merge.", "6 marks", style_name="SAUS Part")
    question(doc, "Count the comparisons merge sort makes on this input and compare the "
                  "number with insertion sort on the same input.", "4 marks",
             style_name="SAUS Part")
    question(doc, "A hash table stores the courses a department offers, keyed by course "
                  "code.", "10 marks", "4")
    question(doc, "Write the insertion routine for separate chaining, one line of code "
                  "per line of the answer book:", "4 marks", style_name="SAUS Part")
    para(doc, "def insert(table, key, value):", "SAUS Code")
    question(doc, "The table has 16 slots and holds 40 courses. Explain what the load "
                  "factor does to the cost of a lookup, and describe one way to keep that "
                  "cost near constant as the department adds courses.", "6 marks",
             style_name="SAUS Part")
    answer_lines(doc, 4)
    question(doc, "Bonus: state one change to the hash table above that would make its "
                  "iteration order predictable, and what it would cost.", "+3 marks", "4")


def template_paper(doc):
    section_band(doc, "Section A: Short questions", "10 marks")
    p = doc.add_paragraph(style="SAUS Question")
    fill(p, "Type the question here. Apply SAUS Question and Word numbers it Q1, Q2, ...",
         "Question", "q1", False)
    marks(p, "5 marks", "1")
    p = doc.add_paragraph(style="SAUS Question")
    fill(p, "A question answered on the paper itself, with ruled lines under it.",
         "Question", "q2", False)
    marks(p, "5 marks", "2")
    answer_lines(doc, 4)

    section_band(doc, "Section B: Long questions", "20 marks")
    p = doc.add_paragraph(style="SAUS Question")
    fill(p, "A question in parts. Apply SAUS Part for (a), (b), ...", "Question", "q3", False)
    marks(p, "20 marks", "3")
    p = doc.add_paragraph(style="SAUS Part")
    fill(p, "The first part.", "Part", "q3a", False)
    marks(p, "12 marks")
    p = doc.add_paragraph(style="SAUS Part")
    fill(p, "The second part.", "Part", "q3b", False)
    marks(p, "8 marks")
    answer(doc, "The model answer. It is hidden text: it prints only when Print hidden "
                "text is turned on, which gives the answer key from this same file.")


if __name__ == "__main__":
    L.save(build("template"), os.path.join(OUT, "SAUS-exam.dotx"), True)
    L.save(build("demo"), os.path.join(OUT, "SAUS-exam-demo.docx"), False)
    for f in os.listdir(HERE):
        if f.startswith("exam-rule-") and f.endswith(".png"):
            os.remove(os.path.join(HERE, f))
    print("wrote SAUS-exam.dotx and SAUS-exam-demo.docx")
