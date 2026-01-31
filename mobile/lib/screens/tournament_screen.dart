import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../services/user_session.dart';

class TournamentScreen extends StatefulWidget {
  const TournamentScreen({super.key});

  @override
  State<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen> {
  final _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  // --- HÀM XỬ LÝ (ACTIONS) ---

  // 1. Tham gia giải đấu
  void _handleJoinTournament(int tournamentId) {
    // Gọi API tham gia tại đây (Hiện tại chỉ hiện thông báo)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã gửi yêu cầu tham gia! BTC sẽ liên hệ bạn."), backgroundColor: Colors.blue),
    );
  }

  // 2. Duyệt hoặc Từ chối giải đấu (Chỉ Admin)
  void _handleApprove(int id, bool isApprove) async {
    String status = isApprove ? "Upcoming" : "Rejected";
    
    // Gọi API cập nhật trạng thái
    bool success = await ApiService.updateTournamentStatus(id, status);
    
    if (success) {
      setState(() {}); // Reload danh sách ngay lập tức
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isApprove ? "Đã duyệt giải đấu thành công!" : "Đã từ chối đề xuất!"),
            backgroundColor: isApprove ? Colors.green : Colors.red,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi kết nối Server!"), backgroundColor: Colors.red));
      }
    }
  }

  // 3. Hiển thị Dialog Tạo mới / Đề xuất
  void _showAddDialog() {
    final nameController = TextEditingController();
    final prizeController = TextEditingController();
    
    // Giá trị mặc định
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
    TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 0);
    int selectedCourt = 1;
    String selectedFormat = "2v2";
    
    bool isAdmin = UserSession.isAdmin;

    showDialog(
      context: context,
      builder: (context) {
        // Dùng StatefulBuilder để cập nhật UI bên trong Dialog (Dropdown, DatePicker)
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(isAdmin ? "Tạo giải đấu mới" : "Đề xuất giải đấu"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isAdmin)
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(5)),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: Colors.orange),
                            SizedBox(width: 5),
                            Expanded(child: Text("Đề xuất của bạn sẽ chờ Admin duyệt.", style: TextStyle(fontSize: 12, color: Colors.deepOrange))),
                          ],
                        ),
                      ),
                    
                    // Nhập tên
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Tên giải đấu", prefixIcon: Icon(Icons.emoji_events_outlined)),
                    ),
                    const SizedBox(height: 10),
                    
                    // Nhập tiền thưởng
                    TextField(
                      controller: prizeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Tiền thưởng (VNĐ)", prefixIcon: Icon(Icons.attach_money)),
                    ),
                    const SizedBox(height: 15),

                    // Chọn Thể thức
                    DropdownButtonFormField<String>(
                      value: selectedFormat,
                      decoration: const InputDecoration(labelText: "Thể thức thi đấu", prefixIcon: Icon(Icons.groups)),
                      items: const [
                        DropdownMenuItem(value: "1v1", child: Text("Đơn (1 vs 1)")),
                        DropdownMenuItem(value: "2v2", child: Text("Đôi (2 vs 2)")),
                      ],
                      onChanged: (val) => setStateDialog(() => selectedFormat = val!),
                    ),

                    // Chọn Sân
                    DropdownButtonFormField<int>(
                      value: selectedCourt,
                      decoration: const InputDecoration(labelText: "Sân tổ chức", prefixIcon: Icon(Icons.stadium)),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text("Sân số 1 (Trong nhà)")),
                        DropdownMenuItem(value: 2, child: Text("Sân số 2 (Ngoài trời)")),
                        DropdownMenuItem(value: 3, child: Text("Sân số 3 (VIP)")),
                      ],
                      onChanged: (val) => setStateDialog(() => selectedCourt = val!),
                    ),

                    const SizedBox(height: 15),
                    
                    // Chọn Ngày & Giờ
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              DateTime? picked = await showDatePicker(
                                context: context, initialDate: selectedDate, firstDate: DateTime.now(), lastDate: DateTime(2030),
                              );
                              if (picked != null) setStateDialog(() => selectedDate = picked);
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: "Ngày", prefixIcon: Icon(Icons.calendar_today)),
                              child: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              TimeOfDay? picked = await showTimePicker(context: context, initialTime: selectedTime);
                              if (picked != null) setStateDialog(() => selectedTime = picked);
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: "Giờ", prefixIcon: Icon(Icons.access_time)),
                              child: Text(selectedTime.format(context)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isNotEmpty) {
                      double prize = double.tryParse(prizeController.text) ?? 0;
                      String status = isAdmin ? "Upcoming" : "Pending";
                      
                      // Gộp ngày và giờ thành DateTime chuẩn
                      DateTime finalDateTime = DateTime(
                        selectedDate.year, selectedDate.month, selectedDate.day,
                        selectedTime.hour, selectedTime.minute
                      );

                      bool success = await ApiService.createTournament(
                        nameController.text,
                        prize,
                        status,
                        selectedFormat,
                        finalDateTime.toIso8601String(),
                        selectedCourt
                      );

                      if (success) {
                        setState(() {}); // Refresh list bên ngoài
                        if (context.mounted) Navigator.pop(context);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(isAdmin ? "Đã tạo giải đấu!" : "Đã gửi đề xuất thành công!"), backgroundColor: Colors.green),
                          );
                        }
                      }
                    }
                  },
                  child: Text(isAdmin ? "Tạo ngay" : "Gửi đề xuất"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- HÀM UI HELPER ---
  Color _getStatusColor(String status) {
    switch (status) {
      case "Upcoming": return Colors.green;
      case "Pending": return Colors.orange;
      case "Rejected": return Colors.red;
      case "Finished": return Colors.grey;
      default: return Colors.blue;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case "Upcoming": return "Sắp diễn ra";
      case "Pending": return "Chờ duyệt";
      case "Rejected": return "Bị từ chối";
      case "Finished": return "Đã kết thúc";
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Giải Đấu Pickleball"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.add),
        label: Text(UserSession.isAdmin ? "Tạo giải" : "Đề xuất"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService.getTournaments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  const Text("Chưa có giải đấu nào", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final tour = snapshot.data![index];
              final status = tour['status'] ?? "Upcoming";
              final format = tour['format'] ?? "2v2";
              final date = DateTime.tryParse(tour['startDate'] ?? "") ?? DateTime.now();

              // Ẩn giải bị từ chối đối với User thường (chỉ Admin hoặc người tạo mới thấy - ở đây ta ẩn luôn cho gọn nếu User thường)
              if (status == "Rejected" && !UserSession.isAdmin) return const SizedBox.shrink();

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                // Nếu là Admin và giải đang Pending -> highlight màu cam nhạt
                color: (UserSession.isAdmin && status == "Pending") ? Colors.orange[50] : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Tên giải + Badge trạng thái
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: _getStatusColor(status).withOpacity(0.1), shape: BoxShape.circle),
                            child: Icon(Icons.emoji_events, color: _getStatusColor(status)),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tour['name'] ?? "Giải đấu", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: _getStatusColor(status).withOpacity(0.5))
                                  ),
                                  child: Text(_getStatusText(status), style: TextStyle(fontSize: 10, color: _getStatusColor(status), fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                          ),
                          Text(_currencyFormat.format(tour['prizeMoney'] ?? 0), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                        ],
                      ),
                      
                      const Divider(height: 25),

                      // Thông tin chi tiết: Ngày, Sân, Thể thức
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoItem(Icons.calendar_today, _dateFormat.format(date)),
                          _buildInfoItem(Icons.stadium, "Sân ${tour['courtId'] ?? 1}"),
                          _buildInfoItem(Icons.groups, format),
                        ],
                      ),
                      
                      const SizedBox(height: 15),

                      // --- BUTTONS ACTION AREA ---
                      
                      // 1. ADMIN ACTIONS: Duyệt / Từ chối (Cho giải Pending)
                      if (UserSession.isAdmin && status == "Pending")
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _handleApprove(tour['id'], false),
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                                child: const Text("Từ chối"),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _handleApprove(tour['id'], true),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                child: const Text("Duyệt ngay"),
                              ),
                            ),
                          ],
                        ),

                      // 2. USER/ADMIN ACTIONS: Tham gia (Cho giải Upcoming)
                      if (status == "Upcoming")
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _handleJoinTournament(tour['id']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue, 
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                            ),
                            child: const Text("ĐĂNG KÝ THAM GIA"),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
      ],
    );
  }
}