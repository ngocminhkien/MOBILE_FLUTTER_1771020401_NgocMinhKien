import 'package:flutter/material.dart';
import '../services/api_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double _balance = 0.0;

  void _showTopUpDialog() {
    double amount = 0;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nạp tiền vào ví"),
        content: TextField(
          keyboardType: TextInputType.number,
          onChanged: (value) => amount = double.tryParse(value) ?? 0,
          decoration: const InputDecoration(hintText: "Nhập số tiền"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              // Gọi hàm topUp đã định nghĩa trong ApiService
              bool success = await ApiService().topUp("admin@gmail.com", amount);
              if (success && mounted) {
                setState(() => _balance += amount);
                Navigator.pop(context);
              }
            },
            child: const Text("Nạp ngay"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ví cá nhân")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${_balance.toStringAsFixed(0)} đ", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
            ElevatedButton(onPressed: _showTopUpDialog, child: const Text("Nạp tiền")),
          ],
        ),
      ),
    );
  }
}