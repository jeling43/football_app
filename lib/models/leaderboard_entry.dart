class LeaderboardEntry {
  final String username;
  final Map<String, String> picks;
  final int correctPicks;

  LeaderboardEntry({
    required this.username,
    required this.picks,
    this.correctPicks = 0,
  });

  Map<String, dynamic> toJson() => {
        'picks': picks,
        'correctPicks': correctPicks,
      };

  // Add this static fromJson constructor:
  static LeaderboardEntry fromJson(Map<String, dynamic> json, String id) {
    return LeaderboardEntry(
      username: id,
      picks: Map<String, String>.from(json['picks'] ?? {}),
      correctPicks: json['correctPicks'] ?? 0,
    );
  }
}
