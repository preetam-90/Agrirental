import '../../../../core/domain/entity.dart';

/// Equipment type enum matching database
enum EquipmentType {
  tractor,
  harvester,
  seeder,
  plough,
  sprayer,
  irrigationPump,
  thresher,
  other;
  
  String get displayName {
    switch (this) {
      case EquipmentType.tractor:
        return 'Tractor';
      case EquipmentType.harvester:
        return 'Harvester';
      case EquipmentType.seeder:
        return 'Seeder';
      case EquipmentType.plough:
        return 'Plough';
      case EquipmentType.sprayer:
        return 'Sprayer';
      case EquipmentType.irrigationPump:
        return 'Irrigation Pump';
      case EquipmentType.thresher:
        return 'Thresher';
      case EquipmentType.other:
        return 'Other';
    }
  }
}

/// Equipment listing entity
class Equipment extends Entity {
  final String id;
  final String ownerId;
  final String ownerName;
  
  // Equipment details
  final EquipmentType equipmentType;
  final String title;
  final String? description;
  final String? brand;
  final String? model;
  final int? manufacturingYear;
  
  // Geospatial data
  final double latitude;
  final double longitude;
  final double serviceRadiusKm;
  
  // Pricing
  final double hourlyRate;
  final double? dailyRate;
  
  // Images
  final List<String> images;
  final String? primaryImageUrl;
  
  // Availability & ratings
  final bool isAvailable;
  final int totalBookings;
  final double averageRating;
  
  // Distance (calculated during search, not stored)
  final double? distanceKm;
  
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const Equipment({
    required this.id,
    required this.ownerId,
    required this.ownerName,
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
    this.images = const [],
    this.primaryImageUrl,
    this.isAvailable = true,
    this.totalBookings = 0,
    this.averageRating = 0.0,
    this.distanceKm,
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// Get display image (primary or first image or placeholder)
  String get displayImage {
    if (primaryImageUrl != null) return primaryImageUrl!;
    if (images.isNotEmpty) return images.first;
    return 'assets/images/equipment_placeholder.png';
  }
  
  /// Check if equipment has reviews
  bool get hasReviews => totalBookings > 0;
  
  /// Format price for display
  String get formattedHourlyRate => '₹${hourlyRate.toStringAsFixed(0)}/hr';
  String get formattedDailyRate => dailyRate != null ? '₹${dailyRate!.toStringAsFixed(0)}/day' : '';
  
  /// Copy with method
  Equipment copyWith({
    String? id,
    String? ownerId,
    String? ownerName,
    EquipmentType? equipmentType,
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
    List<String>? images,
    String? primaryImageUrl,
    bool? isAvailable,
    int? totalBookings,
    double? averageRating,
    double? distanceKm,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Equipment(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      equipmentType: equipmentType ?? this.equipmentType,
      title: title ?? this.title,
      description: description ?? this.description,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      manufacturingYear: manufacturingYear ?? this.manufacturingYear,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      serviceRadiusKm: serviceRadiusKm ?? this.serviceRadiusKm,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      dailyRate: dailyRate ?? this.dailyRate,
      images: images ?? this.images,
      primaryImageUrl: primaryImageUrl ?? this.primaryImageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      totalBookings: totalBookings ?? this.totalBookings,
      averageRating: averageRating ?? this.averageRating,
      distanceKm: distanceKm ?? this.distanceKm,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    ownerId,
    ownerName,
    equipmentType,
    title,
    description,
    brand,
    model,
    manufacturingYear,
    latitude,
    longitude,
    serviceRadiusKm,
    hourlyRate,
    dailyRate,
    images,
    primaryImageUrl,
    isAvailable,
    totalBookings,
    averageRating,
    distanceKm,
    createdAt,
    updatedAt,
  ];
}
