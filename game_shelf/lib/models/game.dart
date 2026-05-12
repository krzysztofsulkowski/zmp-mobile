class Game {
  final int id;
  final String title;
  final String imageUrl;

  Game({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    // The API response uses "gameId" instead of "id"
    return Game(
      id: json['gameId'] ?? json['id'] ?? 0,
      title: json['title'] ?? json['Title'] ?? 'Bez nazwy',
      // If imageUrl is null, use a placeholder
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/150',
    );
  }
}
