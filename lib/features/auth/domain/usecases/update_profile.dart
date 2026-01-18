import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/domain/usecase.dart';
import '../repositories/auth_repository.dart';

class UpdateProfile implements UseCase<void, UpdateProfileParams> {
  final AuthRepository repository;

  UpdateProfile(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(
      fullName: params.fullName,
      addressText: params.addressText,
      latitude: params.latitude,
      longitude: params.longitude,
    );
  }
}

class UpdateProfileParams {
  final String fullName;
  final String addressText;
  final double latitude;
  final double longitude;

  UpdateProfileParams({
    required this.fullName,
    required this.addressText,
    required this.latitude,
    required this.longitude,
  });
}
