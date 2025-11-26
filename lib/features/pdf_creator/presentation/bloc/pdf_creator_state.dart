import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class PdfCreatorState extends Equatable {
  const PdfCreatorState();

  @override
  List<Object?> get props => [];
}

class PdfCreatorInitial extends PdfCreatorState {}

class PdfCreatorLoading extends PdfCreatorState {}

class PdfCreatorLoaded extends PdfCreatorState {
  final List<XFile> images;
  final String? pdfPath;

  const PdfCreatorLoaded({required this.images, this.pdfPath});

  PdfCreatorLoaded copyWith({List<XFile>? images, String? pdfPath}) {
    return PdfCreatorLoaded(
      images: images ?? this.images,
      pdfPath: pdfPath ?? this.pdfPath,
    );
  }

  @override
  List<Object?> get props => [images, pdfPath];
}

class PdfCreatorError extends PdfCreatorState {
  final String message;

  const PdfCreatorError(this.message);

  @override
  List<Object?> get props => [message];
}
