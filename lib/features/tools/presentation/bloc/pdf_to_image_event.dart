import 'package:equatable/equatable.dart';

abstract class PdfToImageEvent extends Equatable {
  const PdfToImageEvent();

  @override
  List<Object?> get props => [];
}

class LoadPdfForConversion extends PdfToImageEvent {
  final String path;

  const LoadPdfForConversion(this.path);

  @override
  List<Object?> get props => [path];
}

class SaveImages extends PdfToImageEvent {
  final List<int> selectedIndices;

  const SaveImages(this.selectedIndices);

  @override
  List<Object?> get props => [selectedIndices];
}
