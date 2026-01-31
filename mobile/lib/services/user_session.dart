class UserSession {
  static String userId = "";
  static String email = "";
  static String fullName = "";
  static double balance = 0.0;
  
  // Biến lưu quyền hạn (Mặc định là Member)
  static String role = "Member";
  
  // SỬA LỖI Ở ĐÂY:
  // Định nghĩa isAdmin là một 'getter' trả về bool (True nếu là Admin, False nếu không phải)
  static bool get isAdmin => role == "Admin";
}