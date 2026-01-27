import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  List<dynamic> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    // API lấy toàn bộ member bạn cần viết thêm ở Backend
    // Ở đây tạm để rỗng cho đến khi bạn có API list member
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thành viên")),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _members.isEmpty 
          ? const Center(child: Text("Chưa có thành viên nào"))
          : ListView.builder(
              itemCount: _members.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(_members[index]['fullName']),
                subtitle: Text("Hạng: ${_members[index]['tier']}"),
              ),
            ),
    );
  }
}