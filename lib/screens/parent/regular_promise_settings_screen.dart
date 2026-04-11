// lib/screens/parent_mode/regular_promise_settings_screen.dart

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:kimigatsukuru_sekai/managers/notification_manager.dart';
import '../../widgets/custom_back_button.dart';
import '../../widgets/blinking_effect.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../helpers/shared_prefs_helper.dart';
import 'add_edit_promise_screen.dart';
import '../../managers/sfx_manager.dart';
import '../../l10n/app_localizations.dart';

/// チュートリアルのフェーズ
enum _TutorialPhase { add, delete, finish, done }

class RegularPromiseSettingsScreen extends StatefulWidget {
  final bool isTutorial;
  const RegularPromiseSettingsScreen({super.key, this.isTutorial = false});

  @override
  State<RegularPromiseSettingsScreen> createState() =>
      _RegularPromiseSettingsScreenState();
}

class _RegularPromiseSettingsScreenState
    extends State<RegularPromiseSettingsScreen> {
  // 定例のやくそくリストを管理するためのデータ
  List<Map<String, dynamic>> _regularPromises = [];

  // チュートリアルフェーズ
  _TutorialPhase _tutorialPhase = _TutorialPhase.add;

  // ▼ 追加: チュートリアル用のおためしテンプレートを取得するメソッド
  Map<String, dynamic> _getTrialTemplate(BuildContext context) {
    return {
      // child_home_screen.dartなどで使っている既存キーを再利用
      'title': AppLocalizations.of(context)!.trialPromiseTitle,
      'icon': '⭐',
      'time': '06:00',
      'duration': 5,
      'points': 5,
    };
  }

  // ▼ 変更: ハードコードされていたおすすめリストを、ローカライズ対応のメソッドに変更
  List<Map<String, dynamic>> _getRecommendedTemplates(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      {
        'title': l10n.recPromiseToilet,
        'icon': '🚽',
        'time': '06:50',
        'duration': 10,
        'points': 10,
      },
      {
        'title': l10n.promiseDefault1Title,
        'icon': '🍳',
        'time': '07:00',
        'duration': 30,
        'points': 20,
      },
      {
        'title': l10n.promiseDefault2Title,
        'icon': '🪥',
        'time': '07:30',
        'duration': 10,
        'points': 10,
      },
      {
        'title': l10n.promiseDefault3Title,
        'icon': '👕',
        'time': '07:45',
        'duration': 10,
        'points': 10,
      },
      {
        'title': l10n.recPromiseShoes,
        'icon': '👟',
        'time': '08:00',
        'duration': 5,
        'points': 5,
      },
      {
        'title': l10n.recPromiseLunch,
        'icon': '🍱',
        'time': '12:00',
        'duration': 30,
        'points': 20,
      },
      {
        'title': l10n.recPromiseWashHands,
        'icon': '🧼',
        'time': '15:30',
        'duration': 5,
        'points': 5,
      },
      {
        'title': l10n.recPromiseHomework,
        'icon': '✍️',
        'time': '16:00',
        'duration': 30,
        'points': 20,
      },
      {
        'title': l10n.recPromisePractice,
        'icon': '🎹',
        'time': '16:45',
        'duration': 20,
        'points': 15,
      },
      {
        'title': l10n.recPromiseReading,
        'icon': '📚',
        'time': '17:00',
        'duration': 20,
        'points': 10,
      },
      {
        'title': l10n.recPromiseHelp,
        'icon': '✨',
        'time': '17:30',
        'duration': 15,
        'points': 15,
      },
      {
        'title': l10n.recPromiseCleanUp,
        'icon': '🧸',
        'time': '18:30',
        'duration': 15,
        'points': 10,
      },
      {
        'title': l10n.promiseDefault4Title,
        'icon': '🛀',
        'time': '18:00',
        'duration': 30,
        'points': 20,
      },
      {
        'title': l10n.recPromisePajamas,
        'icon': '👚',
        'time': '18:40',
        'duration': 10,
        'points': 10,
      },
      {
        'title': l10n.promiseDefault5Title,
        'icon': '🍛',
        'time': '19:00',
        'duration': 30,
        'points': 20,
      },
      {
        'title': l10n.promiseDefault6Title,
        'icon': '🪥',
        'time': '19:30',
        'duration': 10,
        'points': 10,
      },
      {
        'title': l10n.recPromisePrepareNextDay,
        'icon': '🎒',
        'time': '19:45',
        'duration': 15,
        'points': 15,
      },
      {
        'title': l10n.promiseDefault7Title,
        'icon': '💤',
        'time': '20:00',
        'duration': 10,
        'points': 10,
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    _loadPromises();
    if (widget.isTutorial) {
      // チュートリアルモード: 初回ダイアログ（ステップ3）を表示
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showTutorialStep3Dialog();
      });
    } else {
      _checkFirstYakusoku();
    }
  }

  Future<void> _loadPromises() async {
    final loadedPromises = await SharedPrefsHelper.loadRegularPromises(context);
    loadedPromises.sort((a, b) {
      final timeA = a['time'] ?? '00:00';
      final timeB = b['time'] ?? '00:00';
      return timeA.compareTo(timeB);
    });
    setState(() {
      _regularPromises = loadedPromises;
    });
  }

  /// 初回訪問時のみダイアログを表示する
  Future<void> _checkFirstYakusoku() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isFirst = prefs.getBool('is_first_yakusoku') ?? true;

    if (isFirst) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Image.asset(
                        'assets/images/clothes_dress_red.gif',
                        height: 90,
                      ),
                      const SizedBox(width: 16),
                      Image.asset(
                        'assets/images/character_kuma.gif',
                        height: 90,
                      ),
                    ],
                  ),
                  ClipPath(
                    clipper: _SpeechBubbleTailClipper(),
                    child: Container(
                      width: 24,
                      height: 16,
                      color: const Color(0xFFFFF7E6),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 22,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7E6),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildRichText(
                          AppLocalizations.of(context)!.samplePromiseTitle,
                          isTitle: true,
                        ),
                        const SizedBox(height: 10),
                        _buildRichText(
                          AppLocalizations.of(context)!.samplePromiseDesc,
                          isTitle: false,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            _playTapSound();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7043),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(220, 64),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            elevation: 8,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.gotIt,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
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
        );
      });
      await prefs.setBool('is_first_yakusoku', false);
    }
  }

  Widget _buildRichText(
    String text, {
    required bool isTitle,
    TextAlign textAlign = TextAlign.center,
  }) {
    final List<TextSpan> spans = [];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastMatchEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE64A19),
            fontSize: isTitle ? 18 : 16,
          ),
        ),
      );
      lastMatchEnd = match.end;
    }
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return RichText(
      textAlign: textAlign,
      text: TextSpan(
        style: TextStyle(
          fontSize: isTitle ? 18 : 16,
          fontWeight: isTitle ? FontWeight.bold : FontWeight.normal,
          color: Colors.black87,
          height: 1.5,
        ),
        children: spans,
      ),
    );
  }

  void _deletePromise(int index) {
    final String deletedPromiseTitle = _regularPromises[index]['title'];
    setState(() {
      _regularPromises.removeAt(index);
    });
    SharedPrefsHelper.saveRegularPromises(_regularPromises);

    NotificationManager.instance.scheduleAllRegularPromises(_regularPromises);

    // チュートリアル中にやくそく（おためし）を削除したらステップ5へ
    if (widget.isTutorial &&
        _tutorialPhase == _TutorialPhase.delete &&
        deletedPromiseTitle == _getTrialTemplate(context)['title']) {
      setState(() => _tutorialPhase = _TutorialPhase.finish);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showTutorialStep5Dialog();
      });
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.promiseDeleted(deletedPromiseTitle),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToAddScreen() async {
    _playTapSound();
    final newPromise = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const AddEditPromiseScreen()),
    );

    if (newPromise != null) {
      setState(() {
        _regularPromises.add(newPromise);
        _regularPromises.sort((a, b) {
          final timeA = a['time'] ?? '00:00';
          final timeB = b['time'] ?? '00:00';
          return timeA.compareTo(timeB);
        });
      });
      SharedPrefsHelper.saveRegularPromises(_regularPromises);

      NotificationManager.instance.scheduleAllRegularPromises(_regularPromises);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.promiseAdded(newPromise['title']),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToEditScreen(int index) async {
    final promiseToEdit = _regularPromises[index];
    final updatedPromise = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddEditPromiseScreen(initialPromise: promiseToEdit),
      ),
    );

    if (updatedPromise != null) {
      setState(() {
        _regularPromises[index] = updatedPromise;
        _regularPromises.sort((a, b) {
          final timeA = a['time'] ?? '00:00';
          final timeB = b['time'] ?? '00:00';
          return timeA.compareTo(timeB);
        });
      });
      SharedPrefsHelper.saveRegularPromises(_regularPromises);

      NotificationManager.instance.scheduleAllRegularPromises(_regularPromises);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            )!.promiseUpdated(updatedPromise['title']),
          ),
        ),
      );
    }
  }

  void _addRecommendedPromise(Map<String, dynamic> template) {
    bool exists = _regularPromises.any((p) => p['title'] == template['title']);
    if (exists) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // ▼ 変更: 多言語対応
          content: Text(
            AppLocalizations.of(
              context,
            )!.alreadyAddedPromise(template['title']),
          ),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    setState(() {
      _regularPromises.add({
        'title': template['title'],
        'icon': template['icon'],
        'time': template['time'],
        'duration': template['duration'],
        'points': template['points'],
      });
      _regularPromises.sort((a, b) {
        final timeA = a['time'] ?? '00:00';
        final timeB = b['time'] ?? '00:00';
        return timeA.compareTo(timeB);
      });
    });

    // チュートリアル中におためしを追加したらフェーズをdeleteへ
    if (widget.isTutorial &&
        _tutorialPhase == _TutorialPhase.add &&
        template['title'] == _getTrialTemplate(context)['title']) {
      setState(() => _tutorialPhase = _TutorialPhase.delete);
      return;
    }

    SharedPrefsHelper.saveRegularPromises(_regularPromises);

    NotificationManager.instance.scheduleAllRegularPromises(_regularPromises);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.promiseAdded(template['title']),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ---- チュートリアルダイアログ ----

  Future<void> _showTutorialStep3Dialog() async {
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.asset(
                    'assets/images/clothes_dress_red.gif',
                    height: 90,
                  ),
                  const SizedBox(width: 16),
                  Image.asset('assets/images/character_kuma.gif', height: 90),
                ],
              ),
              ClipPath(
                clipper: _SpeechBubbleTailClipper(),
                child: Container(
                  width: 24,
                  height: 16,
                  color: const Color(0xFFFFF7E6),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 22,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E6),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildRichText(
                      AppLocalizations.of(ctx)!.tutorialParentStep3Title,
                      isTitle: true,
                    ),
                    const SizedBox(height: 10),
                    _buildRichText(
                      AppLocalizations.of(ctx)!.tutorialParentStep3Desc,
                      isTitle: false,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        try {
                          SfxManager.instance.playTapSound();
                        } catch (_) {}
                        Navigator.of(ctx).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7043),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(220, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        elevation: 8,
                      ),
                      child: Text(
                        AppLocalizations.of(ctx)!.gotIt,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
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
    );
  }

  Future<void> _showTutorialStep5Dialog() async {
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.asset(
                    'assets/images/clothes_dress_red.gif',
                    height: 90,
                  ),
                  const SizedBox(width: 16),
                  Image.asset('assets/images/character_kuma.gif', height: 90),
                ],
              ),
              ClipPath(
                clipper: _SpeechBubbleTailClipper(),
                child: Container(
                  width: 24,
                  height: 16,
                  color: const Color(0xFFFFF7E6),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 22,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E6),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildRichText(
                      AppLocalizations.of(ctx)!.tutorialParentStep5Title,
                      isTitle: true,
                    ),
                    const SizedBox(height: 10),
                    _buildRichText(
                      AppLocalizations.of(ctx)!.tutorialParentStep5Desc,
                      isTitle: false,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        try {
                          SfxManager.instance.playTapSound();
                        } catch (_) {}
                        Navigator.of(ctx).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7043),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(220, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        elevation: 8,
                      ),
                      child: Text(
                        AppLocalizations.of(ctx)!.gotIt,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
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
    );
  }

  void _playTapSound() {
    try {
      SfxManager.instance.playTapSound();
    } catch (e) {
      debugPrint('再生エラー: $e');
    }
  }

  Widget _buildRecommendedCard(
    Map<String, dynamic> template, {
    bool isDragging = false,
  }) {
    final bool isTutorialTrialCard =
        widget.isTutorial &&
        _tutorialPhase == _TutorialPhase.add &&
        template['title'] == _getTrialTemplate(context)['title'];
    final bool isDisabledInTutorial =
        widget.isTutorial &&
        (_tutorialPhase == _TutorialPhase.add ||
            _tutorialPhase == _TutorialPhase.delete) &&
        template['title'] != _getTrialTemplate(context)['title'];

    final card = Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: isDragging ? 8 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Text(template['icon'], style: const TextStyle(fontSize: 28)),
        title: Text(
          template['title'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          '${template['time']} / ${template['duration']}分 / ${template['points']}pt',
          style: const TextStyle(fontSize: 10),
        ),
        trailing: isTutorialTrialCard
            ? Stack(
                clipBehavior: Clip.none,
                children: [
                  BlinkingEffect(
                    isBlinking: true,
                    child: IconButton(
                      icon: Icon(
                        Icons.add_circle,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: () {
                        if (widget.isTutorial) {
                          FirebaseAnalytics.instance.logEvent(
                            name: 'start_promise_add_tutorial',
                          );
                        }
                        _playTapSound();
                        _addRecommendedPromise(template);
                      },
                    ),
                  ),
                  Positioned(
                    right: 46,
                    top: 20,
                    child: _buildBubble(
                      AppLocalizations.of(context)!.tutorialParentAddBubble,
                      alignRight: true,
                    ),
                  ),
                ],
              )
            : IgnorePointer(
                ignoring: isDisabledInTutorial,
                child: Opacity(
                  opacity: isDisabledInTutorial ? 0.4 : 1.0,
                  child: IconButton(
                    icon: Icon(
                      Icons.add_circle,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      _playTapSound();
                      _addRecommendedPromise(template);
                    },
                  ),
                ),
              ),
      ),
    );
    return card;
  }

  Widget _buildCurrentPromiseCard(Map<String, dynamic> promise, int index) {
    final iconEmoji = promise['icon'] ?? '✨';
    final bool isTutorialTrialCard =
        widget.isTutorial &&
        _tutorialPhase == _TutorialPhase.delete &&
        promise['title'] == _getTrialTemplate(context)['title'];

    Widget deleteButton;
    if (isTutorialTrialCard) {
      deleteButton = Stack(
        clipBehavior: Clip.none,
        children: [
          BlinkingEffect(
            isBlinking: true,
            child: IconButton(
              icon: Icon(Icons.delete, color: Colors.red[400], size: 20),
              onPressed: () {
                _playTapSound();
                _deletePromise(index);
              },
            ),
          ),
          Positioned(
            right: 44,
            top: -4,
            child: _buildBubble(
              AppLocalizations.of(context)!.tutorialParentDeleteBubble,
              alignRight: true,
            ),
          ),
        ],
      );
    } else {
      final bool disabled =
          widget.isTutorial &&
          (_tutorialPhase == _TutorialPhase.add ||
              _tutorialPhase == _TutorialPhase.delete);
      deleteButton = IgnorePointer(
        ignoring: disabled,
        child: Opacity(
          opacity: disabled ? 0.4 : 1.0,
          child: IconButton(
            icon: Icon(Icons.delete, color: Colors.red[400], size: 20),
            onPressed: () {
              if (widget.isTutorial) {
                FirebaseAnalytics.instance.logEvent(
                  name: 'start_promise_delete_tutorial',
                );
              }
              _playTapSound();
              _deletePromise(index);
            },
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        dense: true,
        leading: Text(iconEmoji, style: const TextStyle(fontSize: 24)),
        title: Text(
          promise['title'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${AppLocalizations.of(context)!.timeLabel}: ${promise['time']} / ${promise['duration']}${AppLocalizations.of(context)!.minutesLabel} / ${promise['points']}${AppLocalizations.of(context)!.points}',
          style: const TextStyle(fontSize: 11),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IgnorePointer(
              ignoring:
                  widget.isTutorial &&
                  (_tutorialPhase == _TutorialPhase.add ||
                      _tutorialPhase == _TutorialPhase.delete),
              child: Opacity(
                opacity:
                    widget.isTutorial &&
                        (_tutorialPhase == _TutorialPhase.add ||
                            _tutorialPhase == _TutorialPhase.delete)
                    ? 0.4
                    : 1.0,
                child: IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () {
                    _playTapSound();
                    _navigateToEditScreen(index);
                  },
                ),
              ),
            ),
            deleteButton,
          ],
        ),
      ),
    );
  }

  /// 吹き出しウィジェット
  Widget _buildBubble(String text, {bool alignRight = false}) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 140),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange, width: 2),
        boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final trialTemplate = _getTrialTemplate(context);
    final recommendedTemplates = _getRecommendedTemplates(context);

    // チュートリアル中の場合はおためしテンプレートを先頭に追加
    final baseTemplates =
        widget.isTutorial && _tutorialPhase == _TutorialPhase.add
        ? [trialTemplate, ...recommendedTemplates]
        : recommendedTemplates;

    // 現在のやくそくに「無い」テンプレートだけを抽出する
    final availableTemplates = baseTemplates.where((template) {
      return !_regularPromises.any(
        (promise) => promise['title'] == template['title'],
      );
    }).toList();

    // チュートリアル finish フェーズ: 戻るボタン点滅、他はすべて操作可能
    final bool isFinishPhase =
        widget.isTutorial && _tutorialPhase == _TutorialPhase.finish;
    // チュートリアル add/delete フェーズ: 他のボタンをブロック
    final bool blockOtherButtons =
        widget.isTutorial &&
        (_tutorialPhase == _TutorialPhase.add ||
            _tutorialPhase == _TutorialPhase.delete);

    return Scaffold(
      appBar: AppBar(
        leading: isFinishPhase
            ? BlinkingEffect(
                isBlinking: true,
                borderRadius: 8,
                child: BackButton(
                  onPressed: () {
                    if (widget.isTutorial) {
                      FirebaseAnalytics.instance.logEvent(
                        name: 'finish_regular_promise_settings_tutorial',
                      );
                    }
                    if (Navigator.of(context).canPop())
                      Navigator.of(context).pop();
                  },
                ),
              )
            : IgnorePointer(
                ignoring: blockOtherButtons,
                child: const CustomBackButton(),
              ),
        title: Text(l10n.regularPromiseSettingsTitle),
        actions: [
          IgnorePointer(
            ignoring:
                widget.isTutorial &&
                _tutorialPhase != _TutorialPhase.done &&
                _tutorialPhase != _TutorialPhase.finish,
            child: Opacity(
              opacity:
                  widget.isTutorial &&
                      _tutorialPhase != _TutorialPhase.done &&
                      _tutorialPhase != _TutorialPhase.finish
                  ? 0.4
                  : 1.0,
              child: InkWell(
                onTap: () {
                  FirebaseAnalytics.instance.logEvent(
                    name: 'start_regular_promise_settings_add',
                  );
                  _navigateToAddScreen();
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
                      const Icon(Icons.add),
                      Text(
                        // ▼ 変更: 多言語対応
                        l10n.customAdd,
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
        child: Row(
          children: [
            // 左側：おすすめのやくそく
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
                    Expanded(
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: availableTemplates.length,
                        itemBuilder: (context, index) {
                          final template = availableTemplates[index];
                          // チュートリアルのadd以外フェーズでは左側全体をブロック
                          final bool disableLeft =
                              widget.isTutorial &&
                              _tutorialPhase != _TutorialPhase.add &&
                              _tutorialPhase != _TutorialPhase.finish;
                          return IgnorePointer(
                            ignoring: disableLeft,
                            child: LongPressDraggable<Map<String, dynamic>>(
                              data: template,
                              feedback: Material(
                                color: Colors.transparent,
                                child: _buildRecommendedCard(
                                  template,
                                  isDragging: true,
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.5,
                                child: _buildRecommendedCard(template),
                              ),
                              child: _buildRecommendedCard(template),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 右側：今のやくそく
            Expanded(
              flex: 6,
              child: DragTarget<Map<String, dynamic>>(
                onWillAcceptWithDetails: (details) => true,
                onAcceptWithDetails: (details) {
                  _addRecommendedPromise(details.data);
                },
                builder: (context, candidateData, rejectedData) {
                  final isHovered = candidateData.isNotEmpty;
                  return Container(
                    color: isHovered
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Text(
                            // ▼ 変更: 多言語対応
                            '📝 ${l10n.currentPromiseTitle}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _regularPromises.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.arrow_back,
                                        size: 48,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        // ▼ 変更: 多言語対応
                                        l10n.dragToAddInstruction,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _regularPromises.length,
                                  itemBuilder: (context, index) {
                                    final promise = _regularPromises[index];
                                    return _buildCurrentPromiseCard(
                                      promise,
                                      index,
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeechBubbleTailClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
