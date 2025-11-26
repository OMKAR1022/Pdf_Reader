import 'package:flutter/material.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildToolSection(
          context,
          'Create & Convert',
          [
            _ToolItem(
              icon: Icons.image,
              color: Colors.orange,
              title: 'Image to PDF',
              route: '/image-to-pdf',
            ),
            _ToolItem(
              icon: Icons.text_fields,
              color: Colors.green,
              title: 'Text to PDF',
              route: '/text-to-pdf',
            ),
            _ToolItem(
              icon: Icons.camera_alt,
              color: Colors.blue,
              title: 'Scan to PDF',
              route: '/scan-to-pdf',
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildToolSection(
          context,
          'Modify PDF',
          [
            _ToolItem(
              icon: Icons.merge_type,
              color: Colors.purple,
              title: 'Merge PDFs',
              route: '/merge-pdfs',
            ),
            _ToolItem(
              icon: Icons.compress,
              color: Colors.red,
              title: 'Compress PDF',
              route: '/compress-pdf',
            ),
            _ToolItem(
              icon: Icons.image_outlined,
              color: Colors.teal,
              title: 'PDF to Image',
              route: '/pdf-to-image',
            ),
            _ToolItem(
              icon: Icons.lock,
              color: Colors.blueGrey,
              title: 'Protect PDF',
              route: '/password-protect',
            ),
            _ToolItem(
              icon: Icons.folder_zip,
              color: Colors.amber,
              title: 'Zip to PDF',
              route: '/zip-to-pdf',
            ),
            _ToolItem(
              icon: Icons.call_split,
              color: Colors.purple,
              title: 'Split PDF',
              route: '/split-pdf',
            ),
            _ToolItem(
              icon: Icons.edit_document,
              color: Colors.indigo,
              title: 'Annotate PDF',
              route: '/annotate-pdf',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToolSection(BuildContext context, String title, List<_ToolItem> tools) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: tools.length,
          itemBuilder: (context, index) {
            final tool = tools[index];
            return _buildToolCard(context, tool);
          },
        ),
      ],
    );
  }

  Widget _buildToolCard(BuildContext context, _ToolItem tool) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, tool.route);
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: tool.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(tool.icon, color: tool.color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              tool.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolItem {
  final IconData icon;
  final Color color;
  final String title;
  final String route;

  _ToolItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.route,
  });
}
