import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadButton extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final double iconSize;
  final Function(File?) onImageSelected;
  final Function(String)? onUrlSelected;
  final String currentImageUrl;

  const ImageUploadButton({
    super.key,
    this.size = 40,
    this.backgroundColor,
    this.iconColor,
    this.iconSize = 20,
    required this.onImageSelected,
    this.onUrlSelected,
    this.currentImageUrl = '',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: backgroundColor ?? colorScheme.primary,
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(),
        icon: Icon(
          Icons.camera_alt,
          color: iconColor ?? colorScheme.onPrimary,
          size: iconSize,
        ),
        onPressed: () => _showImageSourceOptions(context),
      ),
    );
  }

  void _showImageSourceOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  _getImage(ImageSource.gallery, context);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _getImage(ImageSource.camera, context);
                  Navigator.of(context).pop();
                },
              ),
              if (onUrlSelected != null)
                ListTile(
                  leading: const Icon(Icons.link),
                  title: const Text('Image URL'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showUrlDialog(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source, BuildContext context) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: source,
      maxWidth: 800,
      imageQuality: 85,
    );

    if (pickedImage != null) {
      onImageSelected(File(pickedImage.path));
    }
  }

  void _showUrlDialog(BuildContext context) {
    final TextEditingController urlController = TextEditingController(text: currentImageUrl);
    final colorScheme = Theme.of(context).colorScheme;
    String? errorText;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Insert image URL'),
            content: TextField(
              controller: urlController,
              decoration: InputDecoration(
                labelText: 'Image URL',
                errorText: errorText,
              ),
              onChanged: (value) {
                if (value.isNotEmpty && !value.startsWith('http')) {
                  setState(() => errorText = 'Image URL not valid');
                } else {
                  setState(() => errorText = null);
                }
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Rollback'),
              ),
              TextButton(
                onPressed: () {
                  if (errorText == null) {
                    onUrlSelected?.call(urlController.text);
                    onImageSelected(null); // Remove local image
                    Navigator.of(context).pop();
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: errorText != null
                      ? colorScheme.onSurface.withOpacity(0.38)
                      : null,
                ),
                child: const Text('Confirm'),
              ),
            ],
          );
        }
      ),
    );
  }
}