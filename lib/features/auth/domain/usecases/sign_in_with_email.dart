import 'package:dartz/dartz.dart';
import '../../../../core/domain/usecase.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmail implements UseCase<User, SignInWithEmailParams> {
  final AuthRepository repository;
  
  SignInWithEmail(this.repository);
  
  @override
  Future<Either<Failure, User>> call(SignInWithEmailParams params) async {
    return await repository.signInWithEmail(
      email: params.email,
      password: params.password,
    );
  }
}

class SignInWithEmailParams {
  final String email;
  final String password;
  
  SignInWithEmailParams({required this.email, required this.password});
}
