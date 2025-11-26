import 'package:equatable/equatable.dart';
import '../../../../core/models/pdf_file_model.dart';

abstract class FilesEvent extends Equatable {
  const FilesEvent();

  @override
  List<Object?> get props => [];
}

class LoadFiles extends FilesEvent {
  const LoadFiles();
}

class DeleteFile extends FilesEvent {
  final PdfFileModel file;

  const DeleteFile(this.file);

  @override
  List<Object?> get props => [file];
}

class RenameFile extends FilesEvent {
  final PdfFileModel file;
  final String newName;

  const RenameFile(this.file, this.newName);

  @override
  List<Object?> get props => [file, newName];
}

class SearchFiles extends FilesEvent {
  final String query;

  const SearchFiles(this.query);

  @override
  List<Object?> get props => [query];
}

class ToggleFavorite extends FilesEvent {
  final String path;

  const ToggleFavorite(this.path);

  @override
  List<Object?> get props => [path];
}

class FilterFavorites extends FilesEvent {
  final bool showFavoritesOnly;

  const FilterFavorites(this.showFavoritesOnly);

  @override
  List<Object?> get props => [showFavoritesOnly];
}
