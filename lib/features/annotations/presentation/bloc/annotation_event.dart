import 'dart:ui';
import 'package:equatable/equatable.dart';
import '../../domain/models/drawing_stroke.dart';
import '../../domain/models/pdf_stamp.dart';

enum AnnotationTool { pen, highlighter, eraser }

abstract class AnnotationEvent extends Equatable {
  const AnnotationEvent();

  @override
  List<Object?> get props => [];
}

class LoadPdfForAnnotation extends AnnotationEvent {
  final String path;

  const LoadPdfForAnnotation(this.path);

  @override
  List<Object?> get props => [path];
}

class SelectTool extends AnnotationEvent {
  final AnnotationTool tool;

  const SelectTool(this.tool);

  @override
  List<Object?> get props => [tool];
}

class UpdateColor extends AnnotationEvent {
  final Color color;

  const UpdateColor(this.color);

  @override
  List<Object?> get props => [color];
}

class UpdateStrokeWidth extends AnnotationEvent {
  final double width;

  const UpdateStrokeWidth(this.width);

  @override
  List<Object?> get props => [width];
}

class AddStroke extends AnnotationEvent {
  final int pageIndex;
  final DrawingStroke stroke;

  const AddStroke({required this.pageIndex, required this.stroke});

  @override
  List<Object?> get props => [pageIndex, stroke];
}

class UndoStroke extends AnnotationEvent {
  final int pageIndex;

  const UndoStroke(this.pageIndex);

  @override
  List<Object?> get props => [pageIndex];
}

class AddStamp extends AnnotationEvent {
  final int pageIndex;
  final PdfStamp stamp;

  const AddStamp({required this.pageIndex, required this.stamp});

  @override
  List<Object?> get props => [pageIndex, stamp];
}

class SaveAnnotations extends AnnotationEvent {
  const SaveAnnotations();
}
