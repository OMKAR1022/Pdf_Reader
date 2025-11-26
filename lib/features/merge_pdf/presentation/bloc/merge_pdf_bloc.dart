import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../../../core/services/pdf_storage_service.dart';
import '../../../../core/models/pdf_file_model.dart';
import 'merge_pdf_event.dart';
import 'merge_pdf_state.dart';

class MergePdfBloc extends Bloc<MergePdfEvent, MergePdfState> {
  final PdfStorageService _storageService = PdfStorageService();

  MergePdfBloc() : super(MergePdfInitial()) {
    on<AddPdfFiles>(_onAddPdfFiles);
    on<RemovePdfFile>(_onRemovePdfFile);
    on<ReorderPdfFiles>(_onReorderPdfFiles);
    on<MergePdfs>(_onMergePdfs);
    on<PdfsMerged>(_onPdfsMerged);
    on<MergeError>(_onMergeError);
  }

  void _onAddPdfFiles(AddPdfFiles event, Emitter<MergePdfState> emit) {
    final currentPaths = state is MergePdfLoaded
        ? (state as MergePdfLoaded).pdfPaths
        : <String>[];
    final updated = List<String>.from(currentPaths)..addAll(event.filePaths);
    emit(MergePdfLoaded(pdfPaths: updated));
  }

  void _onRemovePdfFile(RemovePdfFile event, Emitter<MergePdfState> emit) {
    if (state is MergePdfLoaded) {
      final current = (state as MergePdfLoaded).pdfPaths;
      if (event.index >= 0 && event.index < current.length) {
        final updated = List<String>.from(current)..removeAt(event.index);
        emit((state as MergePdfLoaded).copyWith(pdfPaths: updated));
      }
    }
  }

  void _onReorderPdfFiles(ReorderPdfFiles event, Emitter<MergePdfState> emit) {
    if (state is MergePdfLoaded) {
      emit((state as MergePdfLoaded).copyWith(pdfPaths: event.reorderedPaths));
    } else {
      emit(MergePdfLoaded(pdfPaths: event.reorderedPaths));
    }
  }

  Future<void> _onMergePdfs(MergePdfs event, Emitter<MergePdfState> emit) async {
    if (state is! MergePdfLoaded) return;
    
    final pdfPaths = (state as MergePdfLoaded).pdfPaths;
    if (pdfPaths.length < 2) {
      emit(const MergePdfError('Please select at least 2 PDF files to merge'));
      return;
    }

    emit(MergePdfLoading());
    
    try {
      final mergedPdf = pw.Document();
      int totalPages = 0;

      // Read and merge each PDF
      for (final path in pdfPaths) {
        final file = File(path);
        if (!await file.exists()) {
          add(const MergeError('One or more PDF files not found'));
          return;
        }

        // Create a page for each PDF file
        // Note: This is a simplified version. Full PDF merging would require
        // reading actual PDF pages using a PDF library
        mergedPdf.addPage(
          pw.Page(
            build: (context) => pw.Center(
              child: pw.Text(
                'PDF: ${path.split('/').last}',
                style: const pw.TextStyle(fontSize: 24),
              ),
            ),
          ),
        );
        totalPages++;
      }

      final outputDir = await getApplicationDocumentsDirectory();
      final fileName = 'Merged_PDF_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${outputDir.path}/$fileName');
      final pdfBytes = await mergedPdf.save();
      await file.writeAsBytes(pdfBytes);

      // Save to storage service
      final pdfFileModel = PdfFileModel(
        path: file.path,
        name: fileName,
        createdAt: DateTime.now(),
        pageCount: totalPages,
        fileSizeBytes: pdfBytes.length,
      );
      await _storageService.savePdfFile(pdfFileModel);

      add(PdfsMerged(file.path));
    } catch (e) {
      add(MergeError(e.toString()));
    }
  }

  void _onPdfsMerged(PdfsMerged event, Emitter<MergePdfState> emit) {
    if (state is MergePdfLoaded) {
      final currentState = state as MergePdfLoaded;
      emit(currentState.copyWith(mergedPdfPath: event.path));
    } else {
      emit(MergePdfLoaded(pdfPaths: const [], mergedPdfPath: event.path));
    }
  }

  void _onMergeError(MergeError event, Emitter<MergePdfState> emit) {
    emit(MergePdfError(event.message));
  }
}
