import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../bloc/pdf_to_image_bloc.dart';
import '../bloc/pdf_to_image_event.dart';
import '../bloc/pdf_to_image_state.dart';

class PdfToImagePage extends StatelessWidget {
  const PdfToImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PdfToImageBloc(),
      child: const PdfToImageView(),
    );
  }
}

class PdfToImageView extends StatefulWidget {
  const PdfToImageView({super.key});

  @override
  State<PdfToImageView> createState() => _PdfToImageViewState();
}

class _PdfToImageViewState extends State<PdfToImageView> {
  final Set<int> _selectedIndices = {};

  Future<void> _pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      if (context.mounted) {
        context.read<PdfToImageBloc>().add(LoadPdfForConversion(result.files.single.path!));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF to Image'),
        actions: [
          BlocBuilder<PdfToImageBloc, PdfToImageState>(
            builder: (context, state) {
              if (state is PdfToImageLoaded && _selectedIndices.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    context.read<PdfToImageBloc>().add(SaveImages(_selectedIndices.toList()));
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<PdfToImageBloc, PdfToImageState>(
        listener: (context, state) {
          if (state is PdfToImageError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is PdfToImageSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is PdfToImageLoaded) {
             // Initialize selection with all pages
             setState(() {
               _selectedIndices.clear();
               _selectedIndices.addAll(List.generate(state.images.length, (index) => index));
             });
          }
        },
        builder: (context, state) {
          if (state is PdfToImageLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PdfToImageLoaded) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedIndices.length} pages selected',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            if (_selectedIndices.length == state.images.length) {
                              _selectedIndices.clear();
                            } else {
                              _selectedIndices.clear();
                              _selectedIndices.addAll(List.generate(state.images.length, (index) => index));
                            }
                          });
                        },
                        child: Text(_selectedIndices.length == state.images.length ? 'Deselect All' : 'Select All'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: state.images.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedIndices.contains(index);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedIndices.remove(index);
                            } else {
                              _selectedIndices.add(index);
                            }
                          });
                        },
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: isSelected
                                    ? Border.all(color: Theme.of(context).primaryColor, width: 3)
                                    : null,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Image.memory(
                                  state.images[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Page ${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.image_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Select a PDF to convert to images'),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _pickFile(context),
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Select PDF'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
