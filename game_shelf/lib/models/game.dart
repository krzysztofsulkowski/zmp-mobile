class Game {
  final int id;
  final String title;
  final int genreId;
  final String imageUrl;

  Game({
    required this.id,
    required this.title,
    required this.genreId,
    required this.imageUrl,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      title: json['title'],
      genreId: json['genreId'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'genreId': genreId,
      'imageUrl': imageUrl,
    };
  }
}
