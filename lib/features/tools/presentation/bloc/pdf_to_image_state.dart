import 'dart:typed_data';
import 'package:equatable/equatable.dart';

abstract class PdfToImageState extends Equatable {
  const PdfToImageState();

  @override
  List<Object?> get props => [];
}

class PdfToImageInitial extends PdfToImageState {}

class PdfToImageLoading extends PdfToImageState {}

class PdfToImageLoaded extends PdfToImageState {
  final String path;
  final List<Uint8List> images;
  final List<int> selectedIndices;

  const PdfToImageLoaded({
    required this.path,
    required this.images,
    this.selectedIndices = const [],
  });

  PdfToImageLoaded copyWith({
    String? path,
    List<Uint8List>? images,
    List<int>? selectedIndices,
  }) {
    return PdfToImageLoaded(
      path: path ?? this.path,
      images: images ?? this.images,
      selectedIndices: selectedIndices ?? this.selectedIndices,
    );
  }

  @override
  List<Object?> get props => [path, images, selectedIndices];
}

class PdfToImageError extends PdfToImageState {
  final String message;

  const PdfToImageError(this.message);

  @override
  List<Object?> get props => [message];
}

class PdfToImageSuccess extends PdfToImageState {
  final String message;

  const PdfToImageSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
