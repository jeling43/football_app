import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leaderboard_entry.dart';

class LeaderboardProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<LeaderboardEntry> entries = [];

  LeaderboardProvider() {
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final snapshot = await _db.collection('leaderboard').get();
    entries = snapshot.docs
        .map((doc) => LeaderboardEntry.fromJson(
            doc.data() as Map<String, dynamic>, doc.id))
        .toList();
    notifyListeners();
  }

  Future<void> addOrUpdateEntry(LeaderboardEntry entry) async {
    await _db.collection('leaderboard').doc(entry.username).set(entry.toJson());
    await _loadEntries();
  }

  Future<void> clearAllPicks() async {
    final batch = _db.batch();
    final snapshot = await _db.collection('leaderboard').get();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'picks': {}, 'correctPicks': 0});
    }
    await batch.commit();
    await _loadEntries();
  }

  Future<void> clearUserPicks(String username) async {
    await _db
        .collection('leaderboard')
        .doc(username)
        .update({'picks': {}, 'correctPicks': 0});
    await _loadEntries();
  }

  Future<void> deleteEntry(String username) async {
    await _db.collection('leaderboard').doc(username).delete();
    await _loadEntries();
  }

  Future<void> recalculateLeaderboard() async {}

  // Add recalculateLeaderboard, searchEntries, etc. as needed
}
