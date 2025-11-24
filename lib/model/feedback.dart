import 'package:cloud_firestore/cloud_firestore.dart';

class Feedback {
  String? id;
  int? efficiency;
  int? accessibility;
  int? security;
  int? organization;
  bool isAvailable;
  String createdBy;
  String? createdByProfilePic;
  String mapPointId;
  Timestamp createdAt;
  String? experience;

  Feedback({
    this.id,
    this.efficiency,
    this.accessibility,
    this.security,
    this.organization,
    required this.isAvailable,
    required this.createdBy,
    this.createdByProfilePic,
    required this.mapPointId,
    required this.createdAt,
    this.experience,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'efficiency': efficiency,
      'accessibility': accessibility,
      'security': security,
      'organization': organization,
      'isAvailable': isAvailable,
      'createdBy': createdBy,
      'createdByProfilePic': createdByProfilePic,
      'mapPointId': mapPointId,
      'createdAt': createdAt,
      'experience': experience,
    };
  }

  factory Feedback.fromMap(Map<String, dynamic> map) {
    return Feedback(
      id: map['id'],
      efficiency: map['efficiency'],
      accessibility: map['accessibility'],
      security: map['security'],
      organization: map['organization'],
      isAvailable: map['isAvailable'],
      createdBy: map['createdBy'],
      createdByProfilePic: map['createdByProfilePic'],
      mapPointId: map['mapPointId'],
      createdAt: map['createdAt'],
      experience: map['experience'],
    );
  }
}
