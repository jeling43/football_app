import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/game.dart';
import '../providers/leaderboard_provider.dart';

class GameProvider extends ChangeNotifier {
  List<Game> _games = [];
  final Box<Game> _gameBox = Hive.box<Game>('games');

  GameProvider() {
    _loadGames();
  }

  List<Game> get games => _games;

  void _loadGames() {
    final oneWeekAgo = DateTime.now().subtract(Duration(days: 7));
    _games =
        _gameBox.values.where((g) => g.createdAt.isAfter(oneWeekAgo)).toList();
    notifyListeners();
  }

  void addGame(Game game) async {
    await _gameBox.add(game);
    _loadGames();
  }

  void clearGames() async {
    await _gameBox.clear();
    _loadGames();
  }

  void deleteGame(int index) async {
    final key = _gameBox.keyAt(index);
    await _gameBox.delete(key);
    _loadGames();
  }

  // Winner update now triggers leaderboard recalculation!
  void setWinnerByKey(dynamic key, String winner,
      LeaderboardProvider leaderboardProvider) async {
    final game = _gameBox.get(key);
    if (game != null) {
      game.winner = winner;
      await game.save();
      _loadGames();
      leaderboardProvider
          .updateAllCorrectPicks(_games); // <-- recalculate correct picks!
    }
  }
}
