import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../../../core/services/pdf_storage_service.dart';
import '../../../../core/models/pdf_file_model.dart';
import 'text_to_pdf_event.dart';
import 'text_to_pdf_state.dart';

class TextToPdfBloc extends Bloc<TextToPdfEvent, TextToPdfState> {
  final PdfStorageService _storageService = PdfStorageService();

  TextToPdfBloc() : super(TextToPdfInitial()) {
    on<TextChanged>(_onTextChanged);
    on<FontSizeChanged>(_onFontSizeChanged);
    on<CreatePdfFromText>(_onCreatePdf);
    on<PdfCreatedFromText>(_onPdfCreated);
    on<PdfCreationErrorFromText>(_onPdfCreationError);
  }

  void _onTextChanged(TextChanged event, Emitter<TextToPdfState> emit) {
    if (state is TextToPdfEditing) {
      final currentState = state as TextToPdfEditing;
      emit(currentState.copyWith(text: event.text));
    } else {
      emit(TextToPdfEditing(text: event.text));
    }
  }

  void _onFontSizeChanged(FontSizeChanged event, Emitter<TextToPdfState> emit) {
    if (state is TextToPdfEditing) {
      final currentState = state as TextToPdfEditing;
      emit(currentState.copyWith(fontSize: event.fontSize));
    }
  }

  Future<void> _onCreatePdf(CreatePdfFromText event, Emitter<TextToPdfState> emit) async {
    if (state is! TextToPdfEditing) return;
    
    final currentState = state as TextToPdfEditing;
    if (currentState.text.trim().isEmpty) {
      emit(const TextToPdfError('Please enter some text'));
      return;
    }

    emit(TextToPdfLoading());
    
    try {
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.MultiPage(
          build: (pw.Context context) => [
            pw.Text(
              currentState.text,
              style: pw.TextStyle(fontSize: currentState.fontSize),
            ),
          ],
        ),
      );

      final outputDir = await getApplicationDocumentsDirectory();
      final fileName = 'Text_PDF_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${outputDir.path}/$fileName');
      final pdfBytes = await pdf.save();
      await file.writeAsBytes(pdfBytes);

      // Save to storage service
      final pdfFileModel = PdfFileModel(
        path: file.path,
        name: fileName,
        createdAt: DateTime.now(),
        pageCount: 1,
        fileSizeBytes: pdfBytes.length,
      );
      await _storageService.savePdfFile(pdfFileModel);

      add(PdfCreatedFromText(file.path));
    } catch (e) {
      add(PdfCreationErrorFromText(e.toString()));
    }
  }

  void _onPdfCreated(PdfCreatedFromText event, Emitter<TextToPdfState> emit) {
    if (state is TextToPdfEditing) {
      final currentState = state as TextToPdfEditing;
      emit(currentState.copyWith(pdfPath: event.path));
    } else {
      emit(TextToPdfEditing(text: '', pdfPath: event.path));
    }
  }

  void _onPdfCreationError(PdfCreationErrorFromText event, Emitter<TextToPdfState> emit) {
    emit(TextToPdfError(event.message));
  }
}
