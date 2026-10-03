// lib/screens/home_screen.dart
// Màn hình chính — welcome + tab bar + khu vực xem PDF + status bar
// Tác giả: Chương
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_info.dart';
import '../core/strings_vi.dart';
import '../core/theme.dart';
import '../providers/workspace_provider.dart';
import '../services/file_dialog_service.dart';
import '../widgets/menu_bar.dart';
import '../widgets/drop_zone.dart';
import 'viewer_screen.dart';
import 'editor_screen.dart';
import 'receive_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _dialog = FileDialogService();

  Future<void> _openPdf() async {
    final path = await _dialog.pickPdf();
    if (path == null) return;
    if (!mounted) return;
    await context.read<WorkspaceProvider>().openFile(path);
  }

  Future<void> _openImages() async {
    final paths = await _dialog.pickImages();
    if (paths.isEmpty) return;
    if (!mounted) return;
    final provider = context.read<WorkspaceProvider>();
    provider.setBusy(true);
    try {
      final bytes = await provider.pdfOps.imagesToPdf(paths);
      await provider.openFile('${AppInfo.appName}_${paths.length}_anh.pdf',
          bytes: bytes);
    } finally {
      provider.setBusy(false);
    }
  }

  void _openReceive() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReceiveScreen()),
    );
  }

  void _openEditor() {
    final provider = context.read<WorkspaceProvider>();
    if (provider.active == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng mở 1 file PDF trước')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditorScreen()),
    );
  }

  void _openAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AboutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          DesktopMenuBar(
            onOpenPdf: _openPdf,
            onOpenImages: _openImages,
            onReceive: _openReceive,
            onEditor: _openEditor,
            onAbout: _openAbout,
          ),
          Expanded(
            child: Consumer<WorkspaceProvider>(
              builder: (context, provider, _) {
                if (provider.tabs.isEmpty) {
                  return DropZone(
                    onOpenPdf: _openPdf,
                    onOpenImages: _openImages,
                    onReceive: _openReceive,
                  );
                }
                return Column(
                  children: [
                    _TabBar(provider: provider),
                    Expanded(child: ViewerScreen(provider: provider)),
                  ],
                );
              },
            ),
          ),
          _StatusBar(),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final WorkspaceProvider provider;
  const _TabBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: provider.tabs.length,
              itemBuilder: (context, i) {
                final doc = provider.tabs[i];
                final active = i == provider.activeIndex;
                return InkWell(
                  onTap: () => provider.setActive(i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: active ? AppTheme.primary : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.picture_as_pdf,
                            size: 16, color: AppTheme.primary),
                        const SizedBox(width: 6),
                        Text(doc.displayName,
                            style: TextStyle(
                              fontWeight:
                                  active ? FontWeight.w600 : FontWeight.normal,
                            )),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => provider.closeTab(i),
                          child: const Icon(Icons.close, size: 16),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Mở PDF khác',
            onPressed: () async {
              final path = await FileDialogService().pickPdf();
              if (path == null) return;
              if (!context.mounted) return;
              await context.read<WorkspaceProvider>().openFile(path);
            },
          ),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<WorkspaceProvider>(
      builder: (context, provider, _) {
        final doc = provider.active;
        return Container(
          height: 28,
          color: const Color(0xFF1F2937),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Text(
                doc == null
                    ? S.statusNoDoc
                    : '${doc.displayName} • ${doc.pageCount} ${S.pages}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              const Spacer(),
              if (provider.busy)
                const Row(
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(S.loading,
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                )
              else
                const Text('${AppInfo.appName} ${AppInfo.version}',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        );
      },
    );
  }
}