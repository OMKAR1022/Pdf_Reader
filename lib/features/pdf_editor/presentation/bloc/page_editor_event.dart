import 'package:equatable/equatable.dart';

abstract class PageEditorEvent extends Equatable {
  const PageEditorEvent();

  @override
  List<Object?> get props => [];
}

class LoadPdfForEditing extends PageEditorEvent {
  final String path;

  const LoadPdfForEditing(this.path);

  @override
  List<Object?> get props => [path];
}

class ReorderPages extends PageEditorEvent {
  final int oldIndex;
  final int newIndex;

  const ReorderPages(this.oldIndex, this.newIndex);

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

class DeletePage extends PageEditorEvent {
  final int index;

  const DeletePage(this.index);

  @override
  List<Object?> get props => [index];
}

class RotatePage extends PageEditorEvent {
  final int index;
  final int angle; // 90, 180, 270

  const RotatePage(this.index, this.angle);

  @override
  List<Object?> get props => [index, angle];
}

class SavePdfChanges extends PageEditorEvent {
  const SavePdfChanges();
}
