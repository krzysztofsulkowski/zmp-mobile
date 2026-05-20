import 'package:flutter/material.dart';
import 'package:game_shelf/models/collection.dart';
import 'package:game_shelf/models/game.dart';
import 'package:game_shelf/services/api_service.dart';

class MoveGameView extends StatefulWidget {
  final Game game;
  final int currentCollectionId;
  final List<Collection> allCollections;

  const MoveGameView({
    super.key,
    required this.game,
    required this.currentCollectionId,
    required this.allCollections,
  });

  @override
  State<MoveGameView> createState() => _MoveGameViewState();
}

class _MoveGameViewState extends State<MoveGameView> {
  final _apiService = ApiService();
  Collection? _selectedTargetCollection;

  Future<void> _moveGame() async {
    if (_selectedTargetCollection == null) return;

    try {
      // API expects IDs as integers, ensured by .toInt()
      final body = {
        'gameId': widget.game.id.toInt(),
        'currentCollectionId': widget.currentCollectionId.toInt(),
        'targetCollectionId': _selectedTargetCollection!.id.toInt(),
      };

      print('Moving game with body: $body');

      await _apiService.postData('games/move-game', body);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gra została przeniesiona!', style: TextStyle(color: Colors.white))),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd przenoszenia: $e', style: const TextStyle(color: Colors.white))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter out the current collection
    final targetCollections = widget.allCollections
        .where((c) => c.id != widget.currentCollectionId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Przenieś grę', style: TextStyle(color: Colors.white)),
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
            Text('Przenieś: ${widget.game.title}', style: const TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 20),
            DropdownButtonFormField<Collection>(
              decoration: const InputDecoration(labelText: 'Wybierz nową kolekcję', labelStyle: TextStyle(color: Colors.white)),
              dropdownColor: const Color(0xFF1A1640),
              style: const TextStyle(color: Colors.white),
              items: targetCollections.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
              onChanged: (val) => setState(() => _selectedTargetCollection = val),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _selectedTargetCollection != null ? _moveGame : null,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7B39FD)),
              child: const Text('Przenieś', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
