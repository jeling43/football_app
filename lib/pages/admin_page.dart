import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/leaderboard_provider.dart';
import '../models/game.dart';
import '../models/leaderboard_entry.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _team1Controller = TextEditingController();
  final _team2Controller = TextEditingController();
  final _spreadController = TextEditingController();
  String _searchQuery = '';

  // Password protection variables
  bool _authenticated = false;
  final _passwordController = TextEditingController();
  static const String adminPassword = 'football2024'; // Change as needed

  @override
  void dispose() {
    _team1Controller.dispose();
    _team2Controller.dispose();
    _spreadController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_authenticated) {
      return Scaffold(
        appBar: AppBar(title: Text('Admin Login'), centerTitle: true),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Enter Admin Password',
                    style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  child: Text('Login'),
                  onPressed: () {
                    if (_passwordController.text == adminPassword) {
                      setState(() {
                        _authenticated = true;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Incorrect password'),
                          backgroundColor: Colors.red));
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    final gameProvider = Provider.of<GameProvider>(context);
    final leaderboardProvider = Provider.of<LeaderboardProvider>(context);
    final games = gameProvider.games;
    final users = _searchQuery.isEmpty
        ? leaderboardProvider.entries
        : leaderboardProvider.entries
            .where((entry) => entry.username
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(title: Text('Admin Page'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _team1Controller,
                    decoration: InputDecoration(labelText: "Home Team"),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _team2Controller,
                    decoration: InputDecoration(labelText: "Away Team"),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _spreadController,
                    decoration: InputDecoration(labelText: "Spread"),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  child: Text('Add Game'),
                  onPressed: () {
                    if (_team1Controller.text.isEmpty ||
                        _team2Controller.text.isEmpty ||
                        _spreadController.text.isEmpty) return;
                    gameProvider.addGame(Game(
                      id: '', // Firestore will auto-generate the ID
                      team1: _team1Controller.text,
                      team2: _team2Controller.text,
                      spread: double.tryParse(_spreadController.text) ?? 0.0,
                    ));
                    _team1Controller.clear();
                    _team2Controller.clear();
                    _spreadController.clear();
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  child: Text('Clear All Games'),
                  onPressed: () => gameProvider.clearGames(),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  child: Text('Clear All Picks'),
                  onPressed: () => leaderboardProvider.clearAllPicks(),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text('Games', style: Theme.of(context).textTheme.titleLarge),
            Expanded(
              child: ListView.builder(
                itemCount: games.length,
                itemBuilder: (ctx, i) {
                  final game = games[i];
                  return Card(
                    child: ListTile(
                      title: Text('${game.team1} vs ${game.team2}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Spread: ${game.spread}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButton<String>(
                            hint: Text('Winner'),
                            value: game.winner.isNotEmpty ? game.winner : null,
                            items: [
                              DropdownMenuItem(
                                  value: game.team1, child: Text(game.team1)),
                              DropdownMenuItem(
                                  value: game.team2, child: Text(game.team2)),
                            ],
                            onChanged: (winner) {
                              if (winner != null) {
                                gameProvider.setWinnerByKey(
                                    game.id, winner, leaderboardProvider);
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => gameProvider.deleteGame(game.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(labelText: "Search Users"),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (ctx, i) {
                  final entry = users[i];
                  return Card(
                    child: ListTile(
                      title: Text(entry.username),
                      subtitle: Text('Correct Picks: ${entry.correctPicks}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            child: Text('Clear Picks'),
                            onPressed: () => leaderboardProvider
                                .clearUserPicks(entry.username),
                          ),
                          SizedBox(width: 6),
                          ElevatedButton(
                            child: Text('Delete'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: () =>
                                leaderboardProvider.deleteEntry(entry.username),
                          ),
                        ],
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
