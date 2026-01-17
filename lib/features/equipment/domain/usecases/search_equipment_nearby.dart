import 'package:dartz/dartz.dart';
import '../../../../core/domain/usecase.dart';
import '../../../../core/error/failures.dart';
import '../entities/equipment.dart';
import '../repositories/equipment_repository.dart';

/// Use case for searching equipment nearby using geospatial queries
class SearchEquipmentNearby implements UseCase<List<Equipment>, SearchEquipmentParams> {
  final EquipmentRepository repository;
  
  SearchEquipmentNearby(this.repository);
  
  @override
  Future<Either<Failure, List<Equipment>>> call(SearchEquipmentParams params) async {
    return await repository.searchNearby(
      farmerLatitude: params.farmerLatitude,
      farmerLongitude: params.farmerLongitude,
      equipmentType: params.equipmentType,
      minRating: params.minRating,
      maxHourlyRate: params.maxHourlyRate,
    );
  }
}

/// Parameters for searching equipment
class SearchEquipmentParams {
  final double farmerLatitude;
  final double farmerLongitude;
  final EquipmentType? equipmentType;
  final double? minRating;
  final double? maxHourlyRate;
  
  SearchEquipmentParams({
    required this.farmerLatitude,
    required this.farmerLongitude,
    this.equipmentType,
    this.minRating,
    this.maxHourlyRate,
  });
}
