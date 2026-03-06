// lib/widgets/quick_menu.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../themes/app_theme.dart';

class QuickMenu extends StatelessWidget {
  final VoidCallback onClose;
  
  const QuickMenu({super.key, required this.onClose});

  Future<void> _launchStore() async {
    // TODO: Replace with your actual app store URL when available
    const String appStoreUrl = 'https://play.google.com/store/apps/details?id=com.yourcompany.mando_premium';
    final Uri uri = Uri.parse(appStoreUrl);
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print('Could not launch store');
      }
    } catch (e) {
      print('Error launching store: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: AppTheme.accentCyan.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fixed header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quick Settings',
                  style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: AppTheme.accentCyan),
                  onPressed: onClose,
                ),
              ],
            ),
          ),
          const Divider(color: AppTheme.accentCyan, height: 1),
          
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Regular options
                  ListTile(
                    leading: Icon(Icons.brightness_6, color: AppTheme.accentCyan),
                    title: const Text('Brightness', style: TextStyle(color: AppTheme.textWhite)),
                    subtitle: const Text('Adjust screen brightness', style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right, color: AppTheme.accentCyan),
                    onTap: () {
                      // TODO: Open brightness settings
                      onClose();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.timer, color: AppTheme.accentCyan),
                    title: const Text('Sleep Timer', style: TextStyle(color: AppTheme.textWhite)),
                    subtitle: const Text('Turn off TV after 30/60/90 min', style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right, color: AppTheme.accentCyan),
                    onTap: () {
                      // TODO: Open sleep timer
                      onClose();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.image, color: AppTheme.accentCyan),
                    title: const Text('Picture Mode', style: TextStyle(color: AppTheme.textWhite)),
                    subtitle: const Text('Standard / Dynamic / Movie', style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right, color: AppTheme.accentCyan),
                    onTap: () {
                      // TODO: Open picture settings
                      onClose();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.surround_sound, color: AppTheme.accentCyan),
                    title: const Text('Sound Effects', style: TextStyle(color: AppTheme.textWhite)),
                    subtitle: const Text('Enable/Disable audio enhancements', style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right, color: AppTheme.accentCyan),
                    onTap: () {
                      // TODO: Open sound settings
                      onClose();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.input, color: AppTheme.accentCyan),
                    title: const Text('Input Source', style: TextStyle(color: AppTheme.textWhite)),
                    subtitle: const Text('HDMI1 / HDMI2 / AV', style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right, color: AppTheme.accentCyan),
                    onTap: () {
                      // TODO: Open input selection
                      onClose();
                    },
                  ),
                  
                  const Divider(color: AppTheme.accentCyan, height: 20),
                  
                  // Premium app section - now in English
                  InkWell(
                    onTap: _launchStore,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.accentCyan.withOpacity(0.2),
                            Colors.amber.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // Icons and title
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.auto_awesome, color: Colors.amber, size: 24),
                              const SizedBox(width: 8),
                              const Text(
                                'AI PREMIUM',
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.auto_awesome, color: Colors.amber, size: 24),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Premium features
                          const Text(
                            '✨ Voice control your TV',
                            style: TextStyle(color: AppTheme.textWhite, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '🎯 Personalized show recommendations',
                            style: TextStyle(color: AppTheme.textWhite, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '😴 Automatic sleep timer',
                            style: TextStyle(color: AppTheme.textWhite, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '📊 Viewing statistics',
                            style: TextStyle(color: AppTheme.textWhite, fontSize: 14),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // CTA Button
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Try Now',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, color: Colors.black, size: 16),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Coming soon note
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
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}