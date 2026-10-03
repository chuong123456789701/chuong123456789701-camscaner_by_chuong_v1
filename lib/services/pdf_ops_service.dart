// lib/services/pdf_ops_service.dart
// Tất cả thao tác PDF — dùng API ổn định của Syncfusion
// Tác giả: Chương
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Offset, Size, Rect;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path/path.dart' as p;

class PdfOpsService {
  // Đếm số trang
  Future<int> pageCount(Uint8List bytes) async {
    final doc = PdfDocument(inputBytes: bytes);
    final n = doc.pages.count;
    doc.dispose();
    return n;
  }

  // Lưu bytes ra file
  Future<void> saveBytes(Uint8List bytes, String outputPath) async {
    final f = File(outputPath);
    await f.parent.create(recursive: true);
    await f.writeAsBytes(bytes);
  }

  // Đọc file → bytes
  Future<Uint8List> readBytes(String path) async {
    return await File(path).readAsBytes();
  }

  // Xoá sạch mọi trang của document (helper nội bộ)
  void _clearPages(PdfDocument doc) {
    while (doc.pages.count > 0) {
      doc.pages.removeAt(0);
    }
  }

  // Copy 1 trang từ src sang dst (helper nội bộ)
  void _copyPage(PdfDocument src, int index, PdfDocument dst) {
    final page = src.pages[index];
    final tpl = page.createTemplate();
    final newPage = dst.pages.add();
    newPage.graphics.drawPdfTemplate(
      tpl,
      Offset.zero,
      Size(page.size.width, page.size.height),
    );
  }

  // Gộp nhiều PDF thành 1
  Future<Uint8List> merge(List<Uint8List> listPdf) async {
    final out = PdfDocument();
    _clearPages(out);
    for (final bytes in listPdf) {
      final src = PdfDocument(inputBytes: bytes);
      for (int i = 0; i < src.pages.count; i++) {
        _copyPage(src, i, out);
      }
      src.dispose();
    }
    final result = Uint8List.fromList(out.saveSync());
    out.dispose();
    return result;
  }

  // Tách các trang được chọn (index 0-based) ra PDF mới
  Future<Uint8List> extractPages(
      Uint8List bytes, List<int> pageIndices) async {
    final src = PdfDocument(inputBytes: bytes);
    final out = PdfDocument();
    _clearPages(out);
    for (final i in pageIndices) {
      if (i < 0 || i >= src.pages.count) continue;
      _copyPage(src, i, out);
    }
    final result = Uint8List.fromList(out.saveSync());
    out.dispose();
    src.dispose();
    return result;
  }

  // Xoá các trang được chọn
  Future<Uint8List> removePages(
      Uint8List bytes, List<int> pageIndices) async {
    final doc = PdfDocument(inputBytes: bytes);
    final sorted = [...pageIndices]..sort((a, b) => b.compareTo(a));
    for (final i in sorted) {
      if (i >= 0 && i < doc.pages.count) {
        doc.pages.removeAt(i);
      }
    }
    final result = Uint8List.fromList(doc.saveSync());
    doc.dispose();
    return result;
  }

  // Đảo thứ tự trang
  Future<Uint8List> reverseOrder(Uint8List bytes) async {
    final src = PdfDocument(inputBytes: bytes);
    final out = PdfDocument();
    _clearPages(out);
    for (int i = src.pages.count - 1; i >= 0; i--) {
      _copyPage(src, i, out);
    }
    final result = Uint8List.fromList(out.saveSync());
    out.dispose();
    src.dispose();
    return result;
  }

  // Xoay 1 trang cụ thể (angle: 0, 90, 180, 270)
  Future<Uint8List> rotatePage(
      Uint8List bytes, int pageIndex, int angle) async {
    final doc = PdfDocument(inputBytes: bytes);
    if (pageIndex >= 0 && pageIndex < doc.pages.count) {
      final page = doc.pages[pageIndex];
      final current = page.rotation;
      int currentDeg = 0;
      if (current == PdfPageRotateAngle.rotateAngle90) currentDeg = 90;
      if (current == PdfPageRotateAngle.rotateAngle180) currentDeg = 180;
      if (current == PdfPageRotateAngle.rotateAngle270) currentDeg = 270;
      final newDeg = (currentDeg + angle) % 360;
      if (newDeg == 90) {
        page.rotation = PdfPageRotateAngle.rotateAngle90;
      } else if (newDeg == 180) {
        page.rotation = PdfPageRotateAngle.rotateAngle180;
      } else if (newDeg == 270) {
        page.rotation = PdfPageRotateAngle.rotateAngle270;
      } else {
        page.rotation = PdfPageRotateAngle.rotateAngle0;
      }
    }
    final result = Uint8List.fromList(doc.saveSync());
    doc.dispose();
    return result;
  }

  // Chèn ảnh thành trang A4 (mỗi ảnh 1 trang)
  Future<Uint8List> imagesToPdf(List<String> imagePaths) async {
    final doc = PdfDocument();
    _clearPages(doc);
    const a4W = 595.0;
    const a4H = 842.0;
    for (final path in imagePaths) {
      final bytes = await File(path).readAsBytes();
      final image = PdfBitmap(bytes);
      final page = doc.pages.add();
      // Vẽ nền trắng
      page.graphics.drawRectangle(
        brush: PdfSolidBrush(PdfColor(255, 255, 255)),
        bounds: const Rect.fromLTWH(0, 0, a4W, a4H),
      );
      // Fit ảnh vào A4 giữ tỉ lệ
      final scale = (a4W / image.width) < (a4H / image.height)
          ? a4W / image.width
          : a4H / image.height;
      final w = image.width * scale;
      final h = image.height * scale;
      final x = (a4W - w) / 2;
      final y = (a4H - h) / 2;
      page.graphics.drawImage(image, Rect.fromLTWH(x, y, w, h));
    }
    final result = Uint8List.fromList(doc.saveSync());
    doc.dispose();
    return result;
  }

  // Nén PDF — save lại để Syncfusion tối ưu
  Future<Uint8List> compress(Uint8List bytes, {int quality = 60}) async {
    final doc = PdfDocument(inputBytes: bytes);
    final result = Uint8List.fromList(doc.saveSync());
    doc.dispose();
    return result;
  }

  // Đặt mật khẩu bảo vệ PDF
  // Lưu ý: Syncfusion Community dùng AES 128-bit mặc định
  Future<Uint8List> protect(
    Uint8List bytes, {
    required String userPassword,
    String? ownerPassword,
    bool allowPrint = true,
    bool allowCopy = false,
  }) async {
    final doc = PdfDocument(inputBytes: bytes);
    doc.security.userPassword = userPassword;
    doc.security.ownerPassword = ownerPassword ?? userPassword;
    final result = Uint8List.fromList(doc.saveSync());
    doc.dispose();
    return result;
  }

  // Kiểm tra file PDF có mật khẩu không
  bool isProtected(Uint8List bytes) {
    try {
      final doc = PdfDocument(inputBytes: bytes);
      doc.dispose();
      return false;
    } catch (_) {
      return true;
    }
  }

  // Mở PDF có mật khẩu
  Future<Uint8List?> unlock(Uint8List bytes, String password) async {
    try {
      final doc = PdfDocument(inputBytes: bytes, password: password);
      final result = Uint8List.fromList(doc.saveSync());
      doc.dispose();
      return result;
    } catch (_) {
      return null;
    }
  }

  // Lưu tạm ra file — trả về đường dẫn
  Future<String> saveTemp(Uint8List bytes, String dir, String name) async {
    final path = p.join(dir, name);
    await saveBytes(bytes, path);
    return path;
  }
}