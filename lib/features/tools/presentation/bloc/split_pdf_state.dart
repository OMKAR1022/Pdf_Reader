import 'package:equatable/equatable.dart';

abstract class SplitPdfState extends Equatable {
  const SplitPdfState();

  @override
  List<Object?> get props => [];
}

class SplitPdfInitial extends SplitPdfState {}

class SplitPdfLoading extends SplitPdfState {}

class SplitPdfLoaded extends SplitPdfState {
  final String pdfPath;
  final int pageCount;

  const SplitPdfLoaded({
    required this.pdfPath,
    required this.pageCount,
  });

  @override
  List<Object?> get props => [pdfPath, pageCount];
}

class SplitPdfSuccess extends SplitPdfState {
  final String outputPdfPath;

  const SplitPdfSuccess(this.outputPdfPath);

  @override
  List<Object?> get props => [outputPdfPath];
}

class SplitPdfError extends SplitPdfState {
  final String message;

  const SplitPdfError(this.message);

  @override
  List<Object?> get props => [message];
}
