import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/models/pdf_file_model.dart';
import '../../../../core/services/pdf_storage_service.dart';
import 'files_event.dart';
import 'files_state.dart';

class FilesBloc extends Bloc<FilesEvent, FilesState> {
  final PdfStorageService _storageService = PdfStorageService();

  FilesBloc() : super(FilesInitial()) {
    on<LoadFiles>(_onLoadFiles);
    on<DeleteFile>(_onDeleteFile);
    on<RenameFile>(_onRenameFile);
    on<SearchFiles>(_onSearchFiles);
    on<ToggleFavorite>(_onToggleFavorite);
    on<FilterFavorites>(_onFilterFavorites);
  }

  Future<void> _onLoadFiles(LoadFiles event, Emitter<FilesState> emit) async {
    emit(FilesLoading());
    try {
      // Load files from application documents directory
      final tempDir = await getApplicationDocumentsDirectory();
      final files = <PdfFileModel>[];

      if (await tempDir.exists()) {
        final entities = tempDir.listSync();
        for (final entity in entities) {
          if (entity is File && entity.path.toLowerCase().endsWith('.pdf')) {
            final stat = await entity.stat();
            files.add(PdfFileModel(
              path: entity.path,
              name: entity.path.split('/').last,
              createdAt: stat.changed,
              fileSizeBytes: stat.size,
            ));
          }
        }
      }

      // Sort by date descending
      files.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Load favorites
      final favorites = await _storageService.getFavorites();

      emit(FilesLoaded(
        files: files, 
        filteredFiles: files,
        favorites: favorites,
      ));
    } catch (e) {
      emit(FilesError(e.toString()));
    }
  }

  Future<void> _onDeleteFile(DeleteFile event, Emitter<FilesState> emit) async {
    if (state is FilesLoaded) {
      try {
        final file = File(event.file.path);
        if (await file.exists()) {
          await file.delete();
          
          // Also remove from recent files storage and favorites
          await _storageService.removeFile(event.file.path);
          
          add(const LoadFiles());
        }
      } catch (e) {
        emit(FilesError('Failed to delete file: $e'));
      }
    }
  }

  Future<void> _onRenameFile(RenameFile event, Emitter<FilesState> emit) async {
    if (state is FilesLoaded) {
      try {
        final file = File(event.file.path);
        if (await file.exists()) {
          final dir = file.parent.path;
          final newPath = '$dir/${event.newName}';
          
          if (!event.newName.toLowerCase().endsWith('.pdf')) {
             await file.rename('$newPath.pdf');
          } else {
             await file.rename(newPath);
          }
          
          add(const LoadFiles());
        }
      } catch (e) {
        emit(FilesError('Failed to rename file: $e'));
      }
    }
  }

  void _onSearchFiles(SearchFiles event, Emitter<FilesState> emit) {
    if (state is FilesLoaded) {
      final currentState = state as FilesLoaded;
      final query = event.query.toLowerCase();
      
      _applyFilters(emit, currentState, query: query);
    }
  }

  Future<void> _onToggleFavorite(ToggleFavorite event, Emitter<FilesState> emit) async {
    if (state is FilesLoaded) {
      final currentState = state as FilesLoaded;
      final path = event.path;
      
      if (currentState.favorites.contains(path)) {
        await _storageService.removeFavorite(path);
      } else {
        await _storageService.addFavorite(path);
      }
      
      final updatedFavorites = await _storageService.getFavorites();
      
      // Re-apply filters to update UI immediately
      _applyFilters(emit, currentState.copyWith(favorites: updatedFavorites));
    }
  }

  void _onFilterFavorites(FilterFavorites event, Emitter<FilesState> emit) {
    if (state is FilesLoaded) {
      final currentState = state as FilesLoaded;
      _applyFilters(emit, currentState, showFavoritesOnly: event.showFavoritesOnly);
    }
  }

  void _applyFilters(
    Emitter<FilesState> emit, 
    FilesLoaded currentState, {
    String? query,
    bool? showFavoritesOnly,
  }) {
    final searchQuery = query ?? currentState.searchQuery;
    final favoritesOnly = showFavoritesOnly ?? currentState.showFavoritesOnly;
    
    List<PdfFileModel> filtered = currentState.files;

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((file) {
        return file.name.toLowerCase().contains(searchQuery);
      }).toList();
    }

    // Apply favorites filter
    if (favoritesOnly) {
      filtered = filtered.where((file) {
        return currentState.favorites.contains(file.path);
      }).toList();
    }

    emit(currentState.copyWith(
      filteredFiles: filtered,
      searchQuery: searchQuery,
      showFavoritesOnly: favoritesOnly,
    ));
  }
}
