import 'package:aqui_ajuda_app/model/map_point.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapPointRepository {
  final CollectionReference _collection = FirebaseFirestore.instance.collection(
    "map_points",
  );

  Future<int> insert(MapPoint mapPoint) async {
    final doc = await _collection.add(mapPoint.toMap());
    String generatedId = doc.id;

    // 2. Vincule o ID ao objeto local
    mapPoint.id = generatedId;

    // 3. Use o método set() para salvar o documento com o ID gerado e o ID no Map
    Map<String, dynamic> dataToSave = {
      ...mapPoint.toMap(), // Seus dados originais
      'id': generatedId, // ⭐️ Adiciona o ID ao próprio documento
    };

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

  Future<int> delete(int id) async {
    final query = await _collection.where('id', isEqualTo: id).get();

    for (var doc in query.docs) {
      await doc.reference.delete();
    }
    return query.docs.length;
  }

  Future<List<MapPoint>> find({String filter = ''}) async {
    QuerySnapshot snapshot;
    if (filter.isEmpty) {
      snapshot = await _collection.orderBy('title').get();
    } else {
      snapshot = await _collection.where('type', isEqualTo: filter).get();
    }

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return MapPoint.fromMap(data);
    }).toList();
  }
}
