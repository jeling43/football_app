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

  // Recalculate the leaderboard based on game winners
  Future<void> recalculateLeaderboard() async {
    final gamesSnapshot = await _db.collection('games').get();
    final Map<String, int> userScores = {};

    for (var gameDoc in gamesSnapshot.docs) {
      final gameData = gameDoc.data();
      if (gameData.containsKey('winner') && gameData['winner'] != null) {
        final winner = gameData['winner'] as String;
        userScores[winner] = (userScores[winner] ?? 0) + 1;
      }
    }

    final batch = _db.batch();
    for (var entry in userScores.entries) {
      final username = entry.key;
      final score = entry.value;

      batch.set(
        _db.collection('leaderboard').doc(username),
        {'username': username, 'score': score},
        SetOptions(merge: true),
      );
    }

    await batch.commit();
    await _loadEntries();
  }
}
