import 'package:equatable/equatable.dart';

abstract class TextToPdfState extends Equatable {
  const TextToPdfState();

  @override
  List<Object?> get props => [];
}

class TextToPdfInitial extends TextToPdfState {}

class TextToPdfLoading extends TextToPdfState {}

class TextToPdfEditing extends TextToPdfState {
  final String text;
  final double fontSize;
  final String? pdfPath;

  const TextToPdfEditing({
    required this.text,
    this.fontSize = 12.0,
    this.pdfPath,
  });

  TextToPdfEditing copyWith({
    String? text,
    double? fontSize,
    String? pdfPath,
  }) {
    return TextToPdfEditing(
      text: text ?? this.text,
      fontSize: fontSize ?? this.fontSize,
      pdfPath: pdfPath ?? this.pdfPath,
    );
  }

  @override
  List<Object?> get props => [text, fontSize, pdfPath];
}

class TextToPdfError extends TextToPdfState {
  final String message;

  const TextToPdfError(this.message);

  @override
  List<Object?> get props => [message];
}
