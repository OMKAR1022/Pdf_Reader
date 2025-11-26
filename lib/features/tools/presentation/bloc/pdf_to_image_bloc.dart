import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'pdf_to_image_event.dart';
import 'pdf_to_image_state.dart';

class PdfToImageBloc extends Bloc<PdfToImageEvent, PdfToImageState> {
  PdfToImageBloc() : super(PdfToImageInitial()) {
    on<LoadPdfForConversion>(_onLoadPdf);
    on<SaveImages>(_onSaveImages);
  }

  Future<void> _onLoadPdf(LoadPdfForConversion event, Emitter<PdfToImageState> emit) async {
    emit(PdfToImageLoading());
    try {
      final file = File(event.path);
      if (!await file.exists()) {
        emit(const PdfToImageError('File not found'));
        return;
      }

      final bytes = await file.readAsBytes();
      final images = <Uint8List>[];

      // Rasterize all pages
      await for (final page in Printing.raster(bytes, pages: null, dpi: 150)) { // Higher DPI for better quality
        images.add(await page.toPng());
      }

      emit(PdfToImageLoaded(
        path: event.path,
        images: images,
        selectedIndices: List.generate(images.length, (index) => index), // Select all by default
      ));
    } catch (e) {
      emit(PdfToImageError('Failed to convert PDF: $e'));
    }
  }

  Future<void> _onSaveImages(SaveImages event, Emitter<PdfToImageState> emit) async {
    if (state is PdfToImageLoaded) {
      final currentState = state as PdfToImageLoaded;
      emit(PdfToImageLoading());

      try {
        final tempDir = await getTemporaryDirectory();
        final files = <XFile>[];

        for (final index in event.selectedIndices) {
          final imageBytes = currentState.images[index];
          final fileName = 'page_${index + 1}.png';
          final file = File('${tempDir.path}/$fileName');
          await file.writeAsBytes(imageBytes);
          files.add(XFile(file.path));
        }

        if (files.isNotEmpty) {
          await Share.shareXFiles(files, text: 'Converted images from PDF');
          emit(const PdfToImageSuccess('Images shared successfully'));
          // Restore loaded state
          emit(currentState);
        } else {
          emit(const PdfToImageError('No pages selected'));
          emit(currentState);
        }
      } catch (e) {
        emit(PdfToImageError('Failed to share images: $e'));
        emit(currentState);
      }
    }
  }
}
