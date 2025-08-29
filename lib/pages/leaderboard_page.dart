import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/leaderboard_provider.dart';
import '../models/leaderboard_entry.dart';
import '../models/game.dart';
import 'dart:math';

class LeaderboardPage extends StatefulWidget {
  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  String _searchQuery = '';
  Map<String, double> winProbabilities = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runSimulation());
  }

  void _runSimulation() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final leaderboardProvider =
        Provider.of<LeaderboardProvider>(context, listen: false);
    setState(() {
      winProbabilities = calculateWinProbabilities(
        gameProvider.games,
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
    final openGames = games.where((g) => g.winner.isEmpty).toList();
    final completedGames = games.where((g) => g.winner.isNotEmpty).toList();

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

    for (int sim = 0; sim < simulations; sim++) {
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
          final game = games.firstWhere((g) => g.id == gameId,
              orElse: () => Game(
                  id: gameId, team1: '', team2: '', winner: '', spread: 0.0));
          if (game != null) {
            if (game.winner.isNotEmpty) {
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
    final gameProvider = Provider.of<GameProvider>(context);
    final leaderboardProvider = Provider.of<LeaderboardProvider>(context);
    final totalGames = gameProvider.games.length;
    final users = _searchQuery.isEmpty
        ? leaderboardProvider.entries
        : leaderboardProvider.entries
            .where((entry) => entry.username
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
            .toList();

    users.sort((a, b) => b.correctPicks.compareTo(a.correctPicks));

    return Scaffold(
      appBar: AppBar(title: Text('Leaderboard'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: "Search Users"),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            SizedBox(height: 10),
            Text(
              'Total Games: $totalGames',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.refresh),
              label: Text("Recalculate Odds"),
              onPressed: _runSimulation,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (ctx, i) {
                  final entry = users[i];
                  final winProb = winProbabilities[entry.username] ?? 0.0;
                  return Card(
                    child: ListTile(
                      title: Text(entry.username),
                      subtitle: Text('Correct Picks: ${entry.correctPicks}'),
                      trailing: Text(
                        'Win Odds: ${(winProb * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: winProb > 0.5 ? Colors.green : Colors.black,
                        ),
                      ),
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
