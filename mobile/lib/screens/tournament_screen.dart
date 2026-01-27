import 'package:flutter/material.dart';
import '../models/tournament_model.dart';

class TournamentScreen extends StatefulWidget {
  const TournamentScreen({super.key});

  @override
  State<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen> {
  // Khởi tạo danh sách rỗng để tránh lỗi đỏ
  final List<Tournament> _allTournaments = []; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Giải Đấu")),
      body: _allTournaments.isEmpty 
        ? const Center(child: Text("Chưa có giải đấu nào được cập nhật"))
        : ListView.builder(
            itemCount: _allTournaments.length,
            itemBuilder: (context, index) => ListTile(title: Text(_allTournaments[index].name)),
          ),
    );
  }
}