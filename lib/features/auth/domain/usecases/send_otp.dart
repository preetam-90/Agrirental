import 'package:dartz/dartz.dart';
import '../../../../core/domain/usecase.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

/// Use case for sending OTP to phone number
class SendOTP implements UseCase<void, SendOTPParams> {
  final AuthRepository repository;
  
  SendOTP(this.repository);
  
  @override
  Future<Either<Failure, void>> call(SendOTPParams params) async {
    return await repository.sendOTP(params.phoneNumber);
  }
}

/// Parameters for SendOTP use case
class SendOTPParams {
  final String phoneNumber;
  
  SendOTPParams({required this.phoneNumber});
}
