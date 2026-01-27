import 'package:flutter/material.dart';
import '../models/member_model.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  // Nhận thông tin user từ HomeScreen sau khi đăng nhập thành công
  final Member? user; 
  const ProfileScreen({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    // Nếu chưa có user, hiển thị màn hình yêu cầu đăng nhập
    if (user == null) {
      return const Center(child: Text("Vui lòng đăng nhập để xem thông tin"));
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.green,
              child: Text(user!.fullName[0], style: const TextStyle(fontSize: 40, color: Colors.white)),
            ),
            const SizedBox(height: 16),
            Text(user!.fullName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text("Hạng: ${user!.tier} | Ví: ${user!.walletBalance} đ", style: const TextStyle(color: Colors.grey)),
            const Divider(height: 40),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Đăng xuất", style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
            )
          ],
        ),
      ),
    );
  }
}