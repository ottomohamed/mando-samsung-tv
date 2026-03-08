import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const MyApp());
  }, (error, stack) {
    runApp(ErrorApp(error: error.toString(), stack: stack.toString()));
  });
}

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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Text('❌ CRASH ERROR:',
                style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(error,
                style: const TextStyle(color: Colors.white, fontSize: 14)),
              const SizedBox(height: 20),
              Text(stack.length > 2000 ? stack.substring(0, 2000) : stack,
                style: const TextStyle(color: Colors.grey, fontSize: 11)),
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
      title: 'Samsung Remote',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF0A0E1A),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.tv, color: Color(0xFF00E5FF), size: 80),
              SizedBox(height: 20),
              Text(
                'Samsung TV Remote',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '✅ App launched successfully!',
                style: TextStyle(color: Color(0xFF00E5FF), fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
