import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'themes/app_theme.dart';
import 'screens/remote_screen_tablet.dart';
import 'models/ad_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ دعم كامل لكل الاتجاهات - مطلوب من المتجر
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // شريط الحالة شفاف يتناسب مع التصميم الداكن
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  final adManager = AdManager();
  await adManager.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Samsung Smart TV Remote',
      debugShowCheckedModeBanner: false,

      // ✅ دعم كامل للغات بما فيها العربية
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
        // ✅ Snackbar يتناسب مع التصميم
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppTheme.backgroundDark.withOpacity(0.95),
          contentTextStyle: const TextStyle(color: AppTheme.textWhite),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppTheme.accentCyan.withOpacity(0.4)),
          ),
          behavior: SnackBarBehavior.floating,
        ),
        // ✅ ElevatedButton افتراضي
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

      // ✅ RemoteScreenTablet يدعم الهاتف والتابليت والأفقي والعمودي
      home: const RemoteScreenTablet(),
    );
  }
}
