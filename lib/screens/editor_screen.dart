// lib/screens/editor_screen.dart
// Màn hình chỉnh sửa trang — thumbnail grid, chọn nhiều, xoay/xoá/tách
// Tác giả: Chương
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/strings_vi.dart';
import '../core/theme.dart';
import '../providers/workspace_provider.dart';
import '../services/file_dialog_service.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final Set<int> _selected = {};

  Future<void> _rotateRight() async {
    if (_selected.isEmpty) return;
    final provider = context.read<WorkspaceProvider>();
    final doc = provider.active;
    if (doc == null) return;
    provider.setBusy(true);
    try {
      var bytes = doc.bytes!;
      for (final i in _selected) {
        bytes = await provider.pdfOps.rotatePage(bytes, i, 90);
      }
      provider.updateActiveBytes(bytes);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xoay ${_selected.length} trang')),
      );
    } finally {
      provider.setBusy(false);
    }
  }

  Future<void> _deleteSelected() async {
    if (_selected.isEmpty) return;
    final provider = context.read<WorkspaceProvider>();
    final doc = provider.active;
    if (doc == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận xoá'),
        content: Text('Xoá ${_selected.length} trang đã chọn?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(S.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(S.delete),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    provider.setBusy(true);
    try {
      final newBytes = await provider.pdfOps
          .removePages(doc.bytes!, _selected.toList());
      final newCount = await provider.pdfOps.pageCount(newBytes);
      provider.updateActiveBytes(newBytes, newPageCount: newCount);
      setState(() => _selected.clear());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xoá trang')),
      );
    } finally {
      provider.setBusy(false);
    }
  }

  Future<void> _extractSelected() async {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(S.errEmpty)),
      );
      return;
    }
    final provider = context.read<WorkspaceProvider>();
    final doc = provider.active;
    if (doc == null) return;
    provider.setBusy(true);
    try {
      final bytes = await provider.pdfOps
          .extractPages(doc.bytes!, _selected.toList());
      final path = await FileDialogService().saveAsPdf(
        suggestedName: 'tach_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      if (path == null) return;
      await provider.pdfOps.saveBytes(bytes, path);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã lưu: $path')),
      );
    } finally {
      provider.setBusy(false);
    }
  }

  Future<void> _reverse() async {
    final provider = context.read<WorkspaceProvider>();
    final doc = provider.active;
    if (doc == null) return;
    provider.setBusy(true);
    try {
      final bytes = await provider.pdfOps.reverseOrder(doc.bytes!);
      provider.updateActiveBytes(bytes);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã đảo thứ tự trang')),
      );
    } finally {
      provider.setBusy(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkspaceProvider>();
    final doc = provider.active;
    if (doc == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(S.editor)),
        body: const Center(child: Text(S.noFileOpen)),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('${S.editor} — ${doc.displayName}'),
        actions: [
          TextButton.icon(
            onPressed: () => setState(() {
              if (_selected.length == doc.pageCount) {
                _selected.clear();
              } else {
                _selected.addAll(List.generate(doc.pageCount, (i) => i));
              }
            }),
            icon: const Icon(Icons.select_all, color: Colors.white),
            label: Text(
              _selected.length == doc.pageCount ? S.deselectAll : S.selectAll,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Wrap(
              spacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _rotateRight,
                  icon: const Icon(Icons.rotate_right),
                  label: const Text(S.rotateRight),
                ),
                ElevatedButton.icon(
                  onPressed: _deleteSelected,
                  icon: const Icon(Icons.delete),
                  label: const Text('Xoá trang'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.danger,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _extractSelected,
                  icon: const Icon(Icons.call_split),
                  label: const Text('Tách trang'),
                ),
                ElevatedButton.icon(
                  onPressed: _reverse,
                  icon: const Icon(Icons.swap_vert),
                  label: const Text('Đảo thứ tự'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '${S.selectedCount}: ${_selected.length} ${S.pages}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: AppTheme.background,
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate:
                    const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 160,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: doc.pageCount,
                itemBuilder: (context, i) {
                  final isSelected = _selected.contains(i);
                  return InkWell(
                    onTap: () => setState(() {
                      if (isSelected) {
                        _selected.remove(i);
                      } else {
                        _selected.add(i);
                      }
                    }),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color:
                              isSelected ? AppTheme.primary : Colors.black12,
                          width: isSelected ? 3 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                '${S.page} ${i + 1}',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}