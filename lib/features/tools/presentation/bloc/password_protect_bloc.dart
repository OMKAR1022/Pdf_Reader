import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../../../core/services/pdf_storage_service.dart';
import '../../../../core/models/pdf_file_model.dart';
import 'password_protect_event.dart';
import 'password_protect_state.dart';

class PasswordProtectBloc extends Bloc<PasswordProtectEvent, PasswordProtectState> {
  final PdfStorageService _storageService = PdfStorageService();

  PasswordProtectBloc() : super(PasswordProtectInitial()) {
    on<LoadPdfForProtection>(_onLoadPdf);
    on<ProtectPdf>(_onProtectPdf);
  }

  Future<void> _onLoadPdf(LoadPdfForProtection event, Emitter<PasswordProtectState> emit) async {
    emit(PasswordProtectLoading());
    try {
      final file = File(event.path);
      if (!await file.exists()) {
        emit(const PasswordProtectError('File not found'));
        return;
      }

      emit(PasswordProtectLoaded(originalPath: event.path));
    } catch (e) {
      emit(PasswordProtectError('Failed to load PDF: $e'));
    }
  }

  Future<void> _onProtectPdf(ProtectPdf event, Emitter<PasswordProtectState> emit) async {
    if (state is PasswordProtectLoaded) {
      final currentState = state as PasswordProtectLoaded;
      emit(PasswordProtectLoading());

      try {
        final file = File(currentState.originalPath);
        final bytes = await file.readAsBytes();
        
        final PdfDocument document = PdfDocument(inputBytes: bytes);
        
        // Set security
        final PdfSecurity security = document.security;
        security.userPassword = event.userPassword;
        if (event.ownerPassword != null && event.ownerPassword!.isNotEmpty) {
          security.ownerPassword = event.ownerPassword!;
        }
        security.algorithm = PdfEncryptionAlgorithm.aesx256Bit;
        
        // Save protected document
        final outputDir = await getApplicationDocumentsDirectory();
        final fileName = 'Protected_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final outputFile = File('${outputDir.path}/$fileName');
        
        final List<int> newBytes = await document.save();
        await outputFile.writeAsBytes(newBytes, flush: true);
        
        document.dispose();

        // Save metadata
        final pdfFile = PdfFileModel(
          path: outputFile.path,
          name: fileName,
          createdAt: DateTime.now(),
          fileSizeBytes: await outputFile.length(),
        );
        await _storageService.savePdfFile(pdfFile);

        emit(currentState.copyWith(protectedPath: outputFile.path));
      } catch (e) {
        emit(PasswordProtectError('Failed to protect PDF: $e'));
      }
    }
  }
}
