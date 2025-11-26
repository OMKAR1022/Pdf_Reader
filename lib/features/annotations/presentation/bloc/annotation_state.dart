import 'dart:typed_data';
import 'dart:ui';
import 'package:equatable/equatable.dart';
import '../../domain/models/drawing_stroke.dart';
import '../../domain/models/pdf_stamp.dart';
import 'annotation_event.dart';

class AnnotationState extends Equatable {
  final String? pdfPath;
  final AnnotationTool currentTool;
  final Color currentColor;
  final double currentStrokeWidth;
  final Map<int, List<DrawingStroke>> strokes; // PageIndex -> Strokes
  final Map<int, List<PdfStamp>> stamps; // PageIndex -> Stamps
  final List<Uint8List>? pageImages;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const AnnotationState({
    this.pdfPath,
    this.currentTool = AnnotationTool.pen,
    this.currentColor = const Color(0xFF000000),
    this.currentStrokeWidth = 2.0,
    this.strokes = const {},
    this.stamps = const {},
    this.pageImages,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  AnnotationState copyWith({
    String? pdfPath,
    AnnotationTool? currentTool,
    Color? currentColor,
    double? currentStrokeWidth,
    Map<int, List<DrawingStroke>>? strokes,
    Map<int, List<PdfStamp>>? stamps,
    List<Uint8List>? pageImages,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return AnnotationState(
      pdfPath: pdfPath ?? this.pdfPath,
      currentTool: currentTool ?? this.currentTool,
      currentColor: currentColor ?? this.currentColor,
      currentStrokeWidth: currentStrokeWidth ?? this.currentStrokeWidth,
      strokes: strokes ?? this.strokes,
      stamps: stamps ?? this.stamps,
      pageImages: pageImages ?? this.pageImages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Clear error on new state
      successMessage: successMessage, // Clear success on new state
    );
  }

  @override
  List<Object?> get props => [
        pdfPath,
        currentTool,
        currentColor,
        currentStrokeWidth,
        strokes,
        stamps,
        pageImages,
        isLoading,
        errorMessage,
        successMessage,
      ];
}
