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
    // Also ensuring imageUrl is handled if null or invalid
    final imageUrl = json['imageUrl'];
    
    return Game(
      id: json['gameId'] ?? json['id'] ?? 0,
      title: json['title'] ?? json['Title'] ?? 'Bez nazwy',
      // We check if imageUrl is a valid URL, otherwise provide a fallback
      imageUrl: (imageUrl != null && imageUrl is String && imageUrl.isNotEmpty) 
          ? imageUrl 
          : 'https://placehold.co/150x150/png',
    );
  }
}
