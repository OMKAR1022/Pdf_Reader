import 'dart:typed_data';
import 'package:equatable/equatable.dart';

abstract class PageEditorState extends Equatable {
  const PageEditorState();

  @override
  List<Object?> get props => [];
}

class PageEditorInitial extends PageEditorState {}

class PageEditorLoading extends PageEditorState {}

class PageEditorLoaded extends PageEditorState {
  final String originalPath;
  final List<Uint8List> pageImages; // Thumbnails
  final List<int> pageOrder; // Original page indices
  final Map<int, int> pageRotations; // Index -> Rotation angle
  final String? savedPath;

  const PageEditorLoaded({
    required this.originalPath,
    required this.pageImages,
    required this.pageOrder,
    this.pageRotations = const {},
    this.savedPath,
  });

  PageEditorLoaded copyWith({
    String? originalPath,
    List<Uint8List>? pageImages,
    List<int>? pageOrder,
    Map<int, int>? pageRotations,
    String? savedPath,
  }) {
    return PageEditorLoaded(
      originalPath: originalPath ?? this.originalPath,
      pageImages: pageImages ?? this.pageImages,
      pageOrder: pageOrder ?? this.pageOrder,
      pageRotations: pageRotations ?? this.pageRotations,
      savedPath: savedPath ?? this.savedPath,
    );
  }

  @override
  List<Object?> get props => [originalPath, pageImages, pageOrder, pageRotations, savedPath];
}

class PageEditorError extends PageEditorState {
  final String message;

  const PageEditorError(this.message);

  @override
  List<Object?> get props => [message];
}
