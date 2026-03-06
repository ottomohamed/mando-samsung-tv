// lib/models/ad_manager.dart
import 'dart:io';
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
  String get _bannerAdUnitId => 'ca-app-pub-6500154299593172/1589134287';
  String get _interstitialAdUnitId => 'ca-app-pub-6500154299593172/4291173456';
  String get _rewardedAdUnitId => 'ca-app-pub-6500154299593172/2597596640';

  // تهيئة AdMob
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    print('✅ AdMob initialized');
    
    // تحميل جميع الإعلانات
    loadBannerAd();
    loadInterstitialAd();
    loadRewardedAd();
  }

  // تحميل Banner Ad
  void loadBannerAd() {
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
  }

  // تحميل Interstitial Ad
  void loadInterstitialAd() {
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
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('❌ InterstitialAd failed: $error');
          _isInterstitialAdLoaded = false;
        },
      ),
    );
  }

  // تحميل Rewarded Ad
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          print('✅ RewardedAd loaded');
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
          
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              print('RewardedAd dismissed');
              ad.dispose();
              _rewardedAd = null;
              _isRewardedAdLoaded = false;
              loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('❌ RewardedAd failed: $error');
          _isRewardedAdLoaded = false;
        },
      ),
    );
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

  // عرض Rewarded Ad
  void showRewardedAd() {
    if (_rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          print('🏆 User earned reward: ${reward.amount} ${reward.type}');
        },
      );
      _isRewardedAdLoaded = false;
    } else {
      print('RewardedAd not ready');
      loadRewardedAd();
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