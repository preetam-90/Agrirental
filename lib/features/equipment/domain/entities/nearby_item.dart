import 'package:equatable/equatable.dart';

class NearbyItem extends Equatable {
  final String id;
  final String name;
  final String categoryOrSkills;
  final double rate;
  final double distanceKm;
  final String itemType; // 'equipment' or 'labour'

  const NearbyItem({
    required this.id,
    required this.name,
    required this.categoryOrSkills,
    required this.rate,
    required this.distanceKm,
    required this.itemType,
  });

  factory NearbyItem.fromJson(Map<String, dynamic> json, String itemType) {
    return NearbyItem(
      id: json['id'] as String,
      name: json['name'] as String,
      categoryOrSkills: json['category_or_skills'] as String,
      rate: (json['rate'] as num).toDouble(),
      distanceKm: (json['distance_km'] as num).toDouble(),
      itemType: itemType,
    );
  }

  @override
  List<Object?> get props => [id, name, categoryOrSkills, rate, distanceKm, itemType];
}
