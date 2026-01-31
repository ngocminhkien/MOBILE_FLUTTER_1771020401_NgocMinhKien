import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Cần import để format ngày tháng
import '../services/api_service.dart';
import '../services/user_session.dart';
import 'login_screen.dart';
import 'booking_screen.dart';
import 'tournament_screen.dart';
import 'member_list_screen.dart';
import 'wallet_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Hàm để chuyển Tab từ màn hình con (HomeTab gọi ngược lên đây)
  void _switchTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Hàm xử lý đăng xuất
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Đăng xuất"),
        content: const Text("Bạn có chắc chắn muốn đăng xuất không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          TextButton(
            onPressed: () {
              UserSession.userId = "";
              UserSession.email = "";
              UserSession.role = "";
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text("Đồng ý", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Danh sách màn hình (Được khởi tạo trong build để truyền hàm _switchTab)
    final List<Widget> screens = [
      HomeTab(onSwitchTab: _switchTab), // Truyền hàm chuyển tab vào đây
      const BookingScreen(),
      const TournamentScreen(),
      const WalletScreen(),
      const MemberListScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Pickleball Pro", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Xin chào, ${UserSession.fullName}", style: const TextStyle(fontSize: 12)),
          ],
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout),
            tooltip: "Đăng xuất",
          )
        ],
      ),
      
      body: screens[_selectedIndex],
      
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Đặt sân'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Giải đấu'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Ví'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Cộng đồng'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

// --- HOME TAB (DASHBOARD) ---
class HomeTab extends StatefulWidget {
  final Function(int) onSwitchTab; // Nhận hàm chuyển tab từ cha

  const HomeTab({super.key, required this.onSwitchTab});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Thẻ Ví & Thông tin
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.green, Colors.teal]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Số dư khả dụng", style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 5),
                Text(_currencyFormat.format(UserSession.balance), 
                  style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    // Bấm Nạp tiền -> Chuyển sang Tab Ví (Index 3)
                    Expanded(child: _buildActionButton(Icons.add, "Nạp tiền", () => widget.onSwitchTab(3))),
                    const SizedBox(width: 15),
                    Expanded(child: _buildActionButton(Icons.history, "Lịch sử", () {})),
                  ],
                )
              ],
            ),
          ),
          
          const SizedBox(height: 25),
          const Text("Truy cập nhanh", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),

          // 2. Các nút chức năng (Đã sửa để bấm được)
          Row(
            children: [
              // Bấm Đặt sân -> Chuyển sang Tab Đặt sân (Index 1)
              Expanded(child: _buildBigFeatureCard(Icons.calendar_month, "Đặt sân ngay", Colors.orange, () => widget.onSwitchTab(1))),
              const SizedBox(width: 15),
              // Bấm Giải đấu -> Chuyển sang Tab Giải đấu (Index 2)
              Expanded(child: _buildBigFeatureCard(Icons.emoji_events, "Giải đấu", Colors.purple, () => widget.onSwitchTab(2))),
            ],
          ),

          const SizedBox(height: 25),
          const Text("Lịch đặt sân của bạn", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // 3. HIỂN THỊ DANH SÁCH SÂN ĐÃ ĐẶT (MỚI)
          FutureBuilder<List<dynamic>>(
            future: ApiService.getMyBookings(), // Gọi API lấy lịch
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                  child: const Center(child: Text("Bạn chưa có lịch đặt sân nào.", style: TextStyle(color: Colors.grey))),
                );
              }

              // Hiển thị 3 lịch gần nhất
              var bookings = snapshot.data!;
              // Sắp xếp theo ngày giảm dần (nếu cần) hoặc lấy từ API
              
              return Column(
                children: bookings.map((booking) {
                  // Xử lý ngày giờ
                  String dateStr = booking['startTime'] ?? DateTime.now().toIso8601String();
                  DateTime dateTime = DateTime.parse(dateStr);
                  String dateDisplay = DateFormat('dd/MM/yyyy').format(dateTime);
                  String timeDisplay = DateFormat('HH:mm').format(dateTime);
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.sports_tennis, color: Colors.blue),
                      ),
                      title: Text("Sân số ${booking['courtId']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("$dateDisplay | $timeDisplay"),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(8)),
                        child: const Text("Đã đặt", style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget nút nhỏ
  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.2),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Widget nút to (Feature Card)
  Widget _buildBigFeatureCard(IconData icon, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, // Đã gắn sự kiện bấm
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3))],
        ),
        child: Column(
          children: [
            CircleAvatar(radius: 25, backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color, size: 30)),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}