import 'dart:io';
import 'package:flutter/material.dart';
import '../config/app_config.dart';

class ImagePreviewWidget extends StatelessWidget {
  final String imagePath;
  final VoidCallback? onDelete;
  final VoidCallback? onView;
  final double height;

  const ImagePreviewWidget({
    Key? key,
    required this.imagePath,
    this.onDelete,
    this.onView,
    this.height = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image
        GestureDetector(
          onTap: onView ?? () => _showFullImage(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.file(
                File(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        // Delete Button
        if (onDelete != null)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: onDelete,
              ),
            ),
          ),

        // View Icon
        const Positioned(
          bottom: 8,
          right: 8,
          child: Icon(
            Icons.zoom_in,
            color: Colors.white,
            size: 32,
          ),
        ),
      ],
    );
  }

  void _showFullImage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.file(File(imagePath)),
            ),
          ),
        ),
      ),
    );
  }
}