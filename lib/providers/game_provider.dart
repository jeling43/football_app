import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game.dart';
import '../providers/leaderboard_provider.dart';

class GameProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Game> games = [];

  GameProvider() {
    _loadGames();
  }

  Future<void> _loadGames() async {
    final snapshot = await _db.collection('games').get();
    games =
        snapshot.docs.map((doc) => Game.fromJson(doc.data(), doc.id)).toList();
    notifyListeners();
  }

  Future<void> addGame(Game game) async {
    await _db.collection('games').add(game.toJson());
    await _loadGames();
  }

  Future<void> clearGames() async {
    final batch = _db.batch();
    final snapshot = await _db.collection('games').get();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    await _loadGames();
  }

  Future<void> deleteGame(String id) async {
    await _db.collection('games').doc(id).delete();
    await _loadGames();
  }

  Future<void> setWinnerByKey(
      String id, String winner, LeaderboardProvider leaderboardProvider) async {
    await _db.collection('games').doc(id).update({'winner': winner});
    await _loadGames();
    await leaderboardProvider
        .recalculateLeaderboard(); // You may need to implement this for Firestore
  }
}
