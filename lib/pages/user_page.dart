import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/about');
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: gameProvider.games.isEmpty
            ? Center(
                child: Text(
                  'No games available',
                  style: TextStyle(fontSize: 18),
                ),
              )
            : ListView.builder(
                itemCount: gameProvider.games.length,
                itemBuilder: (context, index) {
                  final game = gameProvider.games[index];
                  final gameId = game['id']?.toString() ??
                      index.toString(); // Always a string
                  return Card(
                    key: ValueKey(gameId), // Local key, safe for ListView
                    child: ListTile(
                      title: Text(
                        '${game['team1'] ?? 'Unknown'} vs ${game['team2'] ?? 'Unknown'}',
                      ),
                      subtitle: Text(
                        'Spread: ${game['spread'] ?? 'N/A'}',
                      ),
                      trailing: game['winner'] != null
                          ? Text(
                              'Winner: ${game['winner']}',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : ElevatedButton(
                              key: ValueKey(
                                  'button_$gameId'), // Local key, unique per button
                              child: Text('Predict Winner'),
                              onPressed: () {
                                print(
                                    'Predict Winner button pressed for game ID: $gameId');
                                _showPredictWinnerDialog(context, gameId);
                              },
                            ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _showPredictWinnerDialog(BuildContext context, String gameId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Predict Winner'),
        content: Text('Predict the winner for game ID: $gameId'),
        actions: [
          TextButton(
            child: Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
