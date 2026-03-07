// lib/models/tv_connection.dart
import 'dart:io';
import 'dart:async';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/samsung_tv_service.dart';

class TVConnection {
  static final TVConnection _instance = TVConnection._internal();
  factory TVConnection() => _instance;
  TVConnection._internal();

  // ✅ كل شيء يمر عبر SamsungTVService
  final SamsungTVService _service = SamsungTVService();

  bool get isConnected => _service.isConnected;
  String? get tvName  => _service.tvName;
  String? get tvIP    => _service.tvIP;

  // ─────────────────────────────────────────────
  // البحث عن التلفزيونات في الشبكة المحلية
  // ─────────────────────────────────────────────
  Future<List<Map<String, String>>> scanForTVs() async {
    List<Map<String, String>> found = [];

    // الصلاحيات مطلوبة على Android للوصول للشبكة
    if (Platform.isAndroid) {
      final status = await Permission.location.request();
      if (!status.isGranted) {
        print('⚠️ Location permission denied - cannot scan network');
        return [];
      }
    }

    // الحصول على IP الحالي للجهاز
    final info = NetworkInfo();
    final wifiIP = await info.getWifiIP();

    if (wifiIP == null || wifiIP.isEmpty) {
      print('❌ No WiFi connection detected');
      return [];
    }

    print('🔍 Scanning network from $wifiIP...');

    // استخراج الـ subnet (مثال: 192.168.1.)
    final parts = wifiIP.split('.');
    if (parts.length != 4) return [];
    final subnet = '${parts[0]}.${parts[1]}.${parts[2]}.';

    // فحص المنفذ 8002 (منفذ Samsung TV الرسمي) لكل IP
    final futures = <Future>[];
    for (int i = 1; i <= 254; i++) {
      final ip = '$subnet$i';
      futures.add(_checkSamsungPort(ip).then((isSamsung) {
        if (isSamsung) {
          found.add({
            'name': 'Samsung TV ($ip)',
            'ip': ip,
          });
          print('✅ Found Samsung TV at $ip');
        }
      }));
    }

    // انتظار كل الفحوصات مع timeout كلي 8 ثوان
    await Future.wait(futures).timeout(
      const Duration(seconds: 8),
      onTimeout: () => [],
    );

    // إذا لم يُعثر على شيء، اقترح IPs شائعة كخيار احتياطي
    if (found.isEmpty) {
      print('ℹ️ No TVs found via scan, adding common IPs as suggestions');
      for (final last in ['100', '101', '105', '110', '150', '200']) {
        found.add({
          'name': 'Samsung TV? ($subnet$last)',
          'ip': '$subnet$last',
        });
      }
    }

    print('🎯 Scan complete: ${found.length} candidates');
    return found;
  }

  // فحص إذا كان IP يملك منفذ Samsung TV مفتوح
  Future<bool> _checkSamsungPort(String ip) async {
    try {
      final socket = await Socket.connect(
        ip, 8002,
        timeout: const Duration(milliseconds: 300),
      );
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // الاتصال بتلفزيون من قائمة البحث
  // ─────────────────────────────────────────────
  Future<bool> connectToTV(String name, String ip) async {
    print('🔌 Connecting to $name at $ip...');
    final success = await _service.connect(ip, name: name);
    if (success) {
      print('✅ Connected to $name');
    } else {
      print('❌ Failed to connect to $name');
    }
    return success;
  }

  // ─────────────────────────────────────────────
  // الاتصال اليدوي بإدخال IP مباشرة
  // ─────────────────────────────────────────────
  Future<bool> connectManually(String ip, {String name = 'Samsung TV'}) async {
    print('🔌 Manual connect to $ip...');
    final success = await _service.connect(ip, name: name);
    if (success) {
      print('✅ Manual connection successful');
    } else {
      print('❌ Manual connection failed');
    }
    return success;
  }

  // ─────────────────────────────────────────────
  // إرسال مفتاح للتلفاز
  // ─────────────────────────────────────────────
  void sendKey(String keyCode) {
    if (!_service.isConnected) {
      print('⚠️ Cannot send key - not connected');
      return;
    }
    _service.sendKey(keyCode);
  }

  // ─────────────────────────────────────────────
  // فصل الاتصال
  // ─────────────────────────────────────────────
  Future<void> disconnect() async {
    await _service.disconnect();
  }
}
