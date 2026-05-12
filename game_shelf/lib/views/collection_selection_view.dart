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
          final List dataList = response is List ? response : [];
          _collections = dataList.map((json) => Collection.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd pobierania: $e', style: const TextStyle(color: Colors.white))),
        );
      }
    }
  }

  Future<void> _createOrUpdateCollection({int? id, String? initialName, bool? initialIsPublic}) async {
    _nameController.text = initialName ?? '';
    bool isPublic = initialIsPublic ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1640),
          title: Text(id == null ? 'Nowa kolekcja' : 'Edytuj kolekcję', style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Nazwa kolekcji',
                  hintStyle: TextStyle(color: Colors.white54),
                ),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Publiczna', style: TextStyle(color: Colors.white)),
                value: isPublic,
                onChanged: (val) => setDialogState(() => isPublic = val ?? false),
                activeColor: const Color(0xFF7B39FD),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Anuluj', style: TextStyle(color: Colors.white70))),
            ElevatedButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                if (name.isEmpty) return;
                try {
                  final body = {'Name': name, 'IsPublic': isPublic};
                  if (id == null) {
                    await _apiService.postData('collections/create', body);
                  } else {
                    await _apiService.putData('collections/update', {...body, 'Id': id});
                  }
                  Navigator.pop(context);
                  _fetchCollections();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Błąd: $e')));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7B39FD)),
              child: const Text('Zapisz', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteCollection(int id) async {
    try {
      await _apiService.deleteData('collections/delete/$id');
      _fetchCollections();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Błąd usuwania: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Twoje Kolekcje', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D0B26),
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
                    child: ListView.builder(
                      itemCount: _collections.length,
                      itemBuilder: (context, index) {
                        final col = _collections[index];
                        return Card(
                          color: Colors.white10,
                          child: ListTile(
                            onTap: () => Navigator.pop(context, col),
                            title: Text(col.name, style: const TextStyle(color: Colors.white)),
                            subtitle: Text(col.isPublic ? 'Publiczna' : 'Prywatna', style: const TextStyle(color: Colors.white54)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _createOrUpdateCollection(id: col.id, initialName: col.name, initialIsPublic: col.isPublic)),
                                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteCollection(col.id)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: ElevatedButton.icon(
                      onPressed: () => _createOrUpdateCollection(),
                      icon: const Icon(Icons.add),
                      label: const Text('STWÓRZ NOWĄ KOLEKCJĘ'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
