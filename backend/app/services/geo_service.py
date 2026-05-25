import httpx
from datetime import datetime, timedelta, timezone
from sqlalchemy.orm import Session
from app.models.province import Province
from app.core.config import settings
import logging

logger = logging.getLogger(__name__)

class GeoService:
    @staticmethod
    def get_provinces(db: Session) -> list[dict]:
        """returns a list of formatted dictionaries ready for the response schema"""
        provinces = db.query(Province.name, Province.id).order_by(Province.name).all()
        return [{"name": p.name, "id": p.id} for p in provinces]

    def ensure_aware(dt: datetime) -> datetime:
        return dt if dt.tzinfo else dt.replace(tzinfo=timezone.utc)

    @staticmethod
    async def fetch_and_update_provinces(db: Session, key: str):
        url = f"https://apiv1.geoapi.es/provincias?type=JSON&version=2025.07&key={key}"
        async with httpx.AsyncClient() as client:
            try:
                response = await client.get(url)
                response.raise_for_status()
                data = response.json()

                provinces_data = data.get("data", [])
                for p in provinces_data:
                    cpro = p.get("CPRO")
                    name = p.get("PRO")
                    ccom = p.get("CCOM")

                    if not cpro or not name:
                        continue

                    province = db.query(Province).filter(Province.id == cpro).first()
                    if province:
                        province.name = name
                        province.community_code = ccom
                    else:
                        new_province = Province(id=cpro, name=name, community_code=ccom)
                        db.add(new_province)

                db.commit()
                logger.info("Provinces updated successfully")
            except Exception as e:
                logger.error(f"Error fetching provinces: {e}")
                db.rollback()

    @staticmethod
    async def run_periodic_update(db: Session):
        first_province = db.query(Province).first()
        needs_update = (
                db.query(Province).count() == 0
                or first_province is None
                or GeoService.ensure_aware(first_province.last_updated)
                < datetime.now(timezone.utc) - timedelta(days=365)
        )

        if needs_update:
            api_key = getattr(settings, "GEOAPI_KEY", None)
            if api_key:
                logger.info("Starting periodic provinces update...")
                await GeoService.fetch_and_update_provinces(db, api_key)
            else:
                logger.error("GEOAPI_KEY not found")
        else:
            logger.info("Provinces already up to date")