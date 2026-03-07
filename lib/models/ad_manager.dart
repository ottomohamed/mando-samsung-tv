// lib/models/ad_manager.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, VoidCallback;
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;

  bool _isBannerAdLoaded = false;
  bool _isInterstitialAdLoaded = false;

  // ✅ Callback لتحديث الـ UI عند تحميل البانر
  VoidCallback? onBannerLoaded;

  BannerAd? get bannerAd            => _bannerAd;
  bool get isBannerAdLoaded         => _isBannerAdLoaded;
  bool get isInterstitialAdLoaded   => _isInterstitialAdLoaded;

  // ─── Ad Unit IDs ───
  String get _bannerAdUnitId {
    if (Platform.isAndroid) return 'ca-app-pub-6500154299593172/1589134287';
    if (Platform.isIOS)     return 'ca-app-pub-6500154299593172/1589134287';
    return 'ca-app-pub-3940256099942544/6300978111'; // test fallback
  }

  String get _interstitialAdUnitId {
    if (Platform.isAndroid) return 'ca-app-pub-6500154299593172/4291173456';
    if (Platform.isIOS)     return 'ca-app-pub-6500154299593172/4291173456';
    return 'ca-app-pub-3940256099942544/1033173712'; // test fallback
  }

  // ─── تهيئة AdMob ───
  Future<void> initialize() async {
    // ✅ الإعلانات لا تعمل على الويب - تجاهل بهدوء
    if (kIsWeb) {
      print('ℹ️ Ads disabled on Web');
      return;
    }

    if (!Platform.isAndroid && !Platform.isIOS) {
      print('ℹ️ Ads disabled on this platform');
      return;
    }

    try {
      await MobileAds.instance.initialize();
      print('✅ AdMob initialized');
      loadBannerAd();
      loadInterstitialAd();
    } catch (e) {
      print('❌ AdMob init failed: $e');
    }
  }

  // ─── Banner Ad ───
  void loadBannerAd() {
    if (kIsWeb) return;
    try {
      _bannerAd = BannerAd(
        adUnitId: _bannerAdUnitId,
        request: const AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            print('✅ BannerAd loaded');
            _isBannerAdLoaded = true;
            onBannerLoaded?.call(); // ✅ يُبلغ الـ UI لعمل setState
          },
          onAdFailedToLoad: (ad, error) {
            print('❌ BannerAd failed: $error');
            ad.dispose();
            _isBannerAdLoaded = false;
          },
        ),
      )..load();
    } catch (e) {
      print('⚠️ Error loading banner: $e');
    }
  }

  // ─── Interstitial Ad ───
  void loadInterstitialAd() {
    if (kIsWeb) return;
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
                ad.dispose();
                _interstitialAd = null;
                _isInterstitialAdLoaded = false;
                loadInterstitialAd(); // تحميل إعلان جديد تلقائياً
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                print('❌ Interstitial show failed: $error');
                ad.dispose();
                _interstitialAd = null;
                _isInterstitialAdLoaded = false;
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
      print('⚠️ Error loading interstitial: $e');
    }
  }

  // ─── عرض الإعلان البيني ───
  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      print('ℹ️ InterstitialAd not ready yet');
      loadInterstitialAd(); // ابدأ تحميل للمرة القادمة
    }
  }

  // ─── تنظيف ───
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _bannerAd = null;
    _interstitialAd = null;
    _isBannerAdLoaded = false;
    _isInterstitialAdLoaded = false;
    onBannerLoaded = null;
  }
}
