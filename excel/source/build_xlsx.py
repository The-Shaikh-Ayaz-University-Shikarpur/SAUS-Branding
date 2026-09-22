"""Build the SAUS Excel workbook template and demo workbook.

    python build_xlsx.py

Writes, in the folder above this one:
  SAUS-workbook.xltx       a report sheet with the letterhead, styles and a table
  SAUS-workbook-demo.xlsx  key figures, an enrolment model with a chart, and the
                           delivery schedule from the slide demo

The brand lives mostly in the workbook theme: its colours are the brand
palette (accent 1 maroon, 2 royal blue, 3 gold, ...) and its fonts Fira Sans,
so Excel's own table styles, charts and cell styles come out in the brand
without further work. On top of that: a letterhead block on each sheet, named
cell styles (Home > Cell Styles) and a print footer.

Needs openpyxl and Pillow (pip install openpyxl pillow).
"""
import io
import os
import re
import zipfile

from lxml import etree
from openpyxl import Workbook
from openpyxl.chart import BarChart, Reference
from openpyxl.chart.label import DataLabelList
from openpyxl.chart.shapes import GraphicalProperties
from openpyxl.drawing.line import LineProperties
from openpyxl.drawing.image import Image as XLImage
from openpyxl.drawing.spreadsheet_drawing import AnchorMarker, OneCellAnchor
from openpyxl.drawing.xdr import XDRPositiveSize2D
from openpyxl.styles import Alignment, Border, Font, NamedStyle, PatternFill, Side
from openpyxl.utils import get_column_letter
from openpyxl.worksheet.filters import AutoFilter
from openpyxl.worksheet.table import Table, TableStyleInfo
from openpyxl.writer.theme import theme_xml
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
ASSETS = os.path.join(ROOT, "latex", "assets")
ART = os.path.join(ROOT, "powerpoint", "source", "art")
OUT = os.path.normpath(os.path.join(HERE, ".."))

MAROON, MAROON_DARK, MAROON_LIGHT = "6B2A4C", "4A1C34", "8E4166"
BLUE, GOLD, MIST = "1A1A91", "C39B3E", "F4EDF1"
INK, SLATE, RULE, GREEN, RED = "231C21", "6A626B", "D9C9D2", "2E6B4F", "B3261E"
SANS, SEMIBOLD, MEDIUM, LIGHT, SERIF = ("Fira Sans", "Fira Sans SemiBold", "Fira Sans Medium",
                                        "Fira Sans Light", "EB Garamond")
UNIVERSITY = "The Shaikh Ayaz University, Shikarpur"
MOTTO = "Revival of Educational Glory of Shikarpur"

# Column layout: a narrow gutter, the crest column, two wide text columns and
# four narrower number columns.
WIDTHS = {"A": 2.5, "B": 10, "C": 22, "D": 22, "E": 12, "F": 12, "G": 12, "H": 12}
LAST_COL = "H"
EMU_PX = 9525


def col_px(width):
    """Excel column width (characters) to pixels, for a 7 px digit."""
    return int(width * 7 + 5)


COL_X = {}
x = 0
for letter, w in WIDTHS.items():
    COL_X[letter] = x
    x += col_px(w)
RIGHT_EDGE = x                                   # right edge of column H, in px


# ---- Theme ------------------------------------------------------------------------------
def brand_theme():
    a = "{http://schemas.openxmlformats.org/drawingml/2006/main}"
    root = etree.fromstring(theme_xml.encode("utf-8"))
    root.set("name", "SAUS")
    clr = root.find(f".//{a}clrScheme")
    clr.set("name", "SAUS")
    scheme = {"dk1": INK, "lt1": "FFFFFF", "dk2": MAROON_DARK, "lt2": MIST,
              "accent1": MAROON, "accent2": BLUE, "accent3": GOLD, "accent4": GREEN,
              "accent5": RED, "accent6": SLATE, "hlink": BLUE, "folHlink": MAROON_LIGHT}
    for key, val in scheme.items():
        el = clr.find(f"{a}{key}")
        for child in list(el):
            el.remove(child)
        etree.SubElement(el, f"{a}srgbClr").set("val", val)
    fonts = root.find(f".//{a}fontScheme")
    fonts.set("name", "SAUS")
    for key, face in (("majorFont", SEMIBOLD), ("minorFont", SANS)):
        f = fonts.find(f"{a}{key}")
        f.find(f"{a}latin").set("typeface", face)
        f.find(f"{a}cs").set("typeface", "Lateef")
        for extra in f.findall(f"{a}font"):
            if extra.get("script") == "Arab":
                extra.set("typeface", "Lateef")
    return etree.tostring(root, xml_declaration=True, encoding="UTF-8", standalone=True)


# ---- Named styles ---------------------------------------------------------------------------
def add_styles(wb):
    thin_rule = Side(style="thin", color=RULE)
    styles = [
        NamedStyle("SAUS Title", font=Font(name=SEMIBOLD, size=18, color=MAROON),
                   alignment=Alignment(vertical="bottom")),
        NamedStyle("SAUS Subtitle", font=Font(name=LIGHT, size=11, color=SLATE)),
        NamedStyle("SAUS Heading", font=Font(name=SEMIBOLD, size=12, color=MAROON),
                   border=Border(bottom=thin_rule), alignment=Alignment(vertical="bottom")),
        NamedStyle("SAUS Key Figure", font=Font(name=SEMIBOLD, size=28, color=MAROON),
                   alignment=Alignment(horizontal="left", vertical="bottom"),
                   number_format="#,##0"),
        NamedStyle("SAUS Key Label", font=Font(name=SANS, size=9, color=SLATE),
                   alignment=Alignment(vertical="top")),
        NamedStyle("SAUS Label", font=Font(name=MEDIUM, size=10, color=MAROON)),
        NamedStyle("SAUS Input", font=Font(name=SANS, size=10, color=INK),
                   fill=PatternFill("solid", fgColor=MIST),
                   border=Border(left=thin_rule, right=thin_rule, top=thin_rule,
                                 bottom=thin_rule)),
        NamedStyle("SAUS Note", font=Font(name=SANS, size=9, color=SLATE),
                   alignment=Alignment(wrap_text=False)),
        NamedStyle("SAUS Total", font=Font(name=SEMIBOLD, size=10, color=INK),
                   border=Border(top=Side(style="thin", color=INK))),
    ]
    for st in styles:
        wb.add_named_style(st)


# ---- Letterhead and page setup ------------------------------------------------------------------
def anchor(img, x_px, y_px, w_px, h_px, row_tops):
    """One-cell anchor for an image whose top-left is at (x, y) px on the sheet."""
    col = max(i for i, (_, left) in enumerate(COL_X.items()) if left <= x_px)
    row = max(i for i, top in enumerate(row_tops) if top <= y_px)
    col_off = (x_px - list(COL_X.values())[col]) * EMU_PX
    row_off = (y_px - row_tops[row]) * EMU_PX
    img.anchor = OneCellAnchor(_from=AnchorMarker(col=col, colOff=col_off, row=row,
                                                  rowOff=row_off),
                               ext=XDRPositiveSize2D(w_px * EMU_PX, h_px * EMU_PX))
    return img


def gold_rule(ws, cell, width_px=70, height_px=4):
    """Short gold rule along the top edge of `cell`, as under the Beamer key figures."""
    img = Image.new("RGB", (width_px * 4, height_px * 4), "#" + GOLD)
    buf = io.BytesIO()
    img.save(buf, "PNG")
    buf.seek(0)
    pic = XLImage(buf)
    col, row = ws[cell].column - 1, ws[cell].row - 1
    pic.anchor = OneCellAnchor(_from=AnchorMarker(col=col, colOff=2 * EMU_PX, row=row, rowOff=0),
                               ext=XDRPositiveSize2D(width_px * EMU_PX, height_px * EMU_PX))
    ws.add_image(pic)


def rule_image(width_px):
    """The maroon-gold-hairline rule, drawn at 8x and shown at width_px."""
    s = 8
    w, h = width_px * s, 3 * s
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    m, g = 21 * s, 9 * s
    d.rectangle([0, 0, m - 1, h - 1], fill="#" + MAROON)
    d.rectangle([m, 0, m + g - 1, h - 1], fill="#" + GOLD)
    d.rectangle([m + g, h // 2 - s // 2, w - 1, h // 2 + s // 2 - 1], fill="#" + RULE)
    buf = io.BytesIO()
    img.save(buf, "PNG")
    buf.seek(0)
    return buf


ROW_HEIGHTS = {1: 10, 2: 19, 3: 16, 4: 14, 5: 9, 6: 5, 7: 12, 8: 28, 9: 17, 10: 14}


def letterhead(ws, department, title, subtitle):
    for letter, w in WIDTHS.items():
        ws.column_dimensions[letter].width = w
    for r, h in ROW_HEIGHTS.items():
        ws.row_dimensions[r].height = h
    row_tops = [0]
    for r in range(1, 12):
        row_tops.append(row_tops[-1] + round(ROW_HEIGHTS.get(r, 15) * 96 / 72))
    row_tops = row_tops[:-1]                       # row_tops[i] = top of row i+1

    crest_h = 74
    crest = XLImage(os.path.join(ASSETS, "saus-logo.png"))
    ws.add_image(anchor(crest, COL_X["B"], row_tops[1] - 4, round(crest_h * 384 / 484),
                        crest_h, row_tops))

    ws["C2"].value = UNIVERSITY.upper()
    ws["C2"].font = Font(name=SEMIBOLD, size=13, color=MAROON)
    ws["C3"].value = MOTTO
    ws["C3"].font = Font(name=SERIF, size=12, italic=True, color=MAROON_LIGHT)
    ws["C4"].value = (department or "Department or office").upper()
    ws["C4"].font = Font(name=MEDIUM, size=8.5, color=SLATE if department else "8C858D")
    for ref in ("C2", "C3", "C4"):
        ws[ref].alignment = Alignment(vertical="center")

    sw, sh = 150, round(150 / (3258 / 437))
    uw, uh = 132, round(132 / (2861 / 746))
    ws.add_image(anchor(XLImage(os.path.join(ART, "sindhi-maroon.png")), RIGHT_EDGE - sw,
                        row_tops[1] - 1, sw, sh, row_tops))
    ws.add_image(anchor(XLImage(os.path.join(ART, "urdu-maroon.png")), RIGHT_EDGE - uw,
                        row_tops[1] + sh + 3, uw, uh, row_tops))

    width = RIGHT_EDGE - COL_X["B"]
    ws.add_image(anchor(XLImage(rule_image(width)), COL_X["B"], row_tops[5] + 1, width, 3,
                        row_tops))

    ws["B8"].value = title
    ws["B8"].style = "SAUS Title"
    ws["B9"].value = subtitle
    ws["B9"].style = "SAUS Subtitle"


def page_setup(ws):
    ws.sheet_view.showGridLines = False
    ws.page_setup.paperSize = ws.PAPERSIZE_A4
    ws.page_setup.orientation = "portrait"
    ws.sheet_properties.pageSetUpPr.fitToPage = True
    ws.page_setup.fitToWidth = 1
    ws.page_setup.fitToHeight = 0
    ws.print_options.horizontalCentered = True
    ws.page_margins.left = ws.page_margins.right = 0.55
    ws.page_margins.top, ws.page_margins.bottom = 0.5, 0.75
    ws.page_margins.header, ws.page_margins.footer = 0.3, 0.35
    foot = ws.oddFooter
    foot.left.text, foot.left.font, foot.left.size, foot.left.color = (
        "THE SHAIKH AYAZ UNIVERSITY, SHIKARPUR", f"{MEDIUM},Regular", 7, MAROON)
    foot.center.text, foot.center.font, foot.center.size, foot.center.color = (
        "&A", f"{SANS},Regular", 7, SLATE)
    foot.right.text, foot.right.font, foot.right.size, foot.right.color = (
        "Page &P of &N", f"{SANS},Regular", 7, SLATE)


def add_table(ws, name, top_left, rows, style="TableStyleMedium2", total=None):
    """An Excel table (Insert > Table) in a theme-coloured style. total: {col: 'sum'}."""
    col0 = ws[top_left].column
    row0 = ws[top_left].row
    for r, row in enumerate(rows):
        for c, value in enumerate(row):
            ws.cell(row=row0 + r, column=col0 + c, value=value)
    last_row = row0 + len(rows) - 1 + (1 if total else 0)
    ref = f"{top_left}:{get_column_letter(col0 + len(rows[0]) - 1)}{last_row}"
    table = Table(displayName=name, ref=ref)
    table.tableStyleInfo = TableStyleInfo(name=style, showRowStripes=True)
    table._initialise_columns()
    for column, header in zip(table.tableColumns, rows[0]):   # must match the header cells
        column.name = str(header)
    if total:
        table.totalsRowCount = 1
        table.autoFilter = AutoFilter(ref=f"{top_left}:{get_column_letter(col0 + len(rows[0]) - 1)}"
                                          f"{last_row - 1}")
        table.tableColumns[0].totalsRowLabel = "Total"
        ws.cell(row=last_row, column=col0, value="Total")
        for c, func in total.items():
            column = table.tableColumns[c]
            column.totalsRowFunction = func
            ws.cell(row=last_row, column=col0 + c,
                    value=f"=SUBTOTAL(109,{name}[{column.name}])")
    ws.add_table(table)
    return table


# ---- Workbooks ------------------------------------------------------------------------------------
def new_workbook():
    wb = Workbook()
    wb.loaded_theme = brand_theme()
    add_styles(wb)
    wb.properties.creator = UNIVERSITY
    wb.properties.lastModifiedBy = UNIVERSITY
    wb.properties.subject = MOTTO
    wb.properties.description = "Generated by excel/source/build_xlsx.py"
    return wb


def build_template():
    wb = new_workbook()
    ws = wb.active
    ws.title = "Report"
    letterhead(ws, None, "Report title", "Subtitle, period or date")
    rows = [("Item", "Description", "Date", "Quantity", "Amount")] + [(None,) * 5] * 4
    add_table(ws, "ReportTable", "B11", rows, total={4: "sum"})
    for r in range(12, 17):
        ws[f"D{r}"].number_format = "d mmm yyyy"
        ws[f"E{r}"].number_format = "#,##0"
        ws[f"F{r}"].number_format = "#,##0.00"
    ws["B18"].value = "Notes and sources go here, in the SAUS Note style."
    ws["B18"].style = "SAUS Note"
    page_setup(ws)
    wb.properties.title = "The Shaikh Ayaz University, Shikarpur — workbook"
    wb.template = True
    return wb


def build_demo():
    wb = new_workbook()
    dept = "Department of Computer Science"

    ws = wb.active
    ws.title = "Overview"
    letterhead(ws, dept, "The university at a glance",
               "Established to revive the educational glory of Shikarpur")
    ws.row_dimensions[11].height = 40
    ws.row_dimensions[12].height = 22
    for col, (value, label) in zip("BDF", ((7, "Degree programmes"), (2, "Faculties"),
                                           (815, "Students enrolled"))):
        ws[f"{col}11"].value = value
        ws[f"{col}11"].style = "SAUS Key Figure"
        ws[f"{col}12"].value = label
        ws[f"{col}12"].style = "SAUS Key Label"
        ws[f"{col}12"].alignment = Alignment(vertical="bottom")
        gold_rule(ws, f"{col}12")

    ws["B14"].value = "Illustrative enrolment model"
    ws["B14"].style = "SAUS Heading"
    for col in "CDEFGH":
        ws[f"{col}14"].style = "SAUS Heading"
    ws.row_dimensions[14].height = 22
    ws["B15"].value = ("Students in year t = 815 × e^(r · t): from 815 today to an "
                       "illustrative 1,500 in three years. Change the shaded inputs.")
    ws["B15"].style = "SAUS Note"
    inputs = (("Students today", 815, "#,##0"), ("Target in 3 years", 1500, "#,##0"),
              ("Growth rate r", "=LN(D18/D17)/3", "0.0%"))
    for i, (label, value, fmt) in enumerate(inputs):
        r = 17 + i
        ws[f"B{r}"].value = label
        ws[f"B{r}"].style = "SAUS Label"
        ws[f"D{r}"].value = value
        ws[f"D{r}"].style = "SAUS Input" if i < 2 else "SAUS Total"
        ws[f"D{r}"].number_format = fmt
    rows = [("Year", "Students")] + [(y, f"=ROUND($D$17*EXP($D$19*(B{22 + i}-2026)),0)")
                                               for i, y in enumerate(range(2026, 2030))]
    add_table(ws, "Projection", "B21", rows)
    for r in range(22, 26):
        ws[f"C{r}"].number_format = "#,##0"

    chart = BarChart()
    chart.type = "col"
    chart.title = "Projected enrolment"
    chart.y_axis.title = None
    chart.y_axis.numFmt = "#,##0"
    chart.y_axis.majorGridlines = None
    chart.x_axis.delete = False
    chart.y_axis.delete = True
    chart.legend = None
    chart.gapWidth = 60
    chart.add_data(Reference(ws, min_col=3, min_row=21, max_row=25), titles_from_data=True)
    chart.set_categories(Reference(ws, min_col=2, min_row=22, max_row=25))
    chart.varyColors = False
    chart.roundedCorners = False
    chart.graphical_properties = GraphicalProperties(ln=LineProperties(noFill=True))
    chart.dataLabels = DataLabelList()
    chart.dataLabels.showVal = True
    for flag in ("showSerName", "showCatName", "showLegendKey", "showPercent"):
        setattr(chart.dataLabels, flag, False)
    chart.dataLabels.position = "outEnd"
    series = chart.series[0]
    series.graphicalProperties.solidFill = MAROON
    series.graphicalProperties.line.noFill = True
    chart.height, chart.width = 6.2, 9.3
    ws.add_chart(chart, "E17")
    page_setup(ws)

    ws = wb.create_sheet("Schedule")
    letterhead(ws, dept, "Delivery schedule", "Digital transformation of campus services, "
                                              "2026 to 2029 (indicative)")
    rows = [("Year", "Workstream", "Owner"),
            # straight apostrophe: Excel's own PDF export falls back to Calibri for ’
            (2026, "Admissions portal", "Registrar's Office"),
            (2027, "Learning management", "Faculty of Education"),
            (2027, "Network refresh", "IT Directorate"),
            (2028, "Digital repository", "Central Library")]
    ws.column_dimensions["B"].width = WIDTHS["B"]
    add_table(ws, "ScheduleTable", "B11", rows, style="TableStyleLight9")
    ws["B17"].value = "Table 1  |  Indicative delivery schedule."
    ws["B17"].style = "SAUS Note"
    page_setup(ws)
    wb.properties.title = "SAUS workbook demo"
    return wb


# ---- Default font --------------------------------------------------------------------------------------
def save(wb, path):
    """Save, then make Fira Sans 10 pt the workbook's default (Normal) font,
    which openpyxl always writes as Calibri 11."""
    buf = io.BytesIO()
    wb.save(buf)
    buf.seek(0)
    with zipfile.ZipFile(buf) as src, zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED) as dst:
        for item in src.infolist():
            data = src.read(item.filename)
            if item.filename == "xl/styles.xml":
                text = data.decode("utf-8")
                text = re.sub(r"(<fonts[^>]*>\s*<font>)(.*?)(</font>)",
                              lambda m: m.group(1) + f'<sz val="10"/><color theme="1"/>'
                              f'<name val="{SANS}"/><family val="2"/><scheme val="minor"/>'
                              + m.group(3), text, count=1, flags=re.S)
                data = text.encode("utf-8")
            dst.writestr(item, data)


if __name__ == "__main__":
    save(build_template(), os.path.join(OUT, "SAUS-workbook.xltx"))
    save(build_demo(), os.path.join(OUT, "SAUS-workbook-demo.xlsx"))
    print("wrote SAUS-workbook.xltx and SAUS-workbook-demo.xlsx")
