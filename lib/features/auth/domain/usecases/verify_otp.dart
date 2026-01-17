import 'package:dartz/dartz.dart';
import '../../../../core/domain/usecase.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for verifying OTP and logging in user
class VerifyOTP implements UseCase<User, VerifyOTPParams> {
  final AuthRepository repository;
  
  VerifyOTP(this.repository);
  
  @override
  Future<Either<Failure, User>> call(VerifyOTPParams params) async {
    return await repository.verifyOTP(
      phoneNumber: params.phoneNumber,
      otpCode: params.otpCode,
    );
  }
}

/// Parameters for VerifyOTP use case
class VerifyOTPParams {
  final String phoneNumber;
  final String otpCode;
  
  VerifyOTPParams({
    required this.phoneNumber,
    required this.otpCode,
  });
}
