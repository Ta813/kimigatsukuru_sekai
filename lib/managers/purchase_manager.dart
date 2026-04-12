import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class PurchaseManager {
  PurchaseManager._internal();
  static final PurchaseManager instance = PurchaseManager._internal();

  static const String _entitlementId = 'KimigatsukuruSekai Premium';
  //static const String _test_apiKey = 'test_tfUevccBSXyNBxmFkegyhuJiRFs';
  static const String _ios_apiKey = 'appl_kqpZisJBGVDPKoRxfmfNGEhRMEC';
  static const String _android_apiKey = 'goog_isVOkUPFLYOcCrdUveOBHOidPQa';

  final ValueNotifier<bool> isPremium = ValueNotifier<bool>(false);
  Offerings? offerings;

  Future<void> init() async {
    try {
      // ログレベルの設定（デバッグ時は詳細に出力）
      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.info);

      // RevenueCatの初期化
      String apiKey = Platform.isAndroid ? _android_apiKey : _ios_apiKey;
      final configuration = PurchasesConfiguration(apiKey);
      await Purchases.configure(configuration);

      // 現在の購入情報の取得と反映
      final CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      _updatePremiumStatus(customerInfo);

      // 購入情報の更新を監視
      Purchases.addCustomerInfoUpdateListener((info) {
        _updatePremiumStatus(info);
      });

      // 商品（Offerings）情報の取得
      offerings = await Purchases.getOfferings();
    } catch (e) {
      debugPrint('RevenueCat初期化エラー: $e');
    }
  }

  /// プレミアム会員かどうか（エンタイトルメントの状態）を更新する
  void _updatePremiumStatus(CustomerInfo customerInfo) {
    final activeEntitlements = customerInfo.entitlements.active;
    isPremium.value = activeEntitlements.containsKey(_entitlementId);
    debugPrint('プレミアム会員ステータス更新: ${isPremium.value}');
  }

  /// RevenueCatのペイウォール画面を表示する
  Future<void> showPaywall() async {
    try {
      // 2024年現在のモダンな実装: RevenueCat公式のPaywall UIを表示
      await RevenueCatUI.presentPaywall();
    } catch (e) {
      debugPrint('ペイウォール表示エラー: $e');
    }
  }

  /// RevenueCatのカスタマーセンター（購読管理・リストア等）を表示する
  Future<void> showCustomerCenter() async {
    try {
      await RevenueCatUI.presentCustomerCenter();
    } catch (e) {
      debugPrint('カスタマーセンター表示エラー: $e');
    }
  }

  /// 購入情報の復元（リストア）を手動で行う場合
  Future<void> restorePurchases() async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      _updatePremiumStatus(customerInfo);
    } catch (e) {
      debugPrint('リストアエラー: $e');
    }
  }
}
