import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';

class TextToPdfPage extends StatelessWidget {
  const TextToPdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TextToPdfBloc(),
      child: const TextToPdfView(),
    );
  }
}

class TextToPdfView extends StatefulWidget {
  const TextToPdfView({super.key});

  @override
  State<TextToPdfView> createState() => _TextToPdfViewState();
}

class _TextToPdfViewState extends State<TextToPdfView> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _showSuccessDialog(BuildContext context, String pdfPath) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
            const Text('Your PDF has been created from text!'),
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
    return BlocConsumer<TextToPdfBloc, TextToPdfState>(
      listener: (context, state) {
        if (state is TextToPdfEditing && state.pdfPath != null) {
          _showSuccessDialog(context, state.pdfPath!);
        } else if (state is TextToPdfError) {
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
        final isEditing = state is TextToPdfEditing;
        final fontSize = isEditing ? state.fontSize : 12.0;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Text to PDF'),
            actions: [
              if (isEditing && _textController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  onPressed: () {
                    context.read<TextToPdfBloc>().add(const CreatePdfFromText());
                  },
                ),
            ],
          ),
          body: state is TextToPdfLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Creating PDF...'),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Font size control
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      child: Row(
                        children: [
                          const Icon(Icons.format_size),
                          const SizedBox(width: 12),
                          const Text('Font Size:'),
                          Expanded(
                            child: Slider(
                              value: fontSize,
                              min: 8,
                              max: 24,
                              divisions: 16,
                              label: fontSize.toStringAsFixed(0),
                              onChanged: (value) {
                                context.read<TextToPdfBloc>().add(FontSizeChanged(value));
                              },
                            ),
                          ),
                          Text(
                            fontSize.toStringAsFixed(0),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                    // Text editor
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          controller: _textController,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          style: TextStyle(fontSize: fontSize),
                          decoration: InputDecoration(
                            hintText: 'Enter your text here...\n\nYou can type or paste any text you want to convert to PDF.',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          onChanged: (text) {
                            context.read<TextToPdfBloc>().add(TextChanged(text));
                          },
                        ),
                      ),
                    ),
                    // Character count
                    if (isEditing && state.text.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${state.text.length} characters',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              '${state.text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length} words',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
          floatingActionButton: isEditing && _textController.text.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: () {
                    context.read<TextToPdfBloc>().add(const CreatePdfFromText());
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Create PDF'),
                )
              : null,
        );
      },
    );
  }
}
