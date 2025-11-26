import 'package:equatable/equatable.dart';
import '../../../../core/models/pdf_file_model.dart';

abstract class FilesState extends Equatable {
  const FilesState();

  @override
  List<Object?> get props => [];
}

class FilesInitial extends FilesState {}

class FilesLoading extends FilesState {}

class FilesLoaded extends FilesState {
  final List<PdfFileModel> files;
  final List<PdfFileModel> filteredFiles;
  final String searchQuery;
  final List<String> favorites;
  final bool showFavoritesOnly;

  const FilesLoaded({
    required this.files,
    this.filteredFiles = const [],
    this.searchQuery = '',
    this.favorites = const [],
    this.showFavoritesOnly = false,
  });

  FilesLoaded copyWith({
    List<PdfFileModel>? files,
    List<PdfFileModel>? filteredFiles,
    String? searchQuery,
    List<String>? favorites,
    bool? showFavoritesOnly,
  }) {
    return FilesLoaded(
      files: files ?? this.files,
      filteredFiles: filteredFiles ?? this.filteredFiles,
      searchQuery: searchQuery ?? this.searchQuery,
      favorites: favorites ?? this.favorites,
      showFavoritesOnly: showFavoritesOnly ?? this.showFavoritesOnly,
    );
  }

  @override
  List<Object?> get props => [files, filteredFiles, searchQuery, favorites, showFavoritesOnly];
}

class FilesError extends FilesState {
  final String message;

  const FilesError(this.message);

  @override
  List<Object?> get props => [message];
}
