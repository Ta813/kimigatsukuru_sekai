import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
// ↓ お使いのアプリのパスに合わせてインポートしてください
import '../../managers/purchase_manager.dart';
import '../../managers/sfx_manager.dart';

class PremiumPaywallScreen extends StatefulWidget {
  const PremiumPaywallScreen({super.key});

  @override
  State<PremiumPaywallScreen> createState() => _PremiumPaywallScreenState();
}

class _PremiumPaywallScreenState extends State<PremiumPaywallScreen> {
  Package? _premiumPackage; // RevenueCatから取得する商品情報
  bool _isLoading = true; // 商品読み込み中
  bool _isPurchasing = false; // 購入処理中

  @override
  void initState() {
    super.initState();
    _fetchOfferings();
  }

  // 🌟 RevenueCatから現在のプラン（商品）を取得する
  Future<void> _fetchOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null &&
          offerings.current!.availablePackages.isNotEmpty) {
        setState(() {
          // とりあえず一番上のパッケージ（月額や年額など）を取得
          _premiumPackage = offerings.current!.availablePackages.first;
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

  // 🌟 購入ボタンが押された時の処理
  Future<void> _purchasePremium() async {
    if (_premiumPackage == null) return;

    try {
      SfxManager.instance.playTapSound();
    } catch (e) {}

    setState(() {
      _isPurchasing = true;
    });

    try {
      // RevenueCatの購入処理を呼び出す
      // 型を明示せず result として受け取る
      final result = await Purchases.purchasePackage(_premiumPackage!);

      // result.customerInfo から entitlements にアクセスする
      final customerInfo = result is CustomerInfo
          ? result
          : (result as dynamic).customerInfo;

      // 🌟 "premium" の部分は、RevenueCatのダッシュボードで設定したEntitlement IDに書き換えてください
      if (customerInfo.entitlements.all["premium"]?.isActive == true) {
        if (!mounted) return;

        // 購入成功！プレミアム状態をONにして画面を閉じる
        PurchaseManager.instance.isPremium.value = true;
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('プレミアムプランへのアップグレードが完了しました！')),
        );
      }
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      // ユーザーが購入をキャンセルした場合以外はエラーを表示
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('エラーが発生しました: ${e.message}')));
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }

  // 🌟 復元（Restore）ボタンの処理
  Future<void> _restorePurchases() async {
    setState(() {
      _isPurchasing = true;
    });
    try {
      final customerInfo = await Purchases.restorePurchases();
      // 🌟 ここもご自身の Entitlement ID に合わせる
      if (customerInfo.entitlements.all["premium"]?.isActive == true) {
        PurchaseManager.instance.isPremium.value = true;
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('購入履歴を復元しました！')));
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('復元できる購入履歴がありませんでした。')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('復元に失敗しました。')));
      }
    } finally {
      if (mounted)
        setState(() {
          _isPurchasing = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: const Text(
          'プレミアムにアップグレード',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFF7043),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'プレミアムにアップグレードして、\nお子様のワクワクを最大限に！',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // 🌟 Before / After の比較表
                        _buildComparisonTable(),
                        const SizedBox(height: 24),
                        // 復元ボタン
                        TextButton(
                          onPressed: _isPurchasing ? null : _restorePurchases,
                          child: const Text(
                            '以前購入された方の復元はこちら',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 🌟 下部に固定される購入ボタンエリア
                _buildPurchaseFooter(),
              ],
            ),
          ),
          // 処理中のローディングオーバーレイ
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

  // 🌟 Before/Afterの表を作るウィジェット
  Widget _buildComparisonTable() {
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
        columnWidths: const {
          0: FlexColumnWidth(1.0), // Beforeの幅
          1: FlexColumnWidth(1.2), // Afterの幅（少し広め）
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            children: [
              _buildTableCell('無料プラン\n(Before)', isHeader: true),
              _buildTableCell(
                'プレミアムプラン\n(After) ✨',
                isHeader: true,
                textColor: const Color(0xFFFF7043),
              ),
            ],
          ),
          TableRow(
            children: [
              _buildTableCell('広告が表示される'),
              _buildTableCell('広告完全ゼロ！\n誤タップの心配がなく安心・快適。', isHighlight: true),
            ],
          ),
          TableRow(
            children: [
              _buildTableCell('アイテムや行く世界に\n「レベル制限」がある'),
              _buildTableCell(
                'すべてのロックを解除！\n最初からアイテムも世界も遊び放題。',
                isHighlight: true,
              ),
            ],
          ),
          TableRow(
            children: [
              _buildTableCell('ルーレットの\n当たりボーナスが通常'),
              _buildTableCell(
                'ポイントボーナス5倍！\nどんどん貯まって達成感がアップ！',
                isHighlight: true,
              ),
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
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isHeader ? 14 : 13,
          fontWeight: (isHeader || isHighlight)
              ? FontWeight.bold
              : FontWeight.normal,
          color: textColor ?? Colors.black87,
          height: 1.4,
        ),
        textAlign: isHeader ? TextAlign.center : TextAlign.left,
      ),
    );
  }

  // 🌟 画面下部の購入ボタン
  Widget _buildPurchaseFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_premiumPackage != null)
              ElevatedButton(
                onPressed: _purchasePremium,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7043),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  // RevenueCatから取得した価格（例: "¥300"）を表示
                  'プレミアムにアップグレード (${_premiumPackage!.storeProduct.priceString} / ${_premiumPackage!.packageType == PackageType.annual ? "年" : "月"})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              const Text(
                '現在、商品情報を取得できません。\nインターネット接続をご確認ください。',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
