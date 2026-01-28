import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/user_session.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  void _showTopUpDialog() {
    double amount = 0;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nạp tiền"),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(suffixText: "VNĐ", hintText: "Nhập số tiền"),
          onChanged: (val) => amount = double.tryParse(val) ?? 0,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              if (amount > 0) {
                bool success = await ApiService.topUp(amount);
                if (success) {
                  setState(() => UserSession.balance += amount);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nạp thành công!")));
                }
              }
            },
            child: const Text("Xác nhận"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ví của tôi"), backgroundColor: Colors.teal, foregroundColor: Colors.white),
      body: Column(
        children: [
          // Thẻ ATM ảo
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.teal, Colors.greenAccent]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Số dư hiện tại", style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 10),
                Text("${UserSession.balance.toStringAsFixed(0)} đ", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(UserSession.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const Icon(Icons.contactless, color: Colors.white70),
                  ],
                )
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _showTopUpDialog,
            icon: const Icon(Icons.add),
            label: const Text("Nạp thêm tiền"),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
          ),
        ],
      ),
    );
  }
}