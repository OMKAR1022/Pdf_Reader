import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../pdf_reader/presentation/pages/pdf_reader_page.dart';
import '../bloc/zip_to_pdf_bloc.dart';
import '../bloc/zip_to_pdf_event.dart';
import '../bloc/zip_to_pdf_state.dart';

class ZipToPdfPage extends StatelessWidget {
  const ZipToPdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ZipToPdfBloc(),
      child: const ZipToPdfView(),
    );
  }
}

class ZipToPdfView extends StatefulWidget {
  const ZipToPdfView({super.key});

  @override
  State<ZipToPdfView> createState() => _ZipToPdfViewState();
}

class _ZipToPdfViewState extends State<ZipToPdfView> {
  Future<void> _pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (result != null && result.files.single.path != null) {
      if (context.mounted) {
        context.read<ZipToPdfBloc>().add(LoadZipFile(result.files.single.path!));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zip to PDF'),
      ),
      body: BlocConsumer<ZipToPdfBloc, ZipToPdfState>(
        listener: (context, state) {
          if (state is ZipToPdfError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is ZipToPdfSuccess) {
            showDialog(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Success'),
                content: const Text('PDF created successfully!'),
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
                          builder: (context) => PdfReaderPage(initialPath: state.pdfPath),
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
          if (state is ZipToPdfLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ZipToPdfLoaded) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.folder_zip, size: 40, color: Colors.orange),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.zipPath.split('/').last,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('${state.images.length} images found'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: state.images.length,
                    itemBuilder: (context, index) {
                      return Image.file(
                        state.images[index],
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<ZipToPdfBloc>().add(const CreatePdfFromZip());
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Text('Create PDF'),
                    ),
                  ),
                ),
              ],
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.folder_zip_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Select a ZIP file containing images'),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _pickFile(context),
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Select ZIP'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
