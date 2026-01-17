import 'package:dartz/dartz.dart';
import '../../../../core/domain/usecase.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogle implements UseCase<bool, NoParams> {
  final AuthRepository repository;
  
  SignInWithGoogle(this.repository);
  
  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.signInWithGoogle();
  }
}
