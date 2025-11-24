import 'package:aqui_ajuda_app/model/map_point.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapPointRepository {
  final CollectionReference _collection = FirebaseFirestore.instance.collection(
    "map_points",
  );

  Future<int> insert(MapPoint mapPoint) async {
    final doc = await _collection.add(mapPoint.toMap());
    String generatedId = doc.id;

    mapPoint.id = generatedId;

    Map<String, dynamic> dataToSave = {...mapPoint.toMap(), 'id': generatedId};

    await doc.set(dataToSave);
    return doc.id.hashCode;
  }

  Future<int> update(MapPoint mapPoint) async {
    if (mapPoint.id == null) return 0;
    final query = await _collection.where('id', isEqualTo: mapPoint.id).get();

    if (query.docs.isEmpty) {
      return 0;
    }
    await query.docs.first.reference.update(mapPoint.toMap());
    return 1;
  }

  Future<int> delete(String id) async {
    if (id == '') return 0;
    final query = await _collection.where('id', isEqualTo: id).get();

    for (var doc in query.docs) {
      final data = doc.data() as Map<String, dynamic>;
      MapPoint mapPoint = MapPoint.fromMap(data);
      mapPoint.active = false;
      await query.docs.first.reference.update(mapPoint.toMap());
    }
    return 1;
  }

  Future<List<MapPoint>> find({String filter = ''}) async {
    QuerySnapshot snapshot;
    if (filter.isEmpty) {
      snapshot = await _collection
          .where('active', isEqualTo: true)
          .orderBy('title')
          .get();
    } else {
      snapshot = await _collection
          .where('type', isEqualTo: filter)
          .where('active', isEqualTo: true)
          .get();
    }

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return MapPoint.fromMap(data);
    }).toList();
  }

  Future<List<MapPoint>> findAll({String filter = ''}) async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return MapPoint.fromMap(data);
    }).toList();
  }
}
