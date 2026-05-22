import 'package:flutter/material.dart';

class GameImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double height;
  final double width;
  final double borderRadius;

  const GameImageWidget({
    super.key,
    this.imageUrl,
    this.height = 200,
    this.width = double.infinity,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.white24),
      ),
      child: (imageUrl != null && imageUrl!.isNotEmpty)
          ? ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
              ),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.gamepad, color: Colors.white54, size: 50),
        SizedBox(height: 10),
        Text('Brak okładki', style: TextStyle(color: Colors.white54)),
      ],
    );
  }
}
