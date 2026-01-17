/// Exceptions for data layer
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  
  ServerException(this.message, [this.statusCode]);
  
  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

class CacheException implements Exception {
  final String message;
  
  CacheException(this.message);
  
  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;
  
  NetworkException([this.message = 'No internet connection']);
  
  @override
  String toString() => 'NetworkException: $message';
}

class AuthException implements Exception {
  final String message;
  final String? code;
  
  AuthException(this.message, [this.code]);
  
  @override
  String toString() => 'AuthException: $message (Code: $code)';
}

class LocationException implements Exception {
  final String message;
  
  LocationException(this.message);
  
  @override
  String toString() => 'LocationException: $message';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, String>? errors;
  
  ValidationException(this.message, [this.errors]);
  
  @override
  String toString() => 'ValidationException: $message';
}

class PaymentException implements Exception {
  final String message;
  final String? code;
  
  PaymentException(this.message, [this.code]);
  
  @override
  String toString() => 'PaymentException: $message (Code: $code)';
}
