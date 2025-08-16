import 'package:flutter/material.dart';
import 'timer_screen.dart';
import '../../helpers/shared_prefs_helper.dart';

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
    final loadedPromises = await SharedPrefsHelper.loadRegularPromises();
    final completedTitles =
        await SharedPrefsHelper.loadTodaysCompletedPromiseTitles();
    if (!mounted) return;
    setState(() {
      _promises = loadedPromises;
      _todaysCompletedTitles = completedTitles;
    });
  }

  // 「はじめる」ボタンが押された時の処理
  void _startPromise(Map<String, dynamic> promise) async {
    final pointsAwarded = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (context) => TimerScreen(promise: promise, isEmergency: false),
      ),
    );

    if (pointsAwarded != null && pointsAwarded > 0) {
      // 達成記録を保存する処理を追加！
      await SharedPrefsHelper.addCompletionRecord(promise['title']);

      if (mounted) {
        // ポイントを持ってホーム画面に戻る
        Navigator.pop(context, pointsAwarded);
      }
    }
  }

  void _skipPromiseOnBoard(String promiseTitle) async {
    // 達成記録を保存します
    await SharedPrefsHelper.addCompletionRecord(promiseTitle);
    // リストの表示を最新の状態に更新します
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('やくそくボード')),
      body: _promises.isEmpty
          ? const Center(child: Text('定例のやくそくがまだありません'))
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
                    title: Text(promise['title'] ?? '名称未設定'),
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
                                child: const Text('はじめる'),
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
    );
  }
}
