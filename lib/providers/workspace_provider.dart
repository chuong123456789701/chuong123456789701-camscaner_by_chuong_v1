// lib/providers/workspace_provider.dart
// Quản lý trạng thái toàn cục: danh sách tab, file hiện tại, trang đang xem
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/pdf_document.dart';
import '../services/pdf_ops_service.dart';
import '../services/recent_files_service.dart';

class WorkspaceProvider extends ChangeNotifier {
  final PdfOpsService pdfOps = PdfOpsService();
  final RecentFilesService recentService = RecentFilesService();
  final _uuid = const Uuid();

  final List<PdfDocumentModel> _tabs = [];
  int _activeIndex = -1;
  List<String> _recent = [];
  bool _busy = false;

  List<PdfDocumentModel> get tabs => List.unmodifiable(_tabs);
  int get activeIndex => _activeIndex;
  PdfDocumentModel? get active =>
      _activeIndex >= 0 && _activeIndex < _tabs.length
          ? _tabs[_activeIndex]
          : null;
  List<String> get recent => List.unmodifiable(_recent);
  bool get busy => _busy;

  WorkspaceProvider() {
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    _recent = await recentService.load();
    notifyListeners();
  }

  void setBusy(bool v) {
    _busy = v;
    notifyListeners();
  }

  Future<void> openFile(String path, {Uint8List? bytes}) async {
    setBusy(true);
    try {
      final data = bytes ?? await pdfOps.readBytes(path);
      final count = await pdfOps.pageCount(data);
      final name = path.split(RegExp(r'[\\/]')).last;
      final doc = PdfDocumentModel(
        id: _uuid.v4(),
        filePath: path,
        fileName: name,
        pageCount: count,
        bytes: data,
      );
      _tabs.add(doc);
      _activeIndex = _tabs.length - 1;
      await recentService.add(path);
      _recent = await recentService.load();
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  void setActive(int index) {
    if (index >= 0 && index < _tabs.length) {
      _activeIndex = index;
      notifyListeners();
    }
  }

  void closeTab(int index) {
    if (index < 0 || index >= _tabs.length) return;
    _tabs.removeAt(index);
    if (_tabs.isEmpty) {
      _activeIndex = -1;
    } else if (_activeIndex >= _tabs.length) {
      _activeIndex = _tabs.length - 1;
    }
    notifyListeners();
  }

  void updateActiveBytes(Uint8List bytes, {int? newPageCount}) {
    final doc = active;
    if (doc == null) return;
    doc.bytes = bytes;
    if (newPageCount != null) doc.pageCount = newPageCount;
    doc.isDirty = true;
    notifyListeners();
  }

  Future<void> clearRecent() async {
    await recentService.clear();
    _recent = [];
    notifyListeners();
  }
}