import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/game.dart';
import 'models/leaderboard_entry.dart';
import 'providers/game_provider.dart';
import 'providers/leaderboard_provider.dart';
import 'pages/user_page.dart';
import 'pages/admin_page.dart';
import 'pages/leaderboard_page.dart';
import 'theme.dart'; // Import theme

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(GameAdapter());
  Hive.registerAdapter(LeaderboardEntryAdapter());

  await Hive.openBox<Game>('games');
  await Hive.openBox<LeaderboardEntry>('leaderboard');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
      ],
      child: MaterialApp(
        title: 'College Football Spread Game',
        theme: georgiaTechTheme, // Use theme
        initialRoute: '/',
        routes: {
          '/': (context) => UserPage(),
          '/admin': (context) => AdminPage(),
          '/leaderboard': (context) => LeaderboardPage(),
        },
      ),
    );
  }
}
