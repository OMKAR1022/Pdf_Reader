import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import '../bloc/pdf_creator_bloc.dart';
import '../bloc/pdf_creator_event.dart';
import '../bloc/pdf_creator_state.dart';
import '../widgets/image_preview_item.dart';
import '../widgets/empty_state_widget.dart';

class ImageToPdfPage extends StatelessWidget {
  const ImageToPdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PdfCreatorBloc(),
      child: const _ImageToPdfView(),
    );
  }
}

class _ImageToPdfView extends StatelessWidget {
  const _ImageToPdfView();

  Future<void> _pickImages(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    
    if (images.isNotEmpty && context.mounted) {
      context.read<PdfCreatorBloc>().add(AddImages(images));
    }
  }

  Future<void> _pickFromCamera(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    
    if (image != null && context.mounted) {
      context.read<PdfCreatorBloc>().add(AddImages([image]));
    }
  }

  Future<void> _cropImage(BuildContext context, XFile image, int index) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Theme.of(context).primaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Crop Image',
        ),
      ],
    );

    if (croppedFile != null && context.mounted) {
      final state = context.read<PdfCreatorBloc>().state;
      if (state is PdfCreatorLoaded) {
        final updatedImages = List<XFile>.from(state.images);
        updatedImages[index] = XFile(croppedFile.path);
        context.read<PdfCreatorBloc>().add(ReorderImages(updatedImages));
      }
    }
  }

  void _createPdf(BuildContext context) {
    context.read<PdfCreatorBloc>().add(const CreatePdf());
  }

  void _showSuccessDialog(BuildContext context, String pdfPath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('PDF Created Successfully'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your PDF has been created successfully!'),
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image to PDF'),
        elevation: 0,
        actions: [
          BlocBuilder<PdfCreatorBloc, PdfCreatorState>(
            builder: (context, state) {
              if (state is PdfCreatorLoaded && state.images.isNotEmpty) {
                return TextButton.icon(
                  onPressed: () => _createPdf(context),
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                  label: const Text(
                    'Create PDF',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<PdfCreatorBloc, PdfCreatorState>(
        listener: (context, state) {
          if (state is PdfCreatorLoaded && state.pdfPath != null) {
            _showSuccessDialog(context, state.pdfPath!);
          } else if (state is PdfCreatorError) {
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
          if (state is PdfCreatorLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Creating PDF...',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          if (state is PdfCreatorLoaded && state.images.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.image,
              title: 'No Images Selected',
              message: 'Add images from gallery or camera to create a PDF',
              onGalleryTap: () => _pickImages(context),
              onCameraTap: () => _pickFromCamera(context),
            );
          }

          if (state is PdfCreatorLoaded && state.images.isNotEmpty) {
            return Column(
              children: [
                // Header with image count
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Row(
                    children: [
                      Icon(
                        Icons.photo_library,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${state.images.length} ${state.images.length == 1 ? 'Image' : 'Images'} Selected',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => _pickImages(context),
                        icon: const Icon(Icons.add_photo_alternate),
                        tooltip: 'Add more images',
                      ),
                    ],
                  ),
                ),
                // Image grid
                Expanded(
                  child: ReorderableGridView.count(
                    crossAxisCount: 2,
                    padding: const EdgeInsets.all(16),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    onReorder: (oldIndex, newIndex) {
                      final images = List<XFile>.from(state.images);
                      final item = images.removeAt(oldIndex);
                      images.insert(newIndex, item);
                      context.read<PdfCreatorBloc>().add(ReorderImages(images));
                    },
                    children: state.images.asMap().entries.map((entry) {
                      final index = entry.key;
                      final image = entry.value;
                      return ImagePreviewItem(
                        key: ValueKey(image.path),
                        image: image,
                        index: index,
                        onRemove: () {
                          context.read<PdfCreatorBloc>().add(RemoveImage(index));
                        },
                        onCrop: () => _cropImage(context, image, index),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          }

          // Initial state
          return EmptyStateWidget(
            icon: Icons.image,
            title: 'Create PDF from Images',
            message: 'Select images from your gallery or take photos to create a PDF',
            onGalleryTap: () => _pickImages(context),
            onCameraTap: () => _pickFromCamera(context),
          );
        },
      ),
      floatingActionButton: BlocBuilder<PdfCreatorBloc, PdfCreatorState>(
        builder: (context, state) {
          if (state is PdfCreatorLoaded && state.images.isNotEmpty) {
            return FloatingActionButton.extended(
              onPressed: () => _createPdf(context),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Create PDF'),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
