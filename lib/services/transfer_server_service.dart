// lib/services/transfer_server_service.dart
// HTTP server nội bộ (LAN) để điện thoại gửi file lên PC
// Chỉ hoạt động trong mạng LAN — KHÔNG đi ra internet
// Tác giả: Chương
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

class TransferServerService {
  HttpServer? _server;
  final int port;
  final void Function(String fileName, String savedPath) onFileReceived;
  final void Function()? onServerStarted;
  final void Function()? onServerStopped;

  String? _saveDir;

  TransferServerService({
    this.port = 8668,
    required this.onFileReceived,
    this.onServerStarted,
    this.onServerStopped,
  });

  bool get isRunning => _server != null;

  Future<String> _ensureSaveDir() async {
    if (_saveDir != null) return _saveDir!;
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'CamScaner_by_Chuong', 'NhanTuDienThoai'));
    if (!await dir.exists()) await dir.create(recursive: true);
    _saveDir = dir.path;
    return _saveDir!;
  }

  Future<String> getSaveDir() => _ensureSaveDir();

  Future<void> start() async {
    if (_server != null) return;

    final router = Router();

    // Trang chủ — form upload
    router.get('/', (Request req) {
      return Response.ok(
        _htmlUploadPage(),
        headers: {'content-type': 'text/html; charset=utf-8'},
      );
    });

    // API upload
    router.post('/upload', (Request req) async {
      try {
        final contentType = req.headers['content-type'] ?? '';
        if (!contentType.contains('multipart/form-data')) {
          return Response.badRequest(body: 'Yêu cầu không hợp lệ');
        }
        final boundary = _extractBoundary(contentType);
        if (boundary == null) {
          return Response.badRequest(body: 'Thiếu boundary');
        }

        final bodyBytes = await _readAll(req.read());
        final parts = _parseMultipart(bodyBytes, boundary);

        final savedNames = <String>[];
        final dir = await _ensureSaveDir();

        for (final part in parts) {
          if (part.filename == null || part.data.isEmpty) continue;
          // Chỉ nhận PDF và ảnh
          final lower = part.filename!.toLowerCase();
          final ok = lower.endsWith('.pdf') ||
              lower.endsWith('.jpg') ||
              lower.endsWith('.jpeg') ||
              lower.endsWith('.png') ||
              lower.endsWith('.webp');
          if (!ok) continue;

          // Tránh trùng tên
          var target = p.join(dir, _sanitize(part.filename!));
          int n = 1;
          while (await File(target).exists()) {
            final base = p.basenameWithoutExtension(part.filename!);
            final ext = p.extension(part.filename!);
            target = p.join(dir, '${base}_$n$ext');
            n++;
          }
          await File(target).writeAsBytes(part.data);
          savedNames.add(p.basename(target));
          onFileReceived(p.basename(target), target);
        }

        return Response.ok(
          jsonEncode({'ok': true, 'files': savedNames}),
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      } catch (e) {
        return Response.internalServerError(body: 'Lỗi: $e');
      }
    });

    final handler = const Pipeline()
        .addMiddleware(logRequests())
        .addHandler(router.call);

    _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
    onServerStarted?.call();
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    onServerStopped?.call();
  }

  // --- Helpers ---

  String _sanitize(String name) {
    return name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }

  String? _extractBoundary(String contentType) {
    final match = RegExp(r'boundary=(?:"([^"]+)"|([^;]+))').firstMatch(contentType);
    if (match == null) return null;
    return (match.group(1) ?? match.group(2))!.trim();
  }

  Future<List<int>> _readAll(Stream<List<int>> stream) async {
    final chunks = <int>[];
    await for (final c in stream) {
      chunks.addAll(c);
    }
    return chunks;
  }

  List<_Part> _parseMultipart(List<int> body, String boundary) {
    final delimiter = utf8.encode('--$boundary');
    final parts = <_Part>[];
    int start = _indexOf(body, delimiter, 0);
    if (start < 0) return parts;

    while (true) {
      start += delimiter.length;
      // Bỏ CRLF
      if (start + 1 < body.length && body[start] == 13 && body[start + 1] == 10) {
        start += 2;
      } else if (start + 1 < body.length && body[start] == 45 && body[start + 1] == 45) {
        break; // kết thúc
      }

      final next = _indexOf(body, delimiter, start);
      if (next < 0) break;

      final partBytes = body.sublist(start, next);
      final part = _parseOnePart(partBytes);
      if (part != null) parts.add(part);
      start = next;
    }
    return parts;
  }

  _Part? _parseOnePart(List<int> bytes) {
    // Tìm \r\n\r\n ngăn header và body
    final sep = _indexOf(bytes, [13, 10, 13, 10], 0);
    if (sep < 0) return null;
    final headerBytes = bytes.sublist(0, sep);
    var bodyBytes = bytes.sublist(sep + 4);
    // Bỏ \r\n cuối
    if (bodyBytes.length >= 2 &&
        bodyBytes[bodyBytes.length - 2] == 13 &&
        bodyBytes[bodyBytes.length - 1] == 10) {
      bodyBytes = bodyBytes.sublist(0, bodyBytes.length - 2);
    }
    final headerText = utf8.decode(headerBytes, allowMalformed: true);
    String? filename;
    final fnMatch = RegExp(r'filename="([^"]*)"').firstMatch(headerText);
    if (fnMatch != null) filename = fnMatch.group(1);
    return _Part(filename: filename, data: bodyBytes);
  }

  int _indexOf(List<int> haystack, List<int> needle, int from) {
    if (needle.isEmpty) return -1;
    outer:
    for (int i = from; i <= haystack.length - needle.length; i++) {
      for (int j = 0; j < needle.length; j++) {
        if (haystack[i + j] != needle[j]) continue outer;
      }
      return i;
    }
    return -1;
  }

  String _htmlUploadPage() {
    return '''
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>CamScaner by Chương — Gửi file lên máy tính</title>
<style>
  * { box-sizing: border-box; }
  body { font-family: -apple-system, Roboto, Arial, sans-serif; margin: 0; padding: 20px;
         background: #F5F7FB; color: #1A1A1A; }
  .card { max-width: 480px; margin: 0 auto; background: white; padding: 24px;
          border-radius: 14px; box-shadow: 0 4px 20px rgba(0,0,0,0.08); }
  h1 { color: #2E6BE6; font-size: 22px; margin: 0 0 6px; }
  .tag { color: #666; font-size: 14px; margin-bottom: 20px; }
  .author { color: #2E6BE6; font-weight: 600; }
  input[type=file] { display: block; width: 100%; padding: 14px;
                     border: 2px dashed #2E6BE6; border-radius: 10px;
                     background: #F0F5FF; font-size: 15px; }
  button { width: 100%; padding: 16px; background: #2E6BE6; color: white;
           border: 0; border-radius: 10px; font-size: 17px; font-weight: 600;
           margin-top: 16px; cursor: pointer; }
  button:active { background: #1E4FB8; }
  .hint { font-size: 13px; color: #888; margin-top: 12px; text-align: center; }
  .ok { background: #E8F5E9; color: #2E7D32; padding: 12px; border-radius: 8px;
        margin-top: 12px; font-size: 14px; }
  .err { background: #FFEBEE; color: #C62828; padding: 12px; border-radius: 8px;
         margin-top: 12px; font-size: 14px; }
</style>
</head>
<body>
<div class="card">
  <h1>📄 Gửi file lên máy tính</h1>
  <div class="tag">Ứng dụng <span class="author">CamScaner by Chương</span></div>

  <form id="f">
    <input type="file" id="file" name="file" multiple accept=".pdf,.jpg,.jpeg,.png,.webp">
    <button type="submit">📤 Gửi lên máy tính</button>
  </form>

  <div id="msg"></div>
  <div class="hint">Chỉ hỗ trợ PDF và ảnh (JPG/PNG/WEBP)</div>
</div>

<script>
const f = document.getElementById('f');
const msg = document.getElementById('msg');
f.addEventListener('submit', async (e) => {
  e.preventDefault();
  const files = document.getElementById('file').files;
  if (!files.length) { msg.innerHTML = '<div class="err">Vui lòng chọn ít nhất 1 file</div>'; return; }
  const fd = new FormData();
  for (const file of files) fd.append('file', file);
  msg.innerHTML = '<div class="ok">Đang gửi...</div>';
  try {
    const res = await fetch('/upload', { method: 'POST', body: fd });
    const json = await res.json();
    if (json.ok) {
      msg.innerHTML = '<div class="ok">✅ Đã gửi ' + json.files.length + ' file thành công!</div>';
      f.reset();
    } else {
      msg.innerHTML = '<div class="err">Lỗi khi gửi</div>';
    }
  } catch (err) {
    msg.innerHTML = '<div class="err">Lỗi kết nối: ' + err + '</div>';
  }
});
</script>
</body>
</html>
''';
  }
}

class _Part {
  final String? filename;
  final List<int> data;
  _Part({this.filename, required this.data});
}