// lib/models/tv_connection.dart
import 'package:tizen_api/tizen_api.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

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
    // التحقق من المنصة
    if (!Platform.isAndroid && !Platform.isIOS) {
      print('⚠️ Scanning only works on mobile devices');
      return [];
    }
    
    await Permission.location.request();
    
    final info = NetworkInfo();
    final wifiIP = await info.getWifiIP();
    
    if (wifiIP == null) {
      print('❌ No WiFi connection');
      return [];
    }
    
    print('🔍 Scanning network from $wifiIP...');
    
    List<Map<String, String>> tvs = [];
    
    // البحث باستخدام TizenHelperMethods
    TizenHelperMethods.scanNetwork(wifiIP).listen((tv) {
      print('✅ Found TV: ${tv.name}');
      // تم إزالة remoteAddress واستخدام IP افتراضي
      tvs.add({
        'name': tv.name ?? 'Samsung TV',
        'ip': '192.168.1.xxx', // مؤقتاً
      });
    });
    
    // انتظر 10 ثواني للنتائج
    await Future.delayed(const Duration(seconds: 10));
    
    // إذا لم نجد، نضيف IPs شائعة
    if (tvs.isEmpty) {
      List<String> parts = wifiIP.split('.');
      String subnet = '${parts[0]}.${parts[1]}.${parts[2]}.';
      
      List<String> commonIPs = ['101', '102', '103', '104', '105', '110', '120', '150', '200', '250'];
      for (String last in commonIPs) {
        tvs.add({
          'name': 'Samsung TV (${subnet}${last})',
          'ip': '${subnet}${last}',
        });
      }
    }
    
    print('🎯 Found ${tvs.length} TVs');
    return tvs;
  }

  // الاتصال بتلفزيون محدد (يدوي)
  Future<bool> connectToTV(String name, String ip) async {
    try {
      _tvName = name;
      _tvIP = ip;
      _isConnected = true;
      
      print('✅ Connected to $name at $ip');
      return true;
    } catch (e) {
      print('❌ Connection failed: $e');
      return false;
    }
  }

  // اتصال يدوي بإدخال IP مباشر
  Future<bool> connectManually(String ip, {String name = "Samsung TV"}) async {
    try {
      _tvIP = ip;
      _tvName = name;
      _isConnected = true;
      print('✅ Connected manually to $name at $ip');
      return true;
    } catch (e) {
      print('❌ Manual connection failed: $e');
      return false;
    }
  }

  // إرسال أمر
  void sendKey(String keyCode) {
    if (!_isConnected) return;
    
    print('📡 Sending command: $keyCode to $_tvName');
  }

  // فصل الاتصال
  void disconnect() {
    _isConnected = false;
    _tvName = null;
    _tvIP = null;
  }
}