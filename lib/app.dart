// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/app_info.dart';
import 'providers/workspace_provider.dart';
import 'screens/home_screen.dart';

class CamScanerApp extends StatelessWidget {
  const CamScanerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WorkspaceProvider(),
      child: MaterialApp(
        title: AppInfo.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: HomeScreen(),   // BỎ chữ "const" ở đây
      ),
    );
  }
}