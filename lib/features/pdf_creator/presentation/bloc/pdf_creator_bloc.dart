import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../../../core/services/pdf_storage_service.dart';
import '../../../../core/models/pdf_file_model.dart';
import 'pdf_creator_event.dart';
import 'pdf_creator_state.dart';

class PdfCreatorBloc extends Bloc<PdfCreatorEvent, PdfCreatorState> {
  final PdfStorageService _storageService = PdfStorageService();

  PdfCreatorBloc() : super(PdfCreatorInitial()) {
    on<AddImages>(_onAddImages);
    on<RemoveImage>(_onRemoveImage);
    on<CreatePdf>(_onCreatePdf);
    on<ReorderImages>(_onReorderImages);
    on<PdfCreated>(_onPdfCreated);
    on<PdfCreationError>(_onPdfCreationError);
  }

  void _onAddImages(AddImages event, Emitter<PdfCreatorState> emit) {
    final currentImages = state is PdfCreatorLoaded
        ? (state as PdfCreatorLoaded).images
        : <XFile>[];
    final updated = List<XFile>.from(currentImages)..addAll(event.images);
    emit(PdfCreatorLoaded(images: updated));
  }

  void _onRemoveImage(RemoveImage event, Emitter<PdfCreatorState> emit) {
    if (state is PdfCreatorLoaded) {
      final current = (state as PdfCreatorLoaded).images;
      if (event.index >= 0 && event.index < current.length) {
        final updated = List<XFile>.from(current)..removeAt(event.index);
        emit((state as PdfCreatorLoaded).copyWith(images: updated));
      }
    }
  }

  void _onReorderImages(ReorderImages event, Emitter<PdfCreatorState> emit) {
    if (state is PdfCreatorLoaded) {
      emit((state as PdfCreatorLoaded).copyWith(images: event.reorderedImages));
    } else {
      emit(PdfCreatorLoaded(images: event.reorderedImages));
    }
  }

  Future<void> _onCreatePdf(CreatePdf event, Emitter<PdfCreatorState> emit) async {
    if (state is! PdfCreatorLoaded) return;
    final images = (state as PdfCreatorLoaded).images;
    if (images.isEmpty) {
      emit(PdfCreatorError('No images selected'));
      return;
    }
    emit(PdfCreatorLoading());
    try {
      final doc = pw.Document();
      for (final img in images) {
        final bytes = await img.readAsBytes();
        final image = pw.MemoryImage(bytes);
        doc.addPage(pw.Page(build: (pw.Context context) => pw.Center(child: pw.Image(image))));
      }
      final outputDir = await getApplicationDocumentsDirectory();
      final fileName = 'PDF_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${outputDir.path}/$fileName');
      final pdfBytes = await doc.save();
      await file.writeAsBytes(pdfBytes);
      
      // Save to storage service
      final pdfFileModel = PdfFileModel(
        path: file.path,
        name: fileName,
        createdAt: DateTime.now(),
        pageCount: images.length,
        fileSizeBytes: pdfBytes.length,
      );
      await _storageService.savePdfFile(pdfFileModel);
      
      add(PdfCreated(file.path));
    } catch (e) {
      add(PdfCreationError(e.toString()));
    }
  }

  void _onPdfCreated(PdfCreated event, Emitter<PdfCreatorState> emit) {
    if (state is PdfCreatorLoaded) {
      final loaded = state as PdfCreatorLoaded;
      emit(loaded.copyWith(pdfPath: event.path));
    } else {
      emit(PdfCreatorLoaded(images: [], pdfPath: event.path));
    }
  }

  void _onPdfCreationError(PdfCreationError event, Emitter<PdfCreatorState> emit) {
    emit(PdfCreatorError(event.message));
  }
}
