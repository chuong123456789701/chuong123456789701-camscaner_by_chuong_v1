// lib/widgets/page_thumbnail.dart
// Widget hiển thị thumbnail 1 trang PDF (đơn giản, dùng placeholder)
// Tác giả: Chương
import 'package:flutter/material.dart';
import '../core/theme.dart';

class PageThumbnail extends StatelessWidget {
  final int pageNumber;
  final bool selected;
  final VoidCallback? onTap;

  const PageThumbnail({
    super.key,
    required this.pageNumber,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: selected ? AppTheme.primary : Colors.black12,
            width: selected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Icon(
                  Icons.description,
                  size: 40,
                  color: selected ? AppTheme.primary : Colors.grey,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.black12)),
              ),
              child: Text(
                'Trang $pageNumber',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}