import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:game_shelf/widgets/library_widget.dart';
import 'package:game_shelf/widgets/friends_widget.dart';
import 'package:game_shelf/widgets/stats_widget.dart';
import 'package:game_shelf/views/profile_view.dart';
import 'package:game_shelf/services/api_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _apiService = ApiService();
  int _selectedIndex = 2; // Default to Home icon (index 2)
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final user = await _apiService.getData('authentication/me');
      if (mounted) {
        setState(() {
          _avatarUrl = user['avatarUrl'];
        });
      }
    } catch (e) {
      debugPrint('Error fetching profile for avatar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0B26), Color(0xFF251B45), Color(0xFF0D0B26)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40),
                    SvgPicture.asset('assets/images/logo.svg', height: 50),
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileView()));
                        _fetchProfile();
                      },
                      child: CircleAvatar(
                        backgroundColor: const Color(0xFF7B39FD),
                        backgroundImage: (_avatarUrl != null && _avatarUrl!.isNotEmpty) ? NetworkImage(_avatarUrl!) : null,
                        child: (_avatarUrl == null || _avatarUrl!.isEmpty) ? const Icon(Icons.person, color: Colors.white) : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(_getTitle(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)),
              const SizedBox(height: 20),
              Expanded(child: _getSelectedWidget()),
              Container(
                height: 70,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(40)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavIcon(Icons.public, 0),
                    _buildNavIcon(Icons.group, 1),
                    _buildNavIcon(Icons.home_outlined, 2),
                    _buildNavIcon(Icons.pie_chart_outline, 3),
                    _buildNavIcon(Icons.notifications_none, 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0: return 'Społeczność';
      case 1: return 'Znajomi';
      case 2: return 'Twoje kolekcje';
      case 3: return 'Statystyki';
      case 4: return 'Powiadomienia';
      default: return 'game SHELF';
    }
  }

  Widget _getSelectedWidget() {
    switch (_selectedIndex) {
      case 1: return const FriendsWidget();
      case 2: return const LibraryWidget();
      case 3: return const StatsWidget();
      default: return const Center(child: Text('W budowie', style: TextStyle(color: Colors.white)));
    }
  }

  Widget _buildNavIcon(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Icon(icon, color: isSelected ? Colors.white : Colors.white54, size: 28),
    );
  }
}
