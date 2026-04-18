import 'package:flutter/material.dart';
import '../../helpers/shared_prefs_helper.dart';
import '../../managers/sfx_manager.dart';
import 'package:confetti/confetti.dart';

// ミッションカテゴリ
enum MissionCategory { tutorial, firstTime, cumulative }

// ミッションのデータをまとめるクラス
class MissionItem {
  final String id;
  final String title;
  final int rewardPoints;
  final bool isCompleted;
  final bool isClaimed;
  final String progressText;
  final MissionCategory category;

  MissionItem({
    required this.id,
    required this.title,
    required this.rewardPoints,
    required this.isCompleted,
    required this.isClaimed,
    required this.category,
    this.progressText = '',
  });
}

class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

// 🌟 変更点: DefaultTabControllerを使うため、SingleTickerProviderStateMixin は削除しました
class _MissionScreenState extends State<MissionScreen> {
  List<MissionItem> _missions = [];
  bool _isLoading = true;
  late ConfettiController _confettiController;

  // 🌟 追加: チュートリアルタブを表示するかどうかのフラグ
  bool _showTutorialTab = true;
  // 🌟 追加: 現在のポイントを保持する変数
  int _currentPoints = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _loadMissions();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    // 🌟 変更点: 自前の _tabController.dispose() を削除
    super.dispose();
  }

  // 累計系ミッション用：グループ内で「直近のもの」だけを追加するヘルパー
  void _addNearestFromGroup(List<MissionItem> dest, List<MissionItem> group) {
    bool addedUncompleted = false;
    for (final m in group) {
      if (m.isClaimed) continue; // 受け取り済みはスキップ
      if (!m.isCompleted) {
        if (addedUncompleted) break; // 2件目以降の未達成はスキップ
        addedUncompleted = true;
      }
      dest.add(m);
    }
  }

  // 🌟 保存されたデータを読み込んで、ミッション一覧を作るメソッド
  Future<void> _loadMissions() async {
    final claimedIds = await SharedPrefsHelper.loadClaimedMissionIds();
    final isParentSetupDone = await SharedPrefsHelper.isTutorialStepShown(
      SharedPrefsHelper.tutorialStepParentSetupShownKey,
    );
    final isChildSetupDone = await SharedPrefsHelper.isTutorialStepShown(
      SharedPrefsHelper.tutorialStepMoveKey,
    );
    final hasChangedBgm = await SharedPrefsHelper.getHasChangedBgm();
    final hasOpenedWorldMap = await SharedPrefsHelper.getHasOpenedWorldMap();
    final hasVisitedBigIsland =
        await SharedPrefsHelper.getHasVisitedBigIsland();
    final hasVisitedSea = await SharedPrefsHelper.getHasVisitedSea();
    final hasVisitedSky = await SharedPrefsHelper.getHasVisitedSky();
    final hasVisitedSpace = await SharedPrefsHelper.getHasVisitedSpace();
    final hasVisitedPromiseBoard =
        await SharedPrefsHelper.getHasVisitedPromiseBoard();
    final hasEnteredHouse = await SharedPrefsHelper.getHasEnteredHouse();

    final cumulativeShop = await SharedPrefsHelper.loadCumulativeShopCount();
    final currentLevel = await SharedPrefsHelper.loadLevel();
    final cumulativePoints = await SharedPrefsHelper.loadCumulativePoints();
    final cumulativeLoginDays =
        await SharedPrefsHelper.loadCumulativeLoginDays();
    // 🌟 追加: 現在の所持ポイントを読み込む
    final currentPoints = await SharedPrefsHelper.loadPoints();

    List<MissionItem> loadedMissions = [];

    // --- チュートリアル系ミッション ---
    loadedMissions.add(
      MissionItem(
        id: 'mission_parent_setup',
        title: 'おやのやくそくを せっていしよう',
        rewardPoints: 200,
        isCompleted: isParentSetupDone,
        isClaimed: claimedIds.contains('mission_parent_setup'),
        category: MissionCategory.tutorial,
      ),
    );

    loadedMissions.add(
      MissionItem(
        id: 'mission_first_promise',
        title: 'はじめて やくそくを クリアしよう',
        rewardPoints: 200,
        isCompleted: isChildSetupDone,
        isClaimed: claimedIds.contains('mission_first_promise'),
        category: MissionCategory.tutorial,
      ),
    );

    // --- 初めて系ミッション ---
    loadedMissions.add(
      MissionItem(
        id: 'mission_enter_house',
        title: 'はじめて おうちの なかに はいろう',
        rewardPoints: 50,
        isCompleted: hasEnteredHouse,
        isClaimed: claimedIds.contains('mission_enter_house'),
        category: MissionCategory.firstTime,
      ),
    );

    loadedMissions.add(
      MissionItem(
        id: 'mission_promise_board',
        title: 'はじめて やくそくボードを みよう',
        rewardPoints: 50,
        isCompleted: hasVisitedPromiseBoard,
        isClaimed: claimedIds.contains('mission_promise_board'),
        category: MissionCategory.firstTime,
      ),
    );

    loadedMissions.add(
      MissionItem(
        id: 'mission_bgm',
        title: 'はじめて おんがくを かえよう',
        rewardPoints: 50,
        isCompleted: hasChangedBgm,
        isClaimed: claimedIds.contains('mission_bgm'),
        category: MissionCategory.firstTime,
      ),
    );

    loadedMissions.add(
      MissionItem(
        id: 'mission_world_map',
        title: 'はじめて せかいマップを みよう',
        rewardPoints: 50,
        isCompleted: hasOpenedWorldMap,
        isClaimed: claimedIds.contains('mission_world_map'),
        category: MissionCategory.firstTime,
      ),
    );

    loadedMissions.add(
      MissionItem(
        id: 'mission_big_island',
        title: 'おおきなしま に いってみよう (Lv.5)',
        rewardPoints: 50,
        isCompleted: hasVisitedBigIsland,
        isClaimed: claimedIds.contains('mission_big_island'),
        category: MissionCategory.firstTime,
      ),
    );

    loadedMissions.add(
      MissionItem(
        id: 'mission_sea',
        title: 'うみ に いってみよう (Lv.10)',
        rewardPoints: 50,
        isCompleted: hasVisitedSea,
        isClaimed: claimedIds.contains('mission_sea'),
        category: MissionCategory.firstTime,
      ),
    );

    loadedMissions.add(
      MissionItem(
        id: 'mission_sky',
        title: 'そら に いってみよう (Lv.15)',
        rewardPoints: 50,
        isCompleted: hasVisitedSky,
        isClaimed: claimedIds.contains('mission_sky'),
        category: MissionCategory.firstTime,
      ),
    );

    loadedMissions.add(
      MissionItem(
        id: 'mission_space',
        title: 'うちゅう に いってみよう (Lv.20)',
        rewardPoints: 50,
        isCompleted: hasVisitedSpace,
        isClaimed: claimedIds.contains('mission_space'),
        category: MissionCategory.firstTime,
      ),
    );

    // --- 累計系ミッション ---
    _addNearestFromGroup(
      loadedMissions,
      SharedPrefsHelper.loginTargets
          .map(
            (target) => MissionItem(
              id: 'mission_login_$target',
              title: '$target日 ログインしよう',
              rewardPoints: 50,
              isCompleted: cumulativeLoginDays >= target,
              isClaimed: claimedIds.contains('mission_login_$target'),
              progressText: '($cumulativeLoginDays/$target)',
              category: MissionCategory.cumulative,
            ),
          )
          .toList(),
    );

    _addNearestFromGroup(
      loadedMissions,
      SharedPrefsHelper.shopTargets
          .map(
            (target) => MissionItem(
              id: 'mission_shop_$target',
              title: 'おみせで $targetかい おかいものしよう',
              rewardPoints: 50,
              isCompleted: cumulativeShop >= target,
              isClaimed: claimedIds.contains('mission_shop_$target'),
              progressText: '($cumulativeShop/$target)',
              category: MissionCategory.cumulative,
            ),
          )
          .toList(),
    );

    _addNearestFromGroup(
      loadedMissions,
      SharedPrefsHelper.levelTargets
          .map(
            (target) => MissionItem(
              id: 'mission_level_$target',
              title: 'レベル$target に なろう',
              rewardPoints: 50,
              isCompleted: currentLevel >= target,
              isClaimed: claimedIds.contains('mission_level_$target'),
              progressText: '(Lv.$currentLevel/Lv.$target)',
              category: MissionCategory.cumulative,
            ),
          )
          .toList(),
    );

    _addNearestFromGroup(
      loadedMissions,
      SharedPrefsHelper.pointTargets
          .map(
            (target) => MissionItem(
              id: 'mission_points_$target',
              title: 'ポイントを $target あつめよう',
              rewardPoints: 50,
              isCompleted: cumulativePoints >= target,
              isClaimed: claimedIds.contains('mission_points_$target'),
              progressText: '($cumulativePoints/$target)',
              category: MissionCategory.cumulative,
            ),
          )
          .toList(),
    );

    // 🌟 追加: ミッションの並び替え
    // 優先度： 0=「うけとる！」, 1=「ちょうせん中」, 2=「クリア！」(一番下)
    loadedMissions.sort((a, b) {
      int getScore(MissionItem m) {
        if (m.isCompleted && !m.isClaimed) return 0; // 最優先（一番上）
        if (!m.isCompleted && !m.isClaimed) return 1; // その次
        return 2; // クリア済み（一番下）
      }

      return getScore(a).compareTo(getScore(b));
    });

    // 🌟 追加: チュートリアルミッションが全て受け取り済みか判定する
    final tutorialMissions = loadedMissions.where(
      (m) => m.category == MissionCategory.tutorial,
    );
    // 「受け取っていない（未完了含む）チュートリアル」が1つでもあれば true
    final shouldShowTutorial = tutorialMissions.any((m) => !m.isClaimed);

    // 画面を更新
    if (mounted) {
      setState(() {
        _missions = loadedMissions;
        _showTutorialTab = shouldShowTutorial;
        _currentPoints = currentPoints; // 🌟 追加: 読み込んだポイントを画面に反映
        _isLoading = false;
      });
    }
  }

  Future<void> _claimReward(MissionItem mission) async {
    try {
      SfxManager.instance.playSuccessSound();
    } catch (e) {}
    _confettiController.play();

    final currentPoints = await SharedPrefsHelper.loadPoints();
    await SharedPrefsHelper.savePoints(currentPoints + mission.rewardPoints);
    await SharedPrefsHelper.addCumulativePoints(mission.rewardPoints);

    await SharedPrefsHelper.claimMission(mission.id);

    await _loadMissions();
  }

  List<MissionItem> _missionsForCategory(MissionCategory category) {
    return _missions.where((m) => m.category == category).toList();
  }

  Widget _buildMissionList(MissionCategory category) {
    final items = _missionsForCategory(category);
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'ミッションがありません',
          style: TextStyle(color: Colors.black54, fontSize: 14),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildMissionCard(items[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF3E0),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 🌟 動的にタブと中身のリストを作る
    final List<Widget> tabs = [];
    final List<Widget> tabViews = [];

    // フラグが true の時だけ「チュートリアル」タブを追加
    if (_showTutorialTab) {
      tabs.add(const Tab(icon: Icon(Icons.school, size: 18), text: 'チュートリアル'));
      tabViews.add(_buildMissionList(MissionCategory.tutorial));
    }

    // 「はじめて」と「累計」は常に表示
    tabs.add(const Tab(icon: Icon(Icons.star, size: 18), text: 'はじめて'));
    tabViews.add(_buildMissionList(MissionCategory.firstTime));

    tabs.add(const Tab(icon: Icon(Icons.bar_chart, size: 18), text: '累計'));
    tabViews.add(_buildMissionList(MissionCategory.cumulative));

    // 🌟 Scaffold全体を DefaultTabController で包む
    return DefaultTabController(
      // key をつけることで、タブの数が減った時にエラーにならず綺麗にリセットされます
      key: ValueKey(tabs.length),
      length: tabs.length,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF3E0),
        appBar: AppBar(
          title: const Text(
            'ミッション',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFFFF7043),
          foregroundColor: Colors.white,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3), // 少し半透明な白枠
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.yellowAccent,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$_currentPoints P',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            tabs: tabs,
          ),
        ),
        body: Stack(
          children: [
            TabBarView(children: tabViews),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.05,
                numberOfParticles: 20,
                gravity: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionCard(MissionItem mission) {
    Color buttonColor;
    String buttonText;
    VoidCallback? onPressed;

    if (mission.isClaimed) {
      buttonColor = Colors.grey;
      buttonText = 'クリア！';
      onPressed = null;
    } else if (mission.isCompleted) {
      buttonColor = const Color(0xFFFF7043);
      buttonText = 'うけとる！';
      onPressed = () => _claimReward(mission);
    } else {
      if (mission.category == MissionCategory.tutorial) {
        // 【追加】チュートリアル系の場合は「やってみる」ボタンにして押せるようにする
        buttonColor = const Color(0xFFFF7043); // 誘導用の色（お好みで変更してください）
        buttonText = 'やってみる';
        onPressed = () {
          try {
            SfxManager.instance.playTapSound();
          } catch (e) {}
          // 🌟 ホーム画面に「どのミッションをやりたいか（ID）」を渡して画面を閉じる
          Navigator.of(context).pop(mission.id);
        };
      } else {
        // 通常の未達成ミッションは今まで通り押せない
        buttonColor = Colors.orange;
        buttonText = 'ちょうせん中';
        onPressed = null;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(
              mission.isClaimed ? Icons.verified : Icons.military_tech,
              color: mission.isClaimed ? Colors.grey : Colors.amber,
              size: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mission.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: mission.isClaimed ? Colors.grey : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'ほうしゅう: ${mission.rewardPoints} P',
                        style: TextStyle(
                          fontSize: 12,
                          color: mission.isClaimed
                              ? Colors.grey
                              : Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (mission.progressText.isNotEmpty)
                        Text(
                          mission.progressText,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: mission.isCompleted && !mission.isClaimed ? 4 : 0,
              ),
              child: Text(
                buttonText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
