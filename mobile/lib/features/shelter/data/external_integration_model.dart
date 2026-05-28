class ExternalIntegration {
  final String portalBaseUrl;
  final String shelterLinkName;
  final String urlPattern;
  final String buttonHtmlTemplate;
  final String usageHint;
  final String duplicateNameHint;

  const ExternalIntegration({
    required this.portalBaseUrl,
    required this.shelterLinkName,
    required this.urlPattern,
    required this.buttonHtmlTemplate,
    required this.usageHint,
    required this.duplicateNameHint,
  });

  factory ExternalIntegration.fromJson(Map<String, dynamic> json) {
    return ExternalIntegration(
      portalBaseUrl: json['portal_base_url'] as String,
      shelterLinkName: json['shelter_link_name'] as String,
      urlPattern: json['url_pattern'] as String,
      buttonHtmlTemplate: json['button_html_template'] as String,
      usageHint: json['usage_hint'] as String,
      duplicateNameHint: json['duplicate_name_hint'] as String,
    );
  }
}
