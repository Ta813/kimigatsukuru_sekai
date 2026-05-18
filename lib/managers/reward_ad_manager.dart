// lib/managers/reward_ad_manager.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardAdManager {
  // シングルトン化
  static final RewardAdManager instance = RewardAdManager._internal();
  RewardAdManager._internal();

  RewardedAd? _rewardedAd;
  bool _isLoading = false;
  bool _hasLoadError = false;

  bool get isAdAvailable => _rewardedAd != null;
  bool get isLoading => _isLoading;
  bool get hasLoadError => _hasLoadError;

  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-2333753292729105/1101792271'
      : 'ca-app-pub-2333753292729105/5014099664';

  // 🌟 広告を裏側で読み込む（プリロード）
  void loadAd() {
    if (_isLoading || _rewardedAd != null) return;

    _isLoading = true;
    _hasLoadError = false;

    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('【Ad】リワード広告の事前読み込み完了');
          _rewardedAd = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('【Ad】リワード広告の事前読み込み失敗: $error');
          _rewardedAd = null;
          _isLoading = false;
          _hasLoadError = true;
        },
      ),
    );
  }

  // 🌟 広告を再生する
  void showAd({
    required VoidCallback onRewardEarned,
    required VoidCallback onAdClosed,
  }) {
    if (_rewardedAd == null) {
      loadAd();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        onAdClosed();
        loadAd(); // ✨ 見終わったら次のためにまた裏で読み込んでおく
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        onAdClosed();
        loadAd();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        onRewardEarned();
      },
    );
  }
}
