import 'package:flutter/material.dart';
import 'package:game_shelf/models/game.dart';
import 'package:game_shelf/services/api_service.dart';
import 'package:game_shelf/views/add_game_view.dart';

class GameSelectionView extends StatefulWidget {
  const GameSelectionView({super.key});

  @override
  State<GameSelectionView> createState() => _GameSelectionViewState();
}

class _GameSelectionViewState extends State<GameSelectionView> {
  final _apiService = ApiService();
  List<Game> _availableGames = [];
  bool _isLoading = true;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchGames();
  }

  Future<void> _fetchGames() async {
    setState(() => _isLoading = true);
    try {
      // Based on your API error, it expects these specific flat keys:
      // "search[value]" and "order[0][dir]"
      final response = await _apiService.postData('games/available-table', {
        'draw': 1,
        'start': 0,
        'length': 100,
        'search[value]': _searchQuery,
        'search[regex]': false,
        'order[0][column]': 0,
        'order[0][dir]': 'asc',
      });

      if (mounted) {
        setState(() {
          // Check if data is nested or direct
          final List dataList = response['data'] ?? [];
          _availableGames = dataList.map((json) => Game.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd: $e')),
        );
      }
    }
  }

  Future<void> _addGameToCollection(int gameId) async {
    try {
      await _apiService.postData('games/add-to-collection/$gameId', {});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gra dodana do Twojej kolekcji!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd dodawania: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wybierz grę', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF0D0B26),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0B26), Color(0xFF251B45), Color(0xFF0D0B26)],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Szukaj gry...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  _searchQuery = value;
                  _fetchGames();
                },
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _availableGames.isEmpty
                      ? const Center(
                          child: Text(
                            'Nie znaleziono gier.',
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _availableGames.length,
                          itemBuilder: (context, index) {
                            final game = _availableGames[index];
                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  game.imageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.gamepad, color: Colors.white),
                                ),
                              ),
                              title: Text(
                                game.title,
                                style: const TextStyle(color: Colors.white),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.add_circle, color: Color(0xFF7B39FD)),
                                onPressed: () => _addGameToCollection(game.id),
                              ),
                            );
                          },
                        ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddGameView()),
                    );
                    if (result == true) {
                      Navigator.pop(context, true);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF7B39FD)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Gry nie ma na liście',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
