import 'package:dartz/dartz.dart';
import '../../../../core/domain/usecase.dart';
import '../../../../core/error/failures.dart';
import '../entities/equipment.dart';
import '../repositories/equipment_repository.dart';

/// Use case for getting current user's equipment listings
class GetMyEquipment implements UseCase<List<Equipment>, NoParams> {
  final EquipmentRepository repository;
  
  GetMyEquipment(this.repository);
  
  @override
  Future<Either<Failure, List<Equipment>>> call(NoParams params) async {
    return await repository.getMyEquipment();
  }
}
