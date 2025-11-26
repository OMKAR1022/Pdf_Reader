import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePreviewItem extends StatelessWidget {
  final XFile image;
  final int index;
  final VoidCallback onRemove;
  final VoidCallback onCrop;

  const ImagePreviewItem({
    super.key,
    required this.image,
    required this.index,
    required this.onRemove,
    required this.onCrop,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(image.path),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          
          // Gradient overlay for better visibility of controls
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
            ),
          ),
          
          // Page number badge
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Page ${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Remove button
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.red,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
          
          // Crop/Edit button
          Positioned(
            bottom: 8,
            right: 8,
            child: Material(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: onCrop,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.crop,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          
          // Drag handle indicator
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.drag_indicator,
                color: Colors.grey[700],
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
