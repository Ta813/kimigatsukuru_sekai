// lib/screens/world_ranking_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kimigatsukuru_sekai/l10n/app_localizations.dart';
import 'package:kimigatsukuru_sekai/models/mini_game_name.dart';

class MiniGameType {
  final String id;
  final String label;
  final String icon;
  final String keySuffix;

  const MiniGameType({
    required this.id,
    required this.label,
    required this.icon,
    this.keySuffix = '',
  });
}

class WorldRankingScreen extends StatefulWidget {
  const WorldRankingScreen({super.key});

  @override
  State<WorldRankingScreen> createState() => _WorldRankingScreenState();
}

class _WorldRankingScreenState extends State<WorldRankingScreen> {
  String _selectedGameId = 'dodge';

  @override
  Widget build(BuildContext context) {
    // 🌟 ミニゲーム一覧（将来ミニゲームが増えたらここに追記するだけでOK！）
    final gameTypes = [
      MiniGameType(
        id: 'dodge',
        label: AppLocalizations.of(context)!.miniGameDodge,
        icon: '🏃‍♂️',
        keySuffix: '',
      ),
      MiniGameType(id: 'jump', label: 'ジャンプ！', icon: '🪂', keySuffix: '_jump'),
    ];

    // ランキングを表示したいコースのリスト
    final courses = ['いつものせかい', 'おおきなしま', 'うみ', 'そら', 'うちゅう', 'ジャングル', 'さばく'];

    return DefaultTabController(
      length: courses.length,
      child: Scaffold(
        backgroundColor: const Color(0xFFE3F2FD), // 世界をイメージした薄い青
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.worldRankingTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            isScrollable: true, // タブが多くてもスクロール可能に
            indicatorColor: Colors.orangeAccent,
            indicatorWeight: 4,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: courses
                .map(
                  (course) =>
                      Tab(text: MiniGameName.getMiniGameName(course, context)),
                )
                .toList(),
          ),
        ),
        body: Column(
          children: [
            // 🌟 ゲーム選択ボタンエリア（横スクロール可能で増えても安心）
            Container(
              color: Colors.blueAccent,
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: gameTypes.map((game) {
                    final isSelected = _selectedGameId == game.id;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_selectedGameId != game.id) {
                            setState(() {
                              _selectedGameId = game.id;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected
                              ? Colors.orangeAccent
                              : Colors.white,
                          foregroundColor: isSelected
                              ? Colors.white
                              : Colors.black87,
                          elevation: isSelected ? 4 : 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              game.icon,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              game.label,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: courses
                    .map((course) => _buildRankingList(course, gameTypes))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🌟 コースごとのランキングリストをFirestoreからリアルタイム取得
  Widget _buildRankingList(String courseName, List<MiniGameType> gameTypes) {
    final currentGame = gameTypes.firstWhere(
      (g) => g.id == _selectedGameId,
      orElse: () => gameTypes.first,
    );
    final queryCourseKey = '$courseName${currentGame.keySuffix}';

    return StreamBuilder<QuerySnapshot>(
      // ⚠️ コスト爆発を防ぐため、必ず orderBy で高い順にし、limit で件数を絞る！
      stream: FirebaseFirestore.instance
          .collection('world_rankings')
          .where('course', isEqualTo: queryCourseKey)
          .orderBy('score', descending: true)
          .limit(30) // 上位30人まで
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('ランキングを読み込めませんでした'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.emoji_events_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.worldRankingEmpty(
                    MiniGameName.getMiniGameName(courseName, context),
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final score = data['score'] as int? ?? 0;
            final rank = index + 1;

            // 順位による装飾の変更
            Color cardColor = Colors.white;
            Widget rankIcon;
            if (rank == 1) {
              cardColor = Colors.amber.shade50;
              rankIcon = const Icon(
                Icons.emoji_events,
                color: Colors.amber,
                size: 40,
              );
            } else if (rank == 2) {
              cardColor = Colors.grey.shade100;
              rankIcon = const Icon(
                Icons.emoji_events,
                color: Colors.grey,
                size: 36,
              );
            } else if (rank == 3) {
              cardColor = Colors.brown.shade50;
              rankIcon = const Icon(
                Icons.emoji_events,
                color: Colors.brown,
                size: 32,
              );
            } else {
              rankIcon = CircleAvatar(
                backgroundColor: Colors.blueAccent.withOpacity(0.1),
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }

            return Card(
              color: cardColor,
              elevation: rank <= 3 ? 4 : 1,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: SizedBox(width: 50, child: Center(child: rankIcon)),
                trailing: Text(
                  AppLocalizations.of(context)!.miniGameScoreDisplay(score),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: rank <= 3 ? Colors.orange : Colors.black87,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
