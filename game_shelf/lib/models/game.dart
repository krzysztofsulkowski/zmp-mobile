class Game {
  final int id;
  final String title;
  final String imageUrl;
  final String? description;
  final String? genreName;
  final String? platformName;
  final String? addedAt;
  final double? averageRating;
  final int? userRating;

  Game({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.description,
    this.genreName,
    this.platformName,
    this.addedAt,
    this.averageRating,
    this.userRating,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    final imageUrl = json['imageUrl'];
    
    return Game(
      id: json['gameId'] ?? json['id'] ?? 0,
      title: json['title'] ?? json['Title'] ?? 'Bez nazwy',
      imageUrl: (imageUrl != null && imageUrl is String && imageUrl.isNotEmpty) 
          ? imageUrl 
          : 'https://placehold.co/150x150/png',
      description: json['description'],
      genreName: json['genreName'],
      platformName: json['platformName'],
      addedAt: json['addedAt'],
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      userRating: json['userRating'],
    );
  }
}
