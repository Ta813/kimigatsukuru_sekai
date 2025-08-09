import 'package:flutter/material.dart';
import 'promise_board_screen.dart';
import 'timer_screen.dart';

Map<String, String> dummyPromise = {
  'time': '7:00〜',
  'title': 'あさごはん',
  'points': '10',
};

class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({super.key});

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  // ポイント数の状態を管理するための変数（仮のデータ）
  int _points = 120;

  @override
  Widget build(BuildContext context) {
    // Scaffoldが画面全体の基本的な骨組みです
    return Scaffold(
      body: Stack(
        children: [
          // ここに、背景、アバター、家、ボタンなどを重ねていきます

          // 背景
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                // 背景画像のファイル名を指定
                image: AssetImage('assets/images/world.jpg'),

                // 画像を画面全体に綺麗に引き伸ばします
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 上のバー（ポイントや設定ボタン）
          // SafeAreaで、スマホの上のステータスバー（時間や電波表示）に
          // ボタンが隠れないようにします
          SafeArea(
            child: Stack(
              children: [
                // 2. 左上の「おやが見る画面へ」ボタン
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2), // 半透明の黒い背景
                      shape: BoxShape.circle, // 形を円にする
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.settings,
                        size: 40,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // TODO: おやが見る画面へ遷移する処理
                        print('設定ボタンが押されました');
                      },
                    ),
                  ),
                ),

                // 3. 右上の「ポイント表示」
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        // 少し影をつけて立体感を出す
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          '$_points', // ポイント数を表示
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 4. 右側の3つのボタン
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 10,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // やくそくボードボタン
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2), // 半透明の黒い背景
                            shape: BoxShape.circle, // 形を円にする
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.article_rounded,
                              size: 40,
                              color: Colors.white,
                            ),
                            onPressed: () async {
                              // やくそくボード画面から戻ってくるのを「await」で待ち、結果を受け取る
                              final pointsFromBoard = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PromiseBoardScreen(),
                                ),
                              );

                              // もし、ポイントを持って戻ってきたら
                              if (pointsFromBoard != null) {
                                // setStateを使って、ポイントを加算し、画面を更新！
                                setState(() {
                                  _points += (pointsFromBoard as int);
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 10), // ボタンの間に少し隙間をあける
                        // キャラクター選択ボタン
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2), // 半透明の黒い背景
                            shape: BoxShape.circle, // 形を円にする
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.face,
                              size: 40,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              // TODO: キャラクター選択画面へ遷移
                              print('キャラクター選択ボタンが押されました');
                            },
                          ),
                        ),
                        const SizedBox(height: 10), // ボタンの間に少し隙間をあける
                        // ごほうびショップボタン
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2), // 半透明の黒い背景
                            shape: BoxShape.circle, // 形を円にする
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.store,
                              size: 40,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              // TODO: ショップ画面へ遷移
                              print('ショップボタンが押されました');
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 真ん中のエリア（アバターと家）
          Align(
            alignment: Alignment.bottomCenter, // 画面下の中央を基準に配置
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80.0), // 下から少し浮かせる
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // 中央揃え
                crossAxisAlignment: CrossAxisAlignment.end, // アバターと家の底を揃える
                children: [
                  // アバター画像
                  Image.asset(
                    'assets/images/avatar.png', // あなたが用意した画像ファイル名
                    height: 80, // 高さを指定
                  ),
                  const SizedBox(width: 20), // アバターと家の間に隙間をあける
                  // 家の画像
                  Image.asset(
                    'assets/images/house.png', // あなたが用意した画像ファイル名
                    height: 180, // 高さを指定
                  ),
                ],
              ),
            ),
          ),

          // 下のバー（つぎのやくそく）
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).scaffoldBackgroundColor.withOpacity(0.7),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 左側のテキスト部分
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'つぎのやくそく',
                        style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${dummyPromise['time']} ${dummyPromise['title']}  ${dummyPromise['points']}ポイント', // 仮のデータ
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // 右と左の要素を離すための隙間
                  const Spacer(),

                  // 右側の「はじめる」ボタン
                  ElevatedButton(
                    onPressed: () async {
                      // タイマー画面から戻ってくるのを「await」で待ち、結果を受け取る
                      final pointsFromBoard = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TimerScreen(promise: dummyPromise),
                        ),
                      );

                      // もし、ポイントを持って戻ってきたら
                      if (pointsFromBoard != null) {
                        // setStateを使って、ポイントを加算し、画面を更新！
                        setState(() {
                          _points += (pointsFromBoard as int);
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.secondary, // ボタンの色
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      'はじめる',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
