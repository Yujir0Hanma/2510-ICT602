import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getAllStudentsWithMarks() async {
    final snapshot = await _db.collection('users')
        .where('role', isEqualTo: 'student')
        .get();

    List<Map<String, dynamic>> result = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final studentId = data['studentId'] ?? '';
      final name = data['name'] ?? '';
      final uid = doc.id;

      final markDoc = await _db.collection('carryMarks').doc(uid).get();
      final marks = markDoc.exists
          ? markDoc.data()
          : {'test': 0.0, 'assignment': 0.0, 'project': 0.0};

      result.add({
        'uid': uid,
        'studentId': studentId,
        'name': name,
        'marks': marks,
      });
    }

    return result;
  }

  Future<void> saveCarryMark(String uid, double rawTest, double rawAssignment, double rawProject) async {
    await _db.collection('carryMarks').doc(uid).set({
      'test': rawTest,
      'assignment': rawAssignment,
      'project': rawProject,
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getCarryMark(String uid) async {
    final doc = await _db.collection('carryMarks').doc(uid).get();
    return doc.exists
        ? doc.data()
        : {'test': 0.0, 'assignment': 0.0, 'project': 0.0};
  }
}
