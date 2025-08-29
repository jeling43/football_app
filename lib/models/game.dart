class Game {
  final String id;
  final String team1;
  final String team2;
  final double spread;
  final String? winner;

  Game({
    required this.id,
    required this.team1,
    required this.team2,
    required this.spread,
    this.winner,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'team1': team1,
      'team2': team2,
      'spread': spread,
      'winner': winner,
    };
  }

  factory Game.fromMap(Map<String, dynamic> map, String documentId) {
    return Game(
      id: documentId,
      team1: map['team1'] ?? '',
      team2: map['team2'] ?? '',
      spread: (map['spread'] as num?)?.toDouble() ?? 0.0,
      winner: map['winner'],
    );
  }
}
