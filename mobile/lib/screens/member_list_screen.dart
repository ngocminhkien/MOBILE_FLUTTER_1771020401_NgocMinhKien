import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  // --- Phần logic lấy danh sách thành viên ---
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
      if (mounted) {
        setState(() {
          _members = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // SỬ DỤNG TAB CONTROLLER ĐỂ CHIA 2 MỤC
    return DefaultTabController(
      length: 2, // 2 Tab: Bảng tin & Thành viên
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Cộng Đồng"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.green,
          elevation: 0,
          // Thanh Tab nằm dưới AppBar
          bottom: const TabBar(
            labelColor: Colors.green,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.green,
            tabs: [
              Tab(text: "Bảng Tin", icon: Icon(Icons.newspaper)),
              Tab(text: "Thành Viên", icon: Icon(Icons.group)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1: BẢNG TIN (Code cũ của HomeTab chuyển sang)
            _buildNewsTab(),
            
            // TAB 2: DANH SÁCH THÀNH VIÊN (Code cũ của MemberList)
            _buildMemberTab(),
          ],
        ),
      ),
    );
  }

  // --- Widget vẽ Tab Bảng Tin ---
  Widget _buildNewsTab() {
    return Container(
      color: Colors.grey[50],
      child: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          // Banner thông báo
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.orange, Colors.deepOrange]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.campaign, color: Colors.white, size: 30),
                SizedBox(width: 15),
                Expanded(
                  child: Text("Giải đấu 'Mùa Hè Sôi Động' đang mở đăng ký! Tham gia ngay.", 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildNewsCard("Khai trương sân mới", "Sân số 4 và 5 đã sẵn sàng phục vụ với mặt sân chuẩn quốc tế.", "2 giờ trước", Colors.blue),
          _buildNewsCard("Off-line Cuối Tuần", "Giao lưu kỹ thuật và thi đấu vui vẻ vào sáng Chủ Nhật.", "1 ngày trước", Colors.green),
          _buildNewsCard("Bảo trì hệ thống", "Hệ thống đặt sân sẽ bảo trì từ 0h-2h sáng mai.", "3 ngày trước", Colors.red),
        ],
      ),
    );
  }

  Widget _buildNewsCard(String title, String desc, String time, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(Icons.article, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(desc),
            const SizedBox(height: 5),
            Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // --- Widget vẽ Tab Thành Viên ---
  Widget _buildMemberTab() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_members.isEmpty) return const Center(child: Text("Chưa có thành viên nào."));

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: _members.length,
      itemBuilder: (context, index) {
        final m = _members[index];
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green[100],
              child: Text(m['fullName'][0].toUpperCase(), 
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            ),
            title: Text(m['fullName'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(m['email'], style: const TextStyle(fontSize: 12)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
              child: Text(m['tier'] ?? "Member", style: const TextStyle(fontSize: 10)),
            ),
          ),
        );
      },
    );
  }
}