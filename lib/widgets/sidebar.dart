// lib/widgets/sidebar.dart
// Sidebar bên trái — hiển thị file gần đây
// Tác giả: Chương
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/strings_vi.dart';
import '../core/theme.dart';
import '../providers/workspace_provider.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkspaceProvider>(
      builder: (context, provider, _) {
        return Container(
          width: 240,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                child: const Text(
                  S.recentFiles,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: provider.recent.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          S.noRecent,
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        itemCount: provider.recent.length,
                        itemBuilder: (context, i) {
                          final path = provider.recent[i];
                          final name =
                              path.split(RegExp(r'[\\/]')).last;
                          return ListTile(
                            dense: true,
                            leading: const Icon(
                              Icons.picture_as_pdf,
                              color: AppTheme.primary,
                              size: 20,
                            ),
                            title: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                            subtitle: Text(
                              path,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11),
                            ),
                            onTap: () => provider.openFile(path),
                          );
                        },
                      ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextButton.icon(
                  onPressed: provider.recent.isEmpty
                      ? null
                      : () => provider.clearRecent(),
                  icon: const Icon(Icons.delete_sweep, size: 18),
                  label: const Text('Xoá danh sách'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}