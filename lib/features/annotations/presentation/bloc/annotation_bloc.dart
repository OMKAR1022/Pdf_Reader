import 'dart:io';
import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:printing/printing.dart';
// import 'package:pdf/pdf.dart' as pw; // Use alias to avoid conflict with syncfusion

import '../../../../core/services/pdf_storage_service.dart';
import '../../../../core/models/pdf_file_model.dart';
import '../../domain/models/drawing_stroke.dart';
import '../../domain/models/pdf_stamp.dart';
import 'annotation_event.dart';
import 'annotation_state.dart';

class AnnotationBloc extends Bloc<AnnotationEvent, AnnotationState> {
  final PdfStorageService _storageService = PdfStorageService();

  AnnotationBloc() : super(const AnnotationState()) {
    on<LoadPdfForAnnotation>(_onLoadPdf);
    on<SelectTool>(_onSelectTool);
    on<UpdateColor>(_onUpdateColor);
    on<UpdateStrokeWidth>(_onUpdateStrokeWidth);
    on<AddStroke>(_onAddStroke);
    on<AddStamp>(_onAddStamp);
    on<UndoStroke>(_onUndoStroke);
    on<SaveAnnotations>(_onSaveAnnotations);
  }

  Future<void> _onLoadPdf(LoadPdfForAnnotation event, Emitter<AnnotationState> emit) async {
    await _loadPdf(event.path, emit);
  }

  Future<void> _loadPdf(String path, Emitter<AnnotationState> emit) async {
    emit(state.copyWith(isLoading: true, pdfPath: path, strokes: {}, stamps: {}));
    
    try {
      final file = File(path);
      if (!await file.exists()) {
        emit(state.copyWith(isLoading: false, errorMessage: 'File not found'));
        return;
      }

      final bytes = await file.readAsBytes();
      
      // Rasterize pages
      final images = <Uint8List>[];
      await for (final page in Printing.raster(bytes, dpi: 150)) {
        images.add(await page.toPng());
      }

      emit(state.copyWith(
        isLoading: false,
        pageImages: images,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Failed to load PDF: $e'));
    }
  }

  void _onSelectTool(SelectTool event, Emitter<AnnotationState> emit) {
    emit(state.copyWith(currentTool: event.tool));
  }

  void _onUpdateColor(UpdateColor event, Emitter<AnnotationState> emit) {
    emit(state.copyWith(currentColor: event.color));
  }

  void _onUpdateStrokeWidth(UpdateStrokeWidth event, Emitter<AnnotationState> emit) {
    emit(state.copyWith(currentStrokeWidth: event.width));
  }

  void _onAddStroke(AddStroke event, Emitter<AnnotationState> emit) {
    final currentStrokes = Map<int, List<DrawingStroke>>.from(state.strokes);
    if (!currentStrokes.containsKey(event.pageIndex)) {
      currentStrokes[event.pageIndex] = [];
    }
    currentStrokes[event.pageIndex]!.add(event.stroke);
    emit(state.copyWith(strokes: currentStrokes));
  }

  void _onUndoStroke(UndoStroke event, Emitter<AnnotationState> emit) {
    final currentStrokes = Map<int, List<DrawingStroke>>.from(state.strokes);
    if (currentStrokes.containsKey(event.pageIndex) && currentStrokes[event.pageIndex]!.isNotEmpty) {
      currentStrokes[event.pageIndex]!.removeLast();
      emit(state.copyWith(strokes: currentStrokes));
    }
  }

  void _onAddStamp(AddStamp event, Emitter<AnnotationState> emit) {
    final currentStamps = Map<int, List<PdfStamp>>.from(state.stamps);
    if (!currentStamps.containsKey(event.pageIndex)) {
      currentStamps[event.pageIndex] = [];
    }
    currentStamps[event.pageIndex]!.add(event.stamp);
    emit(state.copyWith(stamps: currentStamps));
  }

  Future<void> _onSaveAnnotations(SaveAnnotations event, Emitter<AnnotationState> emit) async {
    if (state.pdfPath == null) return;
    emit(state.copyWith(isLoading: true));

    try {
      final file = File(state.pdfPath!);
      final bytes = await file.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);



      // Draw Strokes
      for (final entry in state.strokes.entries) {
        final pageIndex = entry.key;
        final strokes = entry.value;

        if (pageIndex < document.pages.count) {
          final page = document.pages[pageIndex];
          final graphics = page.graphics;
          final pageSize = page.getClientSize();

          for (final stroke in strokes) {
            final pdfPen = PdfPen(
              PdfColor(
                (stroke.color.r * 255).toInt(),
                (stroke.color.g * 255).toInt(),
                (stroke.color.b * 255).toInt(),
                (stroke.color.a * 255).toInt(),
              ),
              width: stroke.width,
            );

            final points = stroke.points.map((p) {
              return Offset(p.dx * pageSize.width, p.dy * pageSize.height);
            }).toList();

            if (points.length > 1) {
              for (int i = 0; i < points.length - 1; i++) {
                graphics.drawLine(pdfPen, points[i], points[i + 1]);
              }
            } else if (points.length == 1) {
              graphics.drawRectangle(
                pen: pdfPen,
                bounds: Rect.fromLTWH(points[0].dx, points[0].dy, 1, 1),
              );
            }
          }
        }
      }

      // Draw Stamps
      for (final entry in state.stamps.entries) {
        final pageIndex = entry.key;
        final stamps = entry.value;

        if (pageIndex < document.pages.count) {
          final page = document.pages[pageIndex];
          final graphics = page.graphics;
          final pageSize = page.getClientSize();

          for (final stamp in stamps) {
            final image = PdfBitmap(stamp.imageBytes);
            final rect = Rect.fromLTWH(
              stamp.position.dx * pageSize.width,
              stamp.position.dy * pageSize.height,
              stamp.size.width * pageSize.width,
              stamp.size.height * pageSize.height,
            );
            graphics.drawImage(image, rect);
          }
        }
      }

      final outputDir = await getApplicationDocumentsDirectory();
      final fileName = 'Annotated_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final outputFile = File('${outputDir.path}/$fileName');
      
      await outputFile.writeAsBytes(await document.save());
      document.dispose();

      // Save metadata
      final pdfFile = PdfFileModel(
        path: outputFile.path,
        name: fileName,
        createdAt: DateTime.now(),
        fileSizeBytes: await outputFile.length(),
      );
      await _storageService.savePdfFile(pdfFile);

      emit(state.copyWith(
        successMessage: 'Annotations saved successfully!',
      ));
      
      // Reload the new PDF
      await _loadPdf(outputFile.path, emit);

    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Failed to save annotations: $e'));
    }
  }
}
