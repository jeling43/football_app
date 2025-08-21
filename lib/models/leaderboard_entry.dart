import 'package:hive/hive.dart';

part 'leaderboard_entry.g.dart';

@HiveType(typeId: 1)
class LeaderboardEntry extends HiveObject {
  @HiveField(0)
  String username;
  @HiveField(1)
  Map<int, String> picks; // game index to pick
  @HiveField(2)
  int correctPicks;
  @HiveField(3)
  DateTime createdAt;

  LeaderboardEntry({
    required this.username,
    required this.picks,
    this.correctPicks = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
