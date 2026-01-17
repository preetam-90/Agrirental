import '../../domain/entities/user.dart';

/// User model for data layer with JSON serialization
class UserModel extends User {
  const UserModel({
    required super.id,
    super.phoneNumber,
    super.email,
    required super.fullName,
    required super.activeRole,
    required super.enabledRoles,
    super.latitude,
    super.longitude,
    super.addressText,
    super.district,
    super.state,
    super.profileImageUrl,
    super.preferredLanguage,
    required super.createdAt,
    required super.updatedAt,
  });
  
  /// Create UserModel from JSON (Supabase response)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Parse enabled_roles array from database
    final enabledRolesRaw = json['enabled_roles'] as List<dynamic>?;
    final enabledRoles = enabledRolesRaw?.map((role) {
      return _parseUserRole(role.toString());
    }).toList() ?? [UserRole.farmer];
    
    // Parse location from PostGIS geography point if available
    double? lat;
    double? lng;
    if (json['location'] != null) {
      // PostGIS returns GeoJSON format
      final location = json['location'];
      if (location is Map && location['coordinates'] != null) {
        final coords = location['coordinates'] as List;
        lng = coords[0] as double?; // Longitude first in GeoJSON
        lat = coords[1] as double?;
      }
    }
    
    return UserModel(
      id: json['id'] as String,
      phoneNumber: json['phone_number'] as String?,
      email: json['email'] as String?,
      fullName: json['full_name'] as String? ?? 'User',
      activeRole: _parseUserRole(json['active_role'] as String? ?? 'farmer'),
      enabledRoles: enabledRoles,
      latitude: lat,
      longitude: lng,
      addressText: json['address_text'] as String?,
      district: json['district'] as String?,
      state: json['state'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      preferredLanguage: json['preferred_language'] as String? ?? 'en',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
  
  /// Convert UserModel to JSON for Supabase
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'id': id,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (email != null) 'email': email,
      'full_name': fullName,
      'active_role': _userRoleToString(activeRole),
      'enabled_roles': enabledRoles.map(_userRoleToString).toList(),
      'address_text': addressText,
      'district': district,
      'state': state,
      'profile_image_url': profileImageUrl,
      'preferred_language': preferredLanguage,
    };
    
    // Add location as GeoJSON if coordinates exist
    if (latitude != null && longitude != null) {
      json['location'] = {
        'type': 'Point',
        'coordinates': [longitude, latitude], // GeoJSON: [lng, lat]
      };
    }
    
    return json;
  }
  
  /// Parse string to UserRole enum
  static UserRole _parseUserRole(String role) {
    switch (role) {
      case 'farmer':
        return UserRole.farmer;
      case 'equipment_provider':
        return UserRole.equipmentProvider;
      case 'labour_provider':
        return UserRole.labourProvider;
      default:
        return UserRole.farmer;
    }
  }
  
  /// Convert UserRole enum to database string
  static String _userRoleToString(UserRole role) {
    switch (role) {
      case UserRole.farmer:
        return 'farmer';
      case UserRole.equipmentProvider:
        return 'equipment_provider';
      case UserRole.labourProvider:
        return 'labour_provider';
    }
  }
  
  /// Create User entity from UserModel
  User toEntity() {
    return User(
      id: id,
      phoneNumber: phoneNumber,
      email: email,
      fullName: fullName,
      activeRole: activeRole,
      enabledRoles: enabledRoles,
      latitude: latitude,
      longitude: longitude,
      addressText: addressText,
      district: district,
      state: state,
      profileImageUrl: profileImageUrl,
      preferredLanguage: preferredLanguage,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
