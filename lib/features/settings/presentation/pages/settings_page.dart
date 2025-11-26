import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = '${info.version} (${info.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return ListView(
            children: [
              _buildSectionHeader('Appearance'),
              ListTile(
                leading: const Icon(Icons.brightness_6),
                title: const Text('Theme'),
                subtitle: Text(_getThemeText(state.themeMode)),
                onTap: () => _showThemeDialog(context, state.themeMode),
              ),
              const Divider(),
              _buildSectionHeader('About'),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Version'),
                subtitle: Text(_version),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Privacy Policy'),
                onTap: () => _launchUrl('https://example.com/privacy'), // Replace with actual URL
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Terms of Service'),
                onTap: () => _launchUrl('https://example.com/terms'), // Replace with actual URL
              ),
              const Divider(),
              _buildSectionHeader('Support'),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share App'),
                onTap: () {
                  Share.share('Check out this amazing PDF Maker app!');
                },
              ),
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Rate Us'),
                onTap: () {
                  // Implement rating logic or open store link
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  String _getThemeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  void _showThemeDialog(BuildContext context, ThemeMode currentMode) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption(context, ThemeMode.system, 'System Default', currentMode),
              _buildThemeOption(context, ThemeMode.light, 'Light', currentMode),
              _buildThemeOption(context, ThemeMode.dark, 'Dark', currentMode),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeOption(BuildContext context, ThemeMode mode, String label, ThemeMode currentMode) {
    return RadioListTile<ThemeMode>(
      title: Text(label),
      value: mode,
      groupValue: currentMode,
      onChanged: (value) {
        if (value != null) {
          context.read<SettingsBloc>().add(UpdateThemeMode(value));
          Navigator.pop(context);
        }
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
