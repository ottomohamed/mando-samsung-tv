// lib/screens/tv_search_screen.dart
import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../models/tv_connection.dart';

class TVSearchScreen extends StatefulWidget {
  const TVSearchScreen({super.key});

  @override
  State<TVSearchScreen> createState() => _TVSearchScreenState();
}

class _TVSearchScreenState extends State<TVSearchScreen> {
  final TVConnection _tvConnection = TVConnection();
  List<Map<String, String>> _foundTVs = [];
  bool _isSearching = false;

  Future<void> _scanForTVs() async {
    setState(() {
      _isSearching = true;
      _foundTVs = [];
    });

    final tvs = await _tvConnection.scanForTVs();
    
    setState(() {
      _foundTVs = tvs;
      _isSearching = false;
    });
  }

  void _connectToTV(Map<String, String> tv) async {
    final name = tv['name']!;
    final ip = tv['ip']!;
    
    final success = await _tvConnection.connectToTV(name, ip);
    
    if (success && mounted) {
      Navigator.pop(context, true); // العودة مع نتيجة نجاح
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Find Your TV',
          style: TextStyle(color: AppTheme.textWhite),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // زر البحث
            Container(
              width: double.infinity,
              height: 50,
              margin: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                onPressed: _isSearching ? null : _scanForTVs,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentCyan,
                  foregroundColor: AppTheme.backgroundDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isSearching ? 'Scanning...' : 'Scan for TVs',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            // قائمة التلفزيونات
            Expanded(
              child: _isSearching
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: AppTheme.accentCyan,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Scanning your network...',
                            style: TextStyle(color: AppTheme.textGrey),
                          ),
                        ],
                      ),
                    )
                  : _foundTVs.isEmpty
                      ? const Center(
                          child: Text(
                            'No TVs found. Make sure your TV is on and connected to the same WiFi network.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppTheme.textGrey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _foundTVs.length,
                          itemBuilder: (context, index) {
                            final tv = _foundTVs[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.glassWhite.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.accentCyan.withOpacity(0.3),
                                ),
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.tv,
                                  color: AppTheme.accentCyan,
                                ),
                                title: Text(
                                  tv['name']!,
                                  style: const TextStyle(
                                    color: AppTheme.textWhite,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  tv['ip']!,
                                  style: const TextStyle(
                                    color: AppTheme.textGrey,
                                    fontSize: 12,
                                  ),
                                ),
                                onTap: () => _connectToTV(tv),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}