// lib/screens/remote_screen_tablet.dart
import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../models/tv_connection.dart';
import 'tv_search_screen.dart';
import 'manual_ip_screen.dart';
import '../widgets/streaming_buttons_v2.dart';
import '../models/ad_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../widgets/quick_menu.dart';
import 'package:responsive_builder/responsive_builder.dart';

class RemoteScreenTablet extends StatefulWidget {
  const RemoteScreenTablet({super.key});

  @override
  State<RemoteScreenTablet> createState() => _RemoteScreenTabletState();
}

class _RemoteScreenTabletState extends State<RemoteScreenTablet> {
  bool _isConnected = false;
  String _tvName = "Living Room TV";
  int _volumeLevel = 50;
  final TVConnection _tvConnection = TVConnection();
  final AdManager _adManager = AdManager();
  bool _showInterstitialOnOpen = true;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    
    Future.delayed(const Duration(seconds: 2), () {
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

  Future<void> _openManualIP() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ManualIPScreen()),
    );
    
    if (result == true) {
      setState(() {
        _isConnected = true;
        _tvName = _tvConnection.tvName ?? "Samsung TV (Manual)";
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Manual Connection Successful!'),
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
          content: Text('No TV connected. Please scan or enter IP manually.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    _tvConnection.sendKey(command);
    print('Sending: $command');
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  void _closeMenu() {
    setState(() {
      _isMenuOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppTheme.backgroundDark,
        child: SafeArea(
          child: ScreenTypeLayout.builder(
            mobile: (BuildContext context) => _buildPhoneLayout(),
            tablet: (BuildContext context) => _buildTabletLayout(),
          ),
        ),
      ),
    );
  }

  // واجهة الهاتف (مشابهة لما لدينا)
  Widget _buildPhoneLayout() {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                _buildStatusBar(),
                _buildTVName(),
                _buildConnectionButtons(),
                const SizedBox(height: 8),
                _buildMainControls(),
                _buildAppIcons(),
                _buildNavButtons(),
                _buildAIAssistant(),
              ],
            ),
          ),
        ),
        if (_isMenuOpen) _buildMenu(),
      ],
    );
  }

  // واجهة التابليت - محسنة للمساحة الأكبر
  Widget _buildTabletLayout() {
    return OrientationLayoutBuilder(
      portrait: (context) => _buildTabletPortrait(),
      landscape: (context) => _buildTabletLandscape(),
    );
  }

  // تابلت - الوضع العمودي
  Widget _buildTabletPortrait() {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildStatusBar(),
                const SizedBox(height: 20),
                _buildTVName(),
                const SizedBox(height: 20),
                _buildConnectionButtons(),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: _buildMainControls(),
                ),
                const SizedBox(height: 30),
                _buildAppIcons(),
                const SizedBox(height: 20),
                _buildNavButtons(),
                const SizedBox(height: 30),
                _buildAIAssistant(),
              ],
            ),
          ),
        ),
        if (_isMenuOpen) _buildMenu(),
      ],
    );
  }

  // تابلت - الوضع الأفقي (مثالي للريموت)
  Widget _buildTabletLandscape() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              // الجزء الأيسر: معلومات الاتصال
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusBar(),
                    const SizedBox(height: 30),
                    _buildTVName(),
                    const SizedBox(height: 30),
                    _buildConnectionButtons(),
                  ],
                ),
              ),
              
              // الجزء الأوسط: عناصر التحكم الرئيسية
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildMainControls(),
                    const SizedBox(height: 30),
                    _buildAppIcons(),
                    const SizedBox(height: 20),
                    _buildNavButtons(),
                  ],
                ),
              ),
              
              // الجزء الأيمن: AI Assistant
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAIAssistant(),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_isMenuOpen) _buildMenu(),
      ],
    );
  }

  // الأجزاء المشتركة
  Widget _buildStatusBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
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
        _buildSmallButton(
          icon: Icons.power_settings_new,
          onPressed: () => _sendCommand('KEY_POWER'),
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildTVName() {
    return Padding(
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
    );
  }

  Widget _buildConnectionButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          ElevatedButton(
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
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _openManualIP,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.accentCyan,
              side: const BorderSide(color: AppTheme.accentCyan),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Manual IP Entry'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainControls() {
    return SizedBox(
      height: 180,
      child: Row(
        children: [
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
          Container(
            width: 220,
            height: 220,
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
    );
  }

  Widget _buildAppIcons() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          NetflixButton(onPressed: () => _sendCommand('KEY_NETFLIX')),
          YouTubeButton(onPressed: () => _sendCommand('KEY_YOUTUBE')),
          PrimeVideoButton(onPressed: () => _sendCommand('KEY_PRIMEINSTANT')),
          DisneyPlusButton(onPressed: () => _sendCommand('KEY_DISNEYPLUS')),
        ],
      ),
    );
  }

  Widget _buildNavButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavButton(Icons.home, 'Home', () => _sendCommand('KEY_HOME')),
          _buildNavButton(Icons.arrow_back, 'Back', () => _sendCommand('KEY_RETURN')),
          _buildNavButton(Icons.menu, 'Menu', _toggleMenu),
        ],
      ),
    );
  }

  Widget _buildAIAssistant() {
    return Column(
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
    );
  }

  Widget _buildMenu() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        child: QuickMenu(onClose: _closeMenu),
      ),
    );
  }

  Widget _buildTinyButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 48,
      height: 48,
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
          borderRadius: BorderRadius.circular(24),
          child: Icon(
            icon,
            color: AppTheme.accentCyan,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildSmallButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.glassWhite.withOpacity(0.1),
        border: Border.all(
          color: color?.withOpacity(0.5) ?? AppTheme.accentCyan.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color?.withOpacity(0.3) ?? AppTheme.glowBlue,
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
            color: color ?? AppTheme.textWhite,
            size: 18,
          ),
        ),
      ),
    );
  }

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