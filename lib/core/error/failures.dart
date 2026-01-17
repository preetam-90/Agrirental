/// Failure classes for domain layer error handling
/// Using Either<Failure, Success> pattern with dartz
abstract class Failure {
  final String message;
  final String? code;
  
  const Failure(this.message, [this.code]);
}

// Authentication Failures
class AuthFailure extends Failure {
  const AuthFailure(String message, [String? code]) : super(message, code);
}

class InvalidOTPFailure extends AuthFailure {
  const InvalidOTPFailure() : super('Invalid or expired OTP', 'INVALID_OTP');
}

class UnauthorizedFailure extends AuthFailure {
  const UnauthorizedFailure() : super('Unauthorized access', 'UNAUTHORIZED');
}

// Network Failures
class NetworkFailure extends Failure {
  const NetworkFailure() : super('No internet connection', 'NETWORK_ERROR');
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message, 'SERVER_ERROR');
}

class TimeoutFailure extends Failure {
  const TimeoutFailure() : super('Request timeout', 'TIMEOUT');
}

// Data Failures
class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message, 'CACHE_ERROR');
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message, 'VALIDATION_ERROR');
}

// Location Failures
class LocationPermissionDeniedFailure extends Failure {
  const LocationPermissionDeniedFailure() 
      : super('Location permission denied', 'LOCATION_PERMISSION_DENIED');
}

class LocationServiceDisabledFailure extends Failure {
  const LocationServiceDisabledFailure() 
      : super('Location service is disabled', 'LOCATION_SERVICE_DISABLED');
}

class LocationFailure extends Failure {
  const LocationFailure(String message) : super(message, 'LOCATION_ERROR');
}

// Payment Failures
class PaymentFailure extends Failure {
  const PaymentFailure(String message, [String? code]) 
      : super(message, code ?? 'PAYMENT_ERROR');
}

class PaymentCancelledFailure extends PaymentFailure {
  const PaymentCancelledFailure() : super('Payment cancelled by user', 'PAYMENT_CANCELLED');
}

// Booking Failures
class BookingFailure extends Failure {
  const BookingFailure(String message, [String? code]) 
      : super(message, code ?? 'BOOKING_ERROR');
}

class BookingNotFoundFailure extends BookingFailure {
  const BookingNotFoundFailure() : super('Booking not found', 'BOOKING_NOT_FOUND');
}

// Generic Failures
class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'An unknown error occurred']) 
      : super(message, 'UNKNOWN_ERROR');
}
