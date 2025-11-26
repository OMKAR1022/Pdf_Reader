import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pdf_file_model.dart';

class PdfStorageService {
  static const String _recentFilesKey = 'recent_files';
  static const String _favoritesKey = 'favorite_files';
  static const int _maxRecentFiles = 10;

  Future<void> savePdfFile(PdfFileModel file) async {
    final prefs = await SharedPreferences.getInstance();
    final recentFiles = await getRecentFiles();
    
    // Remove if already exists (to move to top)
    recentFiles.removeWhere((f) => f.path == file.path);
    
    // Add to top
    recentFiles.insert(0, file);
    
    // Keep only max recent files
    if (recentFiles.length > _maxRecentFiles) {
      recentFiles.removeLast();
    }
    
    final jsonList = recentFiles.map((f) => jsonEncode(f.toJson())).toList();
    await prefs.setStringList(_recentFilesKey, jsonList);
  }

  Future<List<PdfFileModel>> getRecentFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_recentFilesKey) ?? [];
    
    final files = <PdfFileModel>[];
    for (final jsonStr in jsonList) {
      try {
        final file = PdfFileModel.fromJson(jsonDecode(jsonStr));
        // Verify file still exists
        if (await File(file.path).exists()) {
          files.add(file);
        }
      } catch (e) {
        // Ignore invalid entries
      }
    }
    
    // Update list if files were removed
    if (files.length != jsonList.length) {
      final updatedJsonList = files.map((f) => jsonEncode(f.toJson())).toList();
      await prefs.setStringList(_recentFilesKey, updatedJsonList);
    }
    
    return files;
  }

  Future<void> removeFile(String path) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Remove from recents
    final recentFiles = await getRecentFiles();
    recentFiles.removeWhere((f) => f.path == path);
    final jsonList = recentFiles.map((f) => jsonEncode(f.toJson())).toList();
    await prefs.setStringList(_recentFilesKey, jsonList);

    // Remove from favorites
    await removeFavorite(path);
  }

  // Favorites
  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  Future<void> addFavorite(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    if (!favorites.contains(path)) {
      favorites.add(path);
      await prefs.setStringList(_favoritesKey, favorites);
    }
  }

  Future<void> removeFavorite(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    if (favorites.contains(path)) {
      favorites.remove(path);
      await prefs.setStringList(_favoritesKey, favorites);
    }
  }

  Future<bool> isFavorite(String path) async {
    final favorites = await getFavorites();
    return favorites.contains(path);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentFilesKey);
  }
}
