import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:game_shelf/services/api_service.dart';
import 'package:game_shelf/models/genre.dart';
import 'package:game_shelf/models/platform.dart';
import 'package:game_shelf/widgets/custom_text_field.dart';

class AddGameView extends StatefulWidget {
  const AddGameView({super.key});

  @override
  State<AddGameView> createState() => _AddGameViewState();
}

class _AddGameViewState extends State<AddGameView> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _apiService = ApiService();
  final _picker = ImagePicker();

  File? _imageFile;
  List<Genre> _genres = [];
  List<PlatformModel> _platforms = [];
  int? _selectedGenreId;
  int? _selectedPlatformId;
  bool _isLoading = false;
  bool _isFetchingInitial = true;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      final genresData = await _apiService.getData('games/genres');
      final platformsData = await _apiService.getData('games/platforms');

      setState(() {
        _genres = (genresData as List).map((e) => Genre.fromJson(e)).toList();
        _platforms = (platformsData as List).map((e) => PlatformModel.fromJson(e)).toList();
        _isFetchingInitial = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd pobierania danych: $e', style: const TextStyle(color: Colors.white))),
        );
        setState(() => _isFetchingInitial = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _handleSubmit() async {
    if (_titleController.text.isEmpty || _selectedGenreId == null || _selectedPlatformId == null || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proszę wypełnić wymagane pola i dodać zdjęcie', style: TextStyle(color: Colors.white))),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _apiService.postMultipartData(
        'games/create-game',
        {
          'Title': _titleController.text.trim(),
          'Description': _descriptionController.text.trim(),
          'GenreId': _selectedGenreId.toString(),
          'PlatformId': _selectedPlatformId.toString(),
        },
        _imageFile!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gra została pomyślnie dodana!', style: TextStyle(color: Colors.white))),
        );
        Navigator.pop(context, true); // Return true to indicate a refresh is needed
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd dodawania gry: $e', style: const TextStyle(color: Colors.white))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj nową grę', style: TextStyle(color: Colors.white)),
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
        child: _isFetchingInitial
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.file(_imageFile!, fit: BoxFit.cover),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, color: Colors.white54, size: 50),
                                  SizedBox(height: 10),
                                  Text('Dodaj okładkę gry', style: TextStyle(color: Colors.white54)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      label: 'Tytuł gry', 
                      controller: _titleController,
                      labelColor: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    // Genre Dropdown
                    _buildDropdown<int>(
                      label: 'Gatunek',
                      value: _selectedGenreId,
                      items: _genres.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name))).toList(),
                      onChanged: (val) => setState(() => _selectedGenreId = val),
                    ),
                    const SizedBox(height: 16),
                    // Platform Dropdown
                    _buildDropdown<int>(
                      label: 'Platforma',
                      value: _selectedPlatformId,
                      items: _platforms.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                      onChanged: (val) => setState(() => _selectedPlatformId = val),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Opis (opcjonalnie)', 
                      controller: _descriptionController,
                      labelColor: Colors.white,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7B39FD),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('DODAJ GRĘ', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDropdown<T>({required String label, required T? value, required List<DropdownMenuItem<T>> items, required Function(T?) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              items: items,
              onChanged: onChanged,
              dropdownColor: Colors.white,
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}
