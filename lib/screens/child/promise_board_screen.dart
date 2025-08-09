import 'package:flutter/material.dart';
import 'timer_screen.dart';

final List<Map<String, String>> dummyPromises = [
  {'time': '7:00〜', 'title': 'あさごはん', 'points': '10'},
  {'time': '7:30〜', 'title': 'ようちえんのじゅんび', 'points': '20'},
  {'time': '16:30〜', 'title': 'おふろ', 'points': '10'},
  {'time': '18:30〜', 'title': 'よるごはん', 'points': '10'},
];

class PromiseBoardScreen extends StatelessWidget {
  const PromiseBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 画面上部のバー
      appBar: AppBar(title: const Text('やくそくボード')),
      // 画面の中央
      body: ListView.builder(
        // リストに何個の項目があるかを教えます
        itemCount: dummyPromises.length,
        // 各項目をどのように表示するかを決めます
        itemBuilder: (context, index) {
          final promise = dummyPromises[index];
          return Card(
            // 各項目をカード風のUIにします
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              // 左側に表示する時間
              leading: Text(
                promise['time']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              // 中央に表示するやくそくの名前
              title: Text(promise['title']!),
              // 右側に表示する「はじめる」ボタン
              trailing: ElevatedButton(
                onPressed: () async {
                  // タイマー画面から戻ってくるのを「await」で待ち、結果を受け取る
                  final pointsAwarded = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TimerScreen(promise: promise),
                    ),
                  );

                  // もし、ポイント（結果）を持って戻ってきたら
                  if (pointsAwarded != null && context.mounted) {
                    // やくそくボード画面も閉じて、ホーム画面にポイントを渡す
                    Navigator.pop(context, pointsAwarded);
                  }
                },
                style: ElevatedButton.styleFrom(
                  // main.dartで設定したアクセントカラーが自動で適用される
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
                child: const Text('はじめる'),
              ),
            ),
          );
        },
      ),
    );
  }
}
