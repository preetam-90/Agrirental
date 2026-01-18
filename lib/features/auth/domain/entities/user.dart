import '../../../../core/domain/entity.dart';

/// User role enum
enum UserRole {
  farmer,
  provider;
  
  String get displayName {
    switch (this) {
      case UserRole.farmer:
        return 'Farmer';
      case UserRole.provider:
        return 'Provider';
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
  
  // Location
  final double? latitude;
  final double? longitude;
  final String? addressText;
  final String? district;
  final String? state;
  
  // Profile metadata
  final String? avatarUrl;
  final bool isVerified;
  final String preferredLanguage;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const User({
    required this.id,
    this.phoneNumber,
    this.email,
    required this.fullName,
    required this.activeRole,
    this.latitude,
    this.longitude,
    this.addressText,
    this.district,
    this.state,
    this.avatarUrl,
    this.isVerified = false,
    this.preferredLanguage = 'en',
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// Check if user is a farmer
  bool get isFarmer => activeRole == UserRole.farmer;
  
  /// Check if user is a provider
  bool get isProvider => activeRole == UserRole.provider;
  
  /// Check if user has location set
  bool get hasLocation => latitude != null && longitude != null;

  /// Check if profile is complete (has name and location)
  bool get isProfileComplete => fullName != 'New User' && hasLocation;
  
  /// Copy with method for immutability
  User copyWith({
    String? id,
    String? phoneNumber,
    String? email,
    String? fullName,
    UserRole? activeRole,
    double? latitude,
    double? longitude,
    String? addressText,
    String? district,
    String? state,
    String? avatarUrl,
    bool? isVerified,
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
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      addressText: addressText ?? this.addressText,
      district: district ?? this.district,
      state: state ?? this.state,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    fullName,
    activeRole,
    latitude,
    longitude,
    addressText,
    district,
    state,
    avatarUrl,
    isVerified,
    preferredLanguage,
    createdAt,
    updatedAt,
  ];
}
