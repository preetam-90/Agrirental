import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/network_info.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/providers/auth_state_provider.dart';
import '../../data/datasources/cloudinary_datasource.dart';
import '../../data/datasources/equipment_remote_datasource.dart';
import '../../data/repositories/equipment_repository_impl.dart';
import '../../domain/repositories/equipment_repository.dart';
import '../../domain/usecases/create_equipment.dart';
import '../../domain/usecases/get_my_equipment.dart';
import '../../domain/usecases/search_equipment_nearby.dart';
import '../../domain/usecases/get_nearby_items.dart';
import '../../domain/entities/nearby_item.dart';

// ============================================================================
// Infrastructure Providers
// ============================================================================

/// Cloudinary instance provider
final cloudinaryProvider = Provider<CloudinaryPublic>((ref) {
  return CloudinaryFactory.createUnsigned();
});

// ============================================================================
// Data Source Providers
// ============================================================================

/// Equipment remote data source provider
final equipmentRemoteDataSourceProvider = Provider<EquipmentRemoteDataSource>((ref) {
  return EquipmentRemoteDataSourceImpl(
    supabaseClient: ref.watch(supabaseClientProvider),
  );
});

/// Cloudinary data source provider
final cloudinaryDataSourceProvider = Provider<CloudinaryDataSource>((ref) {
  return CloudinaryDataSourceImpl(
    cloudinary: ref.watch(cloudinaryProvider),
  );
});

// ============================================================================
// Repository Provider
// ============================================================================

/// Equipment repository provider
final equipmentRepositoryProvider = Provider<EquipmentRepository>((ref) {
  return EquipmentRepositoryImpl(
    remoteDataSource: ref.watch(equipmentRemoteDataSourceProvider),
    cloudinaryDataSource: ref.watch(cloudinaryDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
    supabaseClient: ref.watch(supabaseClientProvider),
  );
});

// ============================================================================
// Use Case Providers
// ============================================================================

/// Search equipment nearby use case provider
final searchEquipmentNearbyUseCaseProvider = Provider<SearchEquipmentNearby>((ref) {
  return SearchEquipmentNearby(ref.watch(equipmentRepositoryProvider));
});

/// Create equipment use case provider
final createEquipmentUseCaseProvider = Provider<CreateEquipment>((ref) {
  return CreateEquipment(ref.watch(equipmentRepositoryProvider));
});

/// Get my equipment use case provider
final getMyEquipmentUseCaseProvider = Provider<GetMyEquipment>((ref) {
  return GetMyEquipment(ref.watch(equipmentRepositoryProvider));
});

/// Get nearby items use case provider
final getNearbyItemsUseCaseProvider = Provider<GetNearbyItems>((ref) {
  return GetNearbyItems(ref.watch(equipmentRepositoryProvider));
});

/// Provider for nearby items (equipment or labour)
final nearbyItemsProvider = FutureProvider.family<List<NearbyItem>, String>((ref, type) async {
  final user = ref.watch(currentUserProvider);
  if (user == null || !user.hasLocation) return [];

  final getNearbyItems = ref.watch(getNearbyItemsUseCaseProvider);
  
  final result = await getNearbyItems(GetNearbyItemsParams(
    userLat: user.latitude!,
    userLong: user.longitude!,
    radiusKm: 50.0, // Default radius
    itemType: type,
  ));

  return result.fold(
    (failure) => throw failure,
    (items) => items,
  );
});
