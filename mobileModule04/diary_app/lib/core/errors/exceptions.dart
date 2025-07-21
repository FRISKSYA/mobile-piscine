class AppServerException implements Exception {
  final String? message;
  
  const AppServerException([this.message]);
}

class AppCacheException implements Exception {
  final String? message;
  
  const AppCacheException([this.message]);
}

class AppAuthException implements Exception {
  final String? message;
  
  const AppAuthException([this.message]);
}

class AppValidationException implements Exception {
  final String? message;
  
  const AppValidationException([this.message]);
}