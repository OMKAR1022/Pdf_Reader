import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:file_picker/file_picker.dart';
import '../bloc/bloc.dart';

class PdfReaderPage extends StatelessWidget {
  final String? initialPath;

  const PdfReaderPage({super.key, this.initialPath});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = PdfReaderBloc();
        if (initialPath != null) {
          bloc.add(PdfFileOpened(initialPath!));
        }
        return bloc;
      },
      child: const PdfReaderView(),
    );
  }
}

class PdfReaderView extends StatefulWidget {
  const PdfReaderView({super.key});

  @override
  State<PdfReaderView> createState() => _PdfReaderViewState();
}

class _PdfReaderViewState extends State<PdfReaderView> {
  late PdfViewerController _pdfViewerController;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final TextEditingController _searchController = TextEditingController();
  PdfTextSearchResult _searchResult = PdfTextSearchResult();

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      if (context.mounted) {
        context.read<PdfReaderBloc>().add(PdfFileOpened(result.files.single.path!));
      }
    }
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search in PDF'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Enter text to search',
            suffixIcon: Icon(Icons.search),
          ),
          autofocus: true,
          onSubmitted: (value) {
            Navigator.pop(context);
            _performSearch(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performSearch(_searchController.text);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _performSearch(String query) {
    if (query.isEmpty) return;
    
    context.read<PdfReaderBloc>().add(PdfSearchRequested(query));
    _searchResult = _pdfViewerController.searchText(query);
    
    if (_searchResult.totalInstanceCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No matches found')),
      );
    }
    setState(() {});
  }

  void _clearSearch() {
    _pdfViewerController.clearSelection();
    _searchController.clear();
    context.read<PdfReaderBloc>().add(const PdfSearchCleared());
    setState(() {
      _searchResult = PdfTextSearchResult();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PdfReaderBloc, PdfReaderState>(
      builder: (context, state) {
        final isLoaded = state is PdfReaderLoaded;
        final loadedState = state is PdfReaderLoaded ? state : null;

        return Scaffold(
          appBar: AppBar(
            title: isLoaded && loadedState!.isSearching
                ? _buildSearchAppBar(context, loadedState)
                : const Text('PDF Reader'),
            actions: [
              if (isLoaded && !loadedState!.isSearching) ...[
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _showSearchDialog(context),
                ),
                IconButton(
                  icon: Icon(
                    loadedState.isNightMode 
                        ? Icons.light_mode 
                        : Icons.dark_mode
                  ),
                  onPressed: () {
                    context.read<PdfReaderBloc>().add(const PdfNightModeToggled());
                  },
                ),
                IconButton(
                  icon: Icon(
                    loadedState.bookmarks.contains(loadedState.currentPage)
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                  ),
                  onPressed: () {
                    context.read<PdfReaderBloc>().add(
                      PdfBookmarkToggled(loadedState.currentPage),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit_document),
                  tooltip: 'Edit Pages',
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/page-editor',
                      arguments: loadedState.path,
                    );
                  },
                ),
              ],
              if (!isLoaded)
                IconButton(
                  icon: const Icon(Icons.folder_open),
                  onPressed: () => _pickFile(context),
                ),
            ],
          ),
          drawer: isLoaded ? _buildDrawer(context, loadedState!) : null,
          body: _buildBody(context, state),
          floatingActionButton: isLoaded && loadedState!.isSearching
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'prev_search',
                      onPressed: () {
                        _searchResult.previousInstance();
                      },
                      child: const Icon(Icons.navigate_before),
                    ),
                    const SizedBox(width: 16),
                    FloatingActionButton.small(
                      heroTag: 'next_search',
                      onPressed: () {
                        _searchResult.nextInstance();
                      },
                      child: const Icon(Icons.navigate_next),
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }

  Widget _buildSearchAppBar(BuildContext context, PdfReaderLoaded state) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Found ${_searchResult.totalInstanceCount} matches',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: _clearSearch,
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context, PdfReaderLoaded state) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Center(
              child: Text(
                'Bookmarks',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          if (state.bookmarks.isEmpty)
            const Expanded(
              child: Center(
                child: Text('No bookmarks yet'),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: state.bookmarks.length,
                itemBuilder: (context, index) {
                  final pageNum = state.bookmarks[index];
                  return ListTile(
                    leading: const Icon(Icons.bookmark),
                    title: Text('Page $pageNum'),
                    onTap: () {
                      _pdfViewerController.jumpToPage(pageNum);
                      Navigator.pop(context);
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        context.read<PdfReaderBloc>().add(
                          PdfBookmarkToggled(pageNum),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, PdfReaderState state) {
    if (state is PdfReaderInitial) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.picture_as_pdf_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No PDF opened',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _pickFile(context),
              icon: const Icon(Icons.folder_open),
              label: const Text('Open PDF'),
            ),
          ],
        ),
      );
    } else if (state is PdfReaderLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is PdfReaderError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _pickFile(context),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    } else if (state is PdfReaderLoaded) {
      Widget viewer = SfPdfViewer.file(
        File(state.path),
        key: _pdfViewerKey,
        controller: _pdfViewerController,
        enableDoubleTapZooming: true,
        onPageChanged: (PdfPageChangedDetails details) {
          context.read<PdfReaderBloc>().add(
                PdfPageChanged(
                  pageNumber: details.newPageNumber,
                  totalPages: _pdfViewerController.pageCount,
                ),
              );
        },
        onDocumentLoaded: (PdfDocumentLoadedDetails details) {
          context.read<PdfReaderBloc>().add(
                PdfPageChanged(
                  pageNumber: 1,
                  totalPages: details.document.pages.count,
                ),
              );
        },
      );

      if (state.isNightMode) {
        return ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            -1,  0,  0, 0, 255,
             0, -1,  0, 0, 255,
             0,  0, -1, 0, 255,
             0,  0,  0, 1,   0,
          ]),
          child: viewer,
        );
      }
      
      return viewer;
    }
    return const SizedBox.shrink();
  }
}
