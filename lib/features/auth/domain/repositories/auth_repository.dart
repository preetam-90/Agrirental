import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

/// Authentication repository interface
/// Defines contract for authentication operations
abstract class AuthRepository {
  /// Send OTP to phone number
  /// Returns Either<Failure, void> - success means OTP sent
  Future<Either<Failure, void>> sendOTP(String phoneNumber);
  
  /// Verify OTP and create/login user session
  /// Returns Either<Failure, User> - authenticated user on success
  Future<Either<Failure, User>> verifyOTP({
    required String phoneNumber,
    required String otpCode,
  });

  /// Sign in with Email and Password
  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign up with Email and Password
  Future<Either<Failure, User>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  });

  /// Sign in with Google
  Future<Either<Failure, bool>> signInWithGoogle();
  
  /// Get current authenticated user
  /// Returns Either<Failure, User> or UnauthorizedFailure if not logged in
  Future<Either<Failure, User>> getCurrentUser();
  
  /// Sign out current user
  Future<Either<Failure, void>> signOut();
  
  /// Update user profile
  Future<Either<Failure, void>> updateProfile({
    required String fullName,
    required String addressText,
    required double latitude,
    required    double longitude,
  });
  
  /// Update user current role
  Future<Either<Failure, void>> updateProfileRole(UserRole role);
  
  /// Check if user is authenticated
  Future<bool> isAuthenticated();
}
