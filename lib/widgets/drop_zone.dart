// lib/widgets/drop_zone.dart
// Khu vực welcome + kéo thả file + các nút chính
// Tác giả: Chương
import 'dart:io';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_info.dart';
import '../core/strings_vi.dart';
import '../core/theme.dart';
import '../providers/workspace_provider.dart';

class DropZone extends StatefulWidget {
  final VoidCallback onOpenPdf;
  final VoidCallback onOpenImages;
  final VoidCallback onReceive;

  const DropZone({
    super.key,
    required this.onOpenPdf,
    required this.onOpenImages,
    required this.onReceive,
  });

  @override
  State<DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<DropZone> {
  bool _dragging = false;

  Future<void> _handleDrop(List<String> paths) async {
    final provider = context.read<WorkspaceProvider>();
    for (final path in paths) {
      final lower = path.toLowerCase();
      try {
        if (lower.endsWith('.pdf')) {
          await provider.openFile(path);
        } else if (lower.endsWith('.jpg') ||
            lower.endsWith('.jpeg') ||
            lower.endsWith('.png') ||
            lower.endsWith('.webp')) {
          final bytes = await provider.pdfOps.imagesToPdf([path]);
          await provider.openFile(path, bytes: bytes);
        } else if (File(path).existsSync() &&
            Directory(path).existsSync()) {
          // Thư mục — quét tất cả file bên trong
          final dir = Directory(path);
          final all = <String>[];
          await for (final entity in dir.list(recursive: false)) {
            if (entity is File) all.add(entity.path);
          }
          await _handleDrop(all);
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.errOpenFile}: $path')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragEntered: (_) => setState(() => _dragging = true),
      onDragExited: (_) => setState(() => _dragging = false),
      onDragDone: (details) async {
        setState(() => _dragging = false);
        await _handleDrop(details.files.map((f) => f.path).toList());
      },
      child: Container(
        color: _dragging ? const Color(0xFFE3F2FD) : AppTheme.background,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _dragging
                        ? Icons.file_download
                        : Icons.picture_as_pdf,
                    size: 80,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    S.welcome,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${AppInfo.appName} ${AppInfo.version}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppInfo.tagline,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tác giả: Chương',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _dragging
                            ? AppTheme.primary
                            : Colors.black12,
                        width: _dragging ? 3 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.cloud_upload,
                            size: 48,
                            color: _dragging
                                ? AppTheme.primary
                                : Colors.grey),
                        const SizedBox(height: 12),
                        const Text(
                          S.dropHint,
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          S.orClick,
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: widget.onOpenPdf,
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text(S.btnOpenPdf),
                      ),
                      ElevatedButton.icon(
                        onPressed: widget.onOpenImages,
                        icon: const Icon(Icons.image),
                        label: const Text(S.btnOpenImages),
                      ),
                      ElevatedButton.icon(
                        onPressed: widget.onReceive,
                        icon: const Icon(Icons.qr_code),
                        label: const Text(S.btnReceive),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}