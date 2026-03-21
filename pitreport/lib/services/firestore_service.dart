import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createReport(Report report) async {
    await _db.collection('reports').add(report.toMap());
  }

  Stream<List<Report>> getUserReports(String userId) {
    return _db
        .collection('reports')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Report.fromFirestore).toList());
  }

  Stream<List<Report>> getAllReports() {
    return _db
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Report.fromFirestore).toList());
  }
}
