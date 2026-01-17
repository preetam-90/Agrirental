import 'package:dartz/dartz.dart';
import '../../../../core/domain/usecase.dart';
import '../../../../core/error/failures.dart';
import '../entities/equipment.dart';
import '../repositories/equipment_repository.dart';

/// Use case for creating new equipment listing
class CreateEquipment implements UseCase<Equipment, CreateEquipmentParams> {
  final EquipmentRepository repository;
  
  CreateEquipment(this.repository);
  
  @override
  Future<Either<Failure, Equipment>> call(CreateEquipmentParams params) async {
    return await repository.createEquipment(
      equipmentType: params.equipmentType,
      title: params.title,
      description: params.description,
      brand: params.brand,
      model: params.model,
      manufacturingYear: params.manufacturingYear,
      latitude: params.latitude,
      longitude: params.longitude,
      serviceRadiusKm: params.serviceRadiusKm,
      hourlyRate: params.hourlyRate,
      dailyRate: params.dailyRate,
      imageUrls: params.imageUrls,
    );
  }
}

/// Parameters for creating equipment
class CreateEquipmentParams {
  final EquipmentType equipmentType;
  final String title;
  final String? description;
  final String? brand;
  final String? model;
  final int? manufacturingYear;
  final double latitude;
  final double longitude;
  final double serviceRadiusKm;
  final double hourlyRate;
  final double? dailyRate;
  final List<String>? imageUrls;
  
  CreateEquipmentParams({
    required this.equipmentType,
    required this.title,
    this.description,
    this.brand,
    this.model,
    this.manufacturingYear,
    required this.latitude,
    required this.longitude,
    required this.serviceRadiusKm,
    required this.hourlyRate,
    this.dailyRate,
    this.imageUrls,
  });
}
