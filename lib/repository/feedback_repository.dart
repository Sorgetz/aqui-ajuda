import 'package:aqui_ajuda_app/model/feedback.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackRepository {
  final CollectionReference _collection = FirebaseFirestore.instance.collection(
    "feedbacks",
  );

  Future<int> insert(Feedback feedback) async {
    final doc = await _collection.add(feedback.toMap());
    String generatedId = doc.id;

    feedback.id = generatedId;

    Map<String, dynamic> dataToSave = {...feedback.toMap(), 'id': generatedId};

    await doc.set(dataToSave);
    return doc.id.hashCode;
  }

  Future<int> update(Feedback feedback) async {
    if (feedback.id == null) return 0;
    final query = await _collection.where('id', isEqualTo: feedback.id).get();

    if (query.docs.isEmpty) {
      return 0;
    }
    await query.docs.first.reference.update(feedback.toMap());
    return 1;
  }

  Future<int> delete(String id) async {
    final query = await _collection.where('id', isEqualTo: id).get();

    for (var doc in query.docs) {
      await doc.reference.delete();
    }
    return query.docs.length;
  }

  Stream<List<Feedback>> findStream({String filter = ''}) {
    Query query = _collection.orderBy('createdAt', descending: true);

    if (filter.isNotEmpty) {
      query = query.where('mapPointId', isEqualTo: filter);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Feedback.fromMap(data);
      }).toList();
    });
  }
}
