import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../../../core/services/pdf_storage_service.dart';
import '../../../../core/models/pdf_file_model.dart';
import 'compress_pdf_event.dart';
import 'compress_pdf_state.dart';

class CompressPdfBloc extends Bloc<CompressPdfEvent, CompressPdfState> {
  final PdfStorageService _storageService = PdfStorageService();

  CompressPdfBloc() : super(CompressPdfInitial()) {
    on<LoadPdfForCompression>(_onLoadPdf);
    on<CompressPdf>(_onCompressPdf);
  }

  Future<void> _onLoadPdf(LoadPdfForCompression event, Emitter<CompressPdfState> emit) async {
    emit(CompressPdfLoading());
    try {
      final file = File(event.path);
      if (!await file.exists()) {
        emit(const CompressPdfError('File not found'));
        return;
      }

      final size = await file.length();
      emit(CompressPdfLoaded(
        originalPath: event.path,
        originalSize: size,
      ));
    } catch (e) {
      emit(CompressPdfError('Failed to load PDF: $e'));
    }
  }

  Future<void> _onCompressPdf(CompressPdf event, Emitter<CompressPdfState> emit) async {
    if (state is CompressPdfLoaded) {
      final currentState = state as CompressPdfLoaded;
      emit(CompressPdfLoading());

      try {
        final file = File(currentState.originalPath);
        final bytes = await file.readAsBytes();
        
        final PdfDocument document = PdfDocument(inputBytes: bytes);
        
        // Set compression options
        document.compressionLevel = PdfCompressionLevel.best;

        // Save compressed document
        final outputDir = await getApplicationDocumentsDirectory();
        final fileName = 'Compressed_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final outputFile = File('${outputDir.path}/$fileName');
        
        final List<int> newBytes = await document.save();
        await outputFile.writeAsBytes(newBytes, flush: true);
        
        document.dispose();

        final newSize = await outputFile.length();

        // Save metadata
        final pdfFile = PdfFileModel(
          path: outputFile.path,
          name: fileName,
          createdAt: DateTime.now(),
          fileSizeBytes: newSize,
        );
        await _storageService.savePdfFile(pdfFile);

        emit(currentState.copyWith(
          compressedPath: outputFile.path,
          compressedSize: newSize,
        ));
      } catch (e) {
        emit(CompressPdfError('Failed to compress PDF: $e'));
      }
    }
  }
}
