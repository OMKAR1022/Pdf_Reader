import 'package:equatable/equatable.dart';

abstract class TextToPdfEvent extends Equatable {
  const TextToPdfEvent();

  @override
  List<Object?> get props => [];
}

class TextChanged extends TextToPdfEvent {
  final String text;

  const TextChanged(this.text);

  @override
  List<Object?> get props => [text];
}

class FontSizeChanged extends TextToPdfEvent {
  final double fontSize;

  const FontSizeChanged(this.fontSize);

  @override
  List<Object?> get props => [fontSize];
}

class CreatePdfFromText extends TextToPdfEvent {
  const CreatePdfFromText();
}

class PdfCreatedFromText extends TextToPdfEvent {
  final String path;

  const PdfCreatedFromText(this.path);

  @override
  List<Object?> get props => [path];
}

class PdfCreationErrorFromText extends TextToPdfEvent {
  final String message;

  const PdfCreationErrorFromText(this.message);

  @override
  List<Object?> get props => [message];
}
