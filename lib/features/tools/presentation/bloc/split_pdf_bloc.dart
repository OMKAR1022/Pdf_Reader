import 'dart:io';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../../../core/services/pdf_storage_service.dart';
import '../../../../core/models/pdf_file_model.dart';
import 'split_pdf_event.dart';
import 'split_pdf_state.dart';

class SplitPdfBloc extends Bloc<SplitPdfEvent, SplitPdfState> {
  final PdfStorageService _storageService = PdfStorageService();
  PdfDocument? _loadedDocument;

  SplitPdfBloc() : super(SplitPdfInitial()) {
    on<LoadPdfForSplit>(_onLoadPdf);
    on<ExtractPages>(_onExtractPages);
  }

  Future<void> _onLoadPdf(LoadPdfForSplit event, Emitter<SplitPdfState> emit) async {
    emit(SplitPdfLoading());
    try {
      final file = File(event.path);
      if (!await file.exists()) {
        emit(const SplitPdfError('File not found'));
        return;
      }

      final bytes = await file.readAsBytes();
      _loadedDocument = PdfDocument(inputBytes: bytes);

      emit(SplitPdfLoaded(
        pdfPath: event.path,
        pageCount: _loadedDocument!.pages.count,
      ));
    } catch (e) {
      emit(SplitPdfError('Failed to load PDF: $e'));
    }
  }

  Future<void> _onExtractPages(ExtractPages event, Emitter<SplitPdfState> emit) async {
    if (_loadedDocument == null) return;
    if (state is! SplitPdfLoaded) return;

    final currentState = state as SplitPdfLoaded;
    emit(SplitPdfLoading());

    try {
      final indices = _parsePageRange(event.pageRange, _loadedDocument!.pages.count);
      
      if (indices.isEmpty) {
        emit(const SplitPdfError('Invalid page range'));
        emit(currentState); // Restore loaded state
        return;
      }

      // Create a new document
      final newDocument = PdfDocument();

      // Import pages
      // Note: importPage imports a single page. 
      // To import multiple, we loop.
      // However, importPage copies the page to the new document.
      
      // Syncfusion's importPage is: newDoc.pages.add(newDoc.importPage(oldDoc, index));
      // Wait, let's check the API.
      // Usually: newDocument.pages.add(oldDocument.pages[index]); // This might not work across documents directly without import
      
      // Correct way for Syncfusion:
      // PdfDocument.pages.add() adds a page.
      // We can use templates as we did in PageEditorBloc to be safe and efficient.
      
      for (final index in indices) {
        if (index >= 0 && index < _loadedDocument!.pages.count) {
          final template = _loadedDocument!.pages[index].createTemplate();
          final newPage = newDocument.pages.add();
          // Assuming same size
          newPage.graphics.drawPdfTemplate(template, const Offset(0, 0));
        }
      }

      final outputDir = await getApplicationDocumentsDirectory();
      final fileName = 'Split_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final outputFile = File('${outputDir.path}/$fileName');
      
      await outputFile.writeAsBytes(await newDocument.save());
      newDocument.dispose();

      // Save metadata
      final pdfFile = PdfFileModel(
        path: outputFile.path,
        name: fileName,
        createdAt: DateTime.now(),
        fileSizeBytes: await outputFile.length(),
      );
      await _storageService.savePdfFile(pdfFile);

      emit(SplitPdfSuccess(outputFile.path));
      
      // After success, we might want to go back to loaded state or stay?
      // Usually we show success dialog.
    } catch (e) {
      emit(SplitPdfError('Failed to extract pages: $e'));
      emit(currentState);
    }
  }

  List<int> _parsePageRange(String range, int totalPages) {
    final pages = <int>{};
    final parts = range.split(',');
    for (final part in parts) {
      if (part.trim().isEmpty) continue;
      
      if (part.contains('-')) {
        final rangeParts = part.split('-');
        if (rangeParts.length == 2) {
          final start = int.tryParse(rangeParts[0].trim()) ?? 1;
          final end = int.tryParse(rangeParts[1].trim()) ?? totalPages;
          for (var i = start; i <= end; i++) {
            pages.add(i - 1);
          }
        }
      } else {
        final page = int.tryParse(part.trim());
        if (page != null) {
          pages.add(page - 1);
        }
      }
    }
    return pages.toList()..sort();
  }

  @override
  Future<void> close() {
    _loadedDocument?.dispose();
    return super.close();
  }
}
