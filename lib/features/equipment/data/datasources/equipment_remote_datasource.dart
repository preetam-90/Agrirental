import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/equipment.dart';
import '../../domain/entities/nearby_item.dart';
import '../models/equipment_model.dart';

/// Remote data source for equipment using Supabase and PostGIS
abstract class EquipmentRemoteDataSource {
  /// Search equipment nearby using PostGIS ST_DWithin
  Future<List<EquipmentModel>> searchNearby({
    required double farmerLatitude,
    required double farmerLongitude,
    EquipmentType? equipmentType,
    double? minRating,
    double? maxHourlyRate,
  });
  
  /// Search nearby items (equipment or labour)
  Future<List<NearbyItem>> searchNearbyItems({
    required double userLat,
    required double userLong,
    required double radiusKm,
    required String itemType,
  });
  
  /// Get equipment by ID
  Future<EquipmentModel> getEquipmentById(String id);
  
  /// Get equipment owned by specific user
  Future<List<EquipmentModel>> getEquipmentByOwnerId(String ownerId);
  
  /// Create new equipment listing
  Future<EquipmentModel> createEquipment(EquipmentModel equipment, String ownerId);
  
  /// Update equipment listing
  Future<EquipmentModel> updateEquipment(String id, Map<String, dynamic> updates);
  
  /// Delete equipment listing
  Future<void> deleteEquipment(String id);
}

class EquipmentRemoteDataSourceImpl implements EquipmentRemoteDataSource {
  final SupabaseClient supabaseClient;
  
  EquipmentRemoteDataSourceImpl({required this.supabaseClient});
  
  @override
  Future<List<EquipmentModel>> searchNearby({
    required double farmerLatitude,
    required double farmerLongitude,
    EquipmentType? equipmentType,
    double? minRating,
    double? maxHourlyRate,
  }) async {
    try {
      final response = await supabaseClient.rpc(
        'search_equipment_nearby',
        params: {
          'farmer_lat': farmerLatitude,
          'farmer_lng': farmerLongitude,
          'equipment_filter': equipmentType != null 
            ? _equipmentTypeToString(equipmentType) 
            : null,
          'min_rating': minRating ?? 0,
          'max_hourly_rate': maxHourlyRate,
        },
      );
      
      if (response == null) return [];
      
      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => EquipmentModel.fromJson(json as Map<String, dynamic>)).toList();
    } on PostgrestException catch (e) {
      throw ServerException('Failed to search equipment: ${e.message}', 
        e.code != null ? int.tryParse(e.code!) : null);
    } catch (e) {
      throw ServerException('Failed to search equipment: ${e.toString()}');
    }
  }
  
  @override
  Future<List<NearbyItem>> searchNearbyItems({
    required double userLat,
    required double userLong,
    required double radiusKm,
    required String itemType,
  }) async {
    try {
      final response = await supabaseClient.rpc(
        'search_nearby_items',
        params: {
          'user_lat': userLat,
          'user_long': userLong,
          'radius_km': radiusKm,
          'item_type': itemType,
        },
      );
      
      if (response == null) return [];
      
      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => NearbyItem.fromJson(json as Map<String, dynamic>, itemType)).toList();
    } on PostgrestException catch (e) {
      throw ServerException('Failed to search nearby items: ${e.message}', 
        e.code != null ? int.tryParse(e.code!) : null);
    } catch (e) {
      throw ServerException('Failed to search nearby items: ${e.toString()}');
    }
  }
  
  @override
  Future<EquipmentModel> getEquipmentById(String id) async {
    try {
      final response = await supabaseClient
          .from('equipment_listings')
          .select('''
            *,
            user_profiles!owner_id(full_name)
          ''')
          .eq('id', id)
          .single();
      
      // Flatten the response to include owner_name
      final Map<String, dynamic> flattenedData = {
        ...response,
        'owner_name': response['user_profiles']['full_name'],
      };
      
      return EquipmentModel.fromJson(flattenedData);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw ServerException('Equipment not found', 404);
      }
      throw ServerException('Failed to get equipment: ${e.message}', e.code != null ? int.tryParse(e.code!) : null);
    } catch (e) {
      throw ServerException('Failed to get equipment: ${e.toString()}');
    }
  }
  
  @override
  Future<List<EquipmentModel>> getEquipmentByOwnerId(String ownerId) async {
    try {
      final response = await supabaseClient
          .from('equipment_listings')
          .select('''
            *,
            user_profiles!owner_id(full_name)
          ''')
          .eq('owner_id', ownerId)
          .order('created_at', ascending: false);
      
      final List<dynamic> data = response as List<dynamic>;
      
      return data.map((json) {
        final Map<String, dynamic> flattenedData = {
          ...json,
          'owner_name': json['user_profiles']['full_name'],
        };
        return EquipmentModel.fromJson(flattenedData);
      }).toList();
    } on PostgrestException catch (e) {
      throw ServerException('Failed to get equipment: ${e.message}', e.code != null ? int.tryParse(e.code!) : null);
    } catch (e) {
      throw ServerException('Failed to get equipment: ${e.toString()}');
    }
  }
  
  @override
  Future<EquipmentModel> createEquipment(EquipmentModel equipment, String ownerId) async {
    try {
      final equipmentData = equipment.toJson();
      equipmentData['owner_id'] = ownerId;
      
      final response = await supabaseClient
          .from('equipment_listings')
          .insert(equipmentData)
          .select('''
            *,
            user_profiles!owner_id(full_name)
          ''')
          .single();
      
      final Map<String, dynamic> flattenedData = {
        ...response,
        'owner_name': response['user_profiles']['full_name'],
      };
      
      return EquipmentModel.fromJson(flattenedData);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to create equipment: ${e.message}', e.code != null ? int.tryParse(e.code!) : null);
    } catch (e) {
      throw ServerException('Failed to create equipment: ${e.toString()}');
    }
  }
  
  @override
  Future<EquipmentModel> updateEquipment(String id, Map<String, dynamic> updates) async {
    try {
      final response = await supabaseClient
          .from('equipment_listings')
          .update(updates)
          .eq('id', id)
          .select('''
            *,
            user_profiles!owner_id(full_name)
          ''')
          .single();
      
      final Map<String, dynamic> flattenedData = {
        ...response,
        'owner_name': response['user_profiles']['full_name'],
      };
      
      return EquipmentModel.fromJson(flattenedData);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to update equipment: ${e.message}', e.code != null ? int.tryParse(e.code!) : null);
    } catch (e) {
      throw ServerException('Failed to update equipment: ${e.toString()}');
    }
  }
  
  @override
  Future<void> deleteEquipment(String id) async {
    try {
      await supabaseClient
          .from('equipment_listings')
          .delete()
          .eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to delete equipment: ${e.message}', e.code != null ? int.tryParse(e.code!) : null);
    } catch (e) {
      throw ServerException('Failed to delete equipment: ${e.toString()}');
    }
  }
  
  /// Helper to convert EquipmentType to database string
  String _equipmentTypeToString(EquipmentType type) {
    switch (type) {
      case EquipmentType.tractor:
        return 'tractor';
      case EquipmentType.harvester:
        return 'harvester';
      case EquipmentType.seeder:
        return 'seeder';
      case EquipmentType.plough:
        return 'plough';
      case EquipmentType.sprayer:
        return 'sprayer';
      case EquipmentType.irrigationPump:
        return 'irrigation_pump';
      case EquipmentType.thresher:
        return 'thresher';
      case EquipmentType.other:
        return 'other';
    }
  }
}
