// lib/screens/mini_game_hub_screen.dart

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:kimigatsukuru_sekai/l10n/app_localizations.dart';
import 'package:kimigatsukuru_sekai/screens/child/world_ranking_screen.dart';
import 'package:kimigatsukuru_sekai/widgets/breathing_avatar.dart';
import '../../helpers/shared_prefs_helper.dart';
import '../../models/shop_data.dart';
import '../../widgets/avatar_display.dart';
import '../../managers/sfx_manager.dart';
import 'mini_game_screen.dart'; // 前回作ったゲーム・コース選択画面

// ==============================================================
// 🌟 1. ミニゲーム・ハブ画面（入口）
// ==============================================================
class MiniGameHubScreen extends StatefulWidget {
  final int userLevel;
  const MiniGameHubScreen({super.key, required this.userLevel});

  @override
  State<MiniGameHubScreen> createState() => _MiniGameHubScreenState();
}

class _MiniGameHubScreenState extends State<MiniGameHubScreen> {
  String _selectedCharPath = 'MY_AVATAR';
  int _tickets = 0;

  String _equippedFace = 'assets/images/face/face_default.png';
  String _equippedHair = 'assets/images/hair/hair_default.png';
  String _equippedClothes = 'assets/images/clothes/clothes_default.png';
  String? _equippedHeadgear;
  String? _equippedAccessory;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    final char = await SharedPrefsHelper.getMiniGameCharacter();
    final tickets = await SharedPrefsHelper.getGameTickets();

    final face = await SharedPrefsHelper.loadEquippedFace();
    final hair = await SharedPrefsHelper.loadEquippedHairstyle();
    final clothes = await SharedPrefsHelper.loadEquippedClothes();
    final headgear = await SharedPrefsHelper.loadEquippedHeadgear();
    final accessory = await SharedPrefsHelper.loadEquippedAccessory();

    setState(() {
      _selectedCharPath = char;
      _tickets = tickets;

      _equippedFace = face ?? 'assets/images/face/face_default.png';
      _equippedHair = hair ?? 'assets/images/hair/hair_default.png';
      _equippedClothes = clothes ?? 'assets/images/clothes/clothes_default.png';
      _equippedHeadgear = headgear;
      _equippedAccessory = accessory;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.miniGameParkTitle),
        backgroundColor: const Color(0xFFFF7043),
        // 🌟 追加: 世界ランキングへの入口
        actions: [
          IconButton(
            icon: const Icon(Icons.public, size: 28),
            tooltip: AppLocalizations.of(context)!.worldRankingTooltip,
            onPressed: () {
              FirebaseAnalytics.instance.logEvent(name: 'world_ranking');
              try {
                SfxManager.instance.playTapSound();
              } catch (_) {}
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WorldRankingScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🎫 チケット枚数
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                AppLocalizations.of(
                  context,
                )!.miniGameTicketsRemaining(_tickets),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // 👤 現在のキャラクター表示 ＆ 変更ボタン
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  // 現在のキャラの見た目
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: _selectedCharPath == 'MY_AVATAR'
                        ? AnimatedAvatar(
                            child: AvatarDisplay(
                              face: _equippedFace,
                              clothes: _equippedClothes,
                              hair: _equippedHair,
                              headgear: _equippedHeadgear,
                              accessory: _equippedAccessory,
                              size: 80,
                            ),
                          ) // 👈 今のアバター設定をそのまま表示
                        : Image.asset(
                            _selectedCharPath,
                            cacheWidth: 160,
                          ), // 👈 応援キャラGIFを表示
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.miniGamePlayWithChar,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          _selectedCharPath == 'MY_AVATAR'
                              ? AppLocalizations.of(context)!.miniGameAvatar
                              : AppLocalizations.of(
                                  context,
                                )!.miniGameSupportChar,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        ElevatedButton(
                          onPressed: () async {
                            FirebaseAnalytics.instance.logEvent(
                              name: 'mini_game_change_char',
                            );
                            try {
                              SfxManager.instance.playTapSound();
                            } catch (_) {}
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const GameCharacterSelectorScreen(),
                              ),
                            );
                            _refreshData(); // 戻ってきたらキャラを更新
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.miniGameChangeChar,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Text(
                AppLocalizations.of(context)!.miniGameChooseGame,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // 🎮 ゲーム一覧（タイル）
            GridView.count(
              shrinkWrap: true, // 👈 魔法の1行その1：中身のアイテムの数だけ高さを広げる
              physics:
                  const NeverScrollableScrollPhysics(), // 👈 魔法の1行その2：GridView自身のスクロールを殺して、外側のスクロールに任せる
              padding: const EdgeInsets.all(10),
              crossAxisCount: 4,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              children: [
                //よけろ！
                _buildGameTile(
                  context,
                  title: AppLocalizations.of(context)!.miniGameDodge,
                  icon: Icons.directions_run,
                  color: Colors.blueAccent,
                  onTap: () async {
                    FirebaseAnalytics.instance.logEvent(
                      name: 'mini_game_dodge',
                    );
                    try {
                      SfxManager.instance.playTapSound();
                    } catch (_) {}
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MiniGameCoordinator(
                          userLevel: widget.userLevel,
                          gameType: 'dodge',
                        ),
                      ),
                    );
                    _refreshData();
                  },
                ),
                // ジャンプ！
                _buildGameTile(
                  context,
                  title: 'ジャンプ！',
                  icon: Icons.arrow_upward_rounded,
                  color: Colors.greenAccent.shade700,
                  onTap: () async {
                    FirebaseAnalytics.instance.logEvent(name: 'mini_game_jump');
                    try {
                      SfxManager.instance.playTapSound();
                    } catch (_) {}
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MiniGameCoordinator(
                          userLevel: widget.userLevel,
                          gameType: 'jump',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==============================================================
// 🌟 2. キャラクター選択画面（アバター ＋ 購入済みキャラ）
// ==============================================================
class GameCharacterSelectorScreen extends StatefulWidget {
  const GameCharacterSelectorScreen({super.key});

  @override
  State<GameCharacterSelectorScreen> createState() =>
      _GameCharacterSelectorScreenState();
}

class _GameCharacterSelectorScreenState
    extends State<GameCharacterSelectorScreen> {
  // アバター装備データを保持するフィールド
  String _equippedFace = 'assets/images/face/face_default.png';
  String _equippedHair = 'assets/images/hair/hair_default.png';
  String _equippedClothes = 'assets/images/clothes/clothes_default.png';
  String? _equippedHeadgear;
  String? _equippedAccessory;

  @override
  void initState() {
    super.initState();
    _loadAvatarItems();
  }

  Future<void> _loadAvatarItems() async {
    final face = await SharedPrefsHelper.loadEquippedFace();
    final hair = await SharedPrefsHelper.loadEquippedHairstyle();
    final clothes = await SharedPrefsHelper.loadEquippedClothes();
    final headgear = await SharedPrefsHelper.loadEquippedHeadgear();
    final accessory = await SharedPrefsHelper.loadEquippedAccessory();

    setState(() {
      _equippedFace = face ?? 'assets/images/face/face_default.png';
      _equippedHair = hair ?? 'assets/images/hair/hair_default.png';
      _equippedClothes = clothes ?? 'assets/images/clothes/clothes_default.png';
      _equippedHeadgear = headgear;
      _equippedAccessory = accessory;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.miniGameChooseChar),
        backgroundColor: Colors.orangeAccent,
      ),
      body: FutureBuilder<List<String>>(
        future:
            SharedPrefsHelper.loadPurchasedItems(), // 👈 購入済みアイテム（名前のリスト）を取得
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final purchasedNames = snapshot.data!;
          // ショップデータから「購入済みのキャラクター画像」を抽出
          final List<ShopItem> ownedCharacters = shopItems
              .where(
                (item) =>
                    item.type == 'character' &&
                    purchasedNames.contains(item.name),
              )
              .toList();

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: ownedCharacters.length + 1, // アバターの分 +1
            itemBuilder: (context, index) {
              if (index == 0) {
                // 🔘 選択肢：自分のアバター
                return _buildCharCard(
                  context,
                  isAvatar: true,
                  path: 'MY_AVATAR',
                );
              } else {
                // 🔘 選択肢：購入済みの動物など
                final char = ownedCharacters[index - 1];
                return _buildCharCard(context, path: char.imagePath);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildCharCard(
    BuildContext context, {
    bool isAvatar = false,
    required String path,
  }) {
    return GestureDetector(
      onTap: () async {
        await SharedPrefsHelper.saveMiniGameCharacter(path);
        if (!context.mounted) return;
        Navigator.pop(context); // ハブ画面に戻る
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: isAvatar
                    ? AnimatedAvatar(
                        child: AvatarDisplay(
                          face: _equippedFace,
                          clothes: _equippedClothes,
                          hair: _equippedHair,
                          headgear: _equippedHeadgear,
                          accessory: _equippedAccessory,
                          size: 100,
                        ),
                      )
                    : Image.asset(path, cacheWidth: 100),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
