import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/services/pdf_storage_service.dart';
import '../../../../core/models/pdf_file_model.dart';
import 'zip_to_pdf_event.dart';
import 'zip_to_pdf_state.dart';

class ZipToPdfBloc extends Bloc<ZipToPdfEvent, ZipToPdfState> {
  final PdfStorageService _storageService = PdfStorageService();

  ZipToPdfBloc() : super(ZipToPdfInitial()) {
    on<LoadZipFile>(_onLoadZip);
    on<CreatePdfFromZip>(_onCreatePdf);
  }

  Future<void> _onLoadZip(LoadZipFile event, Emitter<ZipToPdfState> emit) async {
    emit(ZipToPdfLoading());
    try {
      final file = File(event.path);
      if (!await file.exists()) {
        emit(const ZipToPdfError('File not found'));
        return;
      }

      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      final tempDir = await getTemporaryDirectory();
      final extractDir = Directory('${tempDir.path}/extracted_${DateTime.now().millisecondsSinceEpoch}');
      await extractDir.create();

      final images = <File>[];

      for (final archiveFile in archive) {
        if (archiveFile.isFile) {
          final filename = archiveFile.name;
          final lowerName = filename.toLowerCase();
          if (lowerName.endsWith('.jpg') || 
              lowerName.endsWith('.jpeg') || 
              lowerName.endsWith('.png')) {
            
            final outFile = File('${extractDir.path}/$filename');
            await outFile.create(recursive: true);
            await outFile.writeAsBytes(archiveFile.content as List<int>);
            images.add(outFile);
          }
        }
      }

      if (images.isEmpty) {
        emit(const ZipToPdfError('No images found in ZIP file'));
        return;
      }

      // Sort images alphabetically
      images.sort((a, b) => a.path.compareTo(b.path));

      emit(ZipToPdfLoaded(
        zipPath: event.path,
        images: images,
      ));
    } catch (e) {
      emit(ZipToPdfError('Failed to extract ZIP: $e'));
    }
  }

  Future<void> _onCreatePdf(CreatePdfFromZip event, Emitter<ZipToPdfState> emit) async {
    if (state is ZipToPdfLoaded) {
      final currentState = state as ZipToPdfLoaded;
      emit(ZipToPdfLoading());

      try {
        final pdf = pw.Document();

        for (final imageFile in currentState.images) {
          final image = pw.MemoryImage(await imageFile.readAsBytes());
          pdf.addPage(
            pw.Page(
              build: (pw.Context context) {
                return pw.Center(
                  child: pw.Image(image),
                );
              },
            ),
          );
        }

        final outputDir = await getApplicationDocumentsDirectory();
        final fileName = 'ZipConverted_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final outputFile = File('${outputDir.path}/$fileName');
        
        await outputFile.writeAsBytes(await pdf.save());

        // Save metadata
        final pdfFile = PdfFileModel(
          path: outputFile.path,
          name: fileName,
          createdAt: DateTime.now(),
          fileSizeBytes: await outputFile.length(),
        );
        await _storageService.savePdfFile(pdfFile);

        emit(ZipToPdfSuccess(outputFile.path));
      } catch (e) {
        emit(ZipToPdfError('Failed to create PDF: $e'));
        // Restore loaded state if possible, but for now error is fine
      }
    }
  }
}
