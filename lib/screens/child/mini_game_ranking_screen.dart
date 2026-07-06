// lib/screens/mini_game_ranking_screen.dart

import 'package:flutter/material.dart';
import 'package:kimigatsukuru_sekai/helpers/shared_prefs_helper.dart';
import 'package:kimigatsukuru_sekai/l10n/app_localizations.dart';
import 'package:kimigatsukuru_sekai/models/mini_game_name.dart';

class GameRankingScreen extends StatelessWidget {
  final String courseName;
  final Color themeColor;

  const GameRankingScreen({
    super.key,
    required this.courseName,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.miniGameRankingTitle(
            MiniGameName.getMiniGameName(courseName, context),
          ),
        ),
        backgroundColor: themeColor,
      ),
      body: FutureBuilder<List<int>>(
        future: SharedPrefsHelper.getRanking(courseName),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final ranking = snapshot.data!;

          if (ranking.isEmpty) {
            return Center(
              child: Text(AppLocalizations.of(context)!.miniGameRankingEmpty),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: ranking.length,
            itemBuilder: (context, index) {
              final score = ranking[index];
              final rank = index + 1;

              // 1~3位までは特別なアイコン
              Widget leadingIcon;
              if (rank == 1)
                leadingIcon = const Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 40,
                );
              else if (rank == 2)
                leadingIcon = const Icon(
                  Icons.emoji_events,
                  color: Colors.grey,
                  size: 35,
                );
              else if (rank == 3)
                leadingIcon = const Icon(
                  Icons.emoji_events,
                  color: Colors.brown,
                  size: 30,
                );
              else
                leadingIcon = CircleAvatar(
                  backgroundColor: themeColor.withOpacity(0.2),
                  child: Text('$rank'),
                );

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: leadingIcon,
                  title: Text(
                    AppLocalizations.of(context)!.miniGameScoreDisplay(score),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
