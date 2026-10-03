// lib/core/app_info.dart
// Thông tin về ứng dụng và tác giả — by Chương
// File này chứa toàn bộ metadata hiển thị cho người dùng.

class AppInfo {
  // Tên hiển thị chính thức — sẽ xuất hiện trên tiêu đề cửa sổ và About
  static const String appName = 'CamScaner by Chương';

  // Phiên bản
  static const String version = 'v1';
  static const String fullVersion = '1.0.0';

  // Tác giả — công sức của Chương, ghi rõ ràng
  static const String author = 'Chương';
  static const String authorTitle = 'Tác giả';

  // Tagline
  static const String tagline = 'Miễn phí – Không quảng cáo – Cho cộng đồng';

  // Mô tả ngắn
  static const String description =
      'Phần mềm đọc, chỉnh sửa, gộp, tách, nén PDF hoàn toàn miễn phí.\n'
      'Dành tặng các cô giáo, phụ huynh, tiệm photo và mọi người khó khăn.\n'
      'Không quảng cáo – Không thu phí – Không đăng nhập – Hoạt động offline.';

  // Lời nhắn của tác giả
  static const String authorMessage =
      'Mình làm phần mềm này không vì lợi nhuận.\n'
      'Mong nó giúp được các cô giáo, phụ huynh và những người khó khăn\n'
      'không có tiền mua các app trả phí.\n\n'
      'Ai cũng được dùng, được sửa, được chia sẻ lại. 💛\n\n'
      '— Chương —';

  // Năm phát hành
  static const String year = '2025';

  // License
  static const String license = 'Mã nguồn mở — Miễn phí cho mọi người';
}