import 'package:cloud_firestore/cloud_firestore.dart';

class MapPoint {
  String? id;
  String title;
  String description;
  String contact;
  String openTimes;
  String type;
  double latitude;
  double longitude;
  Timestamp createdAt;
  String createdBy;
  bool active;

  MapPoint({
    this.id,
    required this.title,
    required this.description,
    required this.contact,
    required this.openTimes,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.createdBy,
    required this.active,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'contact': contact,
      'openTimes': openTimes,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'active': active,
    };
  }

  factory MapPoint.fromMap(Map<String, dynamic> map) {
    return MapPoint(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      contact: map['contact'],
      openTimes: map['openTimes'],
      type: map['type'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      createdAt: map['createdAt'],
      createdBy: map['createdBy'],
      active: map['active'],
    );
  }
}
