import io
import urllib.request
from datetime import date

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_JUSTIFY, TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import cm
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, Image,
    HRFlowable, KeepTogether,
)

PAGE_W, PAGE_H = A4
MARGIN = 2.2 * cm

DARK       = colors.HexColor("#1a1a2e")
ACCENT     = colors.HexColor("#2d6a4f")
ACCENT_LT  = colors.HexColor("#d8f3dc")
RULE       = colors.HexColor("#b7e4c7")
GREY       = colors.HexColor("#6c757d")
WHITE      = colors.white


def _styles():
    base = getSampleStyleSheet()

    def add(name, **kw):
        base.add(ParagraphStyle(name=name, **kw))

    add("ContractTitle",
        fontName="Helvetica-Bold", fontSize=20, textColor=WHITE,
        alignment=TA_CENTER, spaceAfter=4)

    add("ContractSubtitle",
        fontName="Helvetica", fontSize=10, textColor=RULE,
        alignment=TA_CENTER, spaceAfter=0)

    add("SectionHeader",
        fontName="Helvetica-Bold", fontSize=11, textColor=WHITE,
        backColor=ACCENT, alignment=TA_LEFT,
        leftIndent=8, rightIndent=8,
        spaceBefore=14, spaceAfter=6,
        borderPadding=(4, 8, 4, 8))

    add("FieldLabel",
        fontName="Helvetica-Bold", fontSize=9, textColor=DARK)

    add("FieldValue",
        fontName="Helvetica", fontSize=9, textColor=DARK)

    add("ClauseNum",
        fontName="Helvetica-Bold", fontSize=9, textColor=ACCENT)

    add("ClauseBody",
        fontName="Helvetica", fontSize=9, textColor=DARK,
        leading=14, alignment=TA_JUSTIFY,
        leftIndent=14, spaceAfter=6)

    add("SmallGrey",
        fontName="Helvetica-Oblique", fontSize=8, textColor=GREY,
        alignment=TA_CENTER)

    add("SignLabel",
        fontName="Helvetica-Bold", fontSize=9, textColor=DARK,
        alignment=TA_CENTER)

    add("AnimalName",
        fontName="Helvetica-Bold", fontSize=13, textColor=DARK)

    return base


def _header_banner(styles):
    """Dark green banner with title."""
    data = [[
        Paragraph("ADOPTION CONTRACT", styles["ContractTitle"]),
    ]]
    t = Table(data, colWidths=[PAGE_W - 2 * MARGIN])
    t.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), DARK),
        ("TOPPADDING",    (0, 0), (-1, -1), 14),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
        ("LEFTPADDING",   (0, 0), (-1, -1), 12),
        ("RIGHTPADDING",  (0, 0), (-1, -1), 12),
        ("ROUNDEDCORNERS", [6]),
    ]))
    return t


def _section(title, styles):
    return Paragraph(f"&nbsp; {title.upper()}", styles["SectionHeader"])


def _info_table(rows, styles, col_w=(4.5 * cm, 10.5 * cm)):
    """Two-column label/value grid."""
    data = [
        [Paragraph(label, styles["FieldLabel"]),
         Paragraph(str(value), styles["FieldValue"])]
        for label, value in rows
    ]
    t = Table(data, colWidths=list(col_w))
    t.setStyle(TableStyle([
        ("VALIGN",        (0, 0), (-1, -1), "TOP"),
        ("TOPPADDING",    (0, 0), (-1, -1), 3),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 3),
        ("LEFTPADDING",   (0, 0), (-1, -1), 0),
        ("RIGHTPADDING",  (0, 0), (-1, -1), 0),
        ("LINEBELOW", (0, 0), (-1, -2), 0.25, RULE),
    ]))
    return t


def _get_image(url: str, width=5 * cm, height=5 * cm) -> Image | None:
    try:
        with urllib.request.urlopen(url, timeout=8) as r:
            data = io.BytesIO(r.read())
        return Image(data, width=width, height=height)
    except Exception:
        return None


def _clauses(animal_name: str, styles):
    """Official adoption clauses based on Protectora BCN standards."""
    items = [
        ("CLAUSE 1 – Care and Welfare",
         f"The adoptant commits to providing <b>{animal_name}</b> with adequate food, fresh water, "
         "shelter, and all necessary veterinary care throughout the animal's life. "
         "The animal must live inside the home as a family member, never chained or confined outdoors permanently."),

        ("CLAUSE 2 – Veterinary Follow-up",
         f"The adoptant agrees to keep {animal_name}'s vaccinations, deworming, and annual check-ups "
         "up to date. Any illness or injury must be attended to by a licensed veterinarian. "
         "The shelter must be informed of any serious health issue within 15 days."),

        ("CLAUSE 3 – Sterilisation",
         f"If {animal_name} has not yet been sterilised at the time of this adoption, "
         "the adoptant undertakes to have the procedure carried out before the animal reaches "
         "6 months of age, or within the timeframe indicated by the shelter's veterinarian."),

        ("CLAUSE 4 – Microchip & Registration",
         "The adoptant must keep the microchip registration up to date with their current contact "
         "details at all times and register the animal in the municipal census of the corresponding "
         "town hall within 30 days of signing this contract."),

        ("CLAUSE 5 – Prohibition of Transfer",
         f"The adoptant may not give, sell, lend, or otherwise transfer {animal_name} to a third "
         "party without the prior written consent of the shelter. If circumstances arise that make "
         "continued care impossible, the animal must be returned to the shelter."),

        ("CLAUSE 6 – Right of Return",
         "The shelter reserves the right to reclaim the animal at any time if it reasonably "
         "suspects that the conditions of this contract are not being met, or if the animal's "
         "welfare is at risk. The adoptant agrees to allow post-adoption visits or follow-up "
         "contact as requested by the shelter."),

        ("CLAUSE 7 – Prohibited Uses",
         f"The adoptant expressly prohibits using {animal_name} for hunting, guard duty, "
         "experimental purposes, shows, films, or any activity that causes physical or "
         "psychological suffering. The animal may not participate in dog fights or any illegal activity."),

        ("CLAUSE 8 – Breach & Liability",
         "Non-compliance with any clause of this contract may result in the immediate recovery "
         "of the animal by the shelter, as well as the pursuit of civil or criminal liability "
         "as applicable under current animal welfare legislation."),
    ]

    elements = []
    for title, body in items:
        elements.append(KeepTogether([
            Paragraph(title, styles["ClauseNum"]),
            Paragraph(body, styles["ClauseBody"]),
        ]))
    return elements


def generate_contract_pdf(animal, adoptant) -> bytes:
    buffer = io.BytesIO()
    doc = SimpleDocTemplate(
        buffer, pagesize=A4,
        leftMargin=MARGIN, rightMargin=MARGIN,
        topMargin=MARGIN, bottomMargin=MARGIN,
    )
    styles = _styles()
    story = []

    story.append(_header_banner(styles))
    story.append(Spacer(1, 6))
    story.append(Paragraph(
        f"Issued on {date.today().strftime('%d %B %Y')}",
        styles["SmallGrey"],
    ))
    story.append(Spacer(1, 14))

    story.append(_section("Animal Information", styles))
    story.append(Spacer(1, 6))

    img = _get_image(animal.images[0].url) if animal.images else None

    animal_rows = [
        ("Name",        animal.name),
        ("Species",     animal.animal_type.value.capitalize()),
        ("Breed",       animal.breed),
        ("Age",         f"{animal.age} year(s)"),
        ("Description", animal.description),
    ]
    if animal.arrival_date:
        animal_rows.append(("At shelter since", animal.arrival_date.strftime("%d/%m/%Y")))

    info_table = _info_table(animal_rows, styles, col_w=(4 * cm, 8 * cm if img else 13 * cm))

    if img:
        img.hAlign = "CENTER"
        combined = Table(
            [[info_table, img]],
            colWidths=[12 * cm, 5.5 * cm],
        )
        combined.setStyle(TableStyle([
            ("VALIGN", (0, 0), (-1, -1), "TOP"),
            ("LEFTPADDING",  (0, 0), (-1, -1), 0),
            ("RIGHTPADDING", (0, 0), (-1, -1), 0),
        ]))
        story.append(combined)
    else:
        story.append(info_table)

    story.append(Spacer(1, 14))

    story.append(_section("Adoptant Information", styles))
    story.append(Spacer(1, 6))
    story.append(_info_table([
        ("Full name", adoptant.name),
        ("Email",     adoptant.email),
    ], styles))
    story.append(Spacer(1, 14))


    story.append(_section("Terms & Conditions", styles))
    story.append(Spacer(1, 8))
    story.extend(_clauses(animal.name, styles))
    story.append(Spacer(1, 16))

    story.append(HRFlowable(width="100%", thickness=0.5, color=RULE))
    story.append(Spacer(1, 14))

    sig_data = [
        [
            Paragraph("Shelter Representative", styles["SignLabel"]),
            Paragraph("Adoptant", styles["SignLabel"]),
        ],
        [
            Paragraph("<br/><br/>________________________________<br/>Signature &amp; stamp", styles["SmallGrey"]),
            Paragraph("<br/><br/>________________________________<br/>Signature", styles["SmallGrey"]),
        ],
        [
            Paragraph(f"Date: _____ / _____ / _______", styles["SmallGrey"]),
            Paragraph(f"Date: _____ / _____ / _______", styles["SmallGrey"]),
        ],
    ]
    sig_table = Table(sig_data, colWidths=[PAGE_W / 2 - MARGIN, PAGE_W / 2 - MARGIN])
    sig_table.setStyle(TableStyle([
        ("ALIGN",   (0, 0), (-1, -1), "CENTER"),
        ("VALIGN",  (0, 0), (-1, -1), "TOP"),
        ("TOPPADDING",    (0, 0), (-1, -1), 4),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
    ]))
    story.append(sig_table)

    story.append(Spacer(1, 20))
    story.append(Paragraph(
        "Both parties declare that they have read, understood, and agree to all the terms "
        "set out in this contract, which is signed in duplicate, each party retaining one copy.",
        styles["SmallGrey"],
    ))

    doc.build(story)
    return buffer.getvalue()