import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:kimigatsukuru_sekai/widgets/ad_banner.dart';
import '../../helpers/shared_prefs_helper.dart';
import '../../l10n/app_localizations.dart';
import '../../managers/sfx_manager.dart';
import 'package:confetti/confetti.dart';
import '../../widgets/blinking_effect.dart';

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
  final bool isHighlight; // 🌟 追加: 目立たせるかどうかのフラグ

  MissionItem({
    required this.id,
    required this.title,
    required this.rewardPoints,
    required this.isCompleted,
    required this.isClaimed,
    required this.category,
    this.progressText = '',
    this.isHighlight = false, // デフォルトはfalse
  });
}

class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen>
    with TickerProviderStateMixin {
  List<MissionItem> _missions = [];
  bool _isLoading = true;
  late ConfettiController _confettiController;

  // 🌟 追加: バッジをポヨポヨンさせるためのコントローラー
  late AnimationController _badgeAnimationController;

  bool _showTutorialTab = true;
  int _currentPoints = 0;

  // 🌟 追加: 各タブに「！」バッジを出すかどうかのフラグ
  bool _hasUnclaimedTutorial = false;
  bool _hasUnclaimedFirstTime = false;
  bool _hasUnclaimedCumulative = false;
  bool _isTutorialMissionIncomplete = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    // 🌟 追加: バッジアニメーションの設定
    _badgeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true); // 縮む・膨らむを繰り返す
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadMissions();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _badgeAnimationController.dispose(); // 🌟 追加
    super.dispose();
  }

  // 累計系ミッション用：グループ内で「直近のもの」だけを追加するヘルパー
  void _addNearestFromGroup(List<MissionItem> dest, List<MissionItem> group) {
    bool addedUncompleted = false;
    bool allClaimed = true; // グループ全部クリアしたかチェック

    for (final m in group) {
      if (!m.isClaimed) {
        allClaimed = false; // 1つでも未クリアがあれば false
      }

      if (m.isClaimed) continue; // 受け取り済みはスキップ
      if (!m.isCompleted) {
        if (addedUncompleted) break; // 2件目以降の未達成はスキップ
        addedUncompleted = true;
      }
      dest.add(m);
    }

    // 全てクリア済みの場合は、最後のミッションだけをリストに加えて「クリア！」として表示する
    if (allClaimed && group.isNotEmpty) {
      dest.add(group.last);
    }
  }

  // 🌟 保存されたデータを読み込んで、ミッション一覧を作るメソッド
  Future<void> _loadMissions() async {
    final l10n = AppLocalizations.of(context)!;
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
    final currentPoints = await SharedPrefsHelper.loadPoints();

    List<MissionItem> loadedMissions = [];

    // --- チュートリアル系ミッション ---
    loadedMissions.add(
      MissionItem(
        id: 'mission_parent_setup',
        title: l10n.missionTitleParentSetup,
        rewardPoints: 200,
        isCompleted: isParentSetupDone,
        isClaimed: claimedIds.contains('mission_parent_setup'),
        category: MissionCategory.tutorial,
        isHighlight: !claimedIds.contains('mission_parent_setup'), // 未完了なら目立たせる
      ),
    );

    loadedMissions.add(
      MissionItem(
        id: 'mission_first_promise',
        title: l10n.missionTitleFirstPromise,
        rewardPoints: 200,
        isCompleted: isChildSetupDone,
        isClaimed: claimedIds.contains('mission_first_promise'),
        category: MissionCategory.tutorial,
        isHighlight: !claimedIds.contains('mission_first_promise'),
      ),
    );

    // --- 初めて系ミッション ---
    // 🌟 レベル制限のないものは、未クリアなら常に目立たせる
    loadedMissions.add(
      MissionItem(
        id: 'mission_enter_house',
        title: l10n.missionTitleEnterHouse,
        rewardPoints: 50,
        isCompleted: hasEnteredHouse,
        isClaimed: claimedIds.contains('mission_enter_house'),
        category: MissionCategory.firstTime,
        isHighlight: !claimedIds.contains('mission_enter_house'),
      ),
    );

    loadedMissions.add(
      MissionItem(
        id: 'mission_promise_board',
        title: l10n.missionTitlePromiseBoard,
        rewardPoints: 50,
        isCompleted: hasVisitedPromiseBoard,
        isClaimed: claimedIds.contains('mission_promise_board'),
        category: MissionCategory.firstTime,
        isHighlight: !claimedIds.contains('mission_promise_board'),
      ),
    );

    loadedMissions.add(
      MissionItem(
        id: 'mission_bgm',
        title: l10n.missionTitleBgm,
        rewardPoints: 50,
        isCompleted: hasChangedBgm,
        isClaimed: claimedIds.contains('mission_bgm'),
        category: MissionCategory.firstTime,
        isHighlight: !claimedIds.contains('mission_bgm'),
      ),
    );

    loadedMissions.add(
      MissionItem(
        id: 'mission_world_map',
        title: l10n.missionTitleWorldMap,
        rewardPoints: 50,
        isCompleted: hasOpenedWorldMap,
        isClaimed: claimedIds.contains('mission_world_map'),
        category: MissionCategory.firstTime,
        isHighlight: !claimedIds.contains('mission_world_map'),
      ),
    );

    // 🌟 レベル制限のあるものは、現在のレベルが条件を満たしている場合のみ目立たせる
    loadedMissions.add(
      MissionItem(
        id: 'mission_big_island',
        title: l10n.missionTitleBigIsland,
        rewardPoints: 50,
        isCompleted: hasVisitedBigIsland,
        isClaimed: claimedIds.contains('mission_big_island'),
        category: MissionCategory.firstTime,
        isHighlight:
            !claimedIds.contains('mission_big_island') && currentLevel >= 5,
      ),
    );

    loadedMissions.add(
      MissionItem(
        id: 'mission_sea',
        title: l10n.missionTitleSea,
        rewardPoints: 50,
        isCompleted: hasVisitedSea,
        isClaimed: claimedIds.contains('mission_sea'),
        category: MissionCategory.firstTime,
        isHighlight: !claimedIds.contains('mission_sea') && currentLevel >= 10,
      ),
    );

    loadedMissions.add(
      MissionItem(
        id: 'mission_sky',
        title: l10n.missionTitleSky,
        rewardPoints: 50,
        isCompleted: hasVisitedSky,
        isClaimed: claimedIds.contains('mission_sky'),
        category: MissionCategory.firstTime,
        isHighlight: !claimedIds.contains('mission_sky') && currentLevel >= 15,
      ),
    );

    loadedMissions.add(
      MissionItem(
        id: 'mission_space',
        title: l10n.missionTitleSpace,
        rewardPoints: 50,
        isCompleted: hasVisitedSpace,
        isClaimed: claimedIds.contains('mission_space'),
        category: MissionCategory.firstTime,
        isHighlight:
            !claimedIds.contains('mission_space') && currentLevel >= 20,
      ),
    );

    // --- 累計系ミッション ---
    // 累計系は「ちょうせん中」であることをわざわざ目立たせる必要がないので、isHighlightは設定しません
    _addNearestFromGroup(
      loadedMissions,
      SharedPrefsHelper.loginTargets
          .map(
            (target) => MissionItem(
              id: 'mission_login_$target',
              title: l10n.missionTitleLoginDays(target.toString()),
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
              title: l10n.missionTitleShopCount(target.toString()),
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
              title: l10n.missionTitleLevel(target.toString()),
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
              title: l10n.missionTitlePoints(target.toString()),
              rewardPoints: 50,
              isCompleted: cumulativePoints >= target,
              isClaimed: claimedIds.contains('mission_points_$target'),
              progressText: '($cumulativePoints/$target)',
              category: MissionCategory.cumulative,
            ),
          )
          .toList(),
    );

    // 並び替え： 0=「うけとる！」, 1=「ちょうせん中」, 2=「クリア！」(一番下)
    loadedMissions.sort((a, b) {
      int getScore(MissionItem m) {
        if (m.isCompleted && !m.isClaimed) return 0;
        if (!m.isCompleted && !m.isClaimed) return 1;
        return 2;
      }

      return getScore(a).compareTo(getScore(b));
    });

    final tutorialMissions = loadedMissions.where(
      (m) => m.category == MissionCategory.tutorial,
    );
    final shouldShowTutorial = tutorialMissions.any((m) => !m.isClaimed);

    // 🌟 追加: 各タブに「受け取り可能（うけとる！）」なミッションがあるかチェック
    bool checkTabBadge(MissionCategory cat) {
      if (cat == MissionCategory.tutorial) {
        // チュートリアル: 未受け取り（未クリア含む）があれば常に「！」を出す
        return loadedMissions.any((m) => m.category == cat && !m.isClaimed);
      } else if (cat == MissionCategory.firstTime) {
        // はじめて系: 「受け取り可能」または「今のレベルで挑戦可能（ハイライト中）」なら「！」を出す
        return loadedMissions.any(
          (m) =>
              m.category == cat &&
              ((m.isCompleted && !m.isClaimed) ||
                  (m.isHighlight && !m.isClaimed)),
        );
      } else {
        // 累計系: 「受け取り可能（達成済み）」の時だけ「！」を出す
        return loadedMissions.any(
          (m) => m.category == cat && m.isCompleted && !m.isClaimed,
        );
      }
    }

    if (mounted) {
      setState(() {
        _missions = loadedMissions;
        _showTutorialTab = shouldShowTutorial;
        _currentPoints = currentPoints;
        // タブのバッジ状態を更新
        _hasUnclaimedTutorial = checkTabBadge(MissionCategory.tutorial);
        _hasUnclaimedFirstTime = checkTabBadge(MissionCategory.firstTime);
        _hasUnclaimedCumulative = checkTabBadge(MissionCategory.cumulative);
        _isLoading = false;
        _isTutorialMissionIncomplete =
            !claimedIds.contains('mission_parent_setup') ||
            !claimedIds.contains('mission_first_promise');
      });
    }
  }

  Future<void> _claimReward(MissionItem mission) async {
    try {
      SfxManager.instance.playSuccessSound();
    } catch (e) {}
    _confettiController.play();
    FirebaseAnalytics.instance.logEvent(name: '${mission.id}_reward');

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
    final l10n = AppLocalizations.of(context)!;
    final items = _missionsForCategory(category);
    if (items.isEmpty) {
      return Center(
        child: Text(
          l10n.missionNoMissions,
          style: const TextStyle(color: Colors.black54, fontSize: 14),
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

  // 🌟 追加: タブのアイコンに「！」バッジを重ねるヘルパーメソッド
  Widget _buildTabIcon(IconData iconData, bool hasBadge) {
    if (!hasBadge) return Icon(iconData, size: 18);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(iconData, size: 18),
        Positioned(
          top: -6, // 大きくした分、位置を少し外側にズラす
          right: -8,
          child: ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.3).animate(
              CurvedAnimation(
                parent: _badgeAnimationController,
                curve: Curves.easeInOut,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(4), // 余白を増やして少し大きく
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(0, 1), // 少し影をつけて立体的に
                  ),
                ],
              ),
              child: const Text(
                '!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10, // 文字サイズを 9 → 10 に大きく
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Tab _buildCompactTab(String text, IconData icon, bool hasBadge) {
    return Tab(
      height: 46, // 🌟 ここがポイント！標準の72pxから大幅に薄くする
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTabIcon(icon, hasBadge),
          const SizedBox(height: 2), // アイコンと文字の隙間を最小限に
          Text(
            text,
            style: const TextStyle(
              fontSize: 10, // 文字も少し小さくしてスッキリと
              fontWeight: FontWeight.bold,
            ),
            softWrap: false,
            overflow: TextOverflow.visible,
          ),
        ],
      ),
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

    final l10n = AppLocalizations.of(context)!;
    final List<Widget> tabs = [];
    final List<Widget> tabViews = [];

    // フラグが true の時だけ「チュートリアル」タブを追加
    if (_showTutorialTab) {
      tabs.add(
        BlinkingEffect(
          isBlinking: _isTutorialMissionIncomplete,
          child: _buildCompactTab(
            l10n.missionTabTutorial,
            Icons.school,
            _hasUnclaimedTutorial,
          ),
        ),
      );
      tabViews.add(_buildMissionList(MissionCategory.tutorial));
    }

    // 「はじめて」と「累計」は常に表示
    tabs.add(
      _buildCompactTab(
        l10n.missionTabFirstTime,
        Icons.star,
        _hasUnclaimedFirstTime,
      ),
    );
    tabViews.add(_buildMissionList(MissionCategory.firstTime));

    tabs.add(
      _buildCompactTab(
        l10n.missionTabCumulative,
        Icons.bar_chart,
        _hasUnclaimedCumulative,
      ),
    );
    tabViews.add(_buildMissionList(MissionCategory.cumulative));

    return DefaultTabController(
      key: ValueKey(tabs.length),
      length: tabs.length,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF3E0),
        appBar: AppBar(
          title: Text(
            l10n.missionScreenTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFFFF7043),
          foregroundColor: Colors.white,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Center(
                child: Text(
                  '$_currentPoints ${AppLocalizations.of(context)!.points}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelPadding: EdgeInsets.zero,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
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
        // 画面下部にバナーを設置
        bottomNavigationBar: const AdBanner(),
      ),
    );
  }

  Widget _buildMissionCard(MissionItem mission) {
    final l10n = AppLocalizations.of(context)!;
    Color buttonColor;
    String buttonText;
    VoidCallback? onPressed;

    // 🌟 追加: おすすめとしてハイライトするかどうか
    // クリア済みでなく、かつ isHighlight が true の場合
    final bool isHighlightedCard = mission.isHighlight && !mission.isClaimed;

    if (mission.isClaimed) {
      buttonColor = Colors.grey;
      buttonText = l10n.missionButtonCleared;
      onPressed = null;
    } else if (mission.isCompleted) {
      buttonColor = const Color(0xFFFF7043);
      buttonText = l10n.missionButtonClaim;
      onPressed = () => _claimReward(mission);
    } else {
      if (mission.category == MissionCategory.tutorial) {
        buttonColor = Colors.blue;
        buttonText = l10n.missionButtonTry;
        onPressed = () {
          try {
            SfxManager.instance.playTapSound();
          } catch (e) {}
          Navigator.of(context).pop(mission.id);
          FirebaseAnalytics.instance.logEvent(name: '${mission.id}_start');
        };
      } else {
        buttonColor = Colors.orange;
        buttonText = l10n.missionButtonChallenging;
        onPressed = null;
      }
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Card(
          margin: const EdgeInsets.only(bottom: 14.0), // 少しマージンを広げる
          // 🌟 ハイライト時は背景を薄い黄色にして枠線をつける
          color: isHighlightedCard ? const Color(0xFFFFF9C4) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isHighlightedCard
                ? const BorderSide(color: Color(0xFFFFB300), width: 2)
                : BorderSide.none,
          ),
          elevation: isHighlightedCard ? 4 : 2, // ハイライト時は少し浮かせる
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
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
                          color: mission.isClaimed
                              ? Colors.grey
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${l10n.missionRewardPrefix} ${mission.rewardPoints} ${AppLocalizations.of(context)!.points}',
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
                BlinkingEffect(
                  isBlinking:
                      mission.category == MissionCategory.tutorial &&
                      !mission.isClaimed,
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: mission.isCompleted && !mission.isClaimed
                          ? 4
                          : 0,
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // 🌟 追加: おすすめリボンの表示
        if (isHighlightedCard)
          Positioned(
            top: -4,
            left: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomRight: Radius.circular(10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
              child: Text(
                l10n.missionBadgeAvailableNow,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
