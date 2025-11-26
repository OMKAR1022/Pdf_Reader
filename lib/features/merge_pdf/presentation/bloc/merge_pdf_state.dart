import 'package:equatable/equatable.dart';

abstract class MergePdfState extends Equatable {
  const MergePdfState();

  @override
  List<Object?> get props => [];
}

class MergePdfInitial extends MergePdfState {}

class MergePdfLoading extends MergePdfState {}

class MergePdfLoaded extends MergePdfState {
  final List<String> pdfPaths;
  final String? mergedPdfPath;

  const MergePdfLoaded({
    required this.pdfPaths,
    this.mergedPdfPath,
  });

  MergePdfLoaded copyWith({
    List<String>? pdfPaths,
    String? mergedPdfPath,
  }) {
    return MergePdfLoaded(
      pdfPaths: pdfPaths ?? this.pdfPaths,
      mergedPdfPath: mergedPdfPath ?? this.mergedPdfPath,
    );
  }

  @override
  List<Object?> get props => [pdfPaths, mergedPdfPath];
}

class MergePdfError extends MergePdfState {
  final String message;

  const MergePdfError(this.message);

  @override
  List<Object?> get props => [message];
}
