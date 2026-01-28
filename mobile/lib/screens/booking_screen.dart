import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../services/user_session.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDay = DateTime.now();
  int _selectedCourtId = 1; // Mặc định chọn sân 1
  List<String> _bookedSlots = [];
  bool _isLoading = false;

  final List<String> _allSlots = ["07:00", "08:00", "09:00", "15:00", "16:00", "17:00", "18:00", "19:00"];
  final List<int> _courts = [1, 2, 3]; // Giả sử có 3 sân

  @override
  void initState() {
    super.initState();
    _fetchBookedSlots();
  }

  void _fetchBookedSlots() async {
    setState(() => _isLoading = true);
    // Backend cần update API để filter theo cả CourtId (Tạm thời lấy hết theo ngày)
    final booked = await ApiService.getBookedSlots(_selectedDay);
    setState(() {
      _bookedSlots = booked;
      _isLoading = false;
    });
  }

  void _handleBooking(String slot) async {
    // 1. Kiểm tra tiền trước (Client check)
    if (UserSession.balance < 50000) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Không đủ tiền! Vui lòng nạp thêm.")));
      return;
    }

    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Đặt Sân $_selectedCourtId"),
        content: Text("Khung giờ: $slot\nGiá: 50,000 đ\nBạn có chắc chắn?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Thanh toán")),
        ],
      ),
    );

    if (confirm == true) {
      // Gọi API đặt sân
      String result = await ApiService.createBooking(_selectedCourtId, slot, _selectedDay);
      
      if (result == "OK") {
        UserSession.balance -= 50000; // Trừ tiền ảo ở Client để cập nhật ngay
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đặt sân thành công!")));
        _fetchBookedSlots(); // Load lại để ô vừa đặt chuyển màu đỏ
      } else {
        // Hiện lỗi từ Backend (Trùng sân, hết tiền...)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Chọn ngày
        ListTile(
          title: Text("Ngày: ${DateFormat('dd/MM/yyyy').format(_selectedDay)}"),
          trailing: const Icon(Icons.calendar_today),
          onTap: () async {
            final picked = await showDatePicker(context: context, firstDate: DateTime.now(), initialDate: _selectedDay, lastDate: DateTime(2030));
            if (picked != null) {
              setState(() => _selectedDay = picked);
              _fetchBookedSlots();
            }
          },
        ),
        // Chọn sân
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _courts.length,
            itemBuilder: (context, index) {
              int courtId = _courts[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text("Sân $courtId"),
                  selected: _selectedCourtId == courtId,
                  onSelected: (selected) {
                    setState(() => _selectedCourtId = courtId);
                    _fetchBookedSlots();
                  },
                ),
              );
            },
          ),
        ),
        const Divider(),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 2.5, mainAxisSpacing: 10, crossAxisSpacing: 10),
            itemCount: _allSlots.length,
            itemBuilder: (context, index) {
              final slot = _allSlots[index];
              // Kiểm tra xem giờ này ĐÃ CÓ người đặt chưa
              // (Lưu ý: Logic này cần Backend trả về chính xác giờ CỦA SÂN ĐANG CHỌN)
              final isBooked = _bookedSlots.contains(slot); 

              return InkWell(
                onTap: isBooked ? null : () => _handleBooking(slot),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isBooked ? Colors.red[100] : Colors.green[100],
                    border: Border.all(color: isBooked ? Colors.red : Colors.green),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(slot, style: TextStyle(color: isBooked ? Colors.red : Colors.green[800], fontWeight: FontWeight.bold)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}