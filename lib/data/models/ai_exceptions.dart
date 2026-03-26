/// Thrown when a network connection cannot be established.
class NetworkException implements Exception {
  const NetworkException([this.message = 'Network error']);
  final String message;
  @override
  String toString() => 'NetworkException: $message';
}

/// Thrown when the OpenAI API key is invalid (HTTP 401).
class InvalidKeyException implements Exception {
  const InvalidKeyException([this.message = 'Invalid API key']);
  final String message;
  @override
  String toString() => 'InvalidKeyException: $message';
}

/// Thrown when the OpenAI quota is exceeded (HTTP 429).
class QuotaExceededException implements Exception {
  const QuotaExceededException([this.message = 'Quota exceeded']);
  final String message;
  @override
  String toString() => 'QuotaExceededException: $message';
}

/// Thrown for all other OpenAI API errors.
class AIServiceException implements Exception {
  const AIServiceException([this.message = 'AI service error']);
  final String message;
  @override
  String toString() => 'AIServiceException: $message';
}
