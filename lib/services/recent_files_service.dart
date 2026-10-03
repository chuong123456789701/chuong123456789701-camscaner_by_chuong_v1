// lib/services/recent_files_service.dart
// Lưu 20 file gần nhất bằng shared_preferences
import 'package:shared_preferences/shared_preferences.dart';

class RecentFilesService {
  static const _key = 'recent_files_v1';
  static const int maxItems = 20;

  Future<List<String>> load() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getStringList(_key) ?? [];
  }

  Future<void> add(String path) async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_key) ?? [];
    list.remove(path);
    list.insert(0, path);
    if (list.length > maxItems) list.removeRange(maxItems, list.length);
    await sp.setStringList(_key, list);
  }

  Future<void> remove(String path) async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_key) ?? [];
    list.remove(path);
    await sp.setStringList(_key, list);
  }

  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_key);
  }
}