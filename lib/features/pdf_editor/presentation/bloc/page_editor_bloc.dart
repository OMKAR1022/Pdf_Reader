import 'dart:ui';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as syncfusion;

import '../../../../core/services/pdf_storage_service.dart';
import '../../../../core/models/pdf_file_model.dart';
import 'page_editor_event.dart';
import 'page_editor_state.dart';

class PageEditorBloc extends Bloc<PageEditorEvent, PageEditorState> {
  final PdfStorageService _storageService = PdfStorageService();

  PageEditorBloc() : super(PageEditorInitial()) {
    on<LoadPdfForEditing>(_onLoadPdf);
    on<ReorderPages>(_onReorderPages);
    on<DeletePage>(_onDeletePage);
    on<RotatePage>(_onRotatePage);
    on<SavePdfChanges>(_onSaveChanges);
  }

  Future<void> _onLoadPdf(LoadPdfForEditing event, Emitter<PageEditorState> emit) async {
    emit(PageEditorLoading());
    try {
      final file = File(event.path);
      if (!await file.exists()) {
        emit(const PageEditorError('File not found'));
        return;
      }

      final bytes = await file.readAsBytes();
      final pageImages = <Uint8List>[];

      // Rasterize pages to images for preview
      await for (final page in Printing.raster(bytes, pages: null, dpi: 72)) {
        pageImages.add(await page.toPng());
      }

      // Initialize page order (0, 1, 2, ...)
      final pageOrder = List.generate(pageImages.length, (index) => index);

      emit(PageEditorLoaded(
        originalPath: event.path,
        pageImages: pageImages,
        pageOrder: pageOrder,
      ));
    } catch (e) {
      emit(PageEditorError('Failed to load PDF: $e'));
    }
  }

  void _onReorderPages(ReorderPages event, Emitter<PageEditorState> emit) {
    if (state is PageEditorLoaded) {
      final currentState = state as PageEditorLoaded;
      final newOrder = List<int>.from(currentState.pageOrder);
      final newImages = List<Uint8List>.from(currentState.pageImages);

      final item = newOrder.removeAt(event.oldIndex);
      newOrder.insert(event.newIndex, item);

      final image = newImages.removeAt(event.oldIndex);
      newImages.insert(event.newIndex, image);

      emit(currentState.copyWith(
        pageOrder: newOrder,
        pageImages: newImages,
      ));
    }
  }

  void _onDeletePage(DeletePage event, Emitter<PageEditorState> emit) {
    if (state is PageEditorLoaded) {
      final currentState = state as PageEditorLoaded;
      final newOrder = List<int>.from(currentState.pageOrder);
      final newImages = List<Uint8List>.from(currentState.pageImages);
      final newRotations = Map<int, int>.from(currentState.pageRotations);

      // Remove from order and images
      final originalIndex = newOrder[event.index];
      newOrder.removeAt(event.index);
      newImages.removeAt(event.index);
      
      // Clean up rotation for this page if exists
      newRotations.remove(originalIndex);

      emit(currentState.copyWith(
        pageOrder: newOrder,
        pageImages: newImages,
        pageRotations: newRotations,
      ));
    }
  }

  void _onRotatePage(RotatePage event, Emitter<PageEditorState> emit) {
    if (state is PageEditorLoaded) {
      final currentState = state as PageEditorLoaded;
      final newRotations = Map<int, int>.from(currentState.pageRotations);
      
      // Get the original page index
      final originalIndex = currentState.pageOrder[event.index];
      
      // Update rotation (add to existing or set new)
      final currentRotation = newRotations[originalIndex] ?? 0;
      newRotations[originalIndex] = (currentRotation + event.angle) % 360;

      emit(currentState.copyWith(pageRotations: newRotations));
    }
  }

  Future<void> _onSaveChanges(SavePdfChanges event, Emitter<PageEditorState> emit) async {
    if (state is PageEditorLoaded) {
      final currentState = state as PageEditorLoaded;
      emit(PageEditorLoading());

      try {
        // Load original document
        final file = File(currentState.originalPath);
        final bytes = await file.readAsBytes();
        
        final syncfusion.PdfDocument originalDoc = syncfusion.PdfDocument(inputBytes: bytes);
        final syncfusion.PdfDocument newDoc = syncfusion.PdfDocument();

        // Copy pages in the new order
        for (int i = 0; i < currentState.pageOrder.length; i++) {
          final originalIndex = currentState.pageOrder[i];
          
          // Import page via template
          final page = newDoc.pages.add();
          final template = originalDoc.pages[originalIndex].createTemplate();
          page.graphics.drawPdfTemplate(template, Offset.zero);
          
          // Apply rotation if needed
          if (currentState.pageRotations.containsKey(originalIndex)) {
            final rotationAngle = currentState.pageRotations[originalIndex]!;
            
            // Syncfusion rotation is enum
            syncfusion.PdfPageRotateAngle angle;
            switch (rotationAngle) {
              case 90:
                angle = syncfusion.PdfPageRotateAngle.rotateAngle90;
                break;
              case 180:
                angle = syncfusion.PdfPageRotateAngle.rotateAngle180;
                break;
              case 270:
                angle = syncfusion.PdfPageRotateAngle.rotateAngle270;
                break;
              default:
                angle = syncfusion.PdfPageRotateAngle.rotateAngle0;
            }
            
            if (angle != syncfusion.PdfPageRotateAngle.rotateAngle0) {
               page.rotation = angle;
            }
          }
        }

        // Save new document
        final outputDir = await getApplicationDocumentsDirectory();
        final fileName = 'Edited_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final outputFile = File('${outputDir.path}/$fileName');
        
        final List<int> newBytes = await newDoc.save();
        await outputFile.writeAsBytes(newBytes, flush: true);
        
        originalDoc.dispose();
        newDoc.dispose();

        // Save metadata
        final pdfFile = PdfFileModel(
          path: outputFile.path,
          name: fileName,
          createdAt: DateTime.now(),
          fileSizeBytes: await outputFile.length(),
          pageCount: currentState.pageOrder.length,
        );
        await _storageService.savePdfFile(pdfFile);

        emit(currentState.copyWith(savedPath: outputFile.path));
      } catch (e) {
        emit(PageEditorError('Failed to save changes: $e'));
      }
    }
  }
}
