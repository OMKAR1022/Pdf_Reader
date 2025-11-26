import 'package:equatable/equatable.dart';
import '../../../../core/models/pdf_file_model.dart';

enum HomeTab { home, files, tools, settings }

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {
  final int tabIndex;
  final HomeTab currentTab;
  final List<PdfFileModel> recentFiles;

  const HomeInitial({
    this.tabIndex = 0,
    this.currentTab = HomeTab.home,
    this.recentFiles = const [],
  });

  HomeInitial copyWith({
    int? tabIndex,
    HomeTab? currentTab,
    List<PdfFileModel>? recentFiles,
  }) {
    return HomeInitial(
      tabIndex: tabIndex ?? this.tabIndex,
      currentTab: currentTab ?? this.currentTab,
      recentFiles: recentFiles ?? this.recentFiles,
    );
  }

  @override
  List<Object> get props => [tabIndex, currentTab, recentFiles];
}
