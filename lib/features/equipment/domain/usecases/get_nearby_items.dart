import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/nearby_item.dart';
import '../repositories/equipment_repository.dart';

class GetNearbyItems implements UseCase<List<NearbyItem>, GetNearbyItemsParams> {
  final EquipmentRepository repository;

  GetNearbyItems(this.repository);

  @override
  Future<Either<Failure, List<NearbyItem>>> call(GetNearbyItemsParams params) async {
    return await repository.searchNearbyItems(
      userLat: params.userLat,
      userLong: params.userLong,
      radiusKm: params.radiusKm,
      itemType: params.itemType,
    );
  }
}

class GetNearbyItemsParams {
  final double userLat;
  final double userLong;
  final double radiusKm;
  final String itemType;

  GetNearbyItemsParams({
    required this.userLat,
    required this.userLong,
    required this.radiusKm,
    required this.itemType,
  });
}
