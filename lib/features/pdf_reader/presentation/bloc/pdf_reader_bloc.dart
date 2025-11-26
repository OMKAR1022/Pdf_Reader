import 'package:flutter_bloc/flutter_bloc.dart';
import 'pdf_reader_event.dart';
import 'pdf_reader_state.dart';

class PdfReaderBloc extends Bloc<PdfReaderEvent, PdfReaderState> {
  PdfReaderBloc() : super(PdfReaderInitial()) {
    on<PdfFileOpened>(_onFileOpened);
    on<PdfPageChanged>(_onPageChanged);
    on<PdfZoomChanged>(_onZoomChanged);
    on<PdfNightModeToggled>(_onNightModeToggled);
    on<PdfBookmarkToggled>(_onBookmarkToggled);
    on<PdfSearchRequested>(_onSearchRequested);
    on<PdfSearchCleared>(_onSearchCleared);
  }

  void _onFileOpened(
    PdfFileOpened event,
    Emitter<PdfReaderState> emit,
  ) {
    emit(PdfReaderLoading());
    try {
      emit(PdfReaderLoaded(path: event.path));
    } catch (e) {
      emit(PdfReaderError('Failed to open PDF: ${e.toString()}'));
    }
  }

  void _onPageChanged(
    PdfPageChanged event,
    Emitter<PdfReaderState> emit,
  ) {
    if (state is PdfReaderLoaded) {
      final currentState = state as PdfReaderLoaded;
      emit(currentState.copyWith(
        currentPage: event.pageNumber,
        totalPages: event.totalPages,
      ));
    }
  }

  void _onZoomChanged(
    PdfZoomChanged event,
    Emitter<PdfReaderState> emit,
  ) {
    if (state is PdfReaderLoaded) {
      final currentState = state as PdfReaderLoaded;
      emit(currentState.copyWith(zoomLevel: event.zoomLevel));
    }
  }

  void _onNightModeToggled(
    PdfNightModeToggled event,
    Emitter<PdfReaderState> emit,
  ) {
    if (state is PdfReaderLoaded) {
      final currentState = state as PdfReaderLoaded;
      emit(currentState.copyWith(isNightMode: !currentState.isNightMode));
    }
  }

  void _onBookmarkToggled(
    PdfBookmarkToggled event,
    Emitter<PdfReaderState> emit,
  ) {
    if (state is PdfReaderLoaded) {
      final currentState = state as PdfReaderLoaded;
      final bookmarks = List<int>.from(currentState.bookmarks);
      
      if (bookmarks.contains(event.pageNumber)) {
        bookmarks.remove(event.pageNumber);
      } else {
        bookmarks.add(event.pageNumber);
        bookmarks.sort();
      }
      
      emit(currentState.copyWith(bookmarks: bookmarks));
    }
  }

  void _onSearchRequested(
    PdfSearchRequested event,
    Emitter<PdfReaderState> emit,
  ) {
    if (state is PdfReaderLoaded) {
      final currentState = state as PdfReaderLoaded;
      emit(currentState.copyWith(isSearching: true));
      // Note: Actual search logic will be handled by the UI controller, 
      // but we track the state here.
    }
  }

  void _onSearchCleared(
    PdfSearchCleared event,
    Emitter<PdfReaderState> emit,
  ) {
    if (state is PdfReaderLoaded) {
      final currentState = state as PdfReaderLoaded;
      emit(currentState.copyWith(
        isSearching: false,
        searchResultCount: 0,
        currentSearchResultIndex: 0,
      ));
    }
  }
}
