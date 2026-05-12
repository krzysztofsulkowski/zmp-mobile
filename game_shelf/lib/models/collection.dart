import 'package:game_shelf/models/game.dart';

class Collection {
  final int id;
  final String name;
  final bool isPublic;
  final List<Game> games;

  Collection({
    required this.id,
    required this.name,
    required this.isPublic,
    required this.games,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['collectionId'] ?? json['id'] ?? json['Id'] ?? 0,
      name: json['collectionName'] ?? json['name'] ?? json['Name'] ?? 'Bez nazwy',
      isPublic: json['isPublic'] ?? json['IsPublic'] ?? false,
      // API uses "games" which contains objects with "gameId"
      games: (json['games'] as List?)
              ?.map((g) => Game.fromJson(g))
              .toList() ??
          [],
    );
  }
}
