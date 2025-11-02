import 'package:aqui_ajuda_app/model/map_point.dart';
import 'package:aqui_ajuda_app/repository/map_point_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MapPointDTO {
  final String? id;
  final String title;
  final String description;
  final String contact;
  final String openTimes;
  final String type;
  final double latitude;
  final double longitude;
  final Timestamp createdAt;
  final String createdBy;
  final bool active;

  MapPointDTO({
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

  factory MapPointDTO.fromModel(MapPoint mapPoint) {
    return MapPointDTO(
      id: mapPoint.id,
      title: mapPoint.title,
      description: mapPoint.description,
      contact: mapPoint.contact,
      openTimes: mapPoint.openTimes,
      type: mapPoint.type,
      latitude: mapPoint.latitude,
      longitude: mapPoint.longitude,
      createdAt: mapPoint.createdAt,
      createdBy: mapPoint.createdBy,
      active: mapPoint.active,
    );
  }

  MapPoint toModel() {
    return MapPoint(
      id: id,
      title: title,
      description: description,
      contact: contact,
      openTimes: openTimes,
      type: type,
      latitude: latitude,
      longitude: longitude,
      createdAt: createdAt,
      createdBy: createdBy,
      active: active,
    );
  }
}

class MapPointViewModel extends ChangeNotifier {
  final MapPointRepository _repository = MapPointRepository();
  List<MapPoint> _mapPoints = [];
  String _lastFilter = '';

  List<MapPointDTO> get mapPoints =>
      _mapPoints.map((c) => MapPointDTO.fromModel(c)).toList();

  MapPointViewModel() {
    _initRepository();
  }

  Future<void> _initRepository() async {
    await loadMapPoints();
  }

  Future<void> reloadRepository() async {
    await loadMapPoints();
  }

  Future<void> loadMapPoints([String filter = '']) async {
    _lastFilter = filter;
    _mapPoints = await _repository.find(filter: filter);
    notifyListeners();
  }

  Future<void> addMapPoint({required MapPointDTO dto}) async {
    final mapPoint = MapPoint(
      id: dto.id,
      title: dto.title,
      description: dto.description,
      contact: dto.contact,
      openTimes: dto.openTimes,
      type: dto.type,
      latitude: dto.latitude,
      longitude: dto.longitude,
      createdAt: dto.createdAt,
      createdBy: dto.createdBy,
      active: dto.active,
    );
    await _repository.insert(mapPoint);
    await loadMapPoints(_lastFilter);
  }

  Future<void> updateMapPoint({
    required String id,
    required String title,
    required String description,
    required String contact,
    required String openTimes,
    required String type,
    required double latitude,
    required double longitude,
    required Timestamp createdAt,
    required String createdBy,
    required bool active,
  }) async {
    final mapPoint = MapPoint(
      id: id,
      title: title,
      description: description,
      contact: contact,
      openTimes: openTimes,
      type: type,
      latitude: latitude,
      longitude: longitude,
      createdAt: createdAt,
      createdBy: createdBy,
      active: active,
    );
    await _repository.update(mapPoint);
    await loadMapPoints(_lastFilter);
  }

  Future<void> deleteMapPoint(int codigo) async {
    await _repository.delete(codigo);
    await loadMapPoints(_lastFilter);
  }
}
