import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'bgm_manager.dart';

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
      // iOSの場合、強制的に縦画面に回転させる
      if (Platform.isIOS) {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        // 🌟 回転アニメーションのためのわずかな待機（フリッカー防止）
        await Future.delayed(const Duration(milliseconds: 300));
      }

      // 2024年現在のモダンな実装: RevenueCat公式のPaywall UIを表示
      await RevenueCatUI.presentPaywall();

      // BGMの再開を試みる（ネイティブUIや回転で止まる場合があるため）
      try {
        await BgmManager.instance.resume();
      } catch (e) {
        debugPrint('BGM再開エラー: $e');
      }

      // 閉じられたら横画面固定に戻す
      if (Platform.isIOS) {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      }
    } catch (e) {
      debugPrint('ペイウォール表示エラー: $e');
    }
  }

  /// RevenueCatのカスタマーセンター（購読管理・リストア等）を表示する
  Future<void> showCustomerCenter() async {
    try {
      // iOSの場合、強制的に縦画面に回転させる
      if (Platform.isIOS) {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        // 🌟 回転アニメーションのためのわずかな待機（フリッカー防止）
        await Future.delayed(const Duration(milliseconds: 300));
      }

      await RevenueCatUI.presentCustomerCenter();

      // BGMの再開を試みる
      try {
        await BgmManager.instance.resume();
      } catch (e) {
        debugPrint('BGM再開エラー: $e');
      }

      // 閉じられたら横画面固定に戻す
      if (Platform.isIOS) {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      }
    } catch (e) {
      debugPrint('カスタマーセンター表示エラー: $e');
    }
  }

  /// 購入情報の復元（リストア）を手動で行う場合
  Future<bool> restorePurchases() async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      _updatePremiumStatus(customerInfo);
      return true;
    } catch (e) {
      debugPrint('リストアエラー: $e');
      return false;
    }
  }
}
