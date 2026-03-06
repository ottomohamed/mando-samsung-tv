import 'package:flutter/material.dart';
import 'themes/app_theme.dart';
import 'screens/remote_screen_web.dart';
import 'models/ad_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // لا نحدد الاتجاه - التطبيق سيدعم العمودي والأفقي تلقائياً
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
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppTheme.backgroundDark,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppTheme.textWhite),
          bodyMedium: TextStyle(color: AppTheme.textGrey),
        ),
      ),
      home: const RemoteScreenWeb(),
    );
  }
}