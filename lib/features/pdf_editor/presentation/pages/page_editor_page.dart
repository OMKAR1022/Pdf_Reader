import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import '../../../pdf_reader/presentation/pages/pdf_reader_page.dart';
import '../bloc/page_editor_bloc.dart';
import '../bloc/page_editor_event.dart';
import '../bloc/page_editor_state.dart';

class PageEditorPage extends StatelessWidget {
  final String pdfPath;

  const PageEditorPage({
    super.key,
    required this.pdfPath,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PageEditorBloc()..add(LoadPdfForEditing(pdfPath)),
      child: const PageEditorView(),
    );
  }
}

class PageEditorView extends StatelessWidget {
  const PageEditorView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PageEditorBloc, PageEditorState>(
      listener: (context, state) {
        if (state is PageEditorLoaded && state.savedPath != null) {
          // Navigate to reader with new PDF
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PdfReaderPage(initialPath: state.savedPath!),
            ),
          );
        } else if (state is PageEditorError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is PageEditorLoading && state is! PageEditorLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is PageEditorLoaded) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Edit Pages'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () {
                    context.read<PageEditorBloc>().add(const SavePdfChanges());
                  },
                ),
              ],
            ),
            body: state.pageImages.isEmpty
                ? const Center(child: Text('No pages found'))
                : ReorderableGridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: state.pageImages.length,
                    onReorder: (oldIndex, newIndex) {
                      context.read<PageEditorBloc>().add(ReorderPages(oldIndex, newIndex));
                    },
                    itemBuilder: (context, index) {
                      // Map current index to original index to get rotation
                      final originalIndex = state.pageOrder[index];
                      final rotation = state.pageRotations[originalIndex] ?? 0;

                      return Card(
                        key: ValueKey(originalIndex), // Use original index as key to maintain identity
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            // Page Image
                            Positioned.fill(
                              child: RotatedBox(
                                quarterTurns: rotation ~/ 90,
                                child: Image.memory(
                                  state.pageImages[index],
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            
                            // Page Number Badge
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            // Actions Overlay
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.6),
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.rotate_right, color: Colors.white),
                                      onPressed: () {
                                        context.read<PageEditorBloc>().add(RotatePage(index, 90));
                                      },
                                      tooltip: 'Rotate',
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                                      onPressed: () {
                                        context.read<PageEditorBloc>().add(DeletePage(index));
                                      },
                                      tooltip: 'Delete',
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          );
        }

        return const Scaffold(
          body: Center(child: Text('Something went wrong')),
        );
      },
    );
  }
}
