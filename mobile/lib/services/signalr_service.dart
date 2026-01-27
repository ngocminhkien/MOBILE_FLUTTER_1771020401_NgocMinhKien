import 'package:signalr_netcore/signalr_client.dart';

class SignalrService {
  late HubConnection _hubConnection;
  
  // URL của SignalR Hub (KHI CÓ .NET sẽ là: http://10.0.2.2:5000/pcmHub)
  final String _serverUrl = "http://10.0.2.2:5000/pcmHub";

  Future<void> initSignalR() async {
    _hubConnection = HubConnectionBuilder().withUrl(_serverUrl).build();

    _hubConnection.onclose(({error}) {
      print("Kết nối SignalR bị ngắt!");
    });

    // 1. Lắng nghe sự kiện cập nhật lịch (UpdateCalendar)
    _hubConnection.on("UpdateCalendar", (arguments) {
      print("Nhận tín hiệu UpdateCalendar từ Server!");
      // TODO: Gọi hàm reload lại màn hình Booking
    });

    // 2. Lắng nghe thông báo (ReceiveNotification)
    _hubConnection.on("ReceiveNotification", (arguments) {
      final message = arguments?[0] as String?;
      print("Có thông báo mới: $message");
      // TODO: Hiện SnackBar hoặc đẩy Notification
    });

    await _hubConnection.start();
    print("Đã kết nối SignalR thành công!");
  }
}