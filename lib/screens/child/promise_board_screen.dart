import 'package:flutter/material.dart';
import 'timer_screen.dart';
import '../../helpers/shared_prefs_helper.dart';
import '../../managers/bgm_manager.dart';
import '../../managers/sfx_manager.dart';
import '../../widgets/ad_banner.dart';
import '../../l10n/app_localizations.dart';
import '../../screens/parent/advice_screen.dart';
import '../../screens/parent/regular_promise_settings_screen.dart';
import '../child/math_lock_dialog.dart'; // ロック画面
import '../child/passcode_lock_dialog.dart';
import '../../models/lock_mode.dart';

class PromiseBoardScreen extends StatefulWidget {
  // StatefulWidgetに変更
  const PromiseBoardScreen({super.key});

  @override
  State<PromiseBoardScreen> createState() => _PromiseBoardScreenState();
}

class _PromiseBoardScreenState extends State<PromiseBoardScreen> {
  // 表示用のリストを管理する変数
  List<Map<String, dynamic>> _promises = [];
  // 今日の達成済みやくそくリストを管理する変数
  List<String> _todaysCompletedTitles = [];

  // 最初にデータを読み込む
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // 画面が表示されるたびに、やくそくと達成記録の両方を読み込む
  Future<void> _loadData() async {
    final loadedPromises = await SharedPrefsHelper.loadRegularPromises(context);
    final completedTitles =
        await SharedPrefsHelper.loadTodaysCompletedPromiseTitles();

    loadedPromises.sort((a, b) {
      final timeA = a['time'] ?? '00:00';
      final timeB = b['time'] ?? '00:00';
      return timeA.compareTo(timeB);
    });

    if (!mounted) return;
    setState(() {
      _promises = loadedPromises;
      _todaysCompletedTitles = completedTitles;
    });
  }

  // 「はじめる」ボタンが押された時の処理
  void _startPromise(Map<String, dynamic> promise) async {
    // ★タイマー画面に行く前に、集中BGMを再生
    // ★ 保存されている集中BGM設定を読み込む
    final trackName = await SharedPrefsHelper.loadSelectedFocusBgm();
    final focusTrack = BgmTrack.values.firstWhere(
      (e) => e.name == trackName,
      orElse: () => BgmTrack.focus_original, // 保存されていなければデフォルト
    );

    // ★ タイマー画面に行く前に、"選択された"集中BGMを再生
    try {
      BgmManager.instance.play(focusTrack);
    } catch (e) {
      // エラーが発生した場合
      print('再生エラー: $e');
    }

    final result = await Navigator.push<Map<String, int>?>(
      context,
      MaterialPageRoute(
        builder: (context) => TimerScreen(promise: promise, isEmergency: false),
      ),
    );

    // 戻り値からポイントと経験値を取得
    final pointsAwarded = result != null ? result['points'] : null;
    final exp = result != null ? result['exp'] : null;

    // ★タイマー画面から戻ってきたら、メインBGMを再生
    _playSavedBgm();

    if (pointsAwarded != null && pointsAwarded > 0) {
      // 達成記録を保存する処理を追加！
      await SharedPrefsHelper.addCompletionRecord(promise['title']);

      if (mounted) {
        // ポイントを持ってホーム画面に戻る
        Navigator.pop(context, {'points': pointsAwarded, 'exp': exp});
      }
    }
  }

  Future<void> _playSavedBgm() async {
    final trackName = await SharedPrefsHelper.loadSelectedBgm();
    final track = BgmTrack.values.firstWhere(
      (e) => e.name == trackName,
      orElse: () => BgmTrack.main, // デフォルトはmain
    );
    try {
      BgmManager.instance.play(track);
    } catch (e) {
      // エラーが発生した場合
      print('再生エラー: $e');
    }
  }

  void _skipPromiseOnBoard(String promiseTitle) async {
    // 達成記録を保存します
    await SharedPrefsHelper.addCompletionRecord(promiseTitle);
    // リストの表示を最新の状態に更新します
    _loadData();
  }

  void _navigateToAddPromise() async {
    try {
      SfxManager.instance.playTapSound();
    } catch (e) {
      // エラーが発生した場合
      print('再生エラー: $e');
    }
    // 1. ロック画面を表示する
    final lockMode = await SharedPrefsHelper.loadLockMode();
    final bool? isCorrect = await showDialog<bool>(
      context: context,
      builder: (context) {
        if (lockMode == LockMode.passcode) {
          return const PasscodeLockDialog();
        }
        return const MathLockDialog();
      },
    );

    // 2. ロックが解除されたら、やくそく設定画面に遷移
    if (isCorrect == true && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RegularPromiseSettingsScreen(),
        ),
      );
      // ★ 設定画面から戻ってきたら、リストを再読み込みして最新の状態を反映
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.promiseBoard),
        actions: [
          // ？ボタン (アドバイス画面へ)
          IconButton(
            icon: const Icon(Icons.question_mark_outlined),
            onPressed: () {
              try {
                SfxManager.instance.playTapSound();
              } catch (e) {
                // エラーが発生した場合
                print('再生エラー: $e');
              }
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdviceScreen()),
              );
            },
          ),
          // ⚙ボタン (やくそく設定画面へ)
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToAddPromise,
          ),
        ],
      ),
      body: _promises.isEmpty
          ? Center(child: Text(AppLocalizations.of(context)!.noRegularPromises))
          : ListView.builder(
              itemCount: _promises.length,
              itemBuilder: (context, index) {
                final promise = _promises[index];
                // このやくそくが、今日達成済みかどうかをチェック
                final bool isCompleted = _todaysCompletedTitles.contains(
                  promise['title'],
                );

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: Text(
                      promise['time'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    title: Text(
                      promise['title'] ??
                          AppLocalizations.of(context)!.untitled,
                    ),
                    trailing: isCompleted
                        ? const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 40,
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min, // Rowが必要な分だけ幅をとる
                            children: [
                              // 「やらなかった」ボタン
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.grey[400],
                                ),
                                onPressed: () {
                                  try {
                                    SfxManager.instance.playTapSound();
                                  } catch (e) {
                                    // エラーが発生した場合
                                    print('再生エラー: $e');
                                  }
                                  _skipPromiseOnBoard(promise['title']);
                                },
                              ),
                              // 「はじめる」ボタン
                              ElevatedButton(
                                onPressed: () {
                                  _startPromise(promise);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.startPromise,
                                ),
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
      // 画面下部にバナーを設置
      bottomNavigationBar: const AdBanner(),
    );
  }
}
