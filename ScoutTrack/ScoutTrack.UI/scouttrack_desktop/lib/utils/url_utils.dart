class UrlUtils {
  static const String defaultBaseUrl = "http://localhost:5164/";

  static String buildImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) {
      return '';
    }

    if (relativePath.startsWith('http')) {
      return relativePath;
    }

    final baseUrl = const String.fromEnvironment(
      "BASE_URL",
      defaultValue: defaultBaseUrl,
    );

    final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    final cleanRelativePath = relativePath.startsWith('/')
        ? relativePath.substring(1)
        : relativePath;

    return '$cleanBaseUrl$cleanRelativePath';
  }
}
