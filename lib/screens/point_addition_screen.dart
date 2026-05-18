// lib/screens/point_addition_screen.dart

import 'dart:async'; // 🌟 追加: タイマー処理用
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:kimigatsukuru_sekai/l10n/app_localizations.dart';
import '../../helpers/shared_prefs_helper.dart';
import '../../managers/sfx_manager.dart';
import '../../widgets/custom_back_button.dart';
import '../../managers/reward_ad_manager.dart';

class PointAdditionScreen extends StatefulWidget {
  const PointAdditionScreen({super.key});

  @override
  State<PointAdditionScreen> createState() => _PointAdditionScreenState();
}

class _PointAdditionScreenState extends State<PointAdditionScreen> {
  int _currentPoints = 0;
  bool _isMorningClaimed = false;
  bool _isAfternoonClaimed = false;
  bool _isNightClaimed = false;

  // 🌟 追加: カウントダウン用のタイマーと文字列
  Timer? _countdownTimer;
  String _timeUntilNextSlot = '';

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.logEvent(name: 'point_addition_screen_show');
    _loadData();
    _startCountdown(); // 🌟 追加: カウントダウン開始
  }

  @override
  void dispose() {
    _countdownTimer?.cancel(); // 🌟 追加: 画面を閉じる時にタイマーを破棄
    super.dispose();
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
    final points = await SharedPrefsHelper.loadPoints();
    final morning = await SharedPrefsHelper.isRewardClaimed('morning');
    final afternoon = await SharedPrefsHelper.isRewardClaimed('afternoon');
    final night = await SharedPrefsHelper.isRewardClaimed('night');

    setState(() {
      _currentPoints = points;
      _isMorningClaimed = morning;
      _isAfternoonClaimed = afternoon;
      _isNightClaimed = night;
    });
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
  void _showRewardedAd() {
    // 広告ロードエラーがある場合は再読み込みを試みる
    if (RewardAdManager.instance.hasLoadError) {
      RewardAdManager.instance.loadAd();
      return;
    }

    if (!RewardAdManager.instance.isAdAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pointAdditionNotReadyMsg),
        ),
      );
      RewardAdManager.instance.loadAd();
      return;
    }

    try {
      SfxManager.instance.playTapSound();
    } catch (_) {}

    // 🌟 マネージャー経由で広告を表示
    RewardAdManager.instance.showAd(
      onRewardEarned: () async {
        // --- 🌟 報酬付与ロジック (既存のものをそのまま保持) ---
        try {
          SfxManager.instance.playSuccessSound();
        } catch (_) {}
        final slot = _getCurrentSlot();
        await SharedPrefsHelper.setRewardClaimed(slot);
        final newPoints = _currentPoints + 50;
        await SharedPrefsHelper.savePoints(newPoints);
        await SharedPrefsHelper.addCumulativePoints(50);

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
    } else if (RewardAdManager.instance.hasLoadError) {
      buttonText = AppLocalizations.of(context)!.pointAdditionAdError;
      isButtonEnabled = true;
    } else if (RewardAdManager.instance.isLoading ||
        !RewardAdManager.instance.isAdAvailable) {
      buttonText = AppLocalizations.of(context)!.pointAdditionAdLoading;
    } else {
      buttonText = AppLocalizations.of(context)!.pointAdditionAdButton;
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
          padding: const EdgeInsets.all(16.0),
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
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
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
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: isButtonEnabled ? _showRewardedAd : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7043),
                          disabledBackgroundColor: Colors.grey[300],
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.grey[600],
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: isButtonEnabled ? 4 : 0,
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
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ==========================================
              // ② 今後の課金アイテムセクション (Coming Soon)
              // ==========================================
              Text(
                AppLocalizations.of(context)!.pointAdditionShopTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Opacity(
                opacity: 0.6,
                child: Card(
                  color: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.storefront,
                            size: 48,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.pointAdditionShopComingSoon,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.pointAdditionShopComingSoonDesc,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 60,
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
                : Text(emoji, style: const TextStyle(fontSize: 28)),
          ),
        ),
      ],
    );
  }
}
