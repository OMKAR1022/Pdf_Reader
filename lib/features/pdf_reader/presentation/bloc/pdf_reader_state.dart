import 'package:equatable/equatable.dart';

abstract class PdfReaderState extends Equatable {
  const PdfReaderState();

  @override
  List<Object> get props => [];
}

class PdfReaderInitial extends PdfReaderState {}

class PdfReaderLoading extends PdfReaderState {}

class PdfReaderLoaded extends PdfReaderState {
  final String path;
  final int currentPage;
  final int totalPages;
  final double zoomLevel;
  final bool isNightMode;
  final List<int> bookmarks;
  final bool isSearching;
  final int searchResultCount;
  final int currentSearchResultIndex;

  const PdfReaderLoaded({
    required this.path,
    this.currentPage = 1,
    this.totalPages = 0,
    this.zoomLevel = 1.0,
    this.isNightMode = false,
    this.bookmarks = const [],
    this.isSearching = false,
    this.searchResultCount = 0,
    this.currentSearchResultIndex = 0,
  });

  PdfReaderLoaded copyWith({
    String? path,
    int? currentPage,
    int? totalPages,
    double? zoomLevel,
    bool? isNightMode,
    List<int>? bookmarks,
    bool? isSearching,
    int? searchResultCount,
    int? currentSearchResultIndex,
  }) {
    return PdfReaderLoaded(
      path: path ?? this.path,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      isNightMode: isNightMode ?? this.isNightMode,
      bookmarks: bookmarks ?? this.bookmarks,
      isSearching: isSearching ?? this.isSearching,
      searchResultCount: searchResultCount ?? this.searchResultCount,
      currentSearchResultIndex: currentSearchResultIndex ?? this.currentSearchResultIndex,
    );
  }

  @override
  List<Object> get props => [
        path,
        currentPage,
        totalPages,
        zoomLevel,
        isNightMode,
        bookmarks,
        isSearching,
        searchResultCount,
        currentSearchResultIndex,
      ];
}

class PdfReaderError extends PdfReaderState {
  final String message;

  const PdfReaderError(this.message);

  @override
  List<Object> get props => [message];
}
