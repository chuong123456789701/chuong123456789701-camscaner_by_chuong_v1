// lib/models/page_ref.dart
class PageRef {
  final int sourceIndex; // index trong file gốc
  int rotation;          // 0, 90, 180, 270
  bool selected;
  bool deleted;

  PageRef({
    required this.sourceIndex,
    this.rotation = 0,
    this.selected = false,
    this.deleted = false,
  });

  PageRef copy() => PageRef(
        sourceIndex: sourceIndex,
        rotation: rotation,
        selected: selected,
        deleted: deleted,
      );
}