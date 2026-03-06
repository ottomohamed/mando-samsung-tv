// lib/services/samsung_tv_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SamsungTVService {
  static final SamsungTVService _instance = SamsungTVService._internal();
  factory SamsungTVService() => _instance;
  SamsungTVService._internal();

  WebSocket? _webSocket;
  String? _tvIP;
  String? _tvName;
  bool _isConnected = false;
  String? _savedToken;
  
  bool get isConnected => _isConnected;
  String? get tvName => _tvName;
  String? get tvIP => _tvIP;

  // البحث عن التلفزيونات باستخدام UPNP
  Future<List<Map<String, String>>> discoverTVs() async {
    List<Map<String, String>> tvs = [];
    
    // هذه محاكاة - في الواقع سنستخدم UPNP أو البحث في الشبكة
    // لكن للتجربة، سنستخدم IPs شائعة
    
    return tvs;
  }

  // الاتصال بالتلفزيون عبر WebSocket آمن
  Future<bool> connect(String ip, {String name = "Samsung TV", String? token}) async {
    try {
      _tvIP = ip;
      _tvName = name;
      
      // اسم الجهاز مشفر بـ Base64
      String deviceName = base64Encode(utf8.encode("Mando Remote"));
      
      // بناء رابط WebSocket
      String url = "wss://$ip:8002/api/v2/channels/samsung.remote.control?name=$deviceName";
      
      // إضافة token إذا كان موجوداً
      if (token != null && token.isNotEmpty) {
        url += "&token=$token";
      }
      
      print('🔌 Connecting to $url');
      
      // تجاهل شهادة SSL (لأن التلفاز يستخدم شهادة ذاتية)
      // ignore: invalid_use_of_visible_for_testing_member
      _webSocket = await WebSocket.connect(url);
      
      _webSocket!.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDone,
      );
      
      // إرسال ping كل 30 ثانية للحفاظ على الاتصال
      Timer.periodic(const Duration(seconds: 30), (timer) {
        if (_webSocket != null && _isConnected) {
          _webSocket!.add('ping');
        } else {
          timer.cancel();
        }
      });
      
      _isConnected = true;
      print('✅ Connected to $name');
      
      return true;
    } catch (e) {
      print('❌ Connection failed: $e');
      return false;
    }
  }

  // معالجة الرسائل الواردة
  void _handleMessage(dynamic message) {
    print('📩 Received: $message');
    
    try {
      Map<String, dynamic> data = jsonDecode(message);
      
      // إذا وصل token، احفظه
      if (data['event'] == 'ms.channel.connect' && data['data'] != null) {
        String? token = data['data']['token'];
        if (token != null && token.isNotEmpty) {
          _saveToken(token);
          print('🔑 Token saved: $token');
        }
      }
    } catch (e) {
      print('Error parsing message: $e');
    }
  }

  // معالجة الأخطاء
  void _handleError(error) {
    print('❌ WebSocket error: $error');
    _isConnected = false;
  }

  // عند إغلاق الاتصال
  void _handleDone() {
    print('🔌 WebSocket connection closed');
    _isConnected = false;
  }

  // حفظ token للمستقبل
  Future<void> _saveToken(String token) async {
    _savedToken = token;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('tv_token_$_tvIP', token);
  }

  // تحميل token المخزن
  Future<String?> _loadToken(String ip) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('tv_token_$ip');
  }

  // إرسال أمر
  void sendKey(String keyCode) {
    if (_webSocket == null || !_isConnected) {
      print('⚠️ Not connected');
      return;
    }
    
    Map<String, dynamic> command = {
      "method": "ms.remote.control",
      "params": {
        "Cmd": "Click",
        "DataOfCmd": keyCode,
        "Option": "false",
        "TypeOfRemote": "SendRemoteKey"
      }
    };
    
    String jsonCommand = jsonEncode(command);
    _webSocket!.add(jsonCommand);
    print('📡 Sent: $keyCode');
  }

  // فصل الاتصال
  void disconnect() {
    _webSocket?.close();
    _webSocket = null;
    _isConnected = false;
  }
}