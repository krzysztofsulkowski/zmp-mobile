import 'package:flutter/material.dart';
import 'package:game_shelf/models/collection.dart';
import 'package:game_shelf/views/collection_selection_view.dart';
import 'package:game_shelf/views/game_selection_view.dart';
import 'package:game_shelf/services/api_service.dart';
import 'package:game_shelf/widgets/main_container.dart';

class LibraryWidget extends StatefulWidget {
  const LibraryWidget({super.key});

  @override
  State<LibraryWidget> createState() => _LibraryWidgetState();
}

class _LibraryWidgetState extends State<LibraryWidget> {
  final _apiService = ApiService();
  Collection? _selectedCollection;
  bool _isLoadingGames = false;

  Future<void> _fetchCollectionGames() async {
    if (_selectedCollection == null) return;
    setState(() => _isLoadingGames = true);
    try {
      final response = await _apiService.postData('collections/grouped-with-games', {
        'draw': 1, 'start': 0, 'length': 100, 'searchValue': '', 'orderColumn': 0, 'orderDir': 'asc',
      });
      if (mounted) {
        final List dataList = response['data'] ?? [];
        final updated = dataList.firstWhere((c) => c['collectionId'] == _selectedCollection!.id, orElse: () => null);
        if (updated != null) setState(() => _selectedCollection = Collection.fromJson(updated));
        setState(() => _isLoadingGames = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingGames = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Błąd: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainContainer(
      child: Column(
        children: [
          TextButton(
            onPressed: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const CollectionSelectionView()));
              if (result != null && result is Collection) {
                setState(() { _selectedCollection = result; });
                _fetchCollectionGames();
              }
            },
            child: Text(_selectedCollection?.name ?? 'Biblioteka', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
          ),
          const SizedBox(height: 20),
          if (_selectedCollection == null) ...[
            const Spacer(),
            const Text('Wybierz kolekcję, aby wyświetlić gry.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16)),
            const Spacer(),
          ] else if (_isLoadingGames) ...[
            const Spacer(),
            const CircularProgressIndicator(color: Colors.white),
            const Spacer(),
          ] else if (_selectedCollection!.games.isEmpty) ...[
            const Spacer(),
            const Text('Ta kolekcja jest pusta.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
            const Spacer(),
          ] else ...[
            Expanded(
              child: ListView.builder(
                itemCount: _selectedCollection!.games.length,
                itemBuilder: (context, index) {
                  final game = _selectedCollection!.games[index];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(game.imageUrl, width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.gamepad, color: Colors.white)),
                    ),
                    title: Text(game.title, style: const TextStyle(color: Colors.white)),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => GameSelectionView(collectionId: _selectedCollection?.id)));
                if (result == true) _fetchCollectionGames();
              },
              icon: const Icon(Icons.add_circle_outline, color: Colors.white70),
              label: const Text('dodaj grę', style: TextStyle(color: Colors.white70, fontSize: 18)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5A4C8B).withOpacity(0.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            ),
          ),
        ],
      ),
    );
  }
}
