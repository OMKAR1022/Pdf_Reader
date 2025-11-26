import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/models/pdf_file_model.dart';
import '../bloc/bloc.dart';

class FilesPage extends StatelessWidget {
  const FilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FilesBloc()..add(const LoadFiles()),
      child: const FilesView(),
    );
  }
}

class FilesView extends StatefulWidget {
  const FilesView({super.key});

  @override
  State<FilesView> createState() => _FilesViewState();
}

class _FilesViewState extends State<FilesView> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickAndOpenPdf(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        if (context.mounted) {
          Navigator.pushNamed(
            context,
            '/pdf-reader',
            arguments: result.files.single.path,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context, PdfFileModel file) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete File?'),
        content: Text('Are you sure you want to delete "${file.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<FilesBloc>().add(DeleteFile(file));
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, PdfFileModel file) {
    final controller = TextEditingController(text: file.name);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename File'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<FilesBloc>().add(RenameFile(file, controller.text));
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _shareFile(PdfFileModel file) {
    Share.shareXFiles([XFile(file.path)], text: 'Sharing PDF: ${file.name}');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search files...',
                    border: InputBorder.none,
                  ),
                  onChanged: (query) {
                    context.read<FilesBloc>().add(SearchFiles(query));
                  },
                )
              : const Text('My Files'),
          bottom: TabBar(
            onTap: (index) {
              context.read<FilesBloc>().add(FilterFavorites(index == 1));
            },
            tabs: const [
              Tab(text: 'All Files'),
              Tab(text: 'Favorites'),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                    context.read<FilesBloc>().add(const SearchFiles(''));
                  }
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.folder_open),
              tooltip: 'Import PDF',
              onPressed: () => _pickAndOpenPdf(context),
            ),
          ],
        ),
        body: BlocBuilder<FilesBloc, FilesState>(
          builder: (context, state) {
            if (state is FilesLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is FilesLoaded) {
              if (state.filteredFiles.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isSearching ? Icons.search_off : 
                        (state.showFavoritesOnly ? Icons.star_border : Icons.folder_open),
                        size: 64,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isSearching ? 'No files found' : 
                        (state.showFavoritesOnly ? 'No favorites yet' : 'No files yet'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (!_isSearching && !state.showFavoritesOnly) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Create or import a PDF to get started',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<FilesBloc>().add(const LoadFiles());
                },
                child: ListView.builder(
                  itemCount: state.filteredFiles.length,
                  itemBuilder: (context, index) {
                    final file = state.filteredFiles[index];
                    final fileSize = _formatFileSize(file.fileSizeBytes);
                    final date = _formatDate(file.createdAt);
                    final isFavorite = state.favorites.contains(file.path);

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.picture_as_pdf, color: Colors.red),
                        ),
                        title: Text(
                          file.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text('$date • $fileSize'),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/pdf-reader',
                            arguments: file.path,
                          );
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                isFavorite ? Icons.star : Icons.star_border,
                                color: isFavorite ? Colors.amber : null,
                              ),
                              onPressed: () {
                                context.read<FilesBloc>().add(ToggleFavorite(file.path));
                              },
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'share':
                                    _shareFile(file);
                                    break;
                                  case 'rename':
                                    _showRenameDialog(context, file);
                                    break;
                                  case 'delete':
                                    _showDeleteConfirmation(context, file);
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'share',
                                  child: Row(
                                    children: [
                                      Icon(Icons.share, size: 20),
                                      SizedBox(width: 12),
                                      Text('Share'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'rename',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 20),
                                      SizedBox(width: 12),
                                      Text('Rename'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red, size: 20),
                                      SizedBox(width: 12),
                                      Text('Delete', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            } else if (state is FilesError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${state.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<FilesBloc>().add(const LoadFiles());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
