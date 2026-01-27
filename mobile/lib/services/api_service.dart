import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:5290/api";

  // 1. Lấy danh sách thành viên
  static Future<List<dynamic>> fetchMembers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/Auth/members')); 
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) { print("Lỗi fetchMembers: $e"); }
    return [];
  }

  // 2. Lấy giờ đã đặt
  static Future<List<String>> getBookedSlots(DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await http.get(Uri.parse('$baseUrl/Bookings/slots?date=$dateStr'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e.toString()).toList();
      }
    } catch (e) { print("Lỗi getBookedSlots: $e"); }
    return [];
  }

  // 3. Nạp tiền (CHỈ giữ lại 1 hàm duy nhất)
  static Future<bool> topUp(String email, double amount) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Auth/topup?email=$email&amount=$amount'),
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  // 4. Đăng nhập & Đăng ký
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Auth/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) { print("Lỗi login: $e"); }
    return null;
  }

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
  static Future<bool> createBooking(String slot, DateTime date) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Bookings'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "courtId": 1, // ID sân mặc định
          "memberId": "b5f91286-5ec8-4306-8d79-a331f545a7f1", // ID lấy từ kết quả login
          "startTime": "${date.toIso8601String().split('T')[0]}T$slot:00",
          "status": "Confirmed"
        }),
      );
      // Trả về true nếu Backend tạo thành công (200 hoặc 201)
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Lỗi đặt sân: $e");
      return false;
    }
  }
}