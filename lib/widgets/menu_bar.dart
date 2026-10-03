// lib/widgets/menu_bar.dart
// Menu bar kiểu desktop: Tệp / Công cụ / Trợ giúp
// Tác giả: Chương
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_info.dart';
import '../core/strings_vi.dart';
import '../core/theme.dart';
import '../providers/workspace_provider.dart';
import '../services/file_dialog_service.dart';

class DesktopMenuBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onOpenPdf;
  final VoidCallback onOpenImages;
  final VoidCallback onReceive;
  final VoidCallback onEditor;
  final VoidCallback onAbout;

  const DesktopMenuBar({
    super.key,
    required this.onOpenPdf,
    required this.onOpenImages,
    required this.onReceive,
    required this.onEditor,
    required this.onAbout,
  });

  @override
  Size get preferredSize => const Size.fromHeight(36);

  Future<void> _merge(BuildContext context) async {
    final paths = await FileDialogService().pickPdfs();
    if (paths.length < 2) return;
    if (!context.mounted) return;
    final provider = context.read<WorkspaceProvider>();
    provider.setBusy(true);
    try {
      final listBytes = <List<int>>[];
      for (final p in paths) {
        final bytes = await provider.pdfOps.readBytes(p);
        listBytes.add(bytes);
      }
      final merged = await provider.pdfOps
          .merge(listBytes.map((e) => e as dynamic).toList().cast());
      await provider.openFile(
        'gop_${DateTime.now().millisecondsSinceEpoch}.pdf',
        bytes: merged,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gộp PDF thành công')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${S.error}: $e')),
      );
    } finally {
      provider.setBusy(false);
    }
  }

  Future<void> _compress(BuildContext context) async {
    final provider = context.read<WorkspaceProvider>();
    final doc = provider.active;
    if (doc == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mở 1 file PDF trước')),
      );
      return;
    }
    provider.setBusy(true);
    try {
      final result = await provider.pdfOps.compress(doc.bytes!);
      final path = await FileDialogService().saveAsPdf(
        suggestedName: 'nen_${doc.displayName}',
      );
      if (path == null) return;
      await provider.pdfOps.saveBytes(result, path);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã lưu: $path')),
      );
    } finally {
      provider.setBusy(false);
    }
  }

  Future<void> _protect(BuildContext context) async {
    final provider = context.read<WorkspaceProvider>();
    final doc = provider.active;
    if (doc == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mở 1 file PDF trước')),
      );
      return;
    }
    final controller = TextEditingController();
    final pass = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Đặt mật khẩu bảo vệ PDF'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Mật khẩu',
            hintText: 'Nhập mật khẩu cho file PDF',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(S.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text(S.ok),
          ),
        ],
      ),
    );
    if (pass == null || pass.isEmpty) return;
    provider.setBusy(true);
    try {
      final result = await provider.pdfOps
          .protect(doc.bytes!, userPassword: pass);
      final path = await FileDialogService().saveAsPdf(
        suggestedName: 'baomat_${doc.displayName}',
      );
      if (path == null) return;
      await provider.pdfOps.saveBytes(result, path);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã lưu: $path')),
      );
    } finally {
      provider.setBusy(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: AppTheme.primary, size: 20),
          const SizedBox(width: 6),
          Text(
            '${AppInfo.appName} ${AppInfo.version}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          _Menu(
            label: S.menuFile,
            items: [
              _Item(S.menuOpen, Icons.folder_open, onOpenPdf),
              _Item(S.menuOpenImages, Icons.image, onOpenImages),
              _Item(S.menuExit, Icons.exit_to_app, () {
                // Desktop close — không làm gì trong bản này
              }),
            ],
          ),
          _Menu(
            label: S.menuTools,
            items: [
              _Item('Gộp PDF', Icons.merge_type,
                  () => _merge(context)),
              _Item('Nén PDF', Icons.compress, () => _compress(context)),
              _Item('Đặt mật khẩu', Icons.lock, () => _protect(context)),
              _Item(S.menuEditor, Icons.edit, onEditor),
              _Item(S.menuReceive, Icons.qr_code, onReceive),
            ],
          ),
          _Menu(
            label: S.menuHelp,
            items: [
              _Item(S.menuAbout, Icons.info, onAbout),
            ],
          ),
        ],
      ),
    );
  }
}

class _Item {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  _Item(this.label, this.icon, this.onTap);
}

class _Menu extends StatelessWidget {
  final String label;
  final List<_Item> items;
  const _Menu({required this.label, required this.items});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      tooltip: label,
      offset: const Offset(0, 36),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(label, style: const TextStyle(fontSize: 14)),
      ),
      itemBuilder: (_) => items
          .asMap()
          .entries
          .map((e) => PopupMenuItem<int>(
                value: e.key,
                child: Row(
                  children: [
                    Icon(e.value.icon, size: 18),
                    const SizedBox(width: 10),
                    Text(e.value.label),
                  ],
                ),
              ))
          .toList(),
      onSelected: (i) => items[i].onTap(),
    );
  }
}