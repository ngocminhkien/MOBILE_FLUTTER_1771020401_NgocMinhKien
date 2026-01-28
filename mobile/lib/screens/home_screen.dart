import 'package:flutter/material.dart';
import '../services/user_session.dart'; // Import Session
import '../services/api_service.dart';
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
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Xin chào, ${UserSession.fullName}"), // Hiển thị tên thật
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
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
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});
  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thẻ Ví
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.green, Colors.teal]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Số dư ví", style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                // Hiển thị số dư từ Session
                Text("${UserSession.balance.toStringAsFixed(0)} đ", style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text("Lịch đặt sân của bạn", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // Load lịch đặt sân thật
          FutureBuilder<List<dynamic>>(
            future: ApiService.getMyBookings(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.isEmpty) return const Text("Chưa có lịch đặt sân nào.");
              
              return Column(
                children: snapshot.data!.map((item) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.sports_tennis, color: Colors.green),
                    title: Text("Sân số ${item['courtId']}"),
                    // Cắt chuỗi để lấy giờ: 2026-01-27T08:00:00 -> 08:00
                    subtitle: Text("Giờ: ${item['startTime'].toString().split('T')[1].substring(0, 5)}"),
                    trailing: const Chip(label: Text("Đã đặt"), backgroundColor: Colors.greenAccent),
                  ),
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}