import 'package:equatable/equatable.dart';

abstract class PdfReaderEvent extends Equatable {
  const PdfReaderEvent();

  @override
  List<Object> get props => [];
}

class PdfFileOpened extends PdfReaderEvent {
  final String path;

  const PdfFileOpened(this.path);

  @override
  List<Object> get props => [path];
}

class PdfPageChanged extends PdfReaderEvent {
  final int pageNumber;
  final int totalPages;

  const PdfPageChanged({required this.pageNumber, required this.totalPages});

  @override
  List<Object> get props => [pageNumber, totalPages];
}

class PdfZoomChanged extends PdfReaderEvent {
  final double zoomLevel;

  const PdfZoomChanged(this.zoomLevel);

  @override
  List<Object> get props => [zoomLevel];
}

class PdfSearchRequested extends PdfReaderEvent {
  final String query;

  const PdfSearchRequested(this.query);

  @override
  List<Object> get props => [query];
}

class PdfBookmarkToggled extends PdfReaderEvent {
  final int pageNumber;

  const PdfBookmarkToggled(this.pageNumber);

  @override
  List<Object> get props => [pageNumber];
}

class PdfNightModeToggled extends PdfReaderEvent {
  const PdfNightModeToggled();
}

class PdfSearchCleared extends PdfReaderEvent {
  const PdfSearchCleared();
}

