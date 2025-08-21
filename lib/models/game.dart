import 'package:hive/hive.dart';

part 'game.g.dart';

@HiveType(typeId: 0)
class Game extends HiveObject {
  @HiveField(0)
  final String team1;
  @HiveField(1)
  final String team2;
  @HiveField(2)
  final double spread;
  @HiveField(3)
  String winner;
  @HiveField(4)
  DateTime createdAt;

  Game({
    required this.team1,
    required this.team2,
    required this.spread,
    this.winner = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
