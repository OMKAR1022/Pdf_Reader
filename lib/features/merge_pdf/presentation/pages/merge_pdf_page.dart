import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../bloc/bloc.dart';

class MergePdfPage extends StatelessWidget {
  const MergePdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MergePdfBloc(),
      child: const MergePdfView(),
    );
  }
}

class MergePdfView extends StatefulWidget {
  const MergePdfView({super.key});

  @override
  State<MergePdfView> createState() => _MergePdfViewState();
}

class _MergePdfViewState extends State<MergePdfView> {
  Future<void> _pickPdfFiles(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty && context.mounted) {
        final paths = result.files
            .where((file) => file.path != null)
            .map((file) => file.path!)
            .toList();
        
        if (paths.isNotEmpty) {
          context.read<MergePdfBloc>().add(AddPdfFiles(paths));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking files: $e')),
        );
      }
    }
  }

  void _showSuccessDialog(BuildContext context, String pdfPath) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('PDFs Merged Successfully'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your PDFs have been merged into one file!'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.folder, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pdfPath,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushNamed(
                context,
                '/pdf-reader',
                arguments: pdfPath,
              );
            },
            icon: const Icon(Icons.visibility),
            label: const Text('View PDF'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MergePdfBloc, MergePdfState>(
      listener: (context, state) {
        if (state is MergePdfLoaded && state.mergedPdfPath != null) {
          _showSuccessDialog(context, state.mergedPdfPath!);
        } else if (state is MergePdfError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Merge PDFs'),
            actions: [
              if (state is MergePdfLoaded && state.pdfPaths.length >= 2)
                IconButton(
                  icon: const Icon(Icons.merge_type),
                  onPressed: () {
                    context.read<MergePdfBloc>().add(const MergePdfs());
                  },
                ),
            ],
          ),
          body: _buildBody(context, state),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _pickPdfFiles(context),
            icon: const Icon(Icons.add),
            label: const Text('Add PDFs'),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, MergePdfState state) {
    if (state is MergePdfLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Merging PDFs...'),
          ],
        ),
      );
    } else if (state is MergePdfLoaded) {
      if (state.pdfPaths.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.merge_type_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'No PDFs selected',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Add PDF files to merge them into one',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${state.pdfPaths.length} PDF(s) selected',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (state.pdfPaths.length >= 2)
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<MergePdfBloc>().add(const MergePdfs());
                    },
                    icon: const Icon(Icons.merge_type),
                    label: const Text('Merge PDFs'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              itemCount: state.pdfPaths.length,
              onReorder: (oldIndex, newIndex) {
                final paths = List<String>.from(state.pdfPaths);
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final item = paths.removeAt(oldIndex);
                paths.insert(newIndex, item);
                context.read<MergePdfBloc>().add(ReorderPdfFiles(paths));
              },
              itemBuilder: (context, index) {
                final path = state.pdfPaths[index];
                final fileName = path.split('/').last;
                final file = File(path);

                return Card(
                  key: ValueKey(path),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red,
                      ),
                    ),
                    title: Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: FutureBuilder<int>(
                      future: file.length(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final size = _formatFileSize(snapshot.data!);
                          return Text('Position ${index + 1} • $size');
                        }
                        return Text('Position ${index + 1}');
                      },
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.drag_handle),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            context.read<MergePdfBloc>().add(RemovePdfFile(index));
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    } else if (state is MergePdfError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _pickPdfFiles(context),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
