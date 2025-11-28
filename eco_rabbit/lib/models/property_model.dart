// lib/models/property_model.dart
// lib/models/property_model.dart
class PropertyResult {
  final String id;
  final String name;
  final double distanceToWork;
  final String area;
  final double price;
  int ecoScore; // 移除 final，使其可修改
  final PropertyDetails details;
  final String imageUrl;

  PropertyResult({
    required this.id,
    required this.name,
    required this.distanceToWork,
    required this.area,
    required this.price,
    required this.ecoScore, // 保持 required
    required this.details,
    required this.imageUrl,
  });
}

class PropertyDetails {
  final int bedrooms;
  final int bathrooms;
  final int size;
  final List<String> amenities;
  final int commuteTime;
  final int distanceToStation;

  PropertyDetails({
    required this.bedrooms,
    required this.bathrooms,
    required this.size,
    required this.amenities,
    required this.commuteTime,
    required this.distanceToStation,
  });
}