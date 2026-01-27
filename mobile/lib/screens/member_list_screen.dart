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
    try {

      var data = await ApiService.fetchMembers();

      setState(() {
        _members = data; // Gán dữ liệu vào biến _members
        _isLoading = false;
      });
    } catch (e) {
      print("Lỗi tải dữ liệu: $e");
      setState(() {
        _isLoading = false;
      });
    }
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