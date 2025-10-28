import 'package:aqui_ajuda_app/model/map_point.dart';
import 'package:aqui_ajuda_app/repository/map_point_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MapPointDTO {
  final int? id;
  final String title;
  final String description;
  final String type;
  final double latitude;
  final double longitude;
  final Timestamp createdAt;
  final bool active;

  MapPointDTO({
    this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.active,
  });

  factory MapPointDTO.fromModel(MapPoint mapPoint) {
    return MapPointDTO(
      id: mapPoint.id,
      title: mapPoint.title,
      description: mapPoint.description,
      type: mapPoint.type,
      latitude: mapPoint.latitude,
      longitude: mapPoint.longitude,
      createdAt: mapPoint.createdAt,
      active: mapPoint.active,
    );
  }

  MapPoint toModel() {
    return MapPoint(
      id: id,
      title: title,
      description: description,
      type: type,
      latitude: latitude,
      longitude: longitude,
      createdAt: createdAt,
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
      type: dto.type,
      latitude: dto.latitude,
      longitude: dto.longitude,
      createdAt: dto.createdAt,
      active: dto.active,
    );
    await _repository.insert(mapPoint);
    await loadMapPoints(_lastFilter);
  }

  Future<void> updateMapPoint({
    required int id,
    required String title,
    required String description,
    required String type,
    required double latitude,
    required double longitude,
    required Timestamp createdAt,
    required bool active,
  }) async {
    final mapPoint = MapPoint(
      id: id,
      title: title,
      description: description,
      type: type,
      latitude: latitude,
      longitude: longitude,
      createdAt: createdAt,
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
