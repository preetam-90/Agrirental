import 'package:dartz/dartz.dart';
import '../../../../core/domain/usecase.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing out current user
class SignOut implements UseCase<void, NoParams> {
  final AuthRepository repository;
  
  SignOut(this.repository);
  
  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.signOut();
  }
}
