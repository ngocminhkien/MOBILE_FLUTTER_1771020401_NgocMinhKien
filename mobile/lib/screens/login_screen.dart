import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'register_screen.dart'; // Import màn hình đăng ký vừa sửa xong
import '../services/user_session.dart';
import 'admin_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);
    // Gọi API Login
    bool success = await ApiService.login(_emailController.text.trim(), _passwordController.text.trim());
    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        // Điều hướng dựa trên quyền
        if (UserSession.isAdmin) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
  }
}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.login, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text("Đăng Nhập", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder(), prefixIcon: Icon(Icons.email))),
            const SizedBox(height: 15),
            TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: "Mật khẩu", border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock))),
            const SizedBox(height: 20),
            _isLoading 
              ? const CircularProgressIndicator() 
              : SizedBox(
                  width: double.infinity, 
                  height: 50,
                  child: ElevatedButton(onPressed: _handleLogin, style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white), child: const Text("ĐĂNG NHẬP")),
                ),
            TextButton(
              // Chuyển sang màn hình Đăng ký
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
              child: const Text("Chưa có tài khoản? Đăng ký ngay"),
            )
          ],
        ),
      ),
    );
  }
}
