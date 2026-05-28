from app.localization import normalize_locale, translate


def test_normalize_locale_defaults_to_english():
    assert normalize_locale(None) == "en"
    assert normalize_locale("fr-FR") == "en"


def test_normalize_locale_supports_project_languages():
    assert normalize_locale("ca-ES") == "ca"
    assert normalize_locale("es") == "es"


def test_translate_returns_localized_message():
    message = translate("shelter.external_integration.usage_hint", "ca")
    assert "nom de l'animal" in message


def test_translate_falls_back_to_english():
    message = translate("shelter.external_integration.usage_hint", "xx")
    assert "animal's name" in message
