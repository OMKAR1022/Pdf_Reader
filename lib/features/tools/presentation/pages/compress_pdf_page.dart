import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../pdf_reader/presentation/pages/pdf_reader_page.dart';
import '../bloc/compress_pdf_bloc.dart';
import '../bloc/compress_pdf_event.dart';
import '../bloc/compress_pdf_state.dart';

class CompressPdfPage extends StatelessWidget {
  const CompressPdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CompressPdfBloc(),
      child: const CompressPdfView(),
    );
  }
}

class CompressPdfView extends StatefulWidget {
  const CompressPdfView({super.key});

  @override
  State<CompressPdfView> createState() => _CompressPdfViewState();
}

class _CompressPdfViewState extends State<CompressPdfView> {
  int _quality = 50;

  Future<void> _pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      if (context.mounted) {
        context.read<CompressPdfBloc>().add(LoadPdfForCompression(result.files.single.path!));
      }
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compress PDF'),
      ),
      body: BlocConsumer<CompressPdfBloc, CompressPdfState>(
        listener: (context, state) {
          if (state is CompressPdfError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is CompressPdfLoaded && state.compressedPath != null) {
            // Show success dialog
            showDialog(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Compression Complete'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Original Size: ${_formatFileSize(state.originalSize)}'),
                    const SizedBox(height: 8),
                    Text('New Size: ${_formatFileSize(state.compressedSize!)}'),
                    const SizedBox(height: 8),
                    Text(
                      'Saved ${((state.originalSize - state.compressedSize!) / state.originalSize * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Close'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PdfReaderPage(initialPath: state.compressedPath),
                        ),
                      );
                    },
                    child: const Text('Open PDF'),
                  ),
                ],
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CompressPdfLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CompressPdfLoaded) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(Icons.picture_as_pdf, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'Selected File',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(state.originalPath.split('/').last),
                          const SizedBox(height: 8),
                          Text(
                            'Size: ${_formatFileSize(state.originalSize)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Compression Level: $_quality%',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Slider(
                    value: _quality.toDouble(),
                    min: 10,
                    max: 90,
                    divisions: 8,
                    label: '$_quality%',
                    onChanged: (value) {
                      setState(() {
                        _quality = value.toInt();
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Lower quality means smaller file size but potentially blurry images.',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CompressPdfBloc>().add(CompressPdf(_quality));
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Text('Compress PDF'),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.compress, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Select a PDF to compress'),
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
