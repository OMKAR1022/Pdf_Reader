import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../files/presentation/pages/files_page.dart';
import '../../../tools/presentation/pages/tools_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../bloc/bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final currentIndex = (state as HomeInitial).tabIndex;

        return Scaffold(
          appBar: currentIndex == 1
              ? null
              : AppBar(
                  title: Text(_getAppBarTitle(currentIndex)),
                  actions: [
                    if (currentIndex == 0) ...[
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          // TODO: Implement search
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_none),
                        onPressed: () {
                          // TODO: Implement notifications
                        },
                      ),
                    ],
                  ],
                ),
          body: IndexedStack(
            index: currentIndex,
            children: const [
              DashboardView(),
              FilesPage(),
              ToolsPage(),
              SettingsPage(),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              context.read<HomeBloc>().add(HomeTabChanged(index));
              if (index == 0) {
                context.read<HomeBloc>().add(const LoadRecentFiles());
              }
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.folder_outlined),
                selectedIcon: Icon(Icons.folder),
                label: 'Files',
              ),
              NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view),
                label: 'Tools',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
          floatingActionButton: currentIndex == 0
              ? FloatingActionButton.extended(
                  onPressed: () {
                    // TODO: Implement create new PDF
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('New PDF'),
                )
              : null,
        );
      },
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return AppConstants.appName;
      case 1:
        return 'My Files';
      case 2:
        return 'Tools';
      case 3:
        return 'Settings';
      default:
        return AppConstants.appName;
    }
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Actions Section
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildQuickActionCard(
                context,
                'Scan to PDF',
                Icons.camera_alt_rounded,
                Colors.blue,
                () async {
                  await Navigator.pushNamed(context, '/scan-to-pdf');
                  if (context.mounted) {
                    context.read<HomeBloc>().add(const LoadRecentFiles());
                  }
                },
              ),
              _buildQuickActionCard(
                context,
                'Image to PDF',
                Icons.image_rounded,
                Colors.orange,
                () async {
                  await Navigator.pushNamed(context, '/image-to-pdf');
                  if (context.mounted) {
                    context.read<HomeBloc>().add(const LoadRecentFiles());
                  }
                },
              ),
              _buildQuickActionCard(
                context,
                'Text to PDF',
                Icons.text_fields_rounded,
                Colors.green,
                () async {
                  await Navigator.pushNamed(context, '/text-to-pdf');
                  if (context.mounted) {
                    context.read<HomeBloc>().add(const LoadRecentFiles());
                  }
                },
              ),
              _buildQuickActionCard(
                context,
                'Merge PDFs',
                Icons.merge_type_rounded,
                Colors.purple,
                () async {
                  await Navigator.pushNamed(context, '/merge-pdfs');
                  if (context.mounted) {
                    context.read<HomeBloc>().add(const LoadRecentFiles());
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Recent Files Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Files',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () {
                  context.read<HomeBloc>().add(const HomeTabChanged(1)); // Switch to Files tab
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Recent Files List
          BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              final recentFiles = (state as HomeInitial).recentFiles;
              
              if (recentFiles.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.folder_open_rounded,
                        size: 64,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No recent files',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your first PDF now!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentFiles.length > 5 ? 5 : recentFiles.length,
                itemBuilder: (context, index) {
                  final file = recentFiles[index];
                  final fileSize = _formatFileSize(file.fileSizeBytes);
                  final timeAgo = _formatTimeAgo(file.createdAt);
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
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
                        file.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '$timeAgo • ${file.pageCount} page(s) • $fileSize',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/pdf-reader',
                          arguments: file.path,
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()}w ago';
    if (difference.inDays < 365) return '${(difference.inDays / 30).floor()}mo ago';
    return '${(difference.inDays / 365).floor()}y ago';
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
