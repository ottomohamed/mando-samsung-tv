import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'themes/app_theme.dart';
import 'screens/remote_screen_tablet.dart';
import 'models/ad_manager.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    try {
      final adManager = AdManager();
      await adManager.initialize();
    } catch (e) {
      debugPrint('AdManager error: $e');
    }

    runApp(const MyApp());

  }, (error, stack) {
    runApp(ErrorApp(error: error.toString(), stack: stack.toString()));
  });
}

// شاشة عرض الخطأ بدل الـ crash
class ErrorApp extends StatelessWidget {
  final String error;
  final String stack;
  const ErrorApp({super.key, required this.error, required this.stack});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              const Text(
                '❌ App Error',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.5)),
                ),
                child: Text(
                  error,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Stack trace:',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Text(
                stack.length > 1500 ? stack.substring(0, 1500) : stack,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Samsung Smart TV Remote',
      debugShowCheckedModeBanner: false,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ar', 'SA'),
        Locale('es', 'ES'),
      ],
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppTheme.backgroundDark,
        colorScheme: const ColorScheme.dark(
          primary: AppTheme.accentCyan,
          secondary: AppTheme.accentTeal,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppTheme.textWhite),
          bodyMedium: TextStyle(color: AppTheme.textGrey),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppTheme.backgroundDark.withOpacity(0.95),
          contentTextStyle: const TextStyle(color: AppTheme.textWhite),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppTheme.accentCyan.withOpacity(0.4)),
          ),
          behavior: SnackBarBehavior.floating,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentCyan,
            foregroundColor: AppTheme.backgroundDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
      home: const RemoteScreenTablet(),
    );
  }
}
