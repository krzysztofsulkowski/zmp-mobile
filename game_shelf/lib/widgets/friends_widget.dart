import 'package:flutter/material.dart';
import 'package:game_shelf/services/api_service.dart';
import 'package:game_shelf/widgets/main_container.dart';

class FriendsWidget extends StatefulWidget {
  const FriendsWidget({super.key});

  @override
  State<FriendsWidget> createState() => _FriendsWidgetState();
}

class _FriendsWidgetState extends State<FriendsWidget> {
  final _apiService = ApiService();
  final _searchController = TextEditingController();
  List<dynamic> _friends = [];
  List<dynamic> _pendingRequests = [];
  List<dynamic> _searchResults = [];
  bool _isLoading = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final friends = await _apiService.getData('friends/my-friends');
      final pending = await _apiService.getData('friends/pending-requests');
      if (mounted) {
        setState(() {
          _friends = friends is List ? friends : [];
          _pendingRequests = pending is List ? pending : [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final response = await _apiService.postData('friends/search', {
        'draw': 1, 'start': 0, 'length': 20, 'searchValue': query, 'orderColumn': 0, 'orderDir': 'asc',
      });
      if (mounted) {
        setState(() {
          _searchResults = response['data'] ?? [];
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _acceptInvite(dynamic requesterId) async {
    print('Accepting request for ID: $requesterId');
    await _apiService.postData('friends/accept/$requesterId', {});
    _loadData();
  }

  Future<void> _rejectInvite(dynamic friendId) async {
    print('Rejecting request for ID: $friendId');
    await _apiService.deleteData('friends/reject-or-remove/$friendId');
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return MainContainer(
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            onChanged: _searchUsers,
            decoration: const InputDecoration(
              hintText: 'Szukaj użytkownika...',
              hintStyle: TextStyle(color: Colors.white54),
              prefixIcon: Icon(Icons.search, color: Colors.white54),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : ListView(
                    children: [
                      if (_searchResults.isNotEmpty) ...[
                        const Text('Wyniki wyszukiwania', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                        ..._searchResults.map((user) => ListTile(
                          title: Text(user['userName'] ?? 'Nieznany', style: const TextStyle(color: Colors.white)),
                          trailing: IconButton(
                            icon: const Icon(Icons.person_add, color: Color(0xFF7B39FD)), 
                            onPressed: () async {
                              await _apiService.postData('friends/add-by-username/${user['userName']}', {});
                              _loadData();
                            }
                          ),
                        )),
                      ],
                      if (_pendingRequests.isNotEmpty) ...[
                        const Divider(color: Colors.white24),
                        const Text('Oczekujące zaproszenia', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                        ..._pendingRequests.map((req) {
                          // USE userId AS REQUESTER ID
                          final id = req['userId'];
                          return ListTile(
                            title: Text(req['userName'] ?? 'Nieznany', style: const TextStyle(color: Colors.white)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () => _acceptInvite(id)),
                                IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => _rejectInvite(id)),
                              ],
                            ),
                          );
                        }),
                      ],
                      const Divider(color: Colors.white24),
                      const Text('Znajomi', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                      ..._friends.map((friend) => ListTile(
                        title: Text(friend['userName'] ?? 'Nieznany', style: const TextStyle(color: Colors.white)),
                      )),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
