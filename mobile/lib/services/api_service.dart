import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_session.dart'; // Đảm bảo bạn đã tạo file này như hướng dẫn trước

class ApiService {
  // Dùng localhost cho Edge/Web. Nếu chạy Android Emulator thì đổi thành "http://10.0.2.2:5290/api"
  static const String baseUrl = "http://localhost:5290/api";

  // --- 1. AUTHENTICATION (Đăng ký, Đăng nhập, Lấy Info) ---

  static Future<bool> register(String email, String password, String fullName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Auth/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password, "fullName": fullName}),
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Auth/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Lưu Session quan trọng
        UserSession.userId = data['userId'];
        UserSession.email = email;
        UserSession.fullName = data['fullName'];
        UserSession.balance = (data['walletBalance'] ?? 0).toDouble();
        UserSession.role = data['role'] ?? "Member";
        
        return true;
      }
    } catch (e) { print("Lỗi login: $e"); }
    return false;
  }

  static Future<List<dynamic>> fetchMembers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/Auth/members')); 
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) { return []; }
  }

  // --- 2. WALLET (Nạp tiền) ---

  static Future<bool> topUp(double amount) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Auth/topup?email=${UserSession.email}&amount=$amount'),
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  // --- 3. BOOKING (Đặt sân, Lấy lịch, Kiểm tra trùng) ---

  // Trả về String để biết lỗi cụ thể: "OK", "Hết tiền", "Trùng lịch"...
  static Future<String> createBooking(int courtId, String slot, DateTime date) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Bookings'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "courtId": courtId,
          "memberId": UserSession.userId,
          "startTime": "${date.toIso8601String().split('T')[0]}T$slot:00",
          "status": "Confirmed"
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return "OK";
      } else {
        // Lấy thông báo lỗi từ Backend trả về
        final errorData = jsonDecode(response.body);
        return errorData['message'] ?? "Lỗi đặt sân từ hệ thống";
      }
    } catch (e) {
      return "Lỗi kết nối máy chủ";
    }
  }

  static Future<List<dynamic>> getMyBookings() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/Bookings/member/${UserSession.userId}'));
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) { return []; }
  }

  static Future<List<String>> getBookedSlots(DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await http.get(Uri.parse('$baseUrl/Bookings/slots?date=$dateStr'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e.toString()).toList();
      }
    } catch (e) { print(e); }
    return [];
  }

  // --- 4. TOURNAMENT (Giải đấu & Tiền thưởng) ---

  static Future<List<dynamic>> getTournaments() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/Tournaments'));
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) { return []; }
  }

static Future<bool> createTournament(String name, double prizeMoney, String status, String format,String date,int courtId) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/Tournaments'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "prizeMoney": prizeMoney,
        "startDate": date, 
        "courtId": courtId,
        "status": status,
        "format": format // Gửi thêm định dạng (1v1 hoặc 2v2)
      }),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  } catch (e) {
    print("Lỗi API: $e");
    return false;
  }
}
// ... Trong class ApiService

  // 1. Lấy thống kê Dashboard
  static Future<Map<String, dynamic>> getDashboardStats() async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/Stats/dashboard'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
  } catch (e) { print("Lỗi Stats: $e"); }
  // Trả về số 0 mặc định nếu lỗi, tránh bị null
  return {
    "members": 0, 
    "tournaments": 0, 
    "pendingRequests": 0, 
    "systemBalance": 0
  };
}

  // 2. Duyệt hoặc Từ chối giải đấu
  static Future<bool> updateTournamentStatus(int id, String newStatus) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/Tournaments/$id/status'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(newStatus), // Gửi chuỗi status trực tiếp
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }
}