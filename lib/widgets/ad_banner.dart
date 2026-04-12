// lib/widgets/ad_banner.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
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

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2333753292729105/1224734484'; // ← AndroidのバナーID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-2333753292729105/2061719105'; // ← iOSのバナーID
    } else {
      throw UnsupportedError('Unsupported platform');
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

    // if (!Platform.isAndroid) {
    //   return;
    // }

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
          return const Padding(
            padding: EdgeInsets.only(top: 16.0),
            child: SizedBox(height: 50),
          );
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
