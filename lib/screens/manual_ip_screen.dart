// lib/screens/manual_ip_screen.dart
import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../models/tv_connection.dart';

class ManualIPScreen extends StatefulWidget {
  const ManualIPScreen({super.key});

  @override
  State<ManualIPScreen> createState() => _ManualIPScreenState();
}

class _ManualIPScreenState extends State<ManualIPScreen> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TVConnection _tvConnection = TVConnection();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'اتصال يدوي',
          style: TextStyle(color: AppTheme.textWhite),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'أدخل عنوان IP الخاص بالتلفاز',
              style: TextStyle(color: AppTheme.textWhite, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'يمكنك إيجاد IP التلفاز من إعدادات الشبكة في التلفاز',
              style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
            ),
            const SizedBox(height: 30),
            
            // حقل إدخال IP
            TextField(
              controller: _ipController,
              style: const TextStyle(color: AppTheme.textWhite),
              decoration: InputDecoration(
                labelText: 'عنوان IP (مثال: 192.168.1.100)',
                labelStyle: const TextStyle(color: AppTheme.textGrey),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppTheme.accentCyan.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.accentCyan),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // حقل إدخال اسم التلفاز (اختياري)
            TextField(
              controller: _nameController,
              style: const TextStyle(color: AppTheme.textWhite),
              decoration: InputDecoration(
                labelText: 'اسم التلفاز (اختياري)',
                labelStyle: const TextStyle(color: AppTheme.textGrey),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppTheme.accentCyan.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.accentCyan),
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            // زر الاتصال
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _connectManually,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentCyan,
                  foregroundColor: AppTheme.backgroundDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'اتصال',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _connectManually() async {
    String ip = _ipController.text.trim();
    if (ip.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال عنوان IP')),
      );
      return;
    }

    // التحقق البسيط من صيغة IP
    RegExp ipRegex = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$');
    if (!ipRegex.hasMatch(ip)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('صيغة IP غير صحيحة')),
      );
      return;
    }

    String name = _nameController.text.trim();
    if (name.isEmpty) name = 'Samsung TV (يدوي)';

    final success = await _tvConnection.connectManually(ip, name: name);
    
    if (success && mounted) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل الاتصال، تحقق من IP')),
      );
    }
  }
}