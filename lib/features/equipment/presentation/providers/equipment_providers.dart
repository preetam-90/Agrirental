import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/network_info.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/cloudinary_datasource.dart';
import '../../data/datasources/equipment_remote_datasource.dart';
import '../../data/repositories/equipment_repository_impl.dart';
import '../../domain/repositories/equipment_repository.dart';
import '../../domain/usecases/create_equipment.dart';
import '../../domain/usecases/get_my_equipment.dart';
import '../../domain/usecases/search_equipment_nearby.dart';

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
