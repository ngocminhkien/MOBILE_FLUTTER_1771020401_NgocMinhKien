import 'package:flutter/material.dart';
import 'booking_screen.dart';
import 'tournament_screen.dart';
import 'wallet_screen.dart';
import 'member_list_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

final List<Widget> _screens = [
    const DashboardTab(),
    const BookingScreen(),
    const TournamentScreen(),
    const WalletScreen(),
    const ProfileScreen(),
    const MemberListScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vợt Thủ Phố Núi"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          // Icon chuông thông báo [cite: 161]
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Đặt sân'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Giải đấu'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Ví'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Cộng đồng'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Giữ cố định khi có nhiều hơn 3 tab
      ),
    );
  }
}

// Widget con: Nội dung của Tab Trang Chủ (Dashboard) [cite: 163]
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Thẻ hiển thị Số dư Ví (Nổi bật)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.green, Colors.teal]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Số dư ví", style: TextStyle(color: Colors.white70, fontSize: 14)),
                SizedBox(height: 8),
                Text("2,500,000 đ", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text("Hạng: Vàng (Gold)", style: TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. Tiêu đề Lịch sắp tới
          const Text("Lịch thi đấu sắp tới", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          
          // 3. Danh sách trận đấu giả lập (List Card)
          Card(
            child: ListTile(
              leading: const Icon(Icons.sports_tennis, color: Colors.orange),
              title: const Text("Trận Giao Hữu Đôi"),
              subtitle: const Text("18:00 - 19:00 | Sân 01"),
              trailing: Chip(label: const Text("Sắp diễn ra"), backgroundColor: Colors.orange.shade100),
            ),
          ),
        ],
      ),
    );
  }
}