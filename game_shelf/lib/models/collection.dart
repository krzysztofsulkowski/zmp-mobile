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
      id: json['id'] ?? json['Id'] ?? 0,
      name: json['name'] ?? json['Name'] ?? 'Bez nazwy',
      isPublic: json['isPublic'] ?? json['IsPublic'] ?? false,
      games: (json['games'] ?? json['Games'] as List?)
              ?.map((g) => Game.fromJson(g))
              .toList() ??
          [],
    );
  }
}
