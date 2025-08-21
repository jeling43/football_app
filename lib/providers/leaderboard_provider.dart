import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:math';
import '../models/leaderboard_entry.dart';
import '../models/game.dart';

class LeaderboardProvider extends ChangeNotifier {
  List<LeaderboardEntry> _entries = [];
  final Box<LeaderboardEntry> _entryBox =
      Hive.box<LeaderboardEntry>('leaderboard');

  LeaderboardProvider() {
    _loadEntries();
  }

  List<LeaderboardEntry> get entries => _entries;

  void _loadEntries() {
    final oneWeekAgo = DateTime.now().subtract(Duration(days: 7));
    _entries =
        _entryBox.values.where((e) => e.createdAt.isAfter(oneWeekAgo)).toList();
    notifyListeners();
  }

  void addOrUpdateEntry(LeaderboardEntry entry) async {
    int idx = _entries.indexWhere((e) => e.username == entry.username);
    if (idx >= 0) {
      final key = _entryBox.keyAt(idx);
      await _entryBox.put(key, entry);
    } else {
      await _entryBox.add(entry);
    }
    _loadEntries();
  }

  void deleteEntry(String username) async {
    int idx = _entries.indexWhere((e) => e.username == username);
    if (idx >= 0) {
      final key = _entryBox.keyAt(idx);
      await _entryBox.delete(key);
      _loadEntries();
    }
  }

  void clearAllPicks() async {
    for (int i = 0; i < _entries.length; i++) {
      final entry = _entries[i];
      entry.picks.clear();
      entry.correctPicks = 0;
      await entry.save();
    }
    _loadEntries();
  }

  void clearUserPicks(String username) async {
    int idx = _entries.indexWhere((e) => e.username == username);
    if (idx >= 0) {
      final entry = _entries[idx];
      entry.picks.clear();
      entry.correctPicks = 0;
      await entry.save();
      _loadEntries();
    }
  }

  List<LeaderboardEntry> searchEntries(String query) {
    return _entries
        .where((e) => e.username.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Update all users' correct picks based on current game winners.
  void updateAllCorrectPicks(List<Game> games) async {
    for (var entry in _entries) {
      int correct = 0;
      entry.picks.forEach((gameIndex, pickedTeam) {
        if (gameIndex >= 0 && gameIndex < games.length) {
          final game = games[gameIndex];
          if (game.winner.isNotEmpty && game.winner == pickedTeam) {
            correct++;
          }
        }
      });
      entry.correctPicks = correct;
      await entry.save();
    }
    _loadEntries();
  }

  /// Monte Carlo simulation-based win probability
  Map<String, double> calculateWinProbabilities(
      List<Game> games, List<LeaderboardEntry> entries,
      {int simulations = 1000}) {
    final rand = Random();
    final userWinCounts = Map<String, int>.fromIterable(entries,
        key: (e) => e.username, value: (_) => 0);

    // Find undecided games
    List<int> undecidedIndices = [];
    for (int i = 0; i < games.length; i++) {
      if (games[i].winner.isEmpty) {
        undecidedIndices.add(i);
      }
    }

    for (int sim = 0; sim < simulations; sim++) {
      // Simulate winners for undecided games
      Map<int, String> simulatedWinners = {};
      for (var gameIdx in undecidedIndices) {
        var game = games[gameIdx];
        simulatedWinners[gameIdx] = rand.nextBool() ? game.team1 : game.team2;
      }

      // Calculate correct picks for each user
      Map<String, int> simulatedCorrect = {};
      for (var entry in entries) {
        int correct = 0;
        entry.picks.forEach((gameIdx, pickedTeam) {
          final actualWinner = games[gameIdx].winner.isNotEmpty
              ? games[gameIdx].winner
              : simulatedWinners[gameIdx];
          if (actualWinner != null && actualWinner == pickedTeam) {
            correct++;
          }
        });
        simulatedCorrect[entry.username] = correct;
      }

      // Find highest correct pick count
      int maxCorrect = simulatedCorrect.values.fold(0, max);

      // Give credit to all users who have the max correct picks in this simulation
      simulatedCorrect.forEach((username, correct) {
        if (correct == maxCorrect) {
          userWinCounts[username] = userWinCounts[username]! + 1;
        }
      });
    }

    // Calculate probabilities
    Map<String, double> winProbabilities = {};
    userWinCounts.forEach((username, winCount) {
      winProbabilities[username] = winCount / simulations;
    });

    return winProbabilities;
  }
}
