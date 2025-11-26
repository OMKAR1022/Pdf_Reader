import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../pdf_reader/presentation/pages/pdf_reader_page.dart';
import '../bloc/split_pdf_bloc.dart';
import '../bloc/split_pdf_event.dart';
import '../bloc/split_pdf_state.dart';

class SplitPdfPage extends StatelessWidget {
  const SplitPdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplitPdfBloc(),
      child: const SplitPdfView(),
    );
  }
}

class SplitPdfView extends StatefulWidget {
  const SplitPdfView({super.key});

  @override
  State<SplitPdfView> createState() => _SplitPdfViewState();
}

class _SplitPdfViewState extends State<SplitPdfView> {
  final TextEditingController _rangeController = TextEditingController();

  Future<void> _pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      if (context.mounted) {
        context.read<SplitPdfBloc>().add(LoadPdfForSplit(result.files.single.path!));
      }
    }
  }

  @override
  void dispose() {
    _rangeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Split PDF'),
      ),
      body: BlocConsumer<SplitPdfBloc, SplitPdfState>(
        listener: (context, state) {
          if (state is SplitPdfError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is SplitPdfSuccess) {
            showDialog(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Success'),
                content: const Text('PDF pages extracted successfully!'),
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
                          builder: (context) => PdfReaderPage(initialPath: state.outputPdfPath),
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
          if (state is SplitPdfLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SplitPdfLoaded) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.picture_as_pdf, size: 40, color: Colors.red),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.pdfPath.split('/').last,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('${state.pageCount} pages'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Enter Page Range',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('e.g., "1-3", "5", "1,3-5"'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _rangeController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '1-5',
                    ),
                    keyboardType: TextInputType.number, // Might need text for commas/dashes
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<SplitPdfBloc>().add(ExtractPages(_rangeController.text));
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Text('Extract Pages'),
                    ),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.call_split, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Select a PDF to split/extract pages'),
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
