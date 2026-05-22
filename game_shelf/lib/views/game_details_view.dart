import 'package:flutter/material.dart';
import 'package:game_shelf/models/collection.dart';
import 'package:game_shelf/models/game.dart';
import 'package:game_shelf/views/move_game_view.dart';
import 'package:game_shelf/services/api_service.dart';
import 'package:game_shelf/widgets/game_image_widget.dart';
import 'package:intl/intl.dart';

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
  late int _userRating;
  double? _averageRating;
  bool _isLoadingAverage = false;

  @override
  void initState() {
    super.initState();
    // Initialize rating from the game object passed from the list
    _userRating = widget.game.userRating ?? 0;
    _averageRating = widget.game.averageRating;
    _fetchAverageRating();
  }

  Future<void> _fetchAverageRating() async {
    setState(() => _isLoadingAverage = true);
    try {
      final response = await _apiService.getData('games/${widget.game.id}/average-rating');
      if (mounted) {
        setState(() {
          if (response is Map) {
            _averageRating = (response['averageRating'] as num?)?.toDouble();
          } else if (response is num) {
            _averageRating = response.toDouble();
          }
          _isLoadingAverage = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching average rating: $e');
      if (mounted) setState(() => _isLoadingAverage = false);
    }
  }

  Future<void> _rateGame(int rating) async {
    try {
      // POST to /api/games/rate
      await _apiService.postData('games/rate', {
        'gameId': widget.game.id,
        'rating': rating,
      });
      
      setState(() {
        _userRating = rating;
      });

      // Refresh average rating after scoring
      await _fetchAverageRating();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Twoja ocena: $rating/10')),
        );
        // Call refresh so the parent list (LibraryWidget) gets the new rating next time
        widget.onRefresh();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Błąd oceniania: $e')));
      }
    }
  }

  Future<void> _removeFromCollection() async {
    try {
      await _apiService.deleteData('games/remove-from-collection/${widget.game.id}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gra usunięta z kolekcji.')));
        widget.onRefresh();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Błąd: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = '-';
    if (widget.game.addedAt != null) {
      try {
        DateTime dt = DateTime.parse(widget.game.addedAt!);
        formattedDate = DateFormat('dd.MM.yyyy').format(dt);
      } catch (_) {}
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D0B26),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0B26), Color(0xFF251B45), Color(0xFF0D0B26)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GameImageWidget(imageUrl: widget.game.imageUrl, height: 300),
              const SizedBox(height: 24),
              Text(
                widget.game.title,
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.game.platformName ?? 'Nieznana platforma'} | ${widget.game.genreName ?? 'Nieznany gatunek'}',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.white24),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoColumn(
                    'Średnia ocena', 
                    _isLoadingAverage ? '...' : '${_averageRating?.toStringAsFixed(1) ?? '-'}/10'
                  ),
                  _buildInfoColumn('Data dodania', formattedDate),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Twoja ocena',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Center(
                child: Wrap(
                  spacing: 4,
                  children: List.generate(10, (index) {
                    int starValue = index + 1;
                    return GestureDetector(
                      onTap: () => _rateGame(starValue),
                      child: Icon(
                        starValue <= _userRating ? Icons.star : Icons.star_border,
                        color: starValue <= _userRating ? Colors.amber : Colors.white24,
                        size: 30,
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 55,
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B39FD),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('Przenieś grę', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: _removeFromCollection,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('Usuń z kolekcji', style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
