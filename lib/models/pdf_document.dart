// lib/models/pdf_document.dart
import 'dart:typed_data';

class PdfDocumentModel {
  final String id;
  final String filePath;
  final String fileName;
  int pageCount;          // KHÔNG dùng final — để có thể cập nhật
  Uint8List? bytes;
  bool isDirty;
  int currentPage;

  PdfDocumentModel({
    required this.id,
    required this.filePath,
    required this.fileName,
    required this.pageCount,
    this.bytes,
    this.isDirty = false,
    this.currentPage = 0,
  });

  String get displayName => fileName;
}