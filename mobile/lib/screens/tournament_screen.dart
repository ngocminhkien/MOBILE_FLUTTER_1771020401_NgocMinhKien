import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Để format tiền tệ
import '../services/api_service.dart';

class TournamentScreen extends StatefulWidget {
  const TournamentScreen({super.key});
  @override
  State<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen> {
  
  // Hàm hiển thị dialog thêm giải đấu
  void _showAddDialog() {
    final nameController = TextEditingController();
    final prizeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tạo giải đấu mới"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController, 
              decoration: const InputDecoration(labelText: "Tên giải đấu", icon: Icon(Icons.emoji_events)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: prizeController, 
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Tiền thưởng (VNĐ)", icon: Icon(Icons.attach_money)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                double prize = double.tryParse(prizeController.text) ?? 0;
                
                // Gọi API tạo giải
                bool success = await ApiService.createTournament(nameController.text, prize);
                
                if (success) {
                  setState(() {}); // Reload danh sách
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tạo giải thành công!")));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi tạo giải đấu!")));
                }
              }
            },
            child: const Text("Tạo ngay"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Giải Đấu Pickleball"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService.getTournaments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events_outlined, size: 80, color: Colors.grey),
                  Text("Chưa có giải đấu nào", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final tour = snapshot.data![index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.shade100,
                    child: const Icon(Icons.emoji_events, color: Colors.orange),
                  ),
                  title: Text(tour['name'] ?? "Giải đấu", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Tiền thưởng: ${currencyFormat.format(tour['prizeMoney'] ?? 0)}"),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(tour['status'] ?? "Sắp diễn ra", style: TextStyle(fontSize: 12, color: Colors.green.shade800)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}