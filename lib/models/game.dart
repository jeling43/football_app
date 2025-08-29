class Game {
  final String id;
  final String team1;
  final String team2;
  final double spread;
  final String winner;

  Game(
      {required this.id,
      required this.team1,
      required this.team2,
      required this.spread,
      this.winner = ''});

  Map<String, dynamic> toJson() => {
        'team1': team1,
        'team2': team2,
        'spread': spread,
        'winner': winner,
      };

  static Game fromJson(Map<String, dynamic> json, String id) => Game(
        id: id,
        team1: json['team1'],
        team2: json['team2'],
        spread: (json['spread'] as num).toDouble(),
        winner: json['winner'] ?? '',
      );
}
