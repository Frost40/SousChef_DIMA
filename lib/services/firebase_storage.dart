import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';

class FirebaseStorage {
  final firebase_storage.FirebaseStorage _storage = firebase_storage.FirebaseStorage.instance;

  Future<String?> uploadRestaurantImage(String restaurantId, File imageFile) async {
    try {
      // File type validation
      final String extension = imageFile.path.split('.').last.toLowerCase();
      final List<String> validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];

      if (!validExtensions.contains(extension)) {
        return null;
      }

      // Call Firebase Storage to upload the image
      final firebase_storage.Reference ref = _storage.ref().child('images/restaurants/$restaurantId/profile_image.png');
      final firebase_storage.UploadTask uploadTask = ref.putFile(imageFile);
      final firebase_storage.TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  Future<String?> uploadDishImage(String restaurantId, String dishId, File imageFile) async {
    try {
      // File type validation
      final String extension = imageFile.path.split('.').last.toLowerCase();
      final List<String> validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];

      if (!validExtensions.contains(extension)) {
        return null;
      }

      // Call Firebase Storage to upload the image
      final firebase_storage.Reference ref = _storage.ref().child('images/restaurants/$restaurantId/dishes/$dishId.png');
      final firebase_storage.UploadTask uploadTask = ref.putFile(imageFile);
      final firebase_storage.TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  Future<void> deleteDishImage(String restaurantId, String dishId) async {
    try {
      // Reference to the image path
      final firebase_storage.Reference ref = _storage.ref().child('images/restaurants/$restaurantId/dishes/$dishId.png');

      // Delete the file
      await ref.delete();
      debugPrint('Image successfully deleted');
    } catch (e) {
      if (e is firebase_storage.FirebaseException && e.code == 'object-not-found') {
        // The image does not exist, ignore the error
        debugPrint('Image not found in storage, no deletion required');
      } else {
        // Re-throw other errors
        rethrow;
      }
    }
  }
}