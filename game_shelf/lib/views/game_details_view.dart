import 'package:flutter/material.dart';
import 'package:game_shelf/models/collection.dart';
import 'package:game_shelf/models/game.dart';
import 'package:game_shelf/views/move_game_view.dart';
import 'package:game_shelf/services/api_service.dart';

class GameDetailsView extends StatefulWidget {
  final Game game;
  final int collectionId;
  final List<Collection> allCollections;
  final VoidCallback onRefresh;

  const GameDetailsView({
    super.key,
    required this.game,
    required this.collectionId,
    required this.allCollections,
    required this.onRefresh,
  });

  @override
  State<GameDetailsView> createState() => _GameDetailsViewState();
}

class _GameDetailsViewState extends State<GameDetailsView> {
  final _apiService = ApiService();

  Future<void> _removeFromCollection() async {
    try {
      await _apiService.deleteData('games/remove-from-collection/${widget.game.id}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gra usunięta z kolekcji.')));
        widget.onRefresh();
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Błąd: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D0B26),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0B26), Color(0xFF251B45), Color(0xFF0D0B26)],
          ),
        ),
        child: Column(
          children: [
            if (widget.game.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(widget.game.imageUrl, height: 250, width: double.infinity, fit: BoxFit.cover),
              ),
            const SizedBox(height: 24),
            Text(widget.game.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MoveGameView(
                        game: widget.game,
                        currentCollectionId: widget.collectionId,
                        allCollections: widget.allCollections,
                      ),
                    ),
                  );
                  if (result == true) {
                    widget.onRefresh();
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7B39FD)),
                child: const Text('Przenieś grę', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: _removeFromCollection,
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                child: const Text('Usuń z kolekcji', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
