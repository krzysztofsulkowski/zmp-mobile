import 'package:flutter/material.dart';
import 'package:game_shelf/services/api_service.dart';
import 'package:game_shelf/models/collection.dart';

class CollectionSelectionView extends StatefulWidget {
  const CollectionSelectionView({super.key});

  @override
  State<CollectionSelectionView> createState() => _CollectionSelectionViewState();
}

class _CollectionSelectionViewState extends State<CollectionSelectionView> {
  final _apiService = ApiService();
  final _nameController = TextEditingController();
  List<Collection> _collections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCollections();
  }

  Future<void> _fetchCollections() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getData('collections/lookup');

      if (mounted) {
        setState(() {
          // The endpoint returns a List directly, not a Map with a 'data' key
          final List dataList = response is List ? response : [];
          _collections = dataList.map((json) => Collection.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd pobierania kolekcji: $e', style: const TextStyle(color: Colors.white))),
        );
      }
    }
  }

  Future<void> _createCollection() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    try {
      await _apiService.postData('collections/create', {
        'Name': name,
        'IsPublic': true,
      });
      
      _nameController.clear();
      if (mounted) {
        Navigator.pop(context); // Close dialog
        _fetchCollections(); // Refresh list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kolekcja została utworzona!', style: TextStyle(color: Colors.white))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd tworzenia kolekcji: $e', style: const TextStyle(color: Colors.white))),
        );
      }
    }
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1640),
        title: const Text('Nowa kolekcja', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Nazwa kolekcji',
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF7B39FD))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anuluj', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: _createCollection,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7B39FD)),
            child: const Text('Utwórz', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Twoje Kolekcje', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            : Column(
                children: [
                  Expanded(
                    child: _collections.isEmpty
                        ? const Center(
                            child: Text(
                              'Nie znaleziono żadnych kolekcji.',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _collections.length,
                            itemBuilder: (context, index) {
                              final collection = _collections[index];
                              return Card(
                                color: Colors.white10,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                child: ListTile(
                                  title: Text(
                                    collection.name,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    'Gier: ${collection.games.length}',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                                  onTap: () {
                                    Navigator.pop(context, collection);
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: _showCreateDialog,
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('STWÓRZ NOWĄ KOLEKCJĘ', 
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7B39FD),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
