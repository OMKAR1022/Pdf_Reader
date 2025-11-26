import 'package:equatable/equatable.dart';

abstract class MergePdfEvent extends Equatable {
  const MergePdfEvent();

  @override
  List<Object?> get props => [];
}

class AddPdfFiles extends MergePdfEvent {
  final List<String> filePaths;

  const AddPdfFiles(this.filePaths);

  @override
  List<Object?> get props => [filePaths];
}

class RemovePdfFile extends MergePdfEvent {
  final int index;

  const RemovePdfFile(this.index);

  @override
  List<Object?> get props => [index];
}

class ReorderPdfFiles extends MergePdfEvent {
  final List<String> reorderedPaths;

  const ReorderPdfFiles(this.reorderedPaths);

  @override
  List<Object?> get props => [reorderedPaths];
}

class MergePdfs extends MergePdfEvent {
  const MergePdfs();
}

class PdfsMerged extends MergePdfEvent {
  final String path;

  const PdfsMerged(this.path);

  @override
  List<Object?> get props => [path];
}

class MergeError extends MergePdfEvent {
  final String message;

  const MergeError(this.message);

  @override
  List<Object?> get props => [message];
}
