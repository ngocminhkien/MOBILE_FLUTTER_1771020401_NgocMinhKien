import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Dùng 10.0.2.2 cho Android Emulator hoặc IP máy tính cho máy thật
  static const String baseUrl = "http://10.0.2.2:5290/api";

  // 1. Lấy danh sách giờ đã đặt (Sửa lỗi getBookedSlots)
  Future<List<String>> getBookedSlots(DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0]; // Lấy định dạng yyyy-MM-dd
      final response = await http.get(Uri.parse('$baseUrl/Bookings/slots?date=$dateStr'));
      
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e.toString()).toList();
      }
    } catch (e) {
      print("Lỗi getBookedSlots: $e");
    }
    return []; // Trả về danh sách rỗng nếu lỗi
  }

  // 2. Tạo đơn đặt sân (Sửa lỗi createBooking)
  Future<bool> createBooking(String slot, DateTime date) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Bookings'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "courtId": 1, // Tạm thời để mặc định sân số 1
          "startTime": "${date.toIso8601String().split('T')[0]}T$slot:00",
          "status": "Confirmed"
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // 3. Nạp tiền (Đã sửa chữ 't' thường khớp với wallet_screen.dart)
  Future<bool> topUp(String email, double amount) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Auth/topup?email=$email&amount=$amount'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 4. Đăng nhập
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Auth/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {
      print("Lỗi login: $e");
    }
    return null;
  }
}