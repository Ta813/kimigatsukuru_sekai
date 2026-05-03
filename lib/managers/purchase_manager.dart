import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:google_api_availability/google_api_availability.dart';
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

  Future<void> _logDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        debugPrint(
          'Device Info (Android): Brand=${androidInfo.brand}, Model=${androidInfo.model}, SDK=${androidInfo.version.sdkInt}',
        );
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        debugPrint(
          'Device Info (iOS): Name=${iosInfo.name}, Model=${iosInfo.model}, SystemName=${iosInfo.systemName}, SystemVersion=${iosInfo.systemVersion}',
        );
      }
    } catch (e) {
      debugPrint('Device info logging failed: $e');
    }
  }

  Future<void> _checkGooglePlayServices() async {
    if (!Platform.isAndroid) return;
    try {
      final availability = await GoogleApiAvailability.instance
          .checkGooglePlayServicesAvailability();
      debugPrint('Google Play Services Availability: $availability');
    } catch (e) {
      debugPrint('Google Play Services check failed: $e');
    }
  }

  Future<void> init() async {
    try {
      // デバイス情報のログ出力
      await _logDeviceInfo();
      // Google Play Servicesの状態確認（Androidのみ）
      await _checkGooglePlayServices();

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

  /// 現在の購入情報を強制的に同期する
  Future<void> refreshCustomerInfo() async {
    try {
      debugPrint('購入情報の同期を開始...');
      final CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      _updatePremiumStatus(customerInfo);
      debugPrint('購入情報の同期完了');
    } catch (e) {
      debugPrint('購入情報の同期エラー: $e');
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

      // ペイウォール表示前のデバッグログ（OnePlus等でのNullPointerException調査用）
      debugPrint('Billing Flow Initiation: showPaywall');

      // Offerings が null の場合は最大3回リトライして取得する
      // OnePlus等のアグレッシブなバックグラウンドKillでOfferingsが
      // 失われている場合への対策
      if (offerings == null) {
        debugPrint(
          'Warning: Offerings is null before showing paywall. Attempting to fetch...',
        );
        for (int attempt = 1; attempt <= 3; attempt++) {
          try {
            offerings = await Purchases.getOfferings();
            if (offerings != null) {
              debugPrint('Offerings fetched successfully on attempt $attempt');
              break;
            }
          } catch (e) {
            debugPrint('Offerings fetch attempt $attempt failed: $e');
            // 設定が壊れている可能性を考慮して再設定を試みる（Androidのみ、非常に稀なケース）
            if (Platform.isAndroid && attempt == 2) {
              debugPrint('Re-configuring Purchases as a last resort...');
              String apiKey = _android_apiKey;
              await Purchases.configure(PurchasesConfiguration(apiKey));
            }
            if (attempt < 3)
              await Future.delayed(const Duration(milliseconds: 500));
          }
        }
      }

      if (offerings == null) {
        throw Exception('Offerings could not be fetched after retries.');
      }

      debugPrint('Offerings status: ${offerings?.all.keys.toList()}');

      // 🌟 Androidでの接続確認を兼ねて最新情報を取得
      final customerInfo = await Purchases.getCustomerInfo();
      debugPrint(
        'CustomerInfo at showPaywall: ${customerInfo.entitlements.active.keys.toList()}',
      );

      // OnePlus等の端末で前の画面トランジションが完了する前に
      // Billing UI が起動されると PendingIntent が null になるケースへの対策。
      // Androidでは画面遷移後に少し長めの遅延を挟む（300ms -> 500msに強化）。
      if (Platform.isAndroid) {
        debugPrint('Applying transition delay for Android billing flow...');
        await Future.delayed(const Duration(milliseconds: 500));
      }

      debugPrint('Calling RevenueCatUI.presentPaywall()...');
      // 2024年現在のモダンな実装: RevenueCat公式のPaywall UIを表示
      await RevenueCatUI.presentPaywall();
      debugPrint('RevenueCatUI.presentPaywall() returned.');

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
      // スタックトレースもログに残してクラッシュ調査に役立てる
      debugPrint('ペイウォール表示エラー (stackTrace): ${StackTrace.current}');
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

      debugPrint('Billing Flow Initiation: showCustomerCenter');
      final customerInfo = await Purchases.getCustomerInfo();
      debugPrint(
        'CustomerInfo at showCustomerCenter: ${customerInfo.entitlements.active.keys.toList()}',
      );

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
