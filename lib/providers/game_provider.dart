import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'leaderboard_provider.dart';

class GameProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _games = [];

  List<Map<String, dynamic>> get games => _games;

  // Load games from Firestore
  Future<void> _loadGames() async {
    final snapshot = await _db.collection('games').get();
    _games = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        ...data,
      };
    }).toList();
    notifyListeners();
  }

  // Fetch all games (public method)
  Future<void> fetchGames() async {
    await _loadGames();
  }

  // Add a new game to Firestore
  Future<void> addGame(Map<String, dynamic> game) async {
    await _db.collection('games').add(game);
    await _loadGames(); // Refresh the list after adding a game
  }

  // Clear all games from Firestore
  Future<void> clearGames() async {
    final batch = _db.batch();
    final snapshot = await _db.collection('games').get();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    await _loadGames(); // Refresh the list after clearing games
  }

  // Delete a specific game by ID
  Future<void> deleteGame(String id) async {
    await _db.collection('games').doc(id).delete();
    await _loadGames();
  }

  // Set the winner for a specific game and recalculate the leaderboard
  Future<void> setWinnerByKey(
      String id, String winner, LeaderboardProvider leaderboardProvider) async {
    await _db.collection('games').doc(id).update({'winner': winner});
    await _loadGames();
    await leaderboardProvider.recalculateLeaderboard();
  }
}
