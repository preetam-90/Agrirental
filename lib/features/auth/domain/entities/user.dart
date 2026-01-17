import '../../../../core/domain/entity.dart';

/// User role enum
enum UserRole {
  farmer,
  equipmentProvider,
  labourProvider;
  
  String get displayName {
    switch (this) {
      case UserRole.farmer:
        return 'Farmer';
      case UserRole.equipmentProvider:
        return 'Equipment Provider';
      case UserRole.labourProvider:
        return 'Labour Provider';
    }
  }
}

/// User entity representing authenticated user profile
class User extends Entity {
  final String id;
  final String? phoneNumber;
  final String? email;
  final String fullName;
  final UserRole activeRole;
  final List<UserRole> enabledRoles;
  
  // Location
  final double? latitude;
  final double? longitude;
  final String? addressText;
  final String? district;
  final String? state;
  
  // Profile metadata
  final String? profileImageUrl;
  final String preferredLanguage;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const User({
    required this.id,
    this.phoneNumber,
    this.email,
    required this.fullName,
    required this.activeRole,
    required this.enabledRoles,
    this.latitude,
    this.longitude,
    this.addressText,
    this.district,
    this.state,
    this.profileImageUrl,
    this.preferredLanguage = 'en',
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// Check if user has a specific role enabled
  bool hasRole(UserRole role) => enabledRoles.contains(role);
  
  /// Check if user can switch to a role
  bool canSwitchTo(UserRole role) => enabledRoles.contains(role) && role != activeRole;
  
  /// Check if user is a farmer
  bool get isFarmer => activeRole == UserRole.farmer;
  
  /// Check if user is any type of provider
  bool get isProvider => 
    activeRole == UserRole.equipmentProvider || 
    activeRole == UserRole.labourProvider;
  
  /// Check if user has location set
  bool get hasLocation => latitude != null && longitude != null;
  
  /// Copy with method for immutability
  User copyWith({
    String? id,
    String? phoneNumber,
    String? email,
    String? fullName,
    UserRole? activeRole,
    List<UserRole>? enabledRoles,
    double? latitude,
    double? longitude,
    String? addressText,
    String? district,
    String? state,
    String? profileImageUrl,
    String? preferredLanguage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      activeRole: activeRole ?? this.activeRole,
      enabledRoles: enabledRoles ?? this.enabledRoles,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      addressText: addressText ?? this.addressText,
      district: district ?? this.district,
      state: state ?? this.state,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    phoneNumber,
    email,
    fullName,
    activeRole,
    enabledRoles,
    latitude,
    longitude,
    addressText,
    district,
    state,
    profileImageUrl,
    preferredLanguage,
    createdAt,
    updatedAt,
  ];
}
