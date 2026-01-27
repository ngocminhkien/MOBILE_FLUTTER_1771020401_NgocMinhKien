🎾 Pickleball Management System
Hệ thống quản lý sân chơi Pickleball toàn diện bao gồm Backend (ASP.NET Core API) và Mobile/Web App (Flutter). Dự án hỗ trợ quản lý thành viên, đặt sân, nạp tiền vào ví và tổ chức giải đấu.

🛠 Công nghệ sử dụng
Backend: .NET 8 Web API, Entity Framework Core.

Database: MySQL Server.

Mobile/Web: Flutter SDK (Dart).

Authentication: ASP.NET Core Identity (JWT ready).

🚀 Hướng dẫn cài đặt
1. Cấu hình Backend
Cài đặt Database: * Mở MySQL Workbench và chạy các script tạo database.

Cập nhật chuỗi kết nối (ConnectionStrings) trong file appsettings.json cho đúng với mật khẩu MySQL của bạn.

Chạy ứng dụng:

Bash
cd Backend
dotnet restore
dotnet run
API sẽ lắng nghe tại cổng mặc định: http://localhost:5290.

Swagger UI có sẵn tại: http://localhost:5290/swagger.

2. Cấu hình Flutter (Mobile/Web)
Cài đặt thư viện:

Bash
cd mobile
flutter pub get
Cấu hình API URL: * Mở lib/services/api_service.dart.

Nếu chạy trên Edge/Web: Sử dụng http://localhost:5290/api.

Nếu chạy trên Android Emulator: Sử dụng http://10.0.2.2:5290/api.

Chạy App:

Bash
flutter run -d edge  # Cho trình duyệt Edge
# hoặc
flutter run          # Cho thiết bị di động
📋 Tính năng chính
Đăng ký/Đăng nhập: Hệ thống quản lý tài khoản bảo mật với ASP.NET Identity.

Đặt sân trực tuyến: Chọn khung giờ và đặt sân theo thời gian thực.

Quản lý ví: Nạp tiền và thanh toán phí thuê sân.

Giải đấu: Xem thông tin và đăng ký tham gia các giải đấu Pickleball.

🧪 Tài khoản kiểm thử (Test Account)
Email: admin@gmail.com

Mật khẩu: Admin@123 (Mật khẩu mạnh theo tiêu chuẩn .NET)
