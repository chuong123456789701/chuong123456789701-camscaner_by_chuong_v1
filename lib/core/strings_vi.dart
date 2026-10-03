// lib/core/strings_vi.dart
// Toàn bộ chuỗi tiếng Việt — gom 1 chỗ cho dễ sửa
import 'app_info.dart';

class S {
  // Chung
  static const appTitle = '${AppInfo.appName} ${AppInfo.version}';
  static const ok = 'Đồng ý';
  static const cancel = 'Huỷ';
  static const close = 'Đóng';
  static const save = 'Lưu';
  static const open = 'Mở';
  static const delete = 'Xoá';
  static const yes = 'Có';
  static const no = 'Không';
  static const loading = 'Đang xử lý...';
  static const success = 'Thành công';
  static const error = 'Lỗi';
  static const warning = 'Cảnh báo';

  // Menu
  static const menuFile = 'Tệp';
  static const menuTools = 'Công cụ';
  static const menuHelp = 'Trợ giúp';
  static const menuOpen = 'Mở PDF...';
  static const menuOpenImages = 'Mở ảnh...';
  static const menuRecent = 'Mở gần đây';
  static const menuSaveAs = 'Lưu thành...';
  static const menuPrint = 'In...';
  static const menuExit = 'Thoát';
  static const menuMerge = 'Gộp nhiều PDF...';
  static const menuSplit = 'Tách trang...';
  static const menuCompress = 'Nén PDF...';
  static const menuProtect = 'Đặt mật khẩu...';
  static const menuImagesToPdf = 'Ảnh → PDF...';
  static const menuReceive = 'Nhận file từ điện thoại';
  static const menuEditor = 'Chỉnh sửa trang';
  static const menuAbout = 'Về tác giả / Giới thiệu';
  static const menuGuide = 'Hướng dẫn sử dụng';

  // Trang chủ
  static const welcome = 'Chào mừng đến với';
  static const dropHint = 'Kéo thả file PDF hoặc ảnh vào đây';
  static const orClick = 'hoặc bấm nút bên dưới để chọn file';
  static const btnOpenPdf = 'Mở PDF';
  static const btnOpenImages = 'Mở ảnh';
  static const btnReceive = 'Nhận từ điện thoại';
  static const noFileOpen = 'Chưa có file nào được mở';
  static const recentFiles = 'File gần đây';
  static const noRecent = 'Chưa có file nào gần đây';

  // Viewer
  static const page = 'Trang';
  static const of = '/';
  static const zoomIn = 'Phóng to';
  static const zoomOut = 'Thu nhỏ';
  static const fitWidth = 'Vừa chiều rộng';
  static const fitPage = 'Vừa trang';
  static const nextPage = 'Trang sau';
  static const prevPage = 'Trang trước';

  // Editor
  static const editor = 'Chỉnh sửa trang';
  static const selectAll = 'Chọn tất cả';
  static const deselectAll = 'Bỏ chọn';
  static const rotateLeft = 'Xoay trái 90°';
  static const rotateRight = 'Xoay phải 90°';
  static const rotate180 = 'Xoay 180°';
  static const deletePages = 'Xoá trang đã chọn';
  static const extractPages = 'Tách trang đã chọn ra PDF mới';
  static const reverseOrder = 'Đảo thứ tự trang';
  static const selectedCount = 'Đã chọn';
  static const pages = 'trang';

  // Nhận file
  static const receiveTitle = 'Nhận file từ điện thoại';
  static const receiveHint = 'Bật server, sau đó dùng điện thoại quét QR để gửi file PDF/ảnh lên máy tính này.';
  static const startServer = 'Bật nhận file';
  static const stopServer = 'Tắt nhận file';
  static const serverRunning = 'Đang chạy — sẵn sàng nhận file';
  static const serverStopped = 'Đã tắt';
  static const yourIp = 'Địa chỉ IP của máy này';
  static const scanQr = 'Quét QR bằng điện thoại';
  static const orOpenUrl = 'Hoặc mở địa chỉ này trên điện thoại';
  static const receivedFiles = 'File đã nhận';
  static const noReceivedFiles = 'Chưa nhận được file nào';
  static const openFolder = 'Mở thư mục chứa file';
  static const port = 'Cổng';
  static const portInUse = 'Cổng đang bận, thử cổng khác';
  static const needWifi = 'Hãy kết nối WiFi/LAN để dùng tính năng này';

  // Trạng thái
  static const statusReady = 'Sẵn sàng';
  static const statusProcessing = 'Đang xử lý...';
  static const statusDone = 'Xong';
  static const statusNoDoc = 'Chưa mở tài liệu';

  // Lỗi
  static const errOpenFile = 'Không mở được file';
  static const errSaveFile = 'Không lưu được file';
  static const errInvalidPdf = 'File PDF không hợp lệ hoặc đã bị hỏng';
  static const errEmpty = 'Vui lòng chọn ít nhất 1 trang';
  static const errPassword = 'Mật khẩu không đúng hoặc file được bảo vệ';
}