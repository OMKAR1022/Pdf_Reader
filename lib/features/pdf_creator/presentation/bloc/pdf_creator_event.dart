import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class PdfCreatorEvent extends Equatable {
  const PdfCreatorEvent();

  @override
  List<Object?> get props => [];
}

class AddImages extends PdfCreatorEvent {
  final List<XFile> images;

  const AddImages(this.images);

  @override
  List<Object?> get props => [images];
}

class RemoveImage extends PdfCreatorEvent {
  final int index;

  const RemoveImage(this.index);

  @override
  List<Object?> get props => [index];
}

class CreatePdf extends PdfCreatorEvent {
  const CreatePdf();
}

class ReorderImages extends PdfCreatorEvent {
  final List<XFile> reorderedImages;

  const ReorderImages(this.reorderedImages);

  @override
  List<Object?> get props => [reorderedImages];
}

class PdfCreated extends PdfCreatorEvent {
  final String path;

  const PdfCreated(this.path);

  @override
  List<Object?> get props => [path];
}

class PdfCreationError extends PdfCreatorEvent {
  final String message;

  const PdfCreationError(this.message);

  @override
  List<Object?> get props => [message];
}
