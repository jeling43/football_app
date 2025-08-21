import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/leaderboard_provider.dart';
import '../models/leaderboard_entry.dart';

class LeaderboardPage extends StatefulWidget {
  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final leaderboardProvider = Provider.of<LeaderboardProvider>(context);
    final totalGames = gameProvider.games.length;
    final users = _searchQuery.isEmpty
        ? leaderboardProvider.entries
        : leaderboardProvider.searchEntries(_searchQuery);

    // Sort users by correct picks descending
    users.sort((a, b) => b.correctPicks.compareTo(a.correctPicks));

    // Calculate win probabilities using Monte Carlo simulation
    final winProbs = leaderboardProvider.calculateWinProbabilities(
        gameProvider.games, users,
        simulations: 1000);

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
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (ctx, i) {
                  final entry = users[i];
                  double probability = winProbs[entry.username] != null
                      ? winProbs[entry.username]! * 100
                      : -1;
                  return Card(
                    child: ListTile(
                      title: Text(entry.username,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Correct Picks: ${entry.correctPicks}'),
                      trailing: Text(
                        probability >= 0
                            ? 'Win Prob: ${probability.toStringAsFixed(1)}%'
                            : 'N/A',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
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
