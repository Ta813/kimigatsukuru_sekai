import 'dart:async'; // 🌟 追加: タイマー用
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../managers/purchase_manager.dart';
import '../../managers/sfx_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../../helpers/shared_prefs_helper.dart'; // 🌟 追加: 時間判定用

class PremiumPaywallScreen extends StatefulWidget {
  const PremiumPaywallScreen({super.key});

  @override
  State<PremiumPaywallScreen> createState() => _PremiumPaywallScreenState();
}

class _PremiumPaywallScreenState extends State<PremiumPaywallScreen> {
  List<Package> _packages = [];
  Package? _selectedPackage;

  bool _isLoading = true;
  bool _isPurchasing = false;

  final Color _primaryColor = const Color(0xFF8678F9);

  // 🌟 追加: セールのカウントダウンと、通常価格を保持するための変数
  Duration? _saleRemainingTime;
  Timer? _countdownTimer;
  Offering? _regularOffering;

  @override
  void initState() {
    super.initState();
    _startCountdownIfEligible();
    _fetchOfferings();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel(); // タイマーの破棄
    super.dispose();
  }

  // 🌟 追加: 24時間以内かチェックし、タイマーを動かす
  Future<void> _startCountdownIfEligible() async {
    final remaining = await SharedPrefsHelper.getTimeUntilAnySaleEnds();
    if (remaining != null && mounted) {
      setState(() {
        _saleRemainingTime = remaining;
      });
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        setState(() {
          final newRemaining = _saleRemainingTime! - const Duration(seconds: 1);
          if (newRemaining.isNegative) {
            _saleRemainingTime = null;
            timer.cancel();
            _fetchOfferings(); // セールが終わったら通常プランを再取得して画面を更新
          } else {
            _saleRemainingTime = newRemaining;
          }
        });
      });
    }
  }

  // 🌟 変更: セール中なら 'first_launch_sale' を取得し、通常価格も保持する
  Future<void> _fetchOfferings() async {
    setState(() => _isLoading = true);
    try {
      final offerings = await Purchases.getOfferings();

      // デフォルト（通常価格）を保持しておく
      _regularOffering = offerings.current;
      Offering? targetOffering = offerings.current;

      // 24時間セール中で、かつ RevenueCat 側に 'first_launch_sale' がある場合
      if (_saleRemainingTime != null &&
          offerings.all.containsKey('first_launch_sale')) {
        targetOffering = offerings.all['first_launch_sale'];
      }

      if (targetOffering != null &&
          targetOffering.availablePackages.isNotEmpty) {
        if (mounted) {
          setState(() {
            _packages = targetOffering!.availablePackages;
            _selectedPackage = _packages.firstWhere(
              (p) => p.packageType == PackageType.annual,
              orElse: () => _packages.first,
            );
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _purchasePremium() async {
    FirebaseAnalytics.instance.logEvent(name: 'premium_purchase');
    if (_selectedPackage == null) return;

    final l10n = AppLocalizations.of(context)!;

    try {
      SfxManager.instance.playTapSound();
    } catch (e) {}

    setState(() {
      _isPurchasing = true;
    });

    try {
      if (Platform.isAndroid) {
        debugPrint('Applying transition delay before purchasePackage...');
        await Future.delayed(const Duration(milliseconds: 500));
      }

      debugPrint('Calling Purchases.purchasePackage()...');
      final result = await Purchases.purchasePackage(_selectedPackage!);
      final customerInfo = result is CustomerInfo
          ? result
          : (result as dynamic).customerInfo;

      if (customerInfo.entitlements.active.containsKey(
        "KimigatsukuruSekai Premium",
      )) {
        if (!mounted) return;

        PurchaseManager.instance.isPremium.value = true;
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.paywallUpgradeSuccess)));
      }
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.paywallError(e.message ?? 'Unknown'))),
          );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.paywallError(e.toString()))),
        );
    } finally {
      if (mounted)
        setState(() {
          _isPurchasing = false;
        });
    }
  }

  Future<void> _restorePurchases() async {
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isPurchasing = true;
    });
    try {
      final result = await Purchases.restorePurchases();
      final customerInfo = result;

      if (customerInfo.entitlements.active.containsKey(
        "KimigatsukuruSekai Premium",
      )) {
        PurchaseManager.instance.isPremium.value = true;
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.paywallRestoreSuccess)));
      } else {
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.paywallRestoreEmpty)));
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.paywallRestoreFailed)));
    } finally {
      if (mounted)
        setState(() {
          _isPurchasing = false;
        });
    }
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.pageOpenError),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.pageOpenError)),
        );
      }
    }
  }

  // 🌟 追加: カウントダウンを読みやすい文字列にするヘルパー
  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String hours = twoDigits(d.inHours);
    String minutes = twoDigits(d.inMinutes.remainder(60));
    String seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours: $minutes: $seconds";
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: OrientationBuilder(
        builder: (context, orientation) {
          bool isLandscape = orientation == Orientation.landscape;

          if (isLandscape) {
            return _buildLandscapeLayout(l10n);
          } else {
            return _buildPortraitLayout(l10n);
          }
        },
      ),
    );
  }

  // 🌟 追加: セール中のカウントダウンバッジUI
  Widget _buildCountdownBadge() {
    if (_saleRemainingTime == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Text(
        AppLocalizations.of(
          context,
        )!.paywallSaleCountdown(_formatDuration(_saleRemainingTime!)),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildLandscapeLayout(AppLocalizations l10n) {
    return Stack(
      children: [
        SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 左側：説明テキストと表
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    left: 32.0,
                    right: 32.0,
                    top: 48.0,
                    bottom: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildCountdownBadge(), // 🌟 追加: カウントダウン
                      Text(
                        l10n.paywallTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/character_ouji.gif', // 💡 王子様の画像名に合わせてください
                            height: 60,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l10n.paywallSubtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Image.asset(
                            'assets/images/character_hime.gif', // 💡 お姫様の画像名に合わせてください
                            height: 60,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildComparisonTable(l10n),
                    ],
                  ),
                ),
              ),

              // 右側：プラン選択と購入ボタン
              Expanded(
                flex: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(-5, 0),
                      ),
                    ],
                  ),
                  child: _buildRightSidePanel(l10n),
                ),
              ),
            ],
          ),
        ),
        _buildCloseButton(),
        if (_isPurchasing) _buildLoadingOverlay(),
      ],
    );
  }

  Widget _buildPortraitLayout(AppLocalizations l10n) {
    return Stack(
      children: [
        SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      _buildCountdownBadge(), // 🌟 追加: カウントダウン
                      Text(
                        l10n.paywallTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/character_ouji.gif', // 💡 王子様の画像名に合わせてください
                            height: 60,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l10n.paywallSubtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Image.asset(
                            'assets/images/character_hime.gif', // 💡 お姫様の画像名に合わせてください
                            height: 60,
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      const SizedBox(height: 24),
                      _buildComparisonTable(l10n),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: _buildRightSidePanel(l10n),
                ),
              ],
            ),
          ),
        ),
        _buildCloseButton(),
        if (_isPurchasing) _buildLoadingOverlay(),
      ],
    );
  }

  Widget _buildCloseButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.black87),
            onPressed: () {
              FirebaseAnalytics.instance.logEvent(name: 'premium_close');
              try {
                SfxManager.instance.playTapSound();
              } catch (e) {}
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.4),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  // Before/After表のUI
  Widget _buildComparisonTable(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Table(
        border: TableBorder.symmetric(
          inside: BorderSide(color: Colors.grey.shade300),
        ),
        columnWidths: const {0: FlexColumnWidth(1.0), 1: FlexColumnWidth(1.2)},
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            children: [
              _buildTableCell(l10n.paywallFreePlan, isHeader: true),
              _buildTableCell(
                l10n.paywallPremiumPlan,
                isHeader: true,
                textColor: const Color(0xFFFF7043),
              ),
            ],
          ),
          TableRow(
            children: [
              _buildTableCell(l10n.paywallAdBefore),
              _buildTableCell(l10n.paywallAdAfter, isHighlight: true),
            ],
          ),
          TableRow(
            children: [
              _buildTableCell(l10n.paywallLimitBefore),
              _buildTableCell(l10n.paywallLimitAfter, isHighlight: true),
            ],
          ),
          TableRow(
            children: [
              _buildTableCell(l10n.paywallBonusBefore),
              _buildTableCell(l10n.paywallBonusAfter, isHighlight: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    bool isHighlight = false,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(7.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isHeader ? 18 : 13,
          fontWeight: (isHeader || isHighlight)
              ? FontWeight.bold
              : FontWeight.normal,
          color: textColor ?? Colors.black87,
          height: 1.0,
        ),
        textAlign: isHeader ? TextAlign.center : TextAlign.left,
      ),
    );
  }

  // 右側に配置するパネル
  Widget _buildRightSidePanel(AppLocalizations l10n) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_packages.isNotEmpty) ...[
              Text(
                l10n.paywallSelectPlan,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              ..._packages.map((package) => _buildPackageCard(package, l10n)),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: (_selectedPackage != null && !_isPurchasing)
                    ? _purchasePremium
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n.paywallContinue,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: _isPurchasing ? null : _restorePurchases,
                    child: Text(
                      l10n.paywallRestoreLink,
                      style: const TextStyle(
                        fontSize: 8,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      try {
                        SfxManager.instance.playTapSound();
                      } catch (e) {}
                      final isJapanese = l10n.localeName.startsWith('ja');
                      final url = isJapanese
                          ? 'https://www.koto-app.com/home-ja/kimigatsukuru_sekai/terms'
                          : 'https://www.koto-app.com/home-en/kimigatsukuru_sekai/terms';
                      _launchURL(url);
                    },
                    child: Text(
                      l10n.paywallTermsLink,
                      style: const TextStyle(
                        fontSize: 8,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      try {
                        SfxManager.instance.playTapSound();
                      } catch (e) {}
                      final isJapanese = l10n.localeName.startsWith('ja');
                      final url = isJapanese
                          ? 'https://www.koto-app.com/home-ja/kimigatsukuru_sekai/privacy'
                          : 'https://www.koto-app.com/home-en/kimigatsukuru_sekai/privacy';
                      _launchURL(url);
                    },
                    child: Text(
                      l10n.paywallPrivacyLink,
                      style: const TextStyle(
                        fontSize: 8,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ] else
              Text(
                l10n.paywallFetchError,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, height: 1.5),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCard(Package package, AppLocalizations l10n) {
    final isSelected = _selectedPackage?.identifier == package.identifier;
    String title = '';
    String? subText;
    String priceString = package.storeProduct.priceString;
    String? originalPriceString; // 🌟 追加: 元の価格（取り消し線用）

    // 🌟 セール中の場合、デフォルトのOfferingから同じタイプのパッケージを探して「元の価格」を取得
    if (_saleRemainingTime != null && _regularOffering != null) {
      try {
        final regularPkg = _regularOffering!.availablePackages.firstWhere(
          (p) => p.packageType == package.packageType,
        );
        originalPriceString = regularPkg.storeProduct.priceString;
      } catch (e) {
        // 見つからなければ無視
      }
    }

    if (package.packageType == PackageType.monthly) {
      title = l10n.paywallPlanMonthly;
      priceString = '$priceString${l10n.paywallPerMonth}';
      if (originalPriceString != null) {
        originalPriceString = '$originalPriceString${l10n.paywallPerMonth}';
      }
    } else if (package.packageType == PackageType.annual) {
      title = l10n.paywallPlanAnnual;
      priceString = '$priceString${l10n.paywallPerYear}';
      if (originalPriceString != null) {
        originalPriceString = '$originalPriceString${l10n.paywallPerYear}';
      }

      String currencySymbol = package.storeProduct.priceString
          .replaceAll(RegExp(r'[0-9.,]'), '')
          .trim();
      if (currencySymbol.isEmpty)
        currencySymbol = package.storeProduct.currencyCode;
      double monthlyPrice = package.storeProduct.price / 12;

      subText = l10n.paywallJustPerMonth(
        '$currencySymbol${monthlyPrice.toStringAsFixed(0)}',
      );
    } else if (package.packageType == PackageType.lifetime) {
      title = l10n.paywallPlanLifetime;
    } else {
      title = package.packageType.toString().split('.').last;
    }

    return GestureDetector(
      onTap: () {
        try {
          SfxManager.instance.playTapSound();
        } catch (e) {}
        setState(() {
          _selectedPackage = package;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? _primaryColor : Colors.grey.shade300,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (subText != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subText,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
            // 🌟 変更: 価格表示部分（元の価格があれば赤字＆取り消し線で併記）
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (originalPriceString != null &&
                    originalPriceString != priceString)
                  Text(
                    originalPriceString,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: Colors.redAccent,
                      decorationThickness: 2,
                    ),
                  ),
                Text(
                  priceString,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
