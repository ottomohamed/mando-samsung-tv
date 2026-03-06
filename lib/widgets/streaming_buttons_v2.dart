// lib/widgets/streaming_buttons_v2.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../themes/app_theme.dart';

// كلاس أساسي للزر الزجاجي مع إمكانية فتح رابط
class GlassButton extends StatelessWidget {
  final Color color; // لون الخدمة الأساسي
  final String? url; // رابط الاشتراك أو الموقع
  final Widget? child; // الشعار (يمكن أن يكون Text أو Icon أو أي Widget)
  final String? label; // نص بديل
  final IconData? icon; // أيقونة بديلة
  final VoidCallback? onPressed; // دالة ضغط مخصصة (إذا احتجناها)

  const GlassButton({
    super.key,
    required this.color,
    this.url,
    this.child,
    this.label,
    this.icon,
    this.onPressed,
  }) : assert(child != null || label != null || icon != null, 
         'يجب توفير child أو label أو icon');

  // دالة لفتح الرابط
  Future<void> _launchURL() async {
    if (url == null || url!.isEmpty) return;
    
    final Uri uri = Uri.parse(url!);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print('Could not launch $url');
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // تحديد المحتوى المعروض داخل الزر
    Widget content;
    if (child != null) {
      content = child!;
    } else if (label != null) {
      content = Text(
        label!,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      );
    } else {
      content = Icon(
        icon,
        color: Colors.white,
        size: 30,
      );
    }

    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed ?? _launchURL,
          borderRadius: BorderRadius.circular(32.5),
          child: Stack(
            children: [
              // الإطار المتوهج السماوي
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.accentCyan.withOpacity(0.6),
                    width: 1.8,
                  ),
                ),
              ),
              
              // التأثير الزجاجي
              ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withOpacity(0.15),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.3),
                          color.withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: Center(child: content),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// زر Netflix مع شعار N باللون الأحمر
class NetflixButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? url;
  const NetflixButton({super.key, this.onPressed, this.url});

  @override
  Widget build(BuildContext context) {
    return GlassButton(
      color: const Color(0xFFE50914), // أحمر Netflix
      onPressed: onPressed,
      url: url ?? 'https://www.netflix.com/signup',
      child: const Text(
        'N',
        style: TextStyle(
          color: Color(0xFFE50914), // النص باللون الأحمر
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
    );
  }
}

// زر YouTube مع شعار مثلث التشغيل
class YouTubeButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? url;
  const YouTubeButton({super.key, this.onPressed, this.url});

  @override
  Widget build(BuildContext context) {
    return GlassButton(
      color: const Color(0xFFFF0000),
      onPressed: onPressed,
      url: url ?? 'https://www.youtube.com/premium',
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 32,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const Icon(
            Icons.play_arrow_rounded,
            color: Color(0xFFFF0000),
            size: 20,
          ),
        ],
      ),
    );
  }
}

// زر Prime Video مع شعار "Prime"
class PrimeVideoButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? url;
  const PrimeVideoButton({super.key, this.onPressed, this.url});

  @override
  Widget build(BuildContext context) {
    return GlassButton(
      color: const Color(0xFF00A8E1),
      onPressed: onPressed,
      url: url ?? 'https://www.primevideo.com/',
      child: const Text(
        'Prime',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

// زر Disney+ مع شعار "D+"
class DisneyPlusButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? url;
  const DisneyPlusButton({super.key, this.onPressed, this.url});

  @override
  Widget build(BuildContext context) {
    return GlassButton(
      color: const Color(0xFF113CCF),
      onPressed: onPressed,
      url: url ?? 'https://www.disneyplus.com/',
      child: const Text(
        'D+',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}