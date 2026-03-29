import pytest
from unittest.mock import MagicMock, AsyncMock, patch
from datetime import datetime, timedelta
from app.services.geo_service import GeoService

@pytest.mark.asyncio
async def test_get_provinces():
    db = MagicMock()
    query_mock = db.query.return_value
    order_mock = query_mock.order_by.return_value
    order_mock.all.return_value = [("Barcelona", "08"), ("Madrid", "28")]

    result = GeoService.get_provinces(db)

    assert len(result) == 2
    assert result[0] == ("Barcelona", "08")
    db.query.assert_called_once()

@pytest.mark.asyncio
async def test_fetch_and_update_provinces_success():
    db = MagicMock()
    key = "test_key"
    mock_response_data = {
        "data": [
            {"CPRO": "08", "PRO": "Barcelona", "CCOM": "09"},
            {"CPRO": "28", "PRO": "Madrid", "CCOM": "13"}
        ]
    }

    with patch("httpx.AsyncClient.get") as mock_get:
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = mock_response_data
        mock_response.raise_for_status = MagicMock()
        mock_get.return_value = mock_response

        db.query.return_value.filter.return_value.first.return_value = None

        await GeoService.fetch_and_update_provinces(db, key)

        assert db.add.call_count == 2
        db.commit.assert_called_once()

@pytest.mark.asyncio
async def test_run_periodic_update_needs_update():
    db = MagicMock()
    db.query.return_value.count.return_value = 0

    with patch("app.services.geo_service.GeoService.fetch_and_update_provinces", new_callable=AsyncMock) as mock_fetch:
        with patch("app.services.geo_service.settings") as mock_settings:
            mock_settings.GEOAPI_KEY = "test_key"
            await GeoService.run_periodic_update(db)
            mock_fetch.assert_called_once_with(db, "test_key")

@pytest.mark.asyncio
async def test_run_periodic_update_up_to_date():
    db = MagicMock()
    db.query.return_value.count.return_value = 52
    mock_province = MagicMock()
    mock_province.last_updated = datetime.now()
    db.query.return_value.first.return_value = mock_province

    with patch("app.services.geo_service.GeoService.fetch_and_update_provinces", new_callable=AsyncMock) as mock_fetch:
        await GeoService.run_periodic_update(db)
        mock_fetch.assert_not_called()

@pytest.mark.asyncio
async def test_fetch_and_update_provinces_invalid_data():
    db = MagicMock()
    mock_response_data = {
        "data": [
            {"CPRO": None, "PRO": "Barcelona", "CCOM": "09"},
            {"CPRO": "28", "PRO": None, "CCOM": "13"}
        ]
    }
    with patch("httpx.AsyncClient.get") as mock_get:
        mock_response = MagicMock()
        mock_response.json.return_value = mock_response_data
        mock_get.return_value = mock_response
        await GeoService.fetch_and_update_provinces(db, "key")
        db.add.assert_not_called()

@pytest.mark.asyncio
async def test_fetch_and_update_provinces_updates_existing():
    db = MagicMock()
    mock_response_data = {
        "data": [{"CPRO": "08", "PRO": "Barcelona New", "CCOM": "09"}]
    }
    mock_province = MagicMock()
    db.query.return_value.filter.return_value.first.return_value = mock_province
    with patch("httpx.AsyncClient.get") as mock_get:
        mock_response = MagicMock()
        mock_response.json.return_value = mock_response_data
        mock_get.return_value = mock_response
        await GeoService.fetch_and_update_provinces(db, "key")
        assert mock_province.name == "Barcelona New"
        db.commit.assert_called_once()

@pytest.mark.asyncio
async def test_fetch_and_update_provinces_error():
    db = MagicMock()
    with patch("httpx.AsyncClient.get", side_effect=Exception("API Error")):
        await GeoService.fetch_and_update_provinces(db, "key")
        db.rollback.assert_called_once()

@pytest.mark.asyncio
async def test_run_periodic_update_no_key():
    db = MagicMock()
    db.query.return_value.count.return_value = 0
    with patch("app.services.geo_service.settings", spec=[]):
        await GeoService.run_periodic_update(db)