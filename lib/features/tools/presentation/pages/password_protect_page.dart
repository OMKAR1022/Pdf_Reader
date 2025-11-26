import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../pdf_reader/presentation/pages/pdf_reader_page.dart';
import '../bloc/password_protect_bloc.dart';
import '../bloc/password_protect_event.dart';
import '../bloc/password_protect_state.dart';

class PasswordProtectPage extends StatelessWidget {
  const PasswordProtectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PasswordProtectBloc(),
      child: const PasswordProtectView(),
    );
  }
}

class PasswordProtectView extends StatefulWidget {
  const PasswordProtectView({super.key});

  @override
  State<PasswordProtectView> createState() => _PasswordProtectViewState();
}

class _PasswordProtectViewState extends State<PasswordProtectView> {
  final _formKey = GlobalKey<FormState>();
  final _userPasswordController = TextEditingController();
  final _ownerPasswordController = TextEditingController();
  bool _obscureUserPassword = true;
  bool _obscureOwnerPassword = true;

  @override
  void dispose() {
    _userPasswordController.dispose();
    _ownerPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      if (context.mounted) {
        context.read<PasswordProtectBloc>().add(LoadPdfForProtection(result.files.single.path!));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Protect PDF'),
      ),
      body: BlocConsumer<PasswordProtectBloc, PasswordProtectState>(
        listener: (context, state) {
          if (state is PasswordProtectError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is PasswordProtectLoaded && state.protectedPath != null) {
            showDialog(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Success'),
                content: const Text('PDF protected successfully!'),
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
                          builder: (context) => PdfReaderPage(initialPath: state.protectedPath),
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
          if (state is PasswordProtectLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PasswordProtectLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(Icons.lock, size: 48, color: Colors.blue),
                            const SizedBox(height: 16),
                            Text(
                              'Selected File',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(state.originalPath.split('/').last),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _userPasswordController,
                      obscureText: _obscureUserPassword,
                      decoration: InputDecoration(
                        labelText: 'User Password (Required)',
                        helperText: 'Required to open the document',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureUserPassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureUserPassword = !_obscureUserPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 4) {
                          return 'Password must be at least 4 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _ownerPasswordController,
                      obscureText: _obscureOwnerPassword,
                      decoration: InputDecoration(
                        labelText: 'Owner Password (Optional)',
                        helperText: 'Required to change permissions',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureOwnerPassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureOwnerPassword = !_obscureOwnerPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<PasswordProtectBloc>().add(
                                ProtectPdf(
                                  userPassword: _userPasswordController.text,
                                  ownerPassword: _ownerPasswordController.text,
                                ),
                              );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Text('Protect PDF'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Select a PDF to protect'),
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
