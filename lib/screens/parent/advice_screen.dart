// lib/screens/parent_mode/advice_screen.dart

import 'package:flutter/material.dart';

class AdviceScreen extends StatelessWidget {
  const AdviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('やくそく設定のヒント')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '「できた！」を増やすためのヒント💡',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            AdvicePoint(
              icon: Icons.people_outline,
              title: 'やくそくは、お子さんと一緒に決める',
              description:
                  '「何を」「いつまでに」「何ポイントで」やるか、お子さんと一緒に話しながら決めてみましょう。自分で決めたルールだからこそ、挑戦する気持ちが芽生えます。',
            ),
            AdvicePoint(
              icon: Icons.child_care,
              title: '最初は「かんたん」から始めよう',
              description:
                  'まずは、お子さんが絶対にクリアできる簡単なやくそくから始めましょう。「できた！」という成功体験を積み重ねることが、自信に繋がります。',
            ),
            AdvicePoint(
              icon: Icons.timer,
              title: '時間は「少しだけ多め」に設定',
              description:
                  '「急がなきゃ！」と焦らせるのではなく、「時間内にできた！」という達成感を味わえるように、最初のうちは挑戦時間を少しだけ長めに設定してあげるのがコツです。',
            ),
            AdvicePoint(
              icon: Icons.star,
              title: 'ポイントは「特別感」を大切に',
              description:
                  '難しいやくそくほど、もらえるポイントを少しだけ高く設定してみましょう。「このミッションは特別だ！」と感じることで、お子さんの挑戦意欲を引き出します。',
            ),
            AdvicePoint(
              icon: Icons.comment,
              title: '一番のごほうびは「言葉」です',
              description:
                  'アプリでのポイントも大切ですが、やくそくを達成したときには、ぜひ「よくできたね！」「すごい！」と、直接言葉で褒めてあげてください。それが、お子さんにとって最高のエネルギーになります。',
            ),
          ],
        ),
      ),
    );
  }
}

// アドバイスの各項目をきれいに表示するための共通ウィジェット
class AdvicePoint extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const AdvicePoint({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 30, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
