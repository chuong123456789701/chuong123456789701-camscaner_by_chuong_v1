// lib/screens/receive_screen.dart
// Màn hình nhận file từ điện thoại qua WiFi — bật server + hiện QR
// Tác giả: Chương
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_info.dart';
import '../core/strings_vi.dart';
import '../core/theme.dart';
import '../services/transfer_server_service.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  TransferServerService? _server;
  bool _running = false;
  String? _ip;
  int _port = 8668;
  final List<String> _received = [];
  String? _error;

  Future<void> _start() async {
    setState(() {
      _error = null;
    });
    try {
      final info = NetworkInfo();
      final ip = await info.getWifiIP();
      if (ip == null || ip.isEmpty) {
        setState(() => _error = S.needWifi);
        return;
      }
      final server = TransferServerService(
        port: _port,
        onFileReceived: (name, path) {
          setState(() {
            _received.insert(0, name);
          });
        },
      );
      await server.start();
      setState(() {
        _server = server;
        _running = true;
        _ip = ip;
      });
    } catch (e) {
      setState(() {
        _error = '${S.portInUse}: $e';
      });
    }
  }

  Future<void> _stop() async {
    await _server?.stop();
    setState(() {
      _server = null;
      _running = false;
    });
  }

  Future<void> _openFolder() async {
    final dir = await _server?.getSaveDir();
    if (dir == null) return;
    await launchUrl(Uri.file(dir));
  }

  @override
  void dispose() {
    _server?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final url = _running && _ip != null ? 'http://$_ip:$_port' : null;
    return Scaffold(
      appBar: AppBar(title: const Text(S.receiveTitle)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cột trái — điều khiển
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      S.receiveHint,
                      style: TextStyle(fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(_error!,
                            style: const TextStyle(color: Colors.red)),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _running ? _stop : _start,
                          icon: Icon(_running ? Icons.stop : Icons.play_arrow),
                          label: Text(_running ? S.stopServer : S.startServer),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _running ? AppTheme.danger : AppTheme.success,
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: _running ? _openFolder : null,
                          icon: const Icon(Icons.folder_open),
                          label: const Text(S.openFolder),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (_running && url != null) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(S.yourIp,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16)),
                              const SizedBox(height: 6),
                              SelectableText(
                                url,
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text('${S.port}: $_port',
                                  style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Column(
                            children: [
                              const Text(S.scanQr,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16)),
                              const SizedBox(height: 12),
                              QrImageView(
                                data: url,
                                size: 220,
                                backgroundColor: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    const Text(S.receivedFiles,
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 8),
                    if (_received.isEmpty)
                      const Text(S.noReceivedFiles,
                          style: TextStyle(color: Colors.grey))
                    else
                      ..._received.map((name) => ListTile(
                            leading: const Icon(Icons.check_circle,
                                color: AppTheme.success),
                            title: Text(name),
                          )),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            // Cột phải — thông tin
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡 Hướng dẫn',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Bật nhận file\n'
                      '2. Mở điện thoại → Camera → quét QR\n'
                      '3. Chọn file PDF/ảnh → Gửi lên\n'
                      '4. File sẽ xuất hiện trong danh sách\n'
                      '5. Bấm "Mở thư mục" để xem file',
                      style: TextStyle(height: 1.6),
                    ),
                    const Divider(height: 32),
                    Text(
                      '${AppInfo.appName} ${AppInfo.version}\n'
                      '— ${AppInfo.author} —',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    const Text('Chỉ hoạt động trong mạng LAN',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}