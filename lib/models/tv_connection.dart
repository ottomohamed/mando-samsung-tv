// lib/models/tv_connection.dart
import 'package:tizen_api/tizen_api.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class TVConnection {
  static final TVConnection _instance = TVConnection._internal();
  factory TVConnection() => _instance;
  TVConnection._internal();

  bool _isConnected = false;
  String? _tvName;
  String? _tvIP;
  
  bool get isConnected => _isConnected;
  String? get tvName => _tvName;
  String? get tvIP => _tvIP;

  // البحث عن التلفزيونات في الشبكة
  Future<List<Map<String, String>>> scanForTVs() async {
    await Permission.location.request();
    
    final info = NetworkInfo();
    final wifiIP = await info.getWifiIP();
    
    if (wifiIP == null) return [];
    
    print('Scanning network from $wifiIP...');
    
    List<Map<String, String>> tvs = [];
    
    // استخدام الخصائص المتاحة فقط
    TizenHelperMethods.scanNetwork(wifiIP).listen((tv) {
      print('Found TV: ${tv.name}');
      // لا نستخدم remoteAddress حالياً
      tvs.add({
        'name': tv.name ?? 'Samsung TV',
        'ip': '192.168.1.xxx', // مؤقتاً
      });
    });
    
    await Future.delayed(const Duration(seconds: 5));
    
    return tvs;
  }

  // الاتصال بتلفزيون محدد
  Future<bool> connectToTV(String name, String ip) async {
    try {
      _tvName = name;
      _tvIP = ip;
      _isConnected = true;
      
      print('Connected to $name');
      return true;
    } catch (e) {
      print('Connection failed: $e');
      return false;
    }
  }

  // إرسال أمر
  void sendKey(String keyCode) {
    if (!_isConnected) return;
    
    print('Sending command: $keyCode to $_tvName');
    // هنا سنضيف الكود الفعلي لاحقاً
  }

  // فصل الاتصال
  void disconnect() {
    _isConnected = false;
    _tvName = null;
    _tvIP = null;
  }
}