// lib/widgets/ad_banner.dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../managers/purchase_manager.dart';

class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  String get bannerAdUnitId {
    if (kDebugMode) {
      // Google公式のテスト用バナーID
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-3940256099942544/2934735716';
    } else {
      // 🚀 ここにご自身の本番用バナー広告IDを入れてください
      return Platform.isAndroid
          ? 'ca-app-pub-2333753292729105/1224734484' // Android本番用
          : 'ca-app-pub-2333753292729105/2061719105'; // iOS本番用
    }
  }

  void _loadAd() async {
    // プレミアム会員の場合は広告を読み込まない
    if (PurchaseManager.instance.isPremium.value) {
      return;
    }
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // オフラインなら何もしない
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: PurchaseManager.instance.isPremium,
      builder: (context, isPremium, child) {
        if (isPremium) {
          // プレミアム会員の場合は高さを0にして何も表示しない
          return const SizedBox.shrink();
        }

        if (kDebugMode) {
          return const SizedBox(height: 50);
        }

        return Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Container(
            alignment: Alignment.center,
            width: AdSize.banner.width.toDouble(),
            height: AdSize.banner.height.toDouble(),
            child: _isLoaded && _bannerAd != null
                ? AdWidget(ad: _bannerAd!)
                : null,
          ),
        );
      },
    );
  }
}
