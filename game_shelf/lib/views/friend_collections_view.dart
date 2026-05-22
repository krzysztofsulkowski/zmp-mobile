import 'package:flutter/material.dart';
import 'package:game_shelf/services/api_service.dart';
import 'package:game_shelf/models/collection.dart';
import 'package:game_shelf/widgets/main_container.dart';

class FriendCollectionsView extends StatefulWidget {
  final String friendId;
  final String friendName;

  const FriendCollectionsView({
    super.key,
    required this.friendId,
    required this.friendName,
  });

  @override
  State<FriendCollectionsView> createState() => _FriendCollectionsViewState();
}

class _FriendCollectionsViewState extends State<FriendCollectionsView> {
  final _apiService = ApiService();
  List<Collection> _collections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFriendCollections();
  }

  Future<void> _fetchFriendCollections() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getData('friends/${widget.friendId}/collections-with-games');
      if (mounted) {
        setState(() {
          final List dataList = response is List ? response : [];
          _collections = dataList.map((json) => Collection.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd pobierania kolekcji znajomego: $e', style: const TextStyle(color: Colors.white))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kolekcje: ${widget.friendName}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D0B26),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0B26), Color(0xFF251B45), Color(0xFF0D0B26)],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : _collections.isEmpty
                ? const Center(
                    child: Text(
                      'Brak publicznych kolekcji.',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _collections.length,
                    itemBuilder: (context, index) {
                      final collection = _collections[index];
                      return MainContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              collection.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(color: Colors.white24),
                            if (collection.games.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text('Brak gier w tej kolekcji.', style: TextStyle(color: Colors.white54)),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: collection.games.length,
                                itemBuilder: (context, gIndex) {
                                  final game = collection.games[gIndex];
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        game.imageUrl,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => const Icon(Icons.gamepad, color: Colors.white),
                                      ),
                                    ),
                                    title: Text(game.title, style: const TextStyle(color: Colors.white, fontSize: 14)),
                                  );
                                },
                              ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
