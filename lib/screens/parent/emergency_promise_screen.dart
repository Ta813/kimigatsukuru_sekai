// lib/screens/parent_mode/emergency_promise_screen.dart

import 'package:flutter/material.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import '../../helpers/shared_prefs_helper.dart';
import '../../managers/sfx_manager.dart';
import '../../managers/purchase_manager.dart';
import '../../l10n/app_localizations.dart';
import '../premium_paywall_screen.dart';

import '../../widgets/animated_tap_finger.dart';
import '../../widgets/blinking_effect.dart';

class EmergencyPromiseScreen extends StatefulWidget {
  final bool isTutorial;
  const EmergencyPromiseScreen({super.key, this.isTutorial = false});

  @override
  State<EmergencyPromiseScreen> createState() => _EmergencyPromiseScreenState();
}

class _EmergencyPromiseScreenState extends State<EmergencyPromiseScreen> {
  final _formKey = GlobalKey<FormState>();

  // やくそくの名前用コントローラー
  final _titleController = TextEditingController();

  // 各ドロップダウン用の選択肢リストを生成
  final List<String> _durationOptions = List.generate(
    120,
    (index) => (index + 1).toString(),
  ); // 1〜120分
  final List<String> _pointOptions = List.generate(
    30,
    (index) => (index + 1).toString(),
  ); // 1〜30ポイント

  // 選択中の値を保持する変数（初期値は10）
  String _selectedDuration = '10';
  String _selectedPoints = '10';

  // ▼ 変更: ハードコードされていたおすすめリストを、ローカライズ対応のメソッドに変更
  List<Map<String, dynamic>> _getRecommendedPromises(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final List<Map<String, dynamic>> recommendations = [];

    if (widget.isTutorial) {
      recommendations.add({
        'icon': '⭐️',
        'title': l10n.trialPromiseTitle,
        'duration': 10,
        'points': 1,
      });
    }

    recommendations.addAll([
      {'icon': '✨', 'title': l10n.recPromiseHelp, 'duration': 15, 'points': 15},
      {
        'icon': '✍️',
        'title': l10n.recPromiseHomework,
        'duration': 30,
        'points': 20,
      },
      {
        'icon': '🧸',
        'title': l10n.recPromiseCleanUp,
        'duration': 10,
        'points': 10,
      },
      {
        'icon': '📚',
        'title': l10n.recPromiseReadBook,
        'duration': 20,
        'points': 10,
      },
      {
        'icon': '🛁',
        'title': l10n.recPromiseBathCleaning,
        'duration': 10,
        'points': 15,
      },
      {
        'icon': '🛍️',
        'title': l10n.recPromiseErrand,
        'duration': 20,
        'points': 20,
      },
    ]);

    return recommendations;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // おすすめリストの「＋」が押された時の処理
  void _applyRecommended(Map<String, dynamic> promise) {
    try {
      SfxManager.instance.playTapSound();
    } catch (e) {
      print('再生エラー: $e');
    }
    if (widget.isTutorial) {
      FirebaseAnalytics.instance.logEvent(
        name: 'tutorial_emergency_promise_add',
      );
    } else {
      FirebaseAnalytics.instance.logEvent(name: 'start_emergency_promise_add');
    }

    setState(() {
      _titleController.text = promise['title'] as String;
      // ドロップダウンの選択値を更新
      _selectedDuration = promise['duration'].toString();
      _selectedPoints = promise['points'].toString();
    });
  }

  void _savePromise() async {
    try {
      SfxManager.instance.playTapSound();
    } catch (e) {
      // エラーが発生した場合
      print('再生エラー: $e');
    }

    if (widget.isTutorial) {
      FirebaseAnalytics.instance.logEvent(
        name: 'tutorial_emergency_promise_set',
      );
    } else {
      FirebaseAnalytics.instance.logEvent(name: 'start_emergency_promise_set');
    }

    // 非プレミアムユーザーは1日3回まで
    if (!PurchaseManager.instance.isPremium.value) {
      final count = await SharedPrefsHelper.loadTodayEmergencyPromiseCount();
      const int limit = 3;
      if (!widget.isTutorial && count >= limit) {
        if (!mounted) return;
        final l10n = AppLocalizations.of(context)!;
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.emergencyLimitTitle),
            content: Text(l10n.emergencyLimitDesc(limit)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () {
                  FirebaseAnalytics.instance.logEvent(
                    name: 'emegency_limit_reached_open_paywall',
                  );
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PremiumPaywallScreen(),
                    ),
                  );
                },
                child: Text(l10n.upgradeToPremium),
              ),
            ],
          ),
        );
        return;
      }
    }
    if (_formKey.currentState!.validate()) {
      var emergencyPromise;
      if (widget.isTutorial) {
        emergencyPromise = {
          'title': _titleController.text,
          // 選択されている値を数値に変換して保存
          'duration': int.tryParse(_selectedDuration) ?? 10,
          'points': int.tryParse(_selectedPoints) ?? 10,
          'isTrial': true,
        };
      } else {
        emergencyPromise = {
          'title': _titleController.text,
          // 選択されている値を数値に変換して保存
          'duration': int.tryParse(_selectedDuration) ?? 10,
          'points': int.tryParse(_selectedPoints) ?? 10,
        };
      }
      // SharedPreferencesに保存
      await SharedPrefsHelper.saveEmergencyPromise(emergencyPromise);
      // 登録回数をインクリメント（非プレミアムの制限チェックに使用）
      await SharedPrefsHelper.incrementTodayEmergencyPromiseCount();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              )!.emergencyPromiseSet(_titleController.text),
            ),
            duration: const Duration(seconds: 1),
          ),
        );
        if (widget.isTutorial) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pop(true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final recommendedPromises = _getRecommendedPromises(context);

    return Scaffold(
      appBar: AppBar(
        leading: IgnorePointer(
          ignoring: widget.isTutorial,
          child: Opacity(
            opacity: widget.isTutorial ? 0.4 : 1.0,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(false),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_back),
                    Text(
                      AppLocalizations.of(context)!.backButtonLabel,
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
        title: Text(l10n.emergencyPromiseSettingsTitle),
      ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==============================
            // 左側エリア：おすすめリスト
            // ==============================
            Expanded(
              flex: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  border: Border(
                    right: BorderSide(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        // ▼ 変更: 多言語対応
                        '💡 ${l10n.recommendedTitle}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: recommendedPromises.length,
                        itemBuilder: (context, index) {
                          final promise = recommendedPromises[index];
                          final bool isTrialItem =
                              promise['title'] == l10n.trialPromiseTitle;
                          final bool isTrialSelected =
                              _titleController.text == l10n.trialPromiseTitle;
                          final bool canTapRecommend =
                              !widget.isTutorial ||
                              (isTrialItem && !isTrialSelected);

                          return Opacity(
                            opacity: widget.isTutorial && !canTapRecommend
                                ? 0.4
                                : 1.0,
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              child: ListTile(
                                leading: Text(
                                  promise['icon'] as String,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                contentPadding: const EdgeInsets.only(
                                  left: 8,
                                  right: 4,
                                  top: 0,
                                  bottom: 0,
                                ),
                                title: Text(
                                  promise['title'] as String,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  // ▼ 変更: 多言語対応
                                  l10n.durationAndPoints(
                                    promise['duration'].toString(),
                                    promise['points'].toString(),
                                  ),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                trailing:
                                    widget.isTutorial &&
                                        isTrialItem &&
                                        !isTrialSelected
                                    ? Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          BlinkingEffect(
                                            isBlinking: true,
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.add_circle,
                                                color: Theme.of(
                                                  context,
                                                ).primaryColor,
                                              ),
                                              onPressed: () =>
                                                  _applyRecommended(promise),
                                            ),
                                          ),
                                          const Positioned(
                                            right: -5,
                                            bottom: -5,
                                            child: AnimatedTapFinger(),
                                          ),
                                        ],
                                      )
                                    : IconButton(
                                        icon: Icon(
                                          Icons.add_circle,
                                          color: canTapRecommend
                                              ? Theme.of(context).primaryColor
                                              : Colors.grey,
                                        ),
                                        onPressed: canTapRecommend
                                            ? () => _applyRecommended(promise)
                                            : null,
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 16),

            // ==============================
            // 右側エリア：入力フォーム
            // ==============================
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      TextFormField(
                        controller: _titleController,
                        enabled: !widget.isTutorial,
                        decoration: InputDecoration(
                          labelText: l10n.promiseNameExampleHint,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.promiseNameHint;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),

                      // 時間（長さ）ドロップダウン
                      DropdownButtonFormField<String>(
                        value: _selectedDuration,
                        decoration: InputDecoration(
                          labelText: l10n.durationLabel,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 12,
                          ),
                        ),
                        items: _durationOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: widget.isTutorial
                            ? null
                            : (String? newValue) {
                                if (newValue != null) {
                                  setState(() => _selectedDuration = newValue);
                                }
                              },
                      ),

                      const SizedBox(height: 10),

                      // ポイントドロップダウン
                      DropdownButtonFormField<String>(
                        value: _selectedPoints,
                        decoration: InputDecoration(
                          labelText: l10n.points,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 12,
                          ),
                        ),
                        items: _pointOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: widget.isTutorial
                            ? null
                            : (String? newValue) {
                                if (newValue != null) {
                                  setState(() => _selectedPoints = newValue);
                                }
                              },
                      ),

                      const SizedBox(height: 20),
                      widget.isTutorial &&
                              _titleController.text == l10n.trialPromiseTitle
                          ? Stack(
                              clipBehavior: Clip.none,
                              children: [
                                BlinkingEffect(
                                  isBlinking: true,
                                  child: FilledButton(
                                    onPressed: () {
                                      _savePromise();
                                    },
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      minimumSize: const Size(
                                        double.infinity,
                                        48,
                                      ),
                                    ),
                                    child: Text(l10n.setThisPromiseButton),
                                  ),
                                ),
                                const Positioned(
                                  right: -10,
                                  bottom: -10,
                                  child: AnimatedTapFinger(),
                                ),
                              ],
                            )
                          : Opacity(
                              opacity: widget.isTutorial ? 0.4 : 1.0,
                              child: FilledButton(
                                onPressed: widget.isTutorial
                                    ? null
                                    : () {
                                        FirebaseAnalytics.instance.logEvent(
                                          name: 'start_emergency_promise_set',
                                        );
                                        _savePromise();
                                      },
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                child: Text(l10n.setThisPromiseButton),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
