// lib/services/file_dialog_service.dart
// Hộp thoại chọn file — dùng file_selector cho desktop
import 'package:file_selector/file_selector.dart';

class FileDialogService {
  static const pdfGroup = XTypeGroup(
    label: 'PDF',
    extensions: ['pdf'],
  );

  static const imageGroup = XTypeGroup(
    label: 'Ảnh',
    extensions: ['jpg', 'jpeg', 'png', 'webp', 'bmp', 'gif'],
  );

  static const anyGroup = XTypeGroup(
    label: 'Tất cả',
    extensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp', 'bmp', 'gif'],
  );

  Future<String?> pickPdf() async {
    final file = await openFile(acceptedTypeGroups: [pdfGroup]);
    return file?.path;
  }

  Future<List<String>> pickPdfs() async {
    final files = await openFiles(acceptedTypeGroups: [pdfGroup]);
    return files.map((f) => f.path).toList();
  }

  Future<List<String>> pickImages() async {
    final files = await openFiles(acceptedTypeGroups: [imageGroup]);
    return files.map((f) => f.path).toList();
  }

  Future<List<String>> pickAny() async {
    final files = await openFiles(acceptedTypeGroups: [anyGroup]);
    return files.map((f) => f.path).toList();
  }

  Future<String?> saveAsPdf({String? suggestedName}) async {
    final location = await getSaveLocation(
      acceptedTypeGroups: [pdfGroup],
      suggestedName: suggestedName ?? 'output.pdf',
    );
    return location?.path;
  }
}