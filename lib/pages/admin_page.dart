import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/leaderboard_provider.dart';
import '../models/game.dart';

class AdminPage extends StatelessWidget {
  final TextEditingController _team1Controller = TextEditingController();
  final TextEditingController _team2Controller = TextEditingController();
  final TextEditingController _spreadController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final leaderboardProvider = Provider.of<LeaderboardProvider>(context);

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
                    ).toMap());
                    _team1Controller.clear();
                    _team2Controller.clear();
                    _spreadController.clear();
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: gameProvider.games.length,
                itemBuilder: (context, index) {
                  final game = gameProvider.games[index];
                  return Card(
                    child: ListTile(
                      title: Text('${game['team1']} vs ${game['team2']}'),
                      subtitle: Text('Spread: ${game['spread']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              gameProvider.deleteGame(game['id']);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.check, color: Colors.green),
                            onPressed: () {
                              _showSetWinnerDialog(context, game['id'],
                                  gameProvider, leaderboardProvider);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              child: Text('Clear All Games'),
              onPressed: () {
                gameProvider.clearGames();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSetWinnerDialog(BuildContext context, String gameId,
      GameProvider gameProvider, LeaderboardProvider leaderboardProvider) {
    final TextEditingController _winnerController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Set Winner'),
          content: TextField(
            controller: _winnerController,
            decoration: InputDecoration(labelText: 'Winner'),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Set Winner'),
              onPressed: () {
                if (_winnerController.text.isNotEmpty) {
                  gameProvider.setWinnerByKey(
                    gameId,
                    _winnerController.text,
                    leaderboardProvider,
                  );
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
