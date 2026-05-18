import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:game_shelf/widgets/library_widget.dart';
import 'package:game_shelf/widgets/friends_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

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
              SvgPicture.asset('assets/images/logo.svg', height: 60),
              const SizedBox(height: 10),
              Text(
                _selectedIndex == 0 ? 'Twoje kolekcje' : (_selectedIndex == 2 ? 'Znajomi' : 'Społeczność'),
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              
              Expanded(
                child: _selectedIndex == 0 
                  ? const LibraryWidget() 
                  : (_selectedIndex == 2 ? const FriendsWidget() : const Center(child: Text('Społeczność', style: TextStyle(color: Colors.white)))),
              ),
              
              Container(
                height: 70,
                color: Colors.black.withOpacity(0.3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavButton('STRONA GŁÓWNA', 0),
                    _buildNavButton('SPOŁECZNOŚĆ', 1),
                    _buildNavButton('ZNAJOMI', 2),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white54,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
