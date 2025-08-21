import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/leaderboard_provider.dart';
import '../models/game.dart';
import '../models/leaderboard_entry.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  String _username = '';
  Map<int, String> _userPicks = {};
  final TextEditingController _usernameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final games = Provider.of<GameProvider>(context).games;

    return Scaffold(
      appBar: AppBar(
        title: Text('User Page'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: "Username",
                prefixIcon:
                    Icon(Icons.person, color: Theme.of(context).primaryColor),
              ),
              onChanged: (value) {
                setState(() {
                  _username = value;
                });
              },
            ),
            SizedBox(height: 16),
            Expanded(
              child: games.isEmpty
                  ? Center(
                      child: Text(
                        'No games available. Check back soon!',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    )
                  : ListView.builder(
                      itemCount: games.length,
                      itemBuilder: (ctx, i) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 18),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${games[i].team1} vs ${games[i].team2}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 18,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text('Spread: ${games[i].spread}',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary)),
                                  ],
                                ),
                                DropdownButton<String>(
                                  hint: Text('Pick Winner'),
                                  value: _userPicks[i],
                                  items: [
                                    DropdownMenuItem(
                                      value: games[i].team1,
                                      child: Text(games[i].team1),
                                    ),
                                    DropdownMenuItem(
                                      value: games[i].team2,
                                      child: Text(games[i].team2),
                                    ),
                                  ],
                                  onChanged: (pick) {
                                    setState(() {
                                      _userPicks[i] = pick!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(height: 14),
            ElevatedButton.icon(
              icon: Icon(Icons.send),
              label: Text("Submit Picks"),
              onPressed: () {
                if (_username.isEmpty) return;
                Provider.of<LeaderboardProvider>(context, listen: false)
                    .addOrUpdateEntry(
                  LeaderboardEntry(
                      username: _username, picks: Map.from(_userPicks)),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Picks submitted!'),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                );
                // RESET for next user:
                setState(() {
                  _username = '';
                  _userPicks.clear();
                  _usernameController.clear();
                });
              },
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.leaderboard),
                  label: Text("Leaderboard"),
                  onPressed: () => Navigator.pushNamed(context, '/leaderboard'),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.admin_panel_settings),
                  label: Text("Admin"),
                  onPressed: () => Navigator.pushNamed(context, '/admin'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
