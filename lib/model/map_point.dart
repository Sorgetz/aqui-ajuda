import 'package:cloud_firestore/cloud_firestore.dart';

class MapPoint {
  int? id;
  String title;
  String description;
  String type;
  double latitude;
  double longitude;
  Timestamp createdAt;
  bool active;

  MapPoint({
    this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.active,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt,
      'active': active,
    };
  }

  factory MapPoint.fromMap(Map<String, dynamic> map) {
    return MapPoint(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      type: map['type'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      createdAt: map['createdAt'],
      active: map['active'],
    );
  }
}
