import 'package:dartz/dartz.dart';
import '../../../../core/domain/usecase.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUpWithEmail implements UseCase<User, SignUpWithEmailParams> {
  final AuthRepository repository;
  
  SignUpWithEmail(this.repository);
  
  @override
  Future<Either<Failure, User>> call(SignUpWithEmailParams params) async {
    return await repository.signUpWithEmail(
      email: params.email,
      password: params.password,
      fullName: params.fullName,
    );
  }
}

class SignUpWithEmailParams {
  final String email;
  final String password;
  final String fullName;
  
  SignUpWithEmailParams({
    required this.email,
    required this.password,
    required this.fullName,
  });
}
