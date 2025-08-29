import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game.dart';
import '../models/leaderboard_entry.dart';
import '../providers/game_provider.dart';
import '../providers/leaderboard_provider.dart';

class LeaderboardPage extends StatefulWidget {
  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  Map<String, double> winProbabilities = {};

  @override
  void initState() {
    super.initState();
    _runSimulation();
  }

  void _runSimulation() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final leaderboardProvider =
        Provider.of<LeaderboardProvider>(context, listen: false);
    setState(() {
      winProbabilities = calculateWinProbabilities(
        gameProvider.games
            .map((gameMap) => Game.fromMap(gameMap, gameMap['id']))
            .toList(),
        leaderboardProvider.entries,
        simulations: 1000,
      );
    });
  }

  Map<String, double> calculateWinProbabilities(
    List<Game> games,
    List<LeaderboardEntry> users, {
    int simulations = 1000,
  }) {
    // Only include games without a winner yet for simulation
    final openGames =
        games.where((g) => g.winner == null || g.winner!.isEmpty).toList();
    final completedGames =
        games.where((g) => g.winner != null && g.winner!.isNotEmpty).toList();

    // If there are no open games, odds are based on current scores
    if (openGames.isEmpty) {
      // If there are ties, divide odds equally
      final scores = <String, int>{};
      for (var user in users) {
        scores[user.username] = user.correctPicks;
      }
      final maxScore = scores.values.isEmpty ? 0 : scores.values.reduce(max);
      final winners = scores.entries
          .where((e) => e.value == maxScore)
          .map((e) => e.key)
          .toList();
      final odds = <String, double>{};
      for (var user in users) {
        odds[user.username] =
            winners.contains(user.username) ? 1.0 / winners.length : 0.0;
      }
      return odds;
    }

    // Monte Carlo simulation
    final winCounts = <String, int>{};
    for (var user in users) {
      winCounts[user.username] = 0;
    }

    final random = Random();
    for (var i = 0; i < simulations; i++) {
      // Randomly assign winners to open games
      final simulatedWinners = <String, String>{}; // gameId -> winner
      for (var game in openGames) {
        final winner = random.nextBool() ? game.team1 : game.team2;
        simulatedWinners[game.id] = winner;
      }

      // Calculate scores for each user
      final scores = <String, int>{};
      for (var user in users) {
        int correct = user.correctPicks;
        user.picks.forEach((gameId, pick) {
          final game = games.firstWhere(
            (g) => g.id == gameId,
            orElse: () => Game(
                id: gameId, team1: '', team2: '', winner: null, spread: 0.0),
          );
          if (game != null) {
            if (game.winner != null && game.winner!.isNotEmpty) {
              // Null check added here
              if (pick == game.winner) correct++;
            } else if (simulatedWinners[gameId] == pick) {
              correct++;
            }
          }
        });
        scores[user.username] = correct;
      }

      // Find the max score in this simulation
      final maxScore = scores.values.reduce(max);
      final winners = scores.entries
          .where((e) => e.value == maxScore)
          .map((e) => e.key)
          .toList();
      for (var winner in winners) {
        winCounts[winner] = winCounts[winner]! + 1 ~/ winners.length;
      }
    }

    // Convert counts to probability
    final odds = <String, double>{};
    for (var user in users) {
      odds[user.username] = (winCounts[user.username] ?? 0) / simulations;
    }
    return odds;
  }

  @override
  Widget build(BuildContext context) {
    final leaderboardProvider =
        Provider.of<LeaderboardProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: leaderboardProvider.entries.length,
                itemBuilder: (context, index) {
                  final entry = leaderboardProvider.entries[index];
                  final probability = winProbabilities[entry.username] ?? 0.0;
                  return Card(
                    child: ListTile(
                      title: Text(entry.username),
                      subtitle: Text(
                          'Correct Picks: ${entry.correctPicks}, Win Probability: ${(probability * 100).toStringAsFixed(2)}%'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
