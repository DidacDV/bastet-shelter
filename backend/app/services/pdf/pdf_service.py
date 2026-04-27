import io
import urllib.request

from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib.units import cm
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, Image

from app.models.adoption.adoptant import Adoptant
from app.models.animal.animal import Animal


def get_image_from_url(url: str, width: float = 6*cm, height: float = 6*cm) -> Image:
    with urllib.request.urlopen(url) as response:
        img_bytes = io.BytesIO(response.read())
    return Image(img_bytes, width=width, height=height)

def generate_contract_pdf(animal: Animal, adoptant: Adoptant) -> bytes:
    buffer = io.BytesIO()
    doc = SimpleDocTemplate(buffer, pagesize=A4)
    styles = getSampleStyleSheet()
    story = []


    story.append(Paragraph("ADOPTION CONTRACT", styles['Title']))
    story.append(Spacer(1, 20))

    animal_img = get_image_from_url(animal.images[0].url, width=5*cm, height=5*cm)
    animal_info = [
        Paragraph(f"<b>Name:</b> {animal.name}", styles['Normal']),
        Paragraph(f"<b>Breed:</b> {animal.breed}", styles['Normal']),
        Paragraph(f"<b>Type:</b> {animal.animal_type}", styles['Normal']),
    ]
    table = Table([[animal_img, animal_info]], colWidths=[6*cm, 10*cm])
    story.append(table)

    story.append(Spacer(1, 20))
    story.append(Paragraph(f"Adoptant: {adoptant.name}", styles['Normal']))
    story.append(Paragraph(f"Email: {adoptant.email}", styles['Normal']))

    doc.build(story)
    return buffer.getvalue()