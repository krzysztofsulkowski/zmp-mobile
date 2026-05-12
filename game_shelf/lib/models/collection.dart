import 'package:game_shelf/models/game.dart';

class Collection {
  final int id;
  final String name;
  final List<Game> games;

  Collection({
    required this.id,
    required this.name,
    required this.games,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['id'] ?? json['Id'] ?? 0,
      name: json['name'] ?? json['Name'] ?? 'Bez nazwy',
      games: (json['games'] ?? json['Games'] as List?)
              ?.map((g) => Game.fromJson(g))
              .toList() ??
          [],
    );
  }
}
