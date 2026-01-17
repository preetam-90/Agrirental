import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/equipment.dart';

/// Equipment repository interface
abstract class EquipmentRepository {
  /// Search equipment nearby based on farmer's location
  /// Uses PostGIS ST_DWithin to filter by service radius
  Future<Either<Failure, List<Equipment>>> searchNearby({
    required double farmerLatitude,
    required double farmerLongitude,
    EquipmentType? equipmentType,
    double? minRating,
    double? maxHourlyRate,
  });
  
  /// Get equipment by ID
  Future<Either<Failure, Equipment>> getEquipmentById(String id);
  
  /// Get all equipment owned by current user
  Future<Either<Failure, List<Equipment>>> getMyEquipment();
  
  /// Create new equipment listing
  Future<Either<Failure, Equipment>> createEquipment({
    required EquipmentType equipmentType,
    required String title,
    String? description,
    String? brand,
    String? model,
    int? manufacturingYear,
    required double latitude,
    required double longitude,
    required double serviceRadiusKm,
    required double hourlyRate,
    double? dailyRate,
    List<String>? imageUrls,
  });
  
  /// Update existing equipment listing
  Future<Either<Failure, Equipment>> updateEquipment({
    required String id,
    String? title,
    String? description,
    String? brand,
    String? model,
    int? manufacturingYear,
    double? latitude,
    double? longitude,
    double? serviceRadiusKm,
    double? hourlyRate,
    double? dailyRate,
    bool? isAvailable,
    List<String>? imageUrls,
  });
  
  /// Delete equipment listing
  Future<Either<Failure, void>> deleteEquipment(String id);
  
  /// Upload equipment image to Cloudinary
  Future<Either<Failure, String>> uploadImage(String imagePath);
}
