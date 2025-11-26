import 'package:equatable/equatable.dart';

abstract class SplitPdfEvent extends Equatable {
  const SplitPdfEvent();

  @override
  List<Object?> get props => [];
}

class LoadPdfForSplit extends SplitPdfEvent {
  final String path;

  const LoadPdfForSplit(this.path);

  @override
  List<Object?> get props => [path];
}

class ExtractPages extends SplitPdfEvent {
  final String pageRange; // e.g., "1-3, 5"

  const ExtractPages(this.pageRange);

  @override
  List<Object?> get props => [pageRange];
}
