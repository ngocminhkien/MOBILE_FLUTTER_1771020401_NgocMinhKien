import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; // Cần import để format ngày tháng
import '../services/api_service.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  
  // Danh sách các khung giờ cố định của sân
  final List<String> _allSlots = [
    "07:00", "08:00", "09:00", "10:00", 
    "15:00", "16:00", "17:00", "18:00", "19:00", "20:00"
  ];

  List<String> _bookedSlots = []; // Danh sách giờ đã có người đặt
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchSlots(_selectedDay); // Load dữ liệu ngay khi mở màn hình
  }

  // Hàm gọi API lấy dữ liệu
  void _fetchSlots(DateTime date) async {
    setState(() => _isLoading = true);
    final booked = await ApiService().getBookedSlots(date);
    setState(() {
      _bookedSlots = booked;
      _isLoading = false;
    });
  }

  // Hàm xử lý khi bấm nút Đặt sân
  void _handleBooking(String slot) async {
    // Hiện hộp thoại xác nhận
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận đặt sân"),
        content: Text("Bạn muốn đặt khung giờ $slot ngày ${DateFormat('dd/MM').format(_selectedDay)}?\nPhí: 50,000đ"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Đồng ý")),
        ],
      ),
    );

    if (confirm == true) {
      // Gọi API đặt sân
      await ApiService().createBooking(slot, _selectedDay);
      
      // Thông báo và reload lại danh sách
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đặt sân thành công!")));
        _fetchSlots(_selectedDay); // Refresh lại để thấy ô đó chuyển màu đỏ (nếu làm kỹ hơn)
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Lịch
        TableCalendar(
          firstDay: DateTime.utc(2025, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          currentDay: DateTime.now(),
          calendarFormat: CalendarFormat.week, // Chỉ hiện theo tuần cho gọn
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            _fetchSlots(selectedDay); // Chọn ngày mới -> Load lại dữ liệu
          },
        ),
        const Divider(),
        
        // 2. Danh sách Slot
        Expanded(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator()) 
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 cột
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _allSlots.length,
                itemBuilder: (context, index) {
                  final slot = _allSlots[index];
                  final isBooked = _bookedSlots.contains(slot); // Kiểm tra xem giờ này bị đặt chưa

                  return InkWell(
                    onTap: isBooked ? null : () => _handleBooking(slot),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isBooked ? Colors.red.shade100 : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isBooked ? Colors.red : Colors.green),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        slot,
                        style: TextStyle(
                          color: isBooked ? Colors.red : Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }
}