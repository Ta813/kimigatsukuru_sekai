// lib/screens/world_ranking_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kimigatsukuru_sekai/l10n/app_localizations.dart';
import 'package:kimigatsukuru_sekai/models/mini_game_name.dart';

class WorldRankingScreen extends StatelessWidget {
  const WorldRankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ランキングを表示したいコースのリスト
    final courses = ['いつものせかい', 'おおきなしま', 'うみ', 'そら', 'うちゅう', 'ジャングル', 'さばく'];

    return DefaultTabController(
      length: courses.length,
      child: Scaffold(
        backgroundColor: const Color(0xFFE3F2FD), // 世界をイメージした薄い青
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.worldRankingTitle,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
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
        body: TabBarView(
          children: courses.map((course) => _buildRankingList(course)).toList(),
        ),
      ),
    );
  }

  // 🌟 コースごとのランキングリストをFirestoreからリアルタイム取得
  Widget _buildRankingList(String courseName) {
    return StreamBuilder<QuerySnapshot>(
      // ⚠️ コスト爆発を防ぐため、必ず orderBy で高い順にし、limit で件数を絞る！
      stream: FirebaseFirestore.instance
          .collection('world_rankings')
          .where('course', isEqualTo: courseName)
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
