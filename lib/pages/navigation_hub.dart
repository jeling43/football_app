import 'package:flutter/material.dart';
import 'user_page.dart';
import 'admin_page.dart';
import 'leaderboard_page.dart';

class NavigationHub extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Navigation Hub')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserPage()),
              ),
              child: Text('User Page'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminPage()),
              ),
              child: Text('Admin Page'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LeaderboardPage()),
              ),
              child: Text('Leaderboard Page'),
            ),
          ],
        ),
      ),
    );
  }
}
