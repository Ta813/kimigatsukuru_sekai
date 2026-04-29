import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../managers/purchase_manager.dart';
import '../../managers/sfx_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart'; // 🌟 追加: ローカライズのインポート

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

  @override
  void initState() {
    super.initState();
    _fetchOfferings();
  }

  Future<void> _fetchOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null &&
          offerings.current!.availablePackages.isNotEmpty) {
        setState(() {
          _packages = offerings.current!.availablePackages;
          _selectedPackage = _packages.firstWhere(
            (p) => p.packageType == PackageType.annual,
            orElse: () => _packages.first,
          );
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _purchasePremium() async {
    if (_selectedPackage == null) return;

    // 🌟 処理開始時にローカライズオブジェクトを取得
    final l10n = AppLocalizations.of(context)!;

    try {
      SfxManager.instance.playTapSound();
    } catch (e) {}

    setState(() {
      _isPurchasing = true;
    });

    try {
      final result = await Purchases.purchasePackage(_selectedPackage!);
      final customerInfo = result is CustomerInfo
          ? result
          : (result as dynamic).customerInfo;

      if (customerInfo.entitlements.active.containsKey("premium")) {
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
    // 🌟 処理開始時にローカライズオブジェクトを取得
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isPurchasing = true;
    });
    try {
      final result = await Purchases.restorePurchases();
      final customerInfo = result is CustomerInfo
          ? result
          : (result as dynamic).customerInfo;

      if (customerInfo.entitlements.active.containsKey("premium")) {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ==============================
                // 🌟 左側：説明テキストと表
                // ==============================
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
                        Text(
                          l10n.paywallSubtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildComparisonTable(l10n),
                      ],
                    ),
                  ),
                ),

                // ==============================
                // 🌟 右側：プラン選択と購入ボタン
                // ==============================
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

          // ==============================
          // 🌟 左上の×ボタン
          // ==============================
          SafeArea(
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
                    try {
                      SfxManager.instance.playTapSound();
                    } catch (e) {}
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),

          // ローディングオーバーレイ
          if (_isPurchasing)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
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
          fontSize: isHeader ? 15 : 10,
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
        padding: const EdgeInsets.all(24.0),
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
                        fontSize: 9,
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
                          ? 'https://www.koto-app.com/home-ja/kimigatsukuru_sekai/terms' // 🇯🇵 日本語の利用規約URL
                          : 'https://www.koto-app.com/home-en/kimigatsukuru_sekai/terms'; // 🇺🇸 その他の利用規約URL
                      _launchURL(url);
                    },
                    child: Text(
                      l10n.paywallTermsLink,
                      style: const TextStyle(
                        fontSize: 9,
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
                          ? 'https://www.koto-app.com/home-ja/kimigatsukuru_sekai/privacy' // 🇯🇵 日本語のプライバシーポリシーURL
                          : 'https://www.koto-app.com/home-en/kimigatsukuru_sekai/privacy'; // 🇺🇸 その他のプライバシーポリシーURL
                      _launchURL(url);
                    },
                    child: Text(
                      l10n.paywallPrivacyLink,
                      style: const TextStyle(
                        fontSize: 9,
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

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication); // 外部ブラウザで開く
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('ページを開けませんでした')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ページを開けませんでした')));
      }
    }
  }

  Widget _buildPackageCard(Package package, AppLocalizations l10n) {
    final isSelected = _selectedPackage?.identifier == package.identifier;
    String title = '';
    String? subText;
    String priceString = package.storeProduct.priceString;

    if (package.packageType == PackageType.monthly) {
      title = l10n.paywallPlanMonthly;
      priceString = '$priceString${l10n.paywallPerMonth}';
    } else if (package.packageType == PackageType.annual) {
      title = l10n.paywallPlanAnnual;
      priceString = '$priceString${l10n.paywallPerYear}';

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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
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
            Text(
              priceString,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
