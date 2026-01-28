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
        _members = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cộng Đồng Vợt Thủ", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.green,
        elevation: 0.5,
      ),
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _members.isEmpty
              ? const Center(child: Text("Chưa có thành viên nào tham gia."))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _members.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final m = _members[index];
                    String name = m['fullName'] ?? "Ẩn danh";
                    String firstLetter = name.isNotEmpty ? name[0].toUpperCase() : "?";
                    String tier = m['tier'] ?? "Member";
                    bool isGold = tier == "Gold";

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5)
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: isGold ? Colors.amber[100] : Colors.green[100],
                          child: Text(
                            firstLetter,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: isGold ? Colors.deepOrange : Colors.green[800],
                            ),
                          ),
                        ),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Text(m['email'] ?? "No Email", style: TextStyle(color: Colors.grey[600])),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isGold ? Colors.amber[100] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isGold ? Colors.amber : Colors.grey.shade300),
                          ),
                          child: Text(
                            tier.toUpperCase(),
                            style: TextStyle(
                              color: isGold ? Colors.deepOrange : Colors.grey[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}