// lib/core/shortcuts.dart
// Phím tắt desktop
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppShortcuts {
  static final Map<ShortcutActivator, Intent> shortcuts = {
    const SingleActivator(LogicalKeyboardKey.keyO, control: true): const _Intent('open'),
    const SingleActivator(LogicalKeyboardKey.keyS, control: true): const _Intent('save'),
    const SingleActivator(LogicalKeyboardKey.keyP, control: true): const _Intent('print'),
    const SingleActivator(LogicalKeyboardKey.keyW, control: true): const _Intent('close-tab'),
    const SingleActivator(LogicalKeyboardKey.keyE, control: true): const _Intent('editor'),
  };
}

class _Intent extends Intent {
  final String action;
  const _Intent(this.action);
}