import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  
  late Dio _dio;
  final _storage = const FlutterSecureStorage();

  DioClient._internal() {
    _dio = Dio(BaseOptions(
      // KHI CÓ .NET: Sửa dòng này thành IP máy bạn (VD: http://192.168.1.10:5000)
      baseUrl: "http://10.0.2.2:5000", 
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    // Cấu hình Interceptor (Bộ lọc tự động)
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Lấy token từ bộ nhớ máy
        final token = await _storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers["Authorization"] = "Bearer $token";
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Nếu Server báo lỗi 401 (Unauthorized) -> Token hết hạn
        if (e.response?.statusCode == 401) {
          print("Token hết hạn! Cần đăng nhập lại.");
          // Ở đây có thể điều hướng về màn Login
        }
        return handler.next(e);
      },
    ));
  }

  Dio get api => _dio;
}