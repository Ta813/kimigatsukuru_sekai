// lib/screens/parent_mode/parent_top_screen.dart

import 'package:flutter/material.dart';
import 'package:kimigatsukuru_sekai/screens/premium_paywall_screen.dart';
import '../../widgets/custom_back_button.dart';
import '../../widgets/blinking_effect.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'regular_promise_settings_screen.dart';
import 'emergency_promise_screen.dart';
import '../../managers/sfx_manager.dart';
import 'advice_screen.dart';
import '../../l10n/app_localizations.dart';
import 'settings_screen.dart';
import 'child_name_settings_screen.dart';
import '../../managers/purchase_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum _ParentTutorialPhase { regular, back, done }

class ParentTopScreen extends StatefulWidget {
  final bool isTutorial;
  const ParentTopScreen({super.key, this.isTutorial = false});

  @override
  State<ParentTopScreen> createState() => _ParentTopScreenState();
}

class _ParentTopScreenState extends State<ParentTopScreen> {
  _ParentTutorialPhase _tutorialPhase = _ParentTutorialPhase.regular;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:
            widget.isTutorial && _tutorialPhase == _ParentTutorialPhase.back
            ? BlinkingEffect(
                isBlinking: true,
                borderRadius: 8,
                child: BackButton(
                  onPressed: () {
                    if (Navigator.of(context).canPop())
                      Navigator.of(context).pop();
                  },
                ),
              )
            : IgnorePointer(
                ignoring:
                    widget.isTutorial &&
                    _tutorialPhase == _ParentTutorialPhase.regular,
                child: const CustomBackButton(),
              ),
        title: Text(AppLocalizations.of(context)!.parentScreenTitle),
        actions: [
          IgnorePointer(
            ignoring: widget.isTutorial,
            child: Opacity(
              opacity: widget.isTutorial ? 0.4 : 1.0,
              child: InkWell(
                onTap: () {
                  if (widget.isTutorial) {
                    FirebaseAnalytics.instance.logEvent(
                      name: 'finish_tutorial',
                    );
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChildNameSettingsScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 4.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.face_retouching_natural),
                      Text(
                        AppLocalizations.of(context)!.nameSetting,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          IgnorePointer(
            ignoring: widget.isTutorial,
            child: Opacity(
              opacity: widget.isTutorial ? 0.4 : 1.0,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 4.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.settings),
                      Text(
                        AppLocalizations.of(context)!.settingsTitle,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              // 画面いっぱいに広げる
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 「最初にお読みください」ボタン
                IgnorePointer(
                  ignoring:
                      widget.isTutorial &&
                      (_tutorialPhase == _ParentTutorialPhase.regular ||
                          _tutorialPhase == _ParentTutorialPhase.back),
                  child: Opacity(
                    opacity:
                        widget.isTutorial &&
                            (_tutorialPhase == _ParentTutorialPhase.regular ||
                                _tutorialPhase == _ParentTutorialPhase.back)
                        ? 0.4
                        : 1.0,
                    child: _buildMenuCard(
                      context: context,
                      label: AppLocalizations.of(context)!.readFirstButton,
                      icon: FontAwesomeIcons.bookOpenReader,
                      color: Colors.teal.shade400,
                      onPressed: () {
                        FirebaseAnalytics.instance.logEvent(
                          name: 'start_parent_top_read_first',
                        );
                        _playTapSound();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdviceScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // 下段：2列レイアウト
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 「定例のやくそく設定」ボタン
                    Expanded(
                      child:
                          widget.isTutorial &&
                              _tutorialPhase == _ParentTutorialPhase.regular
                          ? Stack(
                              clipBehavior: Clip.none,
                              children: [
                                BlinkingEffect(
                                  isBlinking: true,
                                  borderRadius: 16,
                                  child: _buildMenuCard(
                                    context: context,
                                    label: AppLocalizations.of(
                                      context,
                                    )!.regularPromiseSettingsButton,
                                    icon: FontAwesomeIcons.calendarCheck,
                                    color: Theme.of(context).primaryColor,
                                    onPressed: () async {
                                      if (widget.isTutorial) {
                                        FirebaseAnalytics.instance.logEvent(
                                          name:
                                              'start_parent_top_regular_promise_tutorial',
                                        );
                                      } else {
                                        FirebaseAnalytics.instance.logEvent(
                                          name:
                                              'start_parent_top_regular_promise',
                                        );
                                      }
                                      _playTapSound();
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const RegularPromiseSettingsScreen(
                                                isTutorial: true,
                                              ),
                                        ),
                                      );
                                      if (mounted) {
                                        setState(
                                          () => _tutorialPhase =
                                              _ParentTutorialPhase.back,
                                        );
                                      }
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: -50,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: _buildBubble(
                                      AppLocalizations.of(
                                        context,
                                      )!.tutorialParentRegularBubble,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : IgnorePointer(
                              ignoring:
                                  widget.isTutorial &&
                                  _tutorialPhase == _ParentTutorialPhase.back,
                              child: Opacity(
                                opacity:
                                    widget.isTutorial &&
                                        _tutorialPhase ==
                                            _ParentTutorialPhase.back
                                    ? 0.4
                                    : 1.0,
                                child: _buildMenuCard(
                                  context: context,
                                  label: AppLocalizations.of(
                                    context,
                                  )!.regularPromiseSettingsButton,
                                  icon: FontAwesomeIcons.calendarCheck,
                                  color: Theme.of(context).primaryColor,
                                  onPressed: () async {
                                    FirebaseAnalytics.instance.logEvent(
                                      name: 'start_parent_top_regular_promise',
                                    );
                                    _playTapSound();
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const RegularPromiseSettingsScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    // 「緊急のやくそく設定」ボタン
                    Expanded(
                      child: IgnorePointer(
                        ignoring:
                            widget.isTutorial &&
                            _tutorialPhase != _ParentTutorialPhase.done,
                        child: Opacity(
                          opacity:
                              widget.isTutorial &&
                                  _tutorialPhase != _ParentTutorialPhase.done
                              ? 0.4
                              : 1.0,
                          child: _buildMenuCard(
                            context: context,
                            label: AppLocalizations.of(
                              context,
                            )!.emergencyPromiseSettingsButton,
                            icon: FontAwesomeIcons.bell,
                            color: Colors.deepOrangeAccent,
                            onPressed: () {
                              FirebaseAnalytics.instance.logEvent(
                                name: 'start_parent_top_emergency_promise',
                              );
                              _playTapSound();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EmergencyPromiseScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ▼ プレミアム会員のご案内（派手なデザインで最下部へ）
                _buildPremiumMembershipSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumMembershipSection(BuildContext context) {
    return IgnorePointer(
      ignoring: widget.isTutorial,
      child: Opacity(
        opacity: widget.isTutorial ? 0.4 : 1.0,
        child: ValueListenableBuilder<bool>(
          valueListenable: PurchaseManager.instance.isPremium,
          builder: (context, isPremium, child) {
            return Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isPremium
                          ? [Colors.teal.shade700, Colors.teal.shade400]
                          : [const Color(0xFFFFD700), const Color(0xFFFF8C00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (isPremium ? Colors.teal : Colors.orange)
                            .withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        _playTapSound();
                        if (isPremium) {
                          PurchaseManager.instance.showCustomerCenter();
                        } else {
                          FirebaseAnalytics.instance.logEvent(
                            name: 'start_premium',
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PremiumPaywallScreen(),
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isPremium
                                    ? Icons.stars
                                    : Icons.workspace_premium,
                                size: 32,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isPremium
                                        ? AppLocalizations.of(
                                            context,
                                          )!.premiumActive
                                        : AppLocalizations.of(
                                            context,
                                          )!.upgradeToPremium,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 4,
                                          color: Colors.black26,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isPremium
                                        ? AppLocalizations.of(
                                            context,
                                          )!.manageSubscription
                                        : AppLocalizations.of(
                                            context,
                                          )!.premiumFeaturesDesc,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // 復元ボタン
                TextButton(
                  onPressed: () async {
                    _playTapSound();
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    final l10n = AppLocalizations.of(context)!;

                    // 復元中メッセージ
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text(l10n.restoringPurchases)),
                    );

                    final success = await PurchaseManager.instance
                        .restorePurchases();

                    if (success) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(content: Text(l10n.restoreSuccess)),
                      );
                    } else {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(content: Text(l10n.restoreFailed)),
                      );
                    }
                  },
                  child: Text(
                    AppLocalizations.of(context)!.restorePurchases,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _playTapSound() {
    try {
      SfxManager.instance.playTapSound();
    } catch (e) {
      debugPrint('再生エラー: $e');
    }
  }

  /// 吹き出しウィジェット
  Widget _buildBubble(String text) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 180),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange, width: 2),
        boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    String? subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 24, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: color.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
