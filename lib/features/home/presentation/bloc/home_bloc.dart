import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/pdf_storage_service.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final PdfStorageService _storageService = PdfStorageService();

  HomeBloc() : super(const HomeInitial()) {
    on<HomeTabChanged>(_onTabChanged);
    on<LoadRecentFiles>(_onLoadRecentFiles);
    
    // Load recent files on initialization
    add(const LoadRecentFiles());
  }

  void _onTabChanged(
    HomeTabChanged event,
    Emitter<HomeState> emit,
  ) {
    final tabIndex = event.tabIndex;
    final currentTab = HomeTab.values[tabIndex];
    final currentState = state as HomeInitial;
    emit(currentState.copyWith(tabIndex: tabIndex, currentTab: currentTab));
  }

  Future<void> _onLoadRecentFiles(
    LoadRecentFiles event,
    Emitter<HomeState> emit,
  ) async {
    final recentFiles = await _storageService.getRecentFiles();
    final currentState = state as HomeInitial;
    emit(currentState.copyWith(recentFiles: recentFiles));
  }
}
