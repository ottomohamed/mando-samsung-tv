// lib/services/samsung_tv_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
  Timer? _pingTimer;

  // Callbacks للإشعار بتغيير الحالة
  Function(bool)? onConnectionChanged;
  Function(String)? onTokenReceived;
  Function(String)? onError;

  bool get isConnected => _isConnected;
  String? get tvName => _tvName;
  String? get tvIP => _tvIP;

  // ───────────────────────────────────────────────
  // الاتصال الرئيسي
  // ───────────────────────────────────────────────
  Future<bool> connect(String ip, {String name = "Samsung TV", String? token}) async {
    // قطع أي اتصال سابق
    await disconnect();

    _tvIP = ip;
    _tvName = name;

    // تحميل token مخزن إذا لم يُمرَّر
    token ??= await _loadToken(ip);

    // اسم الجهاز بـ Base64URL (بدون = + /)
    final deviceName = base64Url.encode(utf8.encode("Mando Remote"));

    // بناء الرابط
    String url =
        "wss://$ip:8002/api/v2/channels/samsung.remote.control?name=$deviceName";
    if (token != null && token.isNotEmpty) {
      url += "&token=$token";
    }

    print('🔌 Connecting to: $url');

    try {
      // ─── الحل الأساسي: HttpClient يتجاهل شهادة SSL الذاتية ───
      final httpClient = HttpClient()
        ..badCertificateCallback = (cert, host, port) => true;

      final socket = await SecureSocket.connect(
        ip,
        8002,
        onBadCertificate: (_) => true,
        timeout: const Duration(seconds: 10),
      );

      _webSocket = WebSocket.fromUpgradedSocket(
        socket,
        serverSide: false,
      );

    } catch (e) {
      print('⚠️ SecureSocket failed, trying direct WebSocket: $e');
      try {
        // المحاولة الثانية: تجاوز SSL عبر io_client
        _webSocket = await _connectWithSSLBypass(url);
      } catch (e2) {
        print('❌ All connection attempts failed: $e2');
        onError?.call('Connection failed: $e2');
        return false;
      }
    }

    if (_webSocket == null) return false;

    // الاستماع للرسائل
    _webSocket!.listen(
      _handleMessage,
      onError: _handleError,
      onDone: _handleDone,
      cancelOnError: false,
    );

    // ✅ الاتصال نجح على مستوى WebSocket
    // لكن ننتظر رسالة ms.channel.connect للتأكيد الحقيقي
    _isConnected = true;
    onConnectionChanged?.call(true);

    // Ping كل 30 ثانية للحفاظ على الاتصال
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_webSocket != null && _isConnected) {
        try {
          _webSocket!.add('{"method":"ms.channel.emit","params":{"event":"ping","data":{}}}');
        } catch (_) {}
      } else {
        timer.cancel();
      }
    });

    print('✅ WebSocket connected to $name ($ip)');
    return true;
  }

  // ───────────────────────────────────────────────
  // تجاوز SSL عبر HttpOverrides
  // ───────────────────────────────────────────────
  Future<WebSocket> _connectWithSSLBypass(String url) async {
    WebSocket? ws;

    // استخدام HttpOverrides لتجاهل SSL عالمياً مؤقتاً
    await HttpOverrides.runWithHttpOverrides(() async {
      ws = await WebSocket.connect(url).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('Connection timed out'),
      );
    }, _TrustAllCertificates());

    return ws!;
  }

  // ───────────────────────────────────────────────
  // معالجة الرسائل الواردة من التلفاز
  // ───────────────────────────────────────────────
  void _handleMessage(dynamic message) {
    print('📩 TV says: $message');

    try {
      final Map<String, dynamic> data = jsonDecode(message as String);
      final String? event = data['event'];

      switch (event) {
        case 'ms.channel.connect':
          // التلفاز قبل الاتصال رسمياً
          print('✅ TV confirmed connection!');
          _isConnected = true;
          onConnectionChanged?.call(true);

          // استخراج وحفظ token
          final token = data['data']?['token'] as String?;
          if (token != null && token.isNotEmpty) {
            _saveToken(token);
            onTokenReceived?.call(token);
            print('🔑 Token received and saved: $token');
          }
          break;

        case 'ms.channel.clientConnect':
          print('📱 Another client connected');
          break;

        case 'ms.channel.clientDisconnect':
          print('📱 Another client disconnected');
          break;

        case 'ms.error':
          final errorMsg = data['data']?['message'] ?? 'Unknown TV error';
          print('❌ TV Error: $errorMsg');
          onError?.call(errorMsg.toString());
          break;

        default:
          // رسائل أخرى (تجاهلها بهدوء)
          break;
      }
    } catch (e) {
      // ليست JSON - ربما ping/pong
      print('📩 Non-JSON message: $message');
    }
  }

  // ───────────────────────────────────────────────
  // معالجة الأخطاء وإغلاق الاتصال
  // ───────────────────────────────────────────────
  void _handleError(dynamic error) {
    print('❌ WebSocket error: $error');
    _isConnected = false;
    _pingTimer?.cancel();
    onConnectionChanged?.call(false);
    onError?.call(error.toString());
  }

  void _handleDone() {
    print('🔌 WebSocket closed');
    _isConnected = false;
    _pingTimer?.cancel();
    onConnectionChanged?.call(false);
  }

  // ───────────────────────────────────────────────
  // إرسال مفتاح للتلفاز
  // ───────────────────────────────────────────────
  bool sendKey(String keyCode) {
    if (_webSocket == null || !_isConnected) {
      print('⚠️ Cannot send key - not connected. Key: $keyCode');
      return false;
    }

    final command = jsonEncode({
      "method": "ms.remote.control",
      "params": {
        "Cmd": "Click",
        "DataOfCmd": keyCode,
        "Option": "false",
        "TypeOfRemote": "SendRemoteKey",
      },
    });

    try {
      _webSocket!.add(command);
      print('📡 Key sent: $keyCode');
      return true;
    } catch (e) {
      print('❌ Failed to send key: $e');
      _isConnected = false;
      onConnectionChanged?.call(false);
      return false;
    }
  }

  // إرسال نص (للكيبورد)
  bool sendText(String text) {
    if (_webSocket == null || !_isConnected) return false;

    final command = jsonEncode({
      "method": "ms.remote.control",
      "params": {
        "Cmd": "Move",
        "DataOfCmd": "base64",
        "Option": base64Encode(utf8.encode(text)),
        "TypeOfRemote": "SendInputString",
      },
    });

    try {
      _webSocket!.add(command);
      print('⌨️ Text sent: $text');
      return true;
    } catch (e) {
      print('❌ Failed to send text: $e');
      return false;
    }
  }

  // ───────────────────────────────────────────────
  // فصل الاتصال
  // ───────────────────────────────────────────────
  Future<void> disconnect() async {
    _pingTimer?.cancel();
    _pingTimer = null;
    try {
      await _webSocket?.close();
    } catch (_) {}
    _webSocket = null;
    _isConnected = false;
    print('🔌 Disconnected');
  }

  // ───────────────────────────────────────────────
  // حفظ وتحميل Token
  // ───────────────────────────────────────────────
  Future<void> _saveToken(String token) async {
    _savedToken = token;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('tv_token_${_tvIP}', token);
    } catch (e) {
      print('Error saving token: $e');
    }
  }

  Future<String?> _loadToken(String ip) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('tv_token_$ip');
    } catch (e) {
      return null;
    }
  }

  // حذف token مخزن (لإعادة الاقتران)
  Future<void> clearToken(String ip) async {
    _savedToken = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('tv_token_$ip');
      print('🗑️ Token cleared for $ip');
    } catch (e) {
      print('Error clearing token: $e');
    }
  }
}

// ───────────────────────────────────────────────
// Override لتجاهل شهادات SSL غير الموثوقة
// ───────────────────────────────────────────────
class _TrustAllCertificates extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (cert, host, port) => true;
    return client;
  }
}

// ───────────────────────────────────────────────
// أكواد المفاتيح الكاملة لـ Samsung TV
// ───────────────────────────────────────────────
class SamsungKeys {
  // التشغيل الأساسي
  static const String power        = 'KEY_POWER';
  static const String powerOff     = 'KEY_POWEROFF';
  static const String powerOn      = 'KEY_POWERON';

  // الصوت
  static const String volUp        = 'KEY_VOLUP';
  static const String volDown      = 'KEY_VOLDOWN';
  static const String mute         = 'KEY_MUTE';

  // القنوات
  static const String chUp         = 'KEY_CHUP';
  static const String chDown       = 'KEY_CHDOWN';
  static const String prevCh       = 'KEY_PRECH';

  // التنقل
  static const String up           = 'KEY_UP';
  static const String down         = 'KEY_DOWN';
  static const String left         = 'KEY_LEFT';
  static const String right        = 'KEY_RIGHT';
  static const String enter        = 'KEY_ENTER';
  static const String back         = 'KEY_RETURN';
  static const String exit         = 'KEY_EXIT';
  static const String home         = 'KEY_HOME';
  static const String menu         = 'KEY_MENU';
  static const String tools        = 'KEY_TOOLS';
  static const String info         = 'KEY_INFO';

  // التشغيل والتسجيل
  static const String play         = 'KEY_PLAY';
  static const String pause        = 'KEY_PAUSE';
  static const String stop         = 'KEY_STOP';
  static const String rewind       = 'KEY_REWIND';
  static const String forward      = 'KEY_FF';
  static const String record       = 'KEY_REC';

  // الألوان
  static const String red          = 'KEY_RED';
  static const String green        = 'KEY_GREEN';
  static const String yellow       = 'KEY_YELLOW';
  static const String blue         = 'KEY_CYAN';

  // الأرقام
  static const String num0         = 'KEY_0';
  static const String num1         = 'KEY_1';
  static const String num2         = 'KEY_2';
  static const String num3         = 'KEY_3';
  static const String num4         = 'KEY_4';
  static const String num5         = 'KEY_5';
  static const String num6         = 'KEY_6';
  static const String num7         = 'KEY_7';
  static const String num8         = 'KEY_8';
  static const String num9         = 'KEY_9';

  // خاص
  static const String source       = 'KEY_SOURCE';
  static const String hdmi1        = 'KEY_HDMI1';
  static const String hdmi2        = 'KEY_HDMI2';
  static const String hdmi3        = 'KEY_HDMI3';
  static const String hdmi4        = 'KEY_HDMI4';
  static const String smartHub     = 'KEY_SMARTHUB';
  static const String netflix      = 'KEY_NETFLIX';
  static const String prime        = 'KEY_PRIMEINSTANT';
  static const String aspect       = 'KEY_ASPECT';
  static const String pictureSize  = 'KEY_PICTURE_SIZE';
  static const String sleep        = 'KEY_SLEEP';
  static const String caption      = 'KEY_CAPTION';
  static const String guide        = 'KEY_GUIDE';
}
