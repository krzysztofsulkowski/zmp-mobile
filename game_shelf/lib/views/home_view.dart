import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:game_shelf/models/collection.dart';
import 'package:game_shelf/views/collection_selection_view.dart';
import 'package:game_shelf/views/game_selection_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;
  Collection? _selectedCollection;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D0B26),
              Color(0xFF251B45),
              Color(0xFF0D0B26),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              SvgPicture.asset(
                'assets/images/logo.svg',
                height: 60,
              ),
              const SizedBox(height: 10),
              const Text(
                'Twoje kolekcje',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
              // Main Container
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      TextButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CollectionSelectionView(),
                            ),
                          );
                          if (result != null && result is Collection) {
                            setState(() {
                              _selectedCollection = result;
                            });
                          }
                        },
                        child: Text(
                          _selectedCollection?.name ?? 'Biblioteka',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_selectedCollection == null) ...[
                        const Spacer(),
                        const Text(
                          'Biblioteka to miejsce, w którym znajdziesz wszystkie swoje gry - bez podziału na kategorie.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          'Dodaj swoją pierwszą grę, aby rozpocząć budowanie kolekcji.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                      ] else ...[
                        Expanded(
                          child: _selectedCollection!.games.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Ta kolekcja jest pusta.',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _selectedCollection!.games.length,
                                  itemBuilder: (context, index) {
                                    final game = _selectedCollection!.games[index];
                                    return ListTile(
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          game.imageUrl,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Icon(Icons.gamepad, color: Colors.white),
                                        ),
                                      ),
                                      title: Text(
                                        game.title,
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const GameSelectionView()),
                            );
                          },
                          icon: const Icon(Icons.add_circle_outline, color: Colors.white70),
                          label: const Text(
                            'dodaj pierwszą grę',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5A4C8B).withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              // Bottom Nav
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
