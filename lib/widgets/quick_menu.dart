// lib/widgets/quick_menu.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../themes/app_theme.dart';
import '../services/samsung_tv_service.dart';

class QuickMenu extends StatefulWidget {
  final VoidCallback onClose;

  const QuickMenu({super.key, required this.onClose});

  @override
  State<QuickMenu> createState() => _QuickMenuState();
}

class _QuickMenuState extends State<QuickMenu> {
  final SamsungTVService _tv = SamsungTVService();

  int _brightnessIndex = 1; // 0=Low, 1=Medium, 2=High
  int _sleepTimer = 0;      // 0=Off, 30, 60, 90
  int _pictureIndex = 0;    // Standard, Dynamic, Movie, Game
  int _soundIndex = 0;      // Standard, Music, Movie, Clear Voice
  int _inputIndex = 0;      // TV, HDMI1, HDMI2, HDMI3, AV

  final List<String> _pictureLabels = ['Standard', 'Dynamic', 'Movie', 'Game'];
  final List<String> _soundLabels   = ['Standard', 'Music', 'Movie', 'Clear Voice'];
  final List<String> _inputLabels   = ['TV', 'HDMI 1', 'HDMI 2', 'HDMI 3', 'AV'];
  final List<String> _inputKeys     = ['KEY_TV', 'KEY_HDMI1', 'KEY_HDMI2', 'KEY_HDMI3', 'KEY_AV'];

  void _send(String key) {
    if (_tv.isConnected) {
      _tv.sendKey(key);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('TV not connected'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _setBrightness(int index) {
    setState(() => _brightnessIndex = index);
    switch (index) {
      case 0: _send('KEY_BRIGHTNESS_DOWN'); break;
      case 1: _send('KEY_BRIGHTNESS'); break;
      case 2: _send('KEY_BRIGHTNESS_UP'); break;
    }
    _showConfirmation('Brightness: ${['Low','Medium','High'][index]}');
  }

  void _setSleepTimer(int minutes) {
    setState(() => _sleepTimer = minutes);
    _send('KEY_SLEEP');
    if (minutes > 0) {
      int taps = minutes ~/ 30;
      for (int i = 1; i < taps; i++) {
        Future.delayed(Duration(milliseconds: 600 * i), () => _send('KEY_SLEEP'));
      }
    }
    _showConfirmation('Sleep Timer: ${minutes == 0 ? "Off" : "$minutes min"}');
  }

  void _setPictureMode(int index) {
    setState(() => _pictureIndex = index);
    _send('KEY_PICTURE_SIZE');
    _showConfirmation('Picture: ${_pictureLabels[index]}');
  }

  void _setSoundMode(int index) {
    setState(() => _soundIndex = index);
    _send('KEY_SOUND_MODE');
    _showConfirmation('Sound: ${_soundLabels[index]}');
  }

  void _setInput(int index) {
    setState(() => _inputIndex = index);
    _send(_inputKeys[index]);
    _showConfirmation('Input: ${_inputLabels[index]}');
  }

  void _showConfirmation(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 1),
        backgroundColor: AppTheme.accentCyan.withOpacity(0.9),
      ),
    );
  }

  Future<void> _launchStore() async {
    const String url = 'https://play.google.com/store/apps/details?id=com.pyramic.samsungsmarttv';
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark.withOpacity(0.97),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppTheme.accentCyan.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentCyan.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.accentCyan.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.tune, color: AppTheme.accentCyan, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Quick Settings',
                      style: TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close, color: AppTheme.accentCyan),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),
          const Divider(color: AppTheme.accentCyan, height: 1, thickness: 0.5),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Brightness ──
                  _sectionTitle(Icons.brightness_6, 'Brightness'),
                  const SizedBox(height: 10),
                  Row(children: [
                    _chip('Low',    _brightnessIndex == 0, () => _setBrightness(0)),
                    const SizedBox(width: 8),
                    _chip('Medium', _brightnessIndex == 1, () => _setBrightness(1)),
                    const SizedBox(width: 8),
                    _chip('High',   _brightnessIndex == 2, () => _setBrightness(2)),
                  ]),
                  const SizedBox(height: 20),

                  // ── Sleep Timer ──
                  _sectionTitle(Icons.timer, 'Sleep Timer'),
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    _chip('Off', _sleepTimer == 0,  () => _setSleepTimer(0)),
                    _chip('30m', _sleepTimer == 30, () => _setSleepTimer(30)),
                    _chip('60m', _sleepTimer == 60, () => _setSleepTimer(60)),
                    _chip('90m', _sleepTimer == 90, () => _setSleepTimer(90)),
                  ]),
                  if (_sleepTimer > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '⏱ TV will turn off in $_sleepTimer minutes',
                        style: TextStyle(
                          color: AppTheme.accentCyan.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // ── Picture Mode ──
                  _sectionTitle(Icons.image, 'Picture Mode'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(_pictureLabels.length, (i) =>
                      _chip(_pictureLabels[i], i == _pictureIndex, () => _setPictureMode(i)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Sound Mode ──
                  _sectionTitle(Icons.surround_sound, 'Sound Mode'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(_soundLabels.length, (i) =>
                      _chip(_soundLabels[i], i == _soundIndex, () => _setSoundMode(i)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Input Source ──
                  _sectionTitle(Icons.input, 'Input Source'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(_inputLabels.length, (i) =>
                      _chip(_inputLabels[i], i == _inputIndex, () => _setInput(i)),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: AppTheme.accentCyan, height: 1, thickness: 0.5),
                  const SizedBox(height: 16),

                  // ── Premium ──
                  _buildPremiumSection(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accentCyan, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textWhite,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.accentCyan.withOpacity(0.22)
              : AppTheme.glassWhite.withOpacity(0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppTheme.accentCyan : AppTheme.accentCyan.withOpacity(0.2),
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: isActive
              ? [BoxShadow(color: AppTheme.accentCyan.withOpacity(0.25), blurRadius: 8)]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppTheme.accentCyan : AppTheme.textGrey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumSection() {
    return GestureDetector(
      onTap: _launchStore,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.accentCyan.withOpacity(0.15),
              Colors.amber.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.amber.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, color: Colors.amber, size: 22),
                SizedBox(width: 8),
                Text(
                  'AI PREMIUM',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.auto_awesome, color: Colors.amber, size: 22),
              ],
            ),
            const SizedBox(height: 12),
            const Text('✨ Voice control your TV',
                style: TextStyle(color: AppTheme.textWhite, fontSize: 13)),
            const SizedBox(height: 4),
            const Text('🎯 Personalized show recommendations',
                style: TextStyle(color: AppTheme.textWhite, fontSize: 13)),
            const SizedBox(height: 4),
            const Text('😴 Automatic sleep timer',
                style: TextStyle(color: AppTheme.textWhite, fontSize: 13)),
            const SizedBox(height: 4),
            const Text('📊 Viewing statistics',
                style: TextStyle(color: AppTheme.textWhite, fontSize: 13)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Try Now',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward, color: Colors.black, size: 16),
                ],
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Coming soon to the store',
              style: TextStyle(
                color: AppTheme.textGrey,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
