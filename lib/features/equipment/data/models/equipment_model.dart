import '../../domain/entities/equipment.dart';

/// Equipment model for data layer with JSON serialization
class EquipmentModel extends Equipment {
  const EquipmentModel({
    required super.id,
    required super.ownerId,
    required super.ownerName,
    required super.equipmentType,
    required super.title,
    super.description,
    super.brand,
    super.model,
    super.manufacturingYear,
    required super.latitude,
    required super.longitude,
    required super.serviceRadiusKm,
    required super.hourlyRate,
    super.dailyRate,
    super.images,
    super.primaryImageUrl,
    super.isAvailable,
    super.totalBookings,
    super.averageRating,
    super.distanceKm,
    required super.createdAt,
    required super.updatedAt,
  });
  
  /// Create EquipmentModel from JSON (Supabase response)
  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
    // Parse equipment type
    final equipmentType = _parseEquipmentType(json['equipment_type'] as String? ?? 'other');
    
    // Parse location from PostGIS geography point
    double lat = 0.0;
    double lng = 0.0;
    
    if (json['location'] != null) {
      final location = json['location'];
      if (location is Map && location['coordinates'] != null) {
        final coords = location['coordinates'] as List;
        lng = (coords[0] as num).toDouble();
        lat = (coords[1] as num).toDouble();
      }
    }
    
    // Parse images array
    final imagesList = json['images'] as List<dynamic>?;
    final images = imagesList?.map((e) => e.toString()).toList() ?? <String>[];
    
    return EquipmentModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      ownerName: json['owner_name'] as String? ?? 'Unknown',
      equipmentType: equipmentType,
      title: json['title'] as String,
      description: json['description'] as String?,
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      manufacturingYear: json['manufacturing_year'] as int?,
      latitude: lat,
      longitude: lng,
      serviceRadiusKm: (json['service_radius_km'] as num).toDouble(),
      hourlyRate: (json['hourly_rate'] as num).toDouble(),
      dailyRate: json['daily_rate'] != null ? (json['daily_rate'] as num).toDouble() : null,
      images: images,
      primaryImageUrl: json['primary_image_url'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      totalBookings: json['total_bookings'] as int? ?? 0,
      averageRating: json['average_rating'] != null 
        ? (json['average_rating'] as num).toDouble() 
        : 0.0,
      distanceKm: json['distance_km'] != null 
        ? (json['distance_km'] as num).toDouble() 
        : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
  
  /// Convert EquipmentModel to JSON for Supabase
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'equipment_type': _equipmentTypeToString(equipmentType),
      'title': title,
      'description': description,
      'brand': brand,
      'model': model,
      'manufacturing_year': manufacturingYear,
      'service_radius_km': serviceRadiusKm,
      'hourly_rate': hourlyRate,
      'daily_rate': dailyRate,
      'images': images,
      'primary_image_url': primaryImageUrl,
      'is_available': isAvailable,
    };
    
    // Add location as GeoJSON for PostGIS
    json['location'] = {
      'type': 'Point',
      'coordinates': [longitude, latitude],
    };
    
    return json;
  }
  
  /// Parse string to EquipmentType enum
  static EquipmentType _parseEquipmentType(String type) {
    switch (type) {
      case 'tractor':
        return EquipmentType.tractor;
      case 'harvester':
        return EquipmentType.harvester;
      case 'seeder':
        return EquipmentType.seeder;
      case 'plough':
        return EquipmentType.plough;
      case 'sprayer':
        return EquipmentType.sprayer;
      case 'irrigation_pump':
        return EquipmentType.irrigationPump;
      case 'thresher':
        return EquipmentType.thresher;
      default:
        return EquipmentType.other;
    }
  }
  
  /// Convert EquipmentType enum to database string
  static String _equipmentTypeToString(EquipmentType type) {
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
  
  /// Create Equipment entity from EquipmentModel
  Equipment toEntity() {
    return Equipment(
      id: id,
      ownerId: ownerId,
      ownerName: ownerName,
      equipmentType: equipmentType,
      title: title,
      description: description,
      brand: brand,
      model: model,
      manufacturingYear: manufacturingYear,
      latitude: latitude,
      longitude: longitude,
      serviceRadiusKm: serviceRadiusKm,
      hourlyRate: hourlyRate,
      dailyRate: dailyRate,
      images: images,
      primaryImageUrl: primaryImageUrl,
      isAvailable: isAvailable,
      totalBookings: totalBookings,
      averageRating: averageRating,
      distanceKm: distanceKm,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
