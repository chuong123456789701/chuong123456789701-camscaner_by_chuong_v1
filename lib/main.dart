// lib/main.dart
// CamScaner by Chương v1 — Điểm khởi đầu
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'core/app_info.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cấu hình cửa sổ desktop
  await windowManager.ensureInitialized();
  const opts = WindowOptions(
    size: Size(1280, 800),
    minimumSize: Size(960, 640),
    center: true,
    title: '${AppInfo.appName} ${AppInfo.version}',
    titleBarStyle: TitleBarStyle.normal,
  );
  await windowManager.waitUntilReadyToShow(opts, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const CamScanerApp());
}