// lib/screens/viewer_screen.dart
// Khu vực xem PDF trong tab chính
// Tác giả: Chương
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../core/strings_vi.dart';
import '../providers/workspace_provider.dart';

class ViewerScreen extends StatefulWidget {
  final WorkspaceProvider provider;
  const ViewerScreen({super.key, required this.provider});

  @override
  State<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {
  final _controller = PdfViewerController();
  final _key = GlobalKey<SfPdfViewerState>();

  @override
  Widget build(BuildContext context) {
    final doc = widget.provider.active;
    if (doc == null || doc.bytes == null) {
      return const Center(child: Text(S.noFileOpen));
    }
    return Container(
      color: const Color(0xFF525659),
      child: SfPdfViewer.memory(
        doc.bytes!,
        key: _key,
        controller: _controller,
        canShowScrollHead: true,
        canShowScrollStatus: true,
        enableDoubleTapZooming: true,
        onDocumentLoaded: (details) {
          // nothing
        },
      ),
    );
  }
}