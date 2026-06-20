// lib/screens/point_addition_screen.dart

import 'dart:async'; // 🌟 追加: タイマー処理用
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:kimigatsukuru_sekai/l10n/app_localizations.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../helpers/shared_prefs_helper.dart';
import '../../managers/sfx_manager.dart';
import '../../widgets/custom_back_button.dart';
import '../../managers/reward_ad_manager.dart';
import 'package:flutter/foundation.dart';
import '../../managers/purchase_manager.dart';
import '../../widgets/pulsing_effect.dart';

class PointAdditionScreen extends StatefulWidget {
  const PointAdditionScreen({super.key});

  @override
  State<PointAdditionScreen> createState() => _PointAdditionScreenState();
}

class _PointAdditionScreenState extends State<PointAdditionScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  int _currentPoints = 0;
  bool _isMorningClaimed = false;
  bool _isAfternoonClaimed = false;
  bool _isNightClaimed = false;

  // 🌟 追加: カウントダウン用のタイマーと文字列
  Timer? _countdownTimer;
  String _timeUntilNextSlot = '';

  // クラス上部の変数定義に追加
  int _currentBoostMultiplier = 1;
  int _multiplier = 1;
  bool _isBoost2xTrialUsed = false;

  // ==========================================
  // 🌟 追加: ポイント獲得時のどデカいアニメーション用
  // ==========================================
  late AnimationController _pointsAddedAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  OverlayEntry? _currentPointOverlay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FirebaseAnalytics.instance.logEvent(name: 'point_addition_screen_show');

    // ==========================================
    // 🌟 追加: ポイント獲得アニメーションの設定
    // ==========================================
    _pointsAddedAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0),
          end: const Offset(0, -0.8), // 上に少しフワッと浮く
        ).animate(
          CurvedAnimation(
            parent: _pointsAddedAnimationController,
            curve: Curves.easeOut,
          ),
        );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _pointsAddedAnimationController,
        curve: const Interval(0.5, 1.0),
      ),
    );

    _loadData();
    _startCountdown(); // 🌟 追加: カウントダウン開始
  }

  @override
  void dispose() {
    if (_currentPointOverlay != null) {
      _currentPointOverlay?.remove();
      _currentPointOverlay = null;
    }
    _pointsAddedAnimationController.dispose();

    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App has come to the foreground, reload data to refresh state
      _loadData();
    }
  }

  // ==========================================
  // 🌟 追加: 最前面にアニメーションを表示するメソッド
  // ==========================================
  void _showHugePointAnimation(int points) {
    // すでに表示中のものがあれば一旦消す（連打対策）
    _currentPointOverlay?.remove();

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: IgnorePointer(
          child: Center(
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 60),
                      const SizedBox(width: 12),
                      Text(
                        '+$points', // 引数で受け取ったポイントを表示
                        style: const TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF7043),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    _currentPointOverlay = overlayEntry;
    overlay.insert(overlayEntry); // 最前面のガラス（Overlay）に貼り付け！

    // アニメーションを最初から再生し、終わったらガラスから剥がす
    _pointsAddedAnimationController.forward(from: 0.0).whenComplete(() {
      if (_currentPointOverlay != null) {
        _currentPointOverlay?.remove();
        _currentPointOverlay = null;
      }
    });
  }

  // 🌟 追加: 1秒ごとに残り時間を計算するメソッド
  void _startCountdown() {
    _updateCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateCountdown();
    });
  }

  // 🌟 追加: 次の時間帯までの計算ロジック
  void _updateCountdown() {
    final now = DateTime.now();
    DateTime nextTarget;

    if (now.hour >= 0 && now.hour < 12) {
      // 現在が朝なら、次は12:00
      nextTarget = DateTime(now.year, now.month, now.day, 12, 0, 0);
    } else if (now.hour >= 12 && now.hour < 18) {
      // 現在が昼なら、次は18:00
      nextTarget = DateTime(now.year, now.month, now.day, 18, 0, 0);
    } else {
      // 現在が夜なら、次は翌日の0:00
      nextTarget = DateTime(now.year, now.month, now.day + 1, 0, 0, 0);
    }

    final diff = nextTarget.difference(now);
    final hours = diff.inHours.toString().padLeft(2, '0');
    final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');

    if (mounted) {
      setState(() {
        _timeUntilNextSlot = '$hours:$minutes:$seconds';
      });
      // ちょうど時間が切り替わった時に状態をリロードしてボタンを復活させる
      if (diff.inSeconds == 0) {
        _loadData();
      }
    }
  }

  Future<void> _loadData() async {
    try {
      final points = await SharedPrefsHelper.loadPoints();
      final morning = await SharedPrefsHelper.isRewardClaimed('morning');
      final afternoon = await SharedPrefsHelper.isRewardClaimed('afternoon');
      final night = await SharedPrefsHelper.isRewardClaimed('night');
      final int multiplier =
          await SharedPrefsHelper.getCurrentBoostMultiplier();

      // 🌟 追加: ブースト状態の読み込み
      final boostMultiplier =
          await SharedPrefsHelper.getCurrentBoostMultiplier();

      // 🌟 追加: 無料枠の使用状況を取得
      final boost2xTrialUsed = await SharedPrefsHelper.isBoost2xFreeTrialUsed();
      await PurchaseManager.instance.loadBoostPrices();

      if (!mounted) return;

      setState(() {
        _currentPoints = points;
        _isMorningClaimed = morning;
        _isAfternoonClaimed = afternoon;
        _isNightClaimed = night;
        _currentBoostMultiplier = boostMultiplier; // 🌟 追加
        _multiplier = multiplier;
        _isBoost2xTrialUsed = boost2xTrialUsed;
      });
    } catch (e) {
      debugPrint('Error loading data in _PointAdditionScreenState: $e');
    }
  }

  // 現在の時間帯を取得
  String _getCurrentSlot() {
    final hour = DateTime.now().hour;
    if (hour >= 0 && hour < 12) return 'morning'; // 0:00〜11:59
    if (hour >= 12 && hour < 18) return 'afternoon'; // 12:00〜17:59
    return 'night'; // 18:00〜23:59
  }

  // 現在の時間帯の視聴状態を確認
  bool _isCurrentSlotClaimed() {
    final slot = _getCurrentSlot();
    if (slot == 'morning') return _isMorningClaimed;
    if (slot == 'afternoon') return _isAfternoonClaimed;
    return _isNightClaimed;
  }

  // 広告を再生して報酬を付与する
  void _showRewardedAd() async {
    if (!RewardAdManager.instance.isAdAvailable) {
      // 画面にローディングを出して「準備中」であることを伝える
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF7043)),
        ),
      );

      // ロードを試みつつ、最大5秒間（100ms × 50回）だけ準備ができるのを待つ
      RewardAdManager.instance.loadAd();
      int waitCount = 0;
      while (!RewardAdManager.instance.isAdAvailable && waitCount < 50) {
        await Future.delayed(const Duration(milliseconds: 100));
        waitCount++;
      }

      // ローディングを閉じる
      if (mounted) Navigator.of(context).pop();

      // それでもダメなら諦めてスナックバーを出す
      if (!RewardAdManager.instance.isAdAvailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.pointAdditionNotReadyMsg,
              ),
            ),
          );
        }
        return;
      }
    }

    try {
      SfxManager.instance.playTapSound();
    } catch (_) {}

    // 🌟 マネージャー経由で広告を表示
    RewardAdManager.instance.showAd(
      onRewardEarned: () async {
        // --- 🌟 報酬付与ロジック ---
        try {
          SfxManager.instance.playSuccessSound();
        } catch (_) {}
        final slot = _getCurrentSlot();
        await SharedPrefsHelper.setRewardClaimed(slot);

        final int multiplier =
            await SharedPrefsHelper.getCurrentBoostMultiplier();
        final earnedPoints = 50 * multiplier;
        final newPoints = _currentPoints + earnedPoints;

        // 🌟 追加: アニメーションを発動しつつポイントを即時反映
        if (mounted) {
          setState(() {
            _currentPoints = newPoints;
          });
          // 広告が閉じるのをほんの少し待ってからド派手な演出を出す
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) {
              _showHugePointAnimation(earnedPoints);
            }
          });
        }

        await SharedPrefsHelper.savePoints(newPoints);
        await SharedPrefsHelper.addCumulativePoints(earnedPoints);

        FirebaseAnalytics.instance.logEvent(name: 'reward_ad_claimed_$slot');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.pointAdditionRewardSuccess,
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
          _loadData();
        }
        // --------------------------------------------------
      },
      onAdClosed: () {
        if (mounted) setState(() {});
      },
    );
  }

  Future<void> _processBoostPurchase(
    String productId,
    int multiplier,
    Duration duration,
  ) async {
    FirebaseAnalytics.instance.logEvent(name: 'boost_prepare_$multiplier');
    // UI側のローディング表示（二重タップ防止）
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // １秒待つ
    await Future.delayed(const Duration(seconds: 1));

    // RevenueCat を通じて購入！
    final success = await PurchaseManager.instance.purchaseBoostProduct(
      productId,
    );

    // ローディングを閉じる
    if (mounted) Navigator.of(context).pop();

    if (success) {
      FirebaseAnalytics.instance.logEvent(name: 'boost_purchase_$multiplier');
      // 購入成功時：効果音を鳴らしてデータを保存
      try {
        SfxManager.instance.playSuccessSound();
      } catch (_) {}
      await SharedPrefsHelper.activateBoost(multiplier, duration);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              )!.pointAdditionBoostTestMsg(multiplier),
            ), // ※後で「テスト」の文字を外すようローカライズを修正してください
            backgroundColor: Colors.orange,
          ),
        );
        _loadData(); // 画面を更新してブースト状態を反映
      }
    }
  }

  // 🌟 追加: 初回無料枠を利用した場合の処理
  Future<void> _processFreeTrial() async {
    FirebaseAnalytics.instance.logEvent(name: 'free_trial_used');
    // 少しだけロード画面を出して「処理してる感」を演出
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await Future.delayed(const Duration(seconds: 1)); // 1秒待機

    // 無料枠使用済みに変更し、2倍ブーストを7日間発動
    await SharedPrefsHelper.setBoost2xFreeTrialUsed(true);
    await SharedPrefsHelper.activateBoost(2, const Duration(days: 7));

    try {
      await Purchases.setAttributes({"used_free_boost_2x": "true"});
    } catch (e) {
      debugPrint("RevenueCat属性の送信エラー: $e");
    }

    if (mounted) Navigator.of(context).pop(); // ロード画面を閉じる

    try {
      SfxManager.instance.playSuccessSound();
    } catch (_) {}
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.pointAdditionBoostTestMsg(2),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      _loadData(); // 画面を更新してボタンを「使用中」にする
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSlot = _getCurrentSlot();
    final isClaimed = _isCurrentSlotClaimed();

    String buttonText;
    bool isButtonEnabled = false;

    // 🌟 変更: ボタンのテキストを修正
    if (isClaimed) {
      buttonText = AppLocalizations.of(
        context,
      )!.pointAdditionNextSlot(_timeUntilNextSlot);
    } else {
      // まだ視聴していないなら、ロード状態に関わらず常に「ボタン活性」にする
      buttonText = AppLocalizations.of(
        context,
      )!.pointAdditionAdButton(50 * _multiplier);
      isButtonEnabled = true;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        leading: const CustomBackButton(),
        title: Text(
          AppLocalizations.of(context)!.pointAdditionTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Center(
              child: Row(
                children: [
                  Text(
                    '$_currentPoints ${AppLocalizations.of(context)?.points ?? "P"}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==========================================
              // ① リワード広告セクション
              // ==========================================
              Text(
                AppLocalizations.of(context)!.pointAdditionAdTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildSlotIndicator(
                            AppLocalizations.of(
                              context,
                            )!.pointAdditionSlotMorning,
                            '🌅',
                            _isMorningClaimed,
                            currentSlot == 'morning',
                          ),
                          _buildSlotIndicator(
                            AppLocalizations.of(
                              context,
                            )!.pointAdditionSlotAfternoon,
                            '☀️',
                            _isAfternoonClaimed,
                            currentSlot == 'afternoon',
                          ),
                          _buildSlotIndicator(
                            AppLocalizations.of(
                              context,
                            )!.pointAdditionSlotNight,
                            '🌙',
                            _isNightClaimed,
                            currentSlot == 'night',
                          ),
                        ],
                      ),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.pointAdditionMotivationMsg,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color:
                              Colors.black54, // 少し控えめなグレーにして広告ボタンより目立ちすぎないように
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),

                      PulsingEffect(
                        isPulsing: isButtonEnabled,
                        child: FilledButton(
                          onPressed: isButtonEnabled ? _showRewardedAd : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7043),
                            disabledBackgroundColor: Colors.grey[300],
                            foregroundColor: Colors.white,
                            disabledForegroundColor: Colors.grey[600],
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 48,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isButtonEnabled) ...[
                                const Icon(Icons.play_circle_fill, size: 24),
                                const SizedBox(width: 8),
                              ],
                              // 🌟 変更: カウントダウンが長いのでテキストがはみ出さないように FittedBox で囲む
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    buttonText,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ==========================================
              // ② アイテムショップ（ポイントブースト）
              // ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.pointAdditionShopTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  // 🌟 追加: デバッグモードの時だけ表示される秘密のボタン
                  if (kDebugMode)
                    TextButton.icon(
                      onPressed: () async {
                        await SharedPrefsHelper.debugSetBoostRemainingTo30Seconds();
                        _loadData(); // データを再読み込みして画面を更新
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('【DEBUG】残り時間を30秒にしました'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.av_timer,
                        color: Colors.red,
                        size: 18,
                      ),
                      label: const Text(
                        '残り30秒にする',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),

              // 🌟 追加: ブースト中の場合のアピール帯
              if (_currentBoostMultiplier > 1)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.orangeAccent, Colors.deepOrangeAccent],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(
                        context,
                      )!.pointAdditionBoostActive(_currentBoostMultiplier),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

              // 🌟 追加: ブースト商品のリスト
              _buildBoostCard(
                title: AppLocalizations.of(context)!.pointAdditionBoostTitle1,
                description: AppLocalizations.of(
                  context,
                )!.pointAdditionBoostDesc1,
                priceLabel: !_isBoost2xTrialUsed
                    ? AppLocalizations.of(context)!.pointAdditionFirstTimeFree
                    : (PurchaseManager.instance.boostPrices[PurchaseManager
                              .boost2xKey] ??
                          '¥160'),
                icon: Icons.star_border_purple500,
                color: Colors.blueAccent,
                isPurchasable: _currentBoostMultiplier == 1, // ブースト中は買えないようにする
                onTap: () {
                  if (!_isBoost2xTrialUsed) {
                    _processFreeTrial();
                  } else {
                    _processBoostPurchase(
                      PurchaseManager.boost2xKey,
                      2,
                      const Duration(days: 7),
                    );
                  }
                },
                isPulsing: !_isBoost2xTrialUsed,
              ),
              const SizedBox(height: 6),
              _buildBoostCard(
                title: AppLocalizations.of(context)!.pointAdditionBoostTitle2,
                description: AppLocalizations.of(
                  context,
                )!.pointAdditionBoostDesc2,
                priceLabel:
                    PurchaseManager.instance.boostPrices[PurchaseManager
                        .boost5xKey] ??
                    '¥320',
                icon: Icons.flash_on,
                color: Colors.orange,
                isPurchasable: _currentBoostMultiplier == 1,
                onTap: () => _processBoostPurchase(
                  PurchaseManager.boost5xKey,
                  5,
                  const Duration(days: 3),
                ),
              ),
              const SizedBox(height: 6),
              _buildBoostCard(
                title: AppLocalizations.of(context)!.pointAdditionBoostTitle3,
                description: AppLocalizations.of(
                  context,
                )!.pointAdditionBoostDesc3,
                priceLabel:
                    PurchaseManager.instance.boostPrices[PurchaseManager
                        .boost10xKey] ??
                    '¥480',
                icon: Icons.local_fire_department,
                color: Colors.pinkAccent,
                isPurchasable: _currentBoostMultiplier == 1,
                onTap: () => _processBoostPurchase(
                  PurchaseManager.boost10xKey,
                  10,
                  const Duration(hours: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 時間帯のステータスアイコンを作るウィジェット
  Widget _buildSlotIndicator(
    String label,
    String emoji,
    bool isClaimed,
    bool isCurrent,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isCurrent ? const Color(0xFFFF7043) : Colors.black54,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isClaimed
                ? Colors.grey[200]
                : (isCurrent ? const Color(0xFFFFF3E0) : Colors.white),
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrent ? const Color(0xFFFF7043) : Colors.grey[300]!,
              width: isCurrent ? 3 : 1,
            ),
          ),
          child: Center(
            child: isClaimed
                ? const Icon(Icons.check_circle, color: Colors.green, size: 32)
                : Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
        ),
      ],
    );
  }

  // 🌟 追加: ブースト商品のカードを作るウィジェット
  Widget _buildBoostCard({
    required String title,
    required String description,
    required String priceLabel,
    required IconData icon,
    required Color color,
    required bool isPurchasable,
    required VoidCallback onTap,
    bool isPulsing = false,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
            ),
            PulsingEffect(
              isPulsing: isPulsing,
              child: FilledButton(
                onPressed: isPurchasable ? onTap : null,
                style: FilledButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  isPurchasable
                      ? priceLabel
                      : AppLocalizations.of(context)!.pointAdditionInUse,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
