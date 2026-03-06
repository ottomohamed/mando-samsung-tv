// lib/screens/remote_screen.dart
import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../models/tv_connection.dart';
import 'tv_search_screen.dart';
import '../models/ad_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RemoteScreen extends StatefulWidget {
  const RemoteScreen({super.key});

  @override
  State<RemoteScreen> createState() => _RemoteScreenState();
}

class _RemoteScreenState extends State<RemoteScreen> {
  bool _isConnected = false;
  String _tvName = "Living Room TV";
  int _volumeLevel = 50;
  final TVConnection _tvConnection = TVConnection();
  final AdManager _adManager = AdManager();
  bool _showInterstitialOnOpen = true;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    
    Future.delayed(const Duration(seconds: 1), () {
      if (_showInterstitialOnOpen && mounted) {
        _adManager.showInterstitialAd();
        setState(() {
          _showInterstitialOnOpen = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _adManager.dispose();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    setState(() {
      _isConnected = _tvConnection.isConnected;
      _tvName = _tvConnection.tvName ?? "Living Room TV";
    });
  }

  Future<void> _openTVSearch() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TVSearchScreen()),
    );
    
    if (result == true) {
      setState(() {
        _isConnected = true;
        _tvName = _tvConnection.tvName ?? "Samsung TV";
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('TV Connected Successfully!'),
          duration: Duration(seconds: 2),
          backgroundColor: AppTheme.connectedGreen,
        ),
      );
    }
  }

  void _sendCommand(String command) {
    if (!_tvConnection.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No TV connected. Please scan for TVs first.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    _tvConnection.sendKey(command);
    print('Sending: $command');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppTheme.backgroundDark,
        child: SafeArea(
          child: Column(
            children: [
              // شريط الحالة
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.glassWhite.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isConnected ? AppTheme.connectedGreen : Colors.red,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isConnected ? AppTheme.connectedGreen : Colors.red,
                        boxShadow: [
                          BoxShadow(
                            color: _isConnected 
                                ? AppTheme.connectedGreen.withOpacity(0.5) 
                                : Colors.red.withOpacity(0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isConnected ? 'Samsung TV Connected' : 'Disconnected',
                      style: const TextStyle(color: AppTheme.textWhite, fontSize: 12),
                    ),
                  ],
                ),
              ),
              
              // TV Name مع أيقونة الإشارة
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _tvName,
                      style: const TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.signal_cellular_alt,
                      color: _isConnected ? AppTheme.accentTeal : AppTheme.textGrey,
                      size: 18,
                    ),
                  ],
                ),
              ),
              
              // زر المسح والاتصال
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ElevatedButton(
                  onPressed: _isConnected ? null : _openTVSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isConnected ? Colors.grey : AppTheme.accentCyan,
                    foregroundColor: AppTheme.backgroundDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    _isConnected ? 'Connected' : 'Find TV',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // المنطقة الرئيسية (D-Pad + أزرار جانبية)
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    // أزرار الصوت (يسار)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSmallButton(
                            icon: Icons.volume_up,
                            onPressed: () {
                              setState(() {
                                if (_volumeLevel < 100) _volumeLevel += 10;
                              });
                              _sendCommand('KEY_VOLUP');
                            },
                          ),
                          const SizedBox(height: 4),
                          // شريط مستوى الصوت
                          Container(
                            width: 3,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppTheme.glassWhite.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 3,
                                  height: (_volumeLevel / 100) * 60,
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentCyan,
                                    borderRadius: BorderRadius.circular(2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.accentCyan.withOpacity(0.5),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildSmallButton(
                            icon: Icons.volume_down,
                            onPressed: () {
                              setState(() {
                                if (_volumeLevel > 0) _volumeLevel -= 10;
                              });
                              _sendCommand('KEY_VOLDOWN');
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    // D-Pad (وسط)
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.glassWhite.withOpacity(0.05),
                        border: Border.all(
                          color: AppTheme.accentCyan.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Up
                          Positioned(
                            top: 5,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: _buildTinyButton(
                                icon: Icons.arrow_upward,
                                onPressed: () => _sendCommand('KEY_UP'),
                              ),
                            ),
                          ),
                          // Down
                          Positioned(
                            bottom: 5,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: _buildTinyButton(
                                icon: Icons.arrow_downward,
                                onPressed: () => _sendCommand('KEY_DOWN'),
                              ),
                            ),
                          ),
                          // Left
                          Positioned(
                            left: 5,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: _buildTinyButton(
                                icon: Icons.arrow_back,
                                onPressed: () => _sendCommand('KEY_LEFT'),
                              ),
                            ),
                          ),
                          // Right
                          Positioned(
                            right: 5,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: _buildTinyButton(
                                icon: Icons.arrow_forward,
                                onPressed: () => _sendCommand('KEY_RIGHT'),
                              ),
                            ),
                          ),
                          // Center OK
                          Center(
                            child: Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.glassWhite.withOpacity(0.1),
                                border: Border.all(
                                  color: AppTheme.accentCyan,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.accentCyan.withOpacity(0.5),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _sendCommand('KEY_ENTER'),
                                  borderRadius: BorderRadius.circular(22),
                                  child: const Center(
                                    child: Text(
                                      'OK',
                                      style: TextStyle(
                                        color: AppTheme.textWhite,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // أزرار القنوات (يمين)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSmallButton(
                            icon: Icons.arrow_upward,
                            onPressed: () => _sendCommand('KEY_CHUP'),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.glassWhite.withOpacity(0.05),
                              border: Border.all(
                                color: AppTheme.accentTeal.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.tv,
                              color: AppTheme.accentTeal,
                              size: 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSmallButton(
                            icon: Icons.arrow_downward,
                            onPressed: () => _sendCommand('KEY_CHDOWN'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // أيقونات التطبيقات (صف أفقي)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAppIcon('N', Colors.red, () => _sendCommand('netflix')),
                    _buildAppIcon('YT', Colors.red, () => _sendCommand('youtube')),
                    _buildAppIcon('P', Colors.blue, () => _sendCommand('prime')),
                    _buildAppIcon('D', const Color(0xFF113CCF), () => _sendCommand('disney')),
                  ],
                ),
              ),
              
              // أزرار التحكم السفلية (Home, Back, Menu)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavButton(Icons.home, 'Home', () => _sendCommand('KEY_HOME')),
                    _buildNavButton(Icons.arrow_back, 'Back', () => _sendCommand('KEY_RETURN')),
                    _buildNavButton(Icons.menu, 'Menu', () => _sendCommand('KEY_MENU')),
                  ],
                ),
              ),
              
              // زر المايكروفون مع AI Assistant
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.glassWhite.withOpacity(0.1),
                        border: Border.all(
                          color: AppTheme.accentCyan,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentCyan.withOpacity(0.5),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _sendCommand('KEY_MIC');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('AI Assistant listening...'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: Icon(
                            Icons.mic,
                            color: AppTheme.accentCyan,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'AI Assistant',
                      style: TextStyle(
                        color: AppTheme.textGrey,
                        fontSize: 11,
                      ),
                    ),
                    
                    // Banner Ad - تحت AI Assistant مباشرة
                    if (_adManager.isBannerAdLoaded && _adManager.bannerAd != null)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        child: SizedBox(
                          width: _adManager.bannerAd!.size.width.toDouble(),
                          height: _adManager.bannerAd!.size.height.toDouble(),
                          child: AdWidget(ad: _adManager.bannerAd!),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // أزرار صغيرة جداً للـ D-Pad
  Widget _buildTinyButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 30,
      height: 30,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.glassWhite.withOpacity(0.1),
        border: Border.all(
          color: AppTheme.accentCyan.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.glowBlue,
            blurRadius: 4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: Icon(
            icon,
            color: AppTheme.accentCyan,
            size: 16,
          ),
        ),
      ),
    );
  }

  // أزرار صغيرة للجانبين
  Widget _buildSmallButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.glassWhite.withOpacity(0.1),
        border: Border.all(
          color: AppTheme.accentCyan.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.glowBlue,
            blurRadius: 4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          child: Icon(
            icon,
            color: AppTheme.textWhite,
            size: 18,
          ),
        ),
      ),
    );
  }

  // أيقونات التطبيقات
  Widget _buildAppIcon(String text, Color color, VoidCallback onPressed) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withOpacity(0.8),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // أزرار التحكم
  Widget _buildNavButton(IconData icon, String label, VoidCallback onPressed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppTheme.glassWhite.withOpacity(0.1),
        border: Border.all(
          color: AppTheme.accentCyan.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppTheme.textWhite, size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(color: AppTheme.textWhite, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}