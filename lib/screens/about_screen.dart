// lib/screens/about_screen.dart
// Màn hình giới thiệu + vinh danh tác giả Chương
// Tác giả: Chương
import 'package:flutter/material.dart';
import '../core/app_info.dart';
import '../core/theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Về tác giả / Giới thiệu')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.picture_as_pdf,
                    size: 80, color: AppTheme.primary),
                const SizedBox(height: 16),
                const Text(
                  '${AppInfo.appName} ${AppInfo.version}',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(AppInfo.tagline,
                    style: TextStyle(fontSize: 15, color: Colors.grey)),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Giới thiệu',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                        SizedBox(height: 12),
                        Text(AppInfo.description,
                            style: TextStyle(height: 1.6)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: const Color(0xFFF0F5FF),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.favorite, color: AppTheme.primary),
                            SizedBox(width: 8),
                            Text('Lời nhắn từ tác giả',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(AppInfo.authorMessage,
                            style: TextStyle(height: 1.7, fontSize: 15)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.person,
                                color: AppTheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              '${AppInfo.authorTitle}: ${AppInfo.author}',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '© ${AppInfo.year} ${AppInfo.author}\n${AppInfo.license}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text('Đóng'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}