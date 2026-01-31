import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../services/user_session.dart';
import 'login_screen.dart';
import 'tournament_screen.dart'; // Tab thứ 2 để duyệt giải nằm ở đây

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});
  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const AdminDashboardTab(), // Tab 1: Tổng quan (Dashboard)
    const TournamentScreen(),  // Tab 2: Quản lý & Duyệt giải
  ];

  void _logout() {
    UserSession.userId = "";
    UserSession.role = "";
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QUẢN TRỊ VIÊN"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        actions: [IconButton(onPressed: _logout, icon: const Icon(Icons.logout))],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Tổng quan'),
          BottomNavigationBarItem(icon: Icon(Icons.verified_user), label: 'Duyệt giải đấu'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.redAccent,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

class AdminDashboardTab extends StatefulWidget {
  const AdminDashboardTab({super.key});
  @override
  State<AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends State<AdminDashboardTab> {
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() async {
    var data = await ApiService.getDashboardStats();
    if (mounted) {
      setState(() {
        _stats = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return RefreshIndicator(
      onRefresh: () async => _loadStats(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Tổng Quan Hệ Thống", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          
          Row(
            children: [
              // Key phải viết thường: members, tournaments...
              _buildStatCard("Thành viên", "${_stats['members'] ?? 0}", Colors.blue, Icons.people),
              const SizedBox(width: 15),
              _buildStatCard("Tổng giải đấu", "${_stats['tournaments'] ?? 0}", Colors.green, Icons.emoji_events),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildStatCard("Chờ duyệt", "${_stats['pendingRequests'] ?? 0}", Colors.orange, Icons.pending_actions),
              const SizedBox(width: 15),
              _buildStatCard("Tổng ví User", currencyFormat.format(_stats['systemBalance'] ?? 0), Colors.purple, Icons.account_balance_wallet),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color), textAlign: TextAlign.center),
            const SizedBox(height: 5),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}