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

class _MissionScreenState extends State<MissionScreen>
    with SingleTickerProviderStateMixin {
  List<MissionItem> _missions = [];
  bool _isLoading = true;
  late ConfettiController _confettiController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _tabController = TabController(length: 3, vsync: this);
    _loadMissions();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // 累計系ミッション用：グループ内で「直近のもの」だけを追加するヘルパー
  // ・受け取り済み（isClaimed）はスキップ
  // ・達成済みで未受け取り（isCompleted && !isClaimed）は表示
  // ・未達成（!isCompleted）は最初の1件のみ表示し、それ以降はスキップ
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
    // 1. 各種データをSharedPrefsHelperから取得
    final claimedIds = await SharedPrefsHelper.loadClaimedMissionIds();
    final isParentSetupDone = await SharedPrefsHelper.isTutorialStepShown(
      SharedPrefsHelper.tutorialStepParentSetupShownKey,
    );
    final cumulativePromises =
        await SharedPrefsHelper.loadCumulativePromiseCount();
    final hasChangedBgm = await SharedPrefsHelper.getHasChangedBgm();
    final hasOpenedWorldMap = await SharedPrefsHelper.getHasOpenedWorldMap();
    final hasVisitedBigIsland =
        await SharedPrefsHelper.getHasVisitedBigIsland();
    final hasVisitedSea = await SharedPrefsHelper.getHasVisitedSea();
    final hasVisitedSky = await SharedPrefsHelper.getHasVisitedSky();
    final hasVisitedSpace = await SharedPrefsHelper.getHasVisitedSpace();
    final hasVisitedPromiseBoard =
        await SharedPrefsHelper.getHasVisitedPromiseBoard();
    final cumulativeShop = await SharedPrefsHelper.loadCumulativeShopCount();
    final currentLevel = await SharedPrefsHelper.loadLevel();
    final cumulativePoints = await SharedPrefsHelper.loadCumulativePoints();
    final cumulativeLoginDays =
        await SharedPrefsHelper.loadCumulativeLoginDays();

    List<MissionItem> loadedMissions = [];

    // --- チュートリアル系ミッション ---
    loadedMissions.add(
      MissionItem(
        id: 'mission_parent_setup',
        title: 'おやのやくそくを せっていしよう',
        rewardPoints: 100,
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
        isCompleted: cumulativePromises >= 1,
        isClaimed: claimedIds.contains('mission_first_promise'),
        progressText: '($cumulativePromises/1)',
        category: MissionCategory.tutorial,
      ),
    );

    // --- 初めて系ミッション ---
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
    // ログイン日数
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

    // 買い物回数
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

    // レベル
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

    // 累計ポイント
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

    // 画面を更新
    if (mounted) {
      setState(() {
        _missions = loadedMissions;
        _isLoading = false;
      });
    }
  }

  // 🌟 報酬を受け取る処理
  Future<void> _claimReward(MissionItem mission) async {
    // 効果音と紙吹雪
    try {
      SfxManager.instance.playSuccessSound();
    } catch (e) {}
    _confettiController.play();

    // ポイントを加算して保存
    final currentPoints = await SharedPrefsHelper.loadPoints();
    await SharedPrefsHelper.savePoints(currentPoints + mission.rewardPoints);
    await SharedPrefsHelper.addCumulativePoints(mission.rewardPoints); // 累計にも加算

    // ミッションを「受け取り済み」に記録
    await SharedPrefsHelper.claimMission(mission.id);

    // リストを再読み込みしてUIを更新
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
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0), // ピーチクリーム背景
      appBar: AppBar(
        title: const Text(
          'ミッション',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFF7043),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          tabs: const [
            Tab(icon: Icon(Icons.school, size: 18), text: 'チュートリアル'),
            Tab(icon: Icon(Icons.star, size: 18), text: 'はじめて'),
            Tab(icon: Icon(Icons.bar_chart, size: 18), text: '累計'),
          ],
        ),
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMissionList(MissionCategory.tutorial),
                    _buildMissionList(MissionCategory.firstTime),
                    _buildMissionList(MissionCategory.cumulative),
                  ],
                ),

          // 紙吹雪エフェクト（画面上部中央から）
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
    );
  }

  // ミッションのカードデザイン
  Widget _buildMissionCard(MissionItem mission) {
    // 状態によってボタンの見た目を変える
    Color buttonColor;
    String buttonText;
    VoidCallback? onPressed;

    if (mission.isClaimed) {
      buttonColor = Colors.grey;
      buttonText = 'クリア！';
      onPressed = null; // 押せない
    } else if (mission.isCompleted) {
      buttonColor = const Color(0xFFFF7043); // オレンジ
      buttonText = 'うけとる！';
      onPressed = () => _claimReward(mission); // 受け取り処理
    } else {
      buttonColor = Colors.blueGrey;
      buttonText = 'ちょうせん中';
      onPressed = null; // 押せない（未達成）
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            // 左側：メダルアイコン
            Icon(
              mission.isClaimed ? Icons.verified : Icons.military_tech,
              color: mission.isClaimed ? Colors.grey : Colors.amber,
              size: 40,
            ),
            const SizedBox(width: 12),
            // 中央：タイトルと報酬
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
            // 右側：ボタン
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
