// lib/widgets/ad_banner.dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  final adUnitId = 'ca-app-pub-2333753292729105/1224734484';

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
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
    return Padding(
      // ★Paddingウィジェットで囲む
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        // ★常にContainerを返す
        alignment: Alignment.center,
        // ★最初から標準バナー広告のサイズ分の領域を確保する
        width: AdSize.banner.width.toDouble(),
        height: AdSize.banner.height.toDouble(),
        // 中身を、広告が読み込み済みかどうかで切り替える
        child: _isLoaded && _bannerAd != null
            ? AdWidget(ad: _bannerAd!) // ★読み込みが終わったら、広告を表示
            : null, // 読み込み中は、中身は空（スペースだけ確保されている状態）
      ),
    );
  }
}
