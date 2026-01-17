import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Base class for all use cases
/// Follows Clean Architecture principles
/// T = Return type, Params = Input parameters
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Use case with no parameters
class NoParams {
  const NoParams();
}
