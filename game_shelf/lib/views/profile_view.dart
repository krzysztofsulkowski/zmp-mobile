import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:game_shelf/services/api_service.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _apiService = ApiService();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  Map<String, dynamic>? _user;
  bool _isLoading = true;
  File? _avatarFile;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final user = await _apiService.getData('authentication/me');
      setState(() {
        _user = user;
        _nameController.text = user['userName'] ?? '';
        _bioController.text = user['bio'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAvatar() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _avatarFile = File(pickedFile.path));
    }
  }

  Future<void> _handleUpdate() async {
    setState(() => _isLoading = true);
    try {
      final fields = {
        'Username': _nameController.text.trim(),
        'Bio': _bioController.text.trim(),
      };
      
      // Use the robust sendMultipart method with PUT and 'Avatar' key
      await _apiService.sendMultipart(
        endpoint: 'authentication/update-profile',
        method: 'PUT',
        fields: fields,
        imageFile: _avatarFile, // Can be null
        fileKey: 'Avatar',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil zaktualizowany!', style: TextStyle(color: Colors.white))),
        );
        _fetchProfile();
        setState(() => _avatarFile = null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd aktualizacji: $e', style: const TextStyle(color: Colors.white))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    try { 
      await _apiService.postData('authentication/logout', {}); 
    } catch (_) {}
    await _apiService.logout();
    if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D0B26),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
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
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickAvatar,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white10,
                      backgroundImage: _avatarFile != null 
                        ? FileImage(_avatarFile!) 
                        : (_user?['avatarUrl'] != null 
                            ? NetworkImage(_user!['avatarUrl']) as ImageProvider
                            : null),
                      child: (_avatarFile == null && (_user == null || _user!['avatarUrl'] == null))
                        ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
                        : null,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildTextField('Nazwa użytkownika', _nameController),
                  const SizedBox(height: 16),
                  _buildTextField('Bio', _bioController, maxLines: 3),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _handleUpdate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B39FD),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text('Zapisz zmiany', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      onPressed: _handleLogout,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text('Wyloguj', style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}
