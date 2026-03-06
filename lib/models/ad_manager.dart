// lib/models/ad_manager.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  // الإعلانات
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  
  // حالة التحميل
  bool _isBannerAdLoaded = false;
  bool _isInterstitialAdLoaded = false;
  bool _isRewardedAdLoaded = false;

  // Getters
  BannerAd? get bannerAd => _bannerAd;
  InterstitialAd? get interstitialAd => _interstitialAd;
  RewardedAd? get rewardedAd => _rewardedAd;
  
  bool get isBannerAdLoaded => _isBannerAdLoaded;
  bool get isInterstitialAdLoaded => _isInterstitialAdLoaded;
  bool get isRewardedAdLoaded => _isRewardedAdLoaded;

  // أكواد الإعلانات من حسابك
  String get _bannerAdUnitId {
    if (kIsWeb) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test Ad for Web
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-6500154299593172/1589134287'; // Android Banner
    } else if (Platform.isIOS) {
      return 'ca-app-pub-6500154299593172/1589134287'; // iOS Banner
    } else {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test Ad for other platforms
    }
  }

  String get _interstitialAdUnitId {
    if (kIsWeb) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test Ad for Web
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-6500154299593172/4291173456'; // Android Interstitial
    } else if (Platform.isIOS) {
      return 'ca-app-pub-6500154299593172/4291173456'; // iOS Interstitial
    } else {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test Ad for other platforms
    }
  }

  // تهيئة AdMob
  Future<void> initialize() async {
    print('📢 Initializing AdManager...');
    
    if (kIsWeb) {
      print('🌐 Web platform detected - using test ads');
      // على الويب، نجرب تحميل الإعلانات لكن نتوقع أخطاء
      try {
        loadBannerAd();
        loadInterstitialAd();
      } catch (e) {
        print('⚠️ Web ads not fully supported: $e');
      }
    } else if (Platform.isAndroid || Platform.isIOS) {
      try {
        await MobileAds.instance.initialize();
        print('✅ AdMob initialized on mobile');
        loadBannerAd();
        loadInterstitialAd();
      } catch (e) {
        print('❌ Failed to initialize AdMob: $e');
      }
    } else {
      print('ℹ️ Ads disabled on this platform');
    }
  }

  // تحميل Banner Ad
  void loadBannerAd() {
    try {
      _bannerAd = BannerAd(
        adUnitId: _bannerAdUnitId,
        request: const AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            print('✅ BannerAd loaded');
            _isBannerAdLoaded = true;
          },
          onAdFailedToLoad: (ad, error) {
            print('❌ BannerAd failed: $error');
            ad.dispose();
            _isBannerAdLoaded = false;
          },
          onAdOpened: (ad) => print('BannerAd opened'),
          onAdClosed: (ad) => print('BannerAd closed'),
        ),
      )..load();
    } catch (e) {
      print('⚠️ Error loading banner ad: $e');
    }
  }

  // تحميل Interstitial Ad
  void loadInterstitialAd() {
    try {
      InterstitialAd.load(
        adUnitId: _interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            print('✅ InterstitialAd loaded');
            _interstitialAd = ad;
            _isInterstitialAdLoaded = true;
            
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                print('InterstitialAd dismissed');
                ad.dispose();
                _interstitialAd = null;
                _isInterstitialAdLoaded = false;
                loadInterstitialAd(); // تحميل إعلان جديد
              },
            );
          },
          onAdFailedToLoad: (error) {
            print('❌ InterstitialAd failed: $error');
            _isInterstitialAdLoaded = false;
          },
        ),
      );
    } catch (e) {
      print('⚠️ Error loading interstitial ad: $e');
    }
  }

  // عرض Interstitial Ad
  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _isInterstitialAdLoaded = false;
    } else {
      print('InterstitialAd not ready');
      loadInterstitialAd();
    }
  }

  // التخلص من الإعلانات
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    
    _bannerAd = null;
    _interstitialAd = null;
    _rewardedAd = null;
    
    _isBannerAdLoaded = false;
    _isInterstitialAdLoaded = false;
    _isRewardedAdLoaded = false;
  }
}