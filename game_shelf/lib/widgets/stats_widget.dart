import 'package:flutter/material.dart';
import 'package:game_shelf/services/api_service.dart';
import 'package:game_shelf/widgets/main_container.dart';

class StatsWidget extends StatefulWidget {
  const StatsWidget({super.key});

  @override
  State<StatsWidget> createState() => _StatsWidgetState();
}

class _StatsWidgetState extends State<StatsWidget> {
  final _apiService = ApiService();
  Map<String, dynamic>? _libraryStats;
  Map<String, dynamic>? _globalStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final libraryData = await _apiService.getData('statistics/my-library');
      final globalData = await _apiService.getData('statistics/global');
      
      if (mounted) {
        setState(() {
          _libraryStats = libraryData;
          _globalStats = globalData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd pobierania statystyk: $e', style: const TextStyle(color: Colors.white))),
        );
      }
    }
  }

  String _getFavoriteGenre() {
    if (_libraryStats == null || _libraryStats!['gamesByGenre'] == null) return '-';
    List genres = _libraryStats!['gamesByGenre'];
    if (genres.isEmpty) return '-';
    
    var favorite = genres.reduce((a, b) => (a['value'] ?? 0) >= (b['value'] ?? 0) ? a : b);
    return favorite['label'] ?? '-';
  }

  String _getMostPopularGame() {
    if (_globalStats == null || _globalStats!['mostPopularGames'] == null) return '-';
    List games = _globalStats!['mostPopularGames'];
    if (games.isEmpty) return '-';
    
    var popular = games.reduce((a, b) => (a['value'] ?? 0) >= (b['value'] ?? 0) ? a : b);
    return popular['label'] ?? '-';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    return MainContainer(
      child: RefreshIndicator(
        onRefresh: _fetchStats,
        color: const Color(0xFF7B39FD),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 10),
          children: [
            _buildSectionHeader('Twoja Biblioteka'),
            const SizedBox(height: 12),
            _buildStatCard('Wszystkie gry', _libraryStats?['totalGames']?.toString() ?? '0', Icons.gamepad_outlined),
            _buildStatCard('Ulubiony gatunek', _getFavoriteGenre(), Icons.favorite_outline),
            
            const SizedBox(height: 32),
            _buildSectionHeader('Globalne Statystyki'),
            const SizedBox(height: 12),
            _buildStatCard('Liczba użytkowników', _globalStats?['totalUsers']?.toString() ?? '0', Icons.people_outline),
            _buildStatCard('Wszystkie gry w systemie', _globalStats?['totalGamesInLibrary']?.toString() ?? '0', Icons.library_books_outlined),
            _buildStatCard('Najpopularniejsza gra', _getMostPopularGame(), Icons.star_outline),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF7B39FD), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
