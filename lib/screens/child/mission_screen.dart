// lib/screens/mission_screen.dart

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:kimigatsukuru_sekai/managers/trophy_manager.dart';
import 'package:kimigatsukuru_sekai/widgets/tutorial_character_bubble.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 🌟 追加: デイリーミッションの状態取得用
import '../../helpers/shared_prefs_helper.dart';
import '../../l10n/app_localizations.dart';
import '../../managers/sfx_manager.dart';
import 'package:confetti/confetti.dart';
import '../../widgets/blinking_effect.dart';
import '../../widgets/animated_tap_finger.dart';
import 'package:url_launcher/url_launcher.dart';

// ミッションカテゴリ (🌟 daily を追加)
enum MissionCategory { daily, tutorial, firstTime, cumulative }

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
  const MissionScreen({super.key, required this.isTutorialMode});
  final bool? isTutorialMode;

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

  // ==========================================
  // 🌟 追加: ポイント獲得時のどデカいアニメーション用
  // ==========================================
  late AnimationController _pointsAddedAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  OverlayEntry? _currentPointOverlay;

  bool _showTutorialTab = true;
  int _currentPoints = 0;

  // 🌟 追加: 各タブに「！」バッジを出すかどうかのフラグ
  bool _hasUnclaimedDaily = false; // 🌟 追加
  bool _hasUnclaimedTutorial = false;
  bool _hasUnclaimedFirstTime = false;
  bool _hasUnclaimedCumulative = false;

  int _multiplier = 1;

  // 🌟 追加: チュートリアルの進行度を管理
  int _tutorialStep = 0;
  TabController? _tabController;
  int _previousTabIndex = 0;

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

    // ==========================================
    // 🌟 追加: ポイント獲得アニメーションの設定
    // ==========================================
    _pointsAddedAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // 2秒かけて上にフワッと消える
    );
    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0),
          end: const Offset(0, -0.8), // 上方向への移動距離
        ).animate(
          CurvedAnimation(
            parent: _pointsAddedAnimationController,
            curve: Curves.easeOut,
          ),
        );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _pointsAddedAnimationController,
        curve: const Interval(0.5, 1.0), // 後半の1秒で透明になる
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadMissions();
  }

  @override
  void dispose() {
    _tabController?.dispose(); // 🌟 追加
    _currentPointOverlay?.remove();
    _confettiController.dispose();
    _badgeAnimationController.dispose(); // 🌟 追加
    _pointsAddedAnimationController.dispose();
    super.dispose();
  }

  // 🌟 追加: タブの切り替えを監視してチュートリアルを制御
  void _handleTabSelection() {
    if (_tabController!.indexIsChanging) return;

    if (widget.isTutorialMode == true) {
      final targetIndex = _tabController!.index;

      if (_tutorialStep == 1 && targetIndex == 1) {
        try {
          SfxManager.instance.playTapSound();
        } catch (_) {}
        setState(() => _tutorialStep = 2);
        _previousTabIndex = 1;
      } else if (_tutorialStep == 2 && targetIndex == 2) {
        try {
          SfxManager.instance.playTapSound();
        } catch (_) {}
        setState(() => _tutorialStep = 3);
        _previousTabIndex = 2;
      } else if (_tutorialStep == 3 && targetIndex == 3) {
        try {
          SfxManager.instance.playTapSound();
        } catch (_) {}
        setState(() => _tutorialStep = 4);
        _previousTabIndex = 3;
      } else {
        // 許可されていないタブへ移動しようとしたら引き戻す
        if (targetIndex != _previousTabIndex) {
          _tabController!.index = _previousTabIndex;
        }
      }
    } else {
      _previousTabIndex = _tabController!.index;
    }
  }

  void _showHugePointAnimation(int points) {
    // すでに表示中のものがあれば一旦消す（連打対策）
    _currentPointOverlay?.remove();

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: IgnorePointer(
          child: Center(
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 60),
                      const SizedBox(width: 12),
                      Text(
                        '+$points', // 引数で受け取ったポイントを表示
                        style: const TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF7043),
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.white,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    _currentPointOverlay = overlayEntry;
    overlay.insert(overlayEntry); // 最前面のガラス（Overlay）に貼り付け！

    // アニメーションを最初から再生し、終わったらガラスから剥がす
    _pointsAddedAnimationController.forward(from: 0.0).then((_) {
      if (_currentPointOverlay == overlayEntry && mounted) {
        _currentPointOverlay?.remove();
        _currentPointOverlay = null;
      }
    });
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
      SharedPrefsHelper.tutorialStepCustomizeKey,
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
    final multiplier = await SharedPrefsHelper.getCurrentBoostMultiplier();
    // 🌟 デイリーミッション用のデータ読み込み
    final todaysCompletedTitles =
        await SharedPrefsHelper.loadTodaysCompletedPromiseTitles();
    final regularPromises = await SharedPrefsHelper.loadRegularPromises(
      context,
    );
    final hasFollowedX = await SharedPrefsHelper.isXFollowClaimedEver();
    final hasSharedX = await SharedPrefsHelper.isXShareClaimedEver();
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayStr =
        "${now.year}-${now.month}-${now.day}"; // 日付ごとにIDを変えることで毎日リセットされる仕組み

    List<MissionItem> loadedMissions = [];

    // --- 🌟 デイリーミッション（毎日リセット） ---
    final isPromise1Done = todaysCompletedTitles.isNotEmpty;
    bool isPromiseAllDone = false;
    if (regularPromises.isNotEmpty) {
      isPromiseAllDone = regularPromises.every(
        (p) => todaysCompletedTitles.contains(p['title']),
      );
    }
    final isCustomizeDone =
        prefs.getBool('daily_customize_done_$todayStr') ?? false;
    final isShopDone = prefs.getBool('daily_shop_done_$todayStr') ?? false;

    loadedMissions.add(
      MissionItem(
        id: 'daily_promise_1_$todayStr',
        title: l10n.missionTitleDailyPromise1,
        rewardPoints: 20,
        isCompleted: isPromise1Done,
        isClaimed: claimedIds.contains('daily_promise_1_$todayStr'),
        category: MissionCategory.daily,
      ),
    );
    loadedMissions.add(
      MissionItem(
        id: 'daily_promise_all_$todayStr',
        title: l10n.missionTitleDailyPromiseAll,
        rewardPoints: 50,
        isCompleted: isPromiseAllDone,
        isClaimed: claimedIds.contains('daily_promise_all_$todayStr'),
        category: MissionCategory.daily,
      ),
    );
    loadedMissions.add(
      MissionItem(
        id: 'daily_customize_$todayStr',
        title: l10n.missionTitleDailyCustomize,
        rewardPoints: 10,
        isCompleted: isCustomizeDone,
        isClaimed: claimedIds.contains('daily_customize_$todayStr'),
        category: MissionCategory.daily,
      ),
    );
    loadedMissions.add(
      MissionItem(
        id: 'daily_shop_$todayStr',
        title: l10n.missionTitleDailyShop,
        rewardPoints: 10,
        isCompleted: isShopDone,
        isClaimed: claimedIds.contains('daily_shop_$todayStr'),
        category: MissionCategory.daily,
      ),
    );

    // --- チュートリアル系ミッション ---
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

    loadedMissions.add(
      MissionItem(
        id: 'mission_x_follow',
        title: l10n.missionXFollowTitle, // 🌟 先ほど追加したローカライズキー
        rewardPoints: 200,
        isCompleted: hasFollowedX, // Xを開いて戻ってきていれば true になる
        isClaimed: claimedIds.contains('mission_x_follow'),
        category: MissionCategory.firstTime,
        isHighlight: !claimedIds.contains('mission_x_follow'), // 未受け取りなら目立たせる
      ),
    );

    loadedMissions.add(
      MissionItem(
        id: 'mission_x_share',
        title: l10n.missionXShareTitle, // 「X(Twitter)でシェアしよう！」
        rewardPoints: 200,
        isCompleted: hasSharedX,
        isClaimed: claimedIds.contains('mission_x_share'),
        category: MissionCategory.firstTime, // 1回きりなので「はじめて」タブへ
        isHighlight: !claimedIds.contains('mission_x_share'),
      ),
    );

    // --- 累計系ミッション ---
    // 累計系は「ちょうせん中」であることをわざわざ目立たせる必要がないので、isHighlightは設定しません
    _addNearestFromGroup(
      loadedMissions,
      SharedPrefsHelper.loginTargets
          .map(
            (t) => MissionItem(
              id: 'mission_login_$t',
              title: l10n.missionTitleLoginDays(t.toString()),
              rewardPoints: 50,
              isCompleted: cumulativeLoginDays >= t,
              isClaimed: claimedIds.contains('mission_login_$t'),
              progressText: '($cumulativeLoginDays/$t)',
              category: MissionCategory.cumulative,
            ),
          )
          .toList(),
    );

    _addNearestFromGroup(
      loadedMissions,
      SharedPrefsHelper.shopTargets
          .map(
            (t) => MissionItem(
              id: 'mission_shop_$t',
              title: l10n.missionTitleShopCount(t.toString()),
              rewardPoints: 50,
              isCompleted: cumulativeShop >= t,
              isClaimed: claimedIds.contains('mission_shop_$t'),
              progressText: '($cumulativeShop/$t)',
              category: MissionCategory.cumulative,
            ),
          )
          .toList(),
    );
    _addNearestFromGroup(
      loadedMissions,
      SharedPrefsHelper.levelTargets
          .map(
            (t) => MissionItem(
              id: 'mission_level_$t',
              title: l10n.missionTitleLevel(t.toString()),
              rewardPoints: 50,
              isCompleted: currentLevel >= t,
              isClaimed: claimedIds.contains('mission_level_$t'),
              progressText: '(Lv.$currentLevel/Lv.$t)',
              category: MissionCategory.cumulative,
            ),
          )
          .toList(),
    );
    _addNearestFromGroup(
      loadedMissions,
      SharedPrefsHelper.pointTargets
          .map(
            (t) => MissionItem(
              id: 'mission_points_$t',
              title: l10n.missionTitlePoints(t.toString()),
              rewardPoints: 50,
              isCompleted: cumulativePoints >= t,
              isClaimed: claimedIds.contains('mission_points_$t'),
              progressText: '($cumulativePoints/$t)',
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
      if (cat == MissionCategory.tutorial)
        return loadedMissions.any((m) => m.category == cat && !m.isClaimed);
      else if (cat == MissionCategory.daily)
        return loadedMissions.any(
          (m) => m.category == cat && m.isCompleted && !m.isClaimed,
        );
      else if (cat == MissionCategory.firstTime)
        return loadedMissions.any(
          (m) =>
              m.category == cat &&
              ((m.isCompleted && !m.isClaimed) ||
                  (m.isHighlight && !m.isClaimed)),
        );
      else
        return loadedMissions.any(
          (m) => m.category == cat && m.isCompleted && !m.isClaimed,
        );
    }

    if (mounted) {
      setState(() {
        _missions = loadedMissions;
        _showTutorialTab = shouldShowTutorial;
        _currentPoints = currentPoints;
        // タブのバッジ状態を更新
        _hasUnclaimedDaily = checkTabBadge(MissionCategory.daily); // 🌟 追加
        _hasUnclaimedTutorial = checkTabBadge(MissionCategory.tutorial);
        _hasUnclaimedFirstTime = checkTabBadge(MissionCategory.firstTime);
        _hasUnclaimedCumulative = checkTabBadge(MissionCategory.cumulative);
        _isLoading = false;
        _multiplier = multiplier;

        // 🌟 追加: チュートリアル中かつ「最初のやくそく」が受け取り済みなら、ステップ1（デイリータブ誘導）にスキップ・復帰する
        if (widget.isTutorialMode == true && _tutorialStep == 0) {
          if (claimedIds.contains('mission_first_promise')) {
            _tutorialStep = 1;
          }
        }

        // 🌟 TabController の動的生成
        int tabsCount = _showTutorialTab ? 4 : 3;
        if (_tabController == null || _tabController!.length != tabsCount) {
          _tabController?.dispose();
          _tabController = TabController(length: tabsCount, vsync: this);
          _tabController!.addListener(_handleTabSelection);
        }
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
    final earnedPoints = mission.rewardPoints * _multiplier;

    setState(() {
      _currentPoints = currentPoints + earnedPoints;
    });
    _showHugePointAnimation(earnedPoints);
    await SharedPrefsHelper.savePoints(currentPoints + earnedPoints);
    await SharedPrefsHelper.addCumulativePoints(earnedPoints);

    await SharedPrefsHelper.claimMission(mission.id);

    // 🌟 チュートリアル中のステップ進行
    if (widget.isTutorialMode == true &&
        mission.id == 'mission_first_promise') {
      setState(() {
        _tutorialStep = 1; // ポイント獲得後、デイリータブへ誘導
      });
    }

    await _loadMissions();

    if (widget.isTutorialMode == false) {
      // 🌟 追加: ミッション報酬で累計ポイントが増えた後のトロフィーチェック
      if (mounted) TrophyManager.checkAndShowTrophies(context);
    }
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
          top: -10, // 大きくした分、位置を少し外側にズラす
          right: -17,
          child: ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.3).animate(
              CurvedAnimation(
                parent: _badgeAnimationController,
                curve: Curves.easeInOut,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(4), // 余白を増やして少し大きく
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.0),
                boxShadow: const [
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

  // 🌟 追加: チュートリアルステップに応じて、各タブの点滅と非活性をコントロール
  Tab _buildCompactTab(
    String text,
    IconData icon,
    bool hasBadge,
    int tabIndex,
  ) {
    bool isEnabled = true;
    bool isBlinking = false;
    bool isOpacity = false;

    if (widget.isTutorialMode == true) {
      if (_tutorialStep == 0) {
        if (tabIndex != 0) {
          isEnabled = false;
          isOpacity = true;
        }
      } else if (_tutorialStep == 1) {
        if (tabIndex == 1) {
          isEnabled = true;
          isBlinking = true;
        } else {
          isEnabled = false;
          isOpacity = true;
        }
      } else if (_tutorialStep == 2) {
        if (tabIndex == 2) {
          isEnabled = true;
          isBlinking = true;
        } else {
          isEnabled = false;
          isOpacity = true;
        }
      } else if (_tutorialStep == 3) {
        if (tabIndex == 3) {
          isEnabled = true;
          isBlinking = true;
        } else {
          isEnabled = false;
          isOpacity = true;
        }
      } else if (_tutorialStep == 4) {
        isEnabled = false;
        isOpacity = true;
      }
    }

    Widget tabChild = Column(
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
    );

    if (isOpacity) {
      tabChild = Opacity(opacity: 0.3, child: tabChild);
    }
    if (isBlinking) {
      tabChild = BlinkingEffect(
        isBlinking: true,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            tabChild,
            const Positioned(
              right: -15,
              bottom: -15,
              child: AnimatedTapFinger(),
            ),
          ],
        ),
      );
    }

    return Tab(
      height: 46,
      child: IgnorePointer(ignoring: !isEnabled, child: tabChild),
    );
  }

  // 🌟 追加: チュートリアル用の吹き出しUI
  Widget _buildTutorialBubble() {
    if (widget.isTutorialMode != true) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!; // 🌟 ローカライズ用の変数を取得
    String text = '';

    if (_tutorialStep == 0) {
      text = l10n.tutorialMissionStep0;
    } else if (_tutorialStep == 1) {
      text = l10n.tutorialMissionStep1;
    } else if (_tutorialStep == 2) {
      text = l10n.tutorialMissionStep2;
    } else if (_tutorialStep == 3) {
      text = l10n.tutorialMissionStep3;
    } else if (_tutorialStep == 4) {
      text = l10n.tutorialMissionStep4;
    }

    if (text.isEmpty) return const SizedBox.shrink();

    return Positioned(
      bottom: 0,
      right: 0,
      child: TutorialCharacterBubble(text: text),
    );
  }

  Future<void> _executeXShare() async {
    try {
      SfxManager.instance.playTapSound();
    } catch (_) {}
    final String shareText = AppLocalizations.of(context)!.missionXShareText;
    final String iosUrl = "https://apps.apple.com/app/id6761637868";
    final String androidUrl =
        "https://play.google.com/store/apps/details?id=com.kotoapp.kimigatsukuru_sekai";

    // 投稿を見る人が分かりやすいように絵文字で区別
    final String appUrls = "🍎 iOS:\n$iosUrl\n\n🤖 Android:\n$androidUrl";

    // テキストとURLを合体させてエンコード
    final String urlString =
        "https://twitter.com/intent/tweet?text=${Uri.encodeComponent('$shareText\n\n$appUrls')}";
    final Uri url = Uri.parse(urlString);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.of(context).pop();

      await SharedPrefsHelper.setXShareClaimedEver();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.missionXOpenedSuccess),
            backgroundColor: Colors.orange,
          ),
        );
        _loadMissions();
      }
    } else {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.missionXOpenError),
          ),
        );
    }
  }

  // フォローボタンを押した時の処理
  Future<void> _executeXFollow() async {
    try {
      SfxManager.instance.playTapSound();
    } catch (_) {}

    // 🌟 修正: あなたのアプリの公式XアカウントのURLに変更してください
    final String urlString = "https://x.com/ta813com";
    final Uri url = Uri.parse(urlString);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);

      // Xからアプリに戻ってきた時の処理（少しだけロード演出を入れる）
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.of(context).pop();

      // 🌟 Xを開いたので「ミッション達成済み（isCompleted）」として記録！
      await SharedPrefsHelper.setXFollowClaimedEver();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.missionXOpenedSuccess),
            backgroundColor: Colors.orange,
          ),
        );
        _loadMissions(); // 画面をリロードしてボタンを「うけとる！」に変化させる
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.missionXOpenError),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _tabController == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF3E0),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final l10n = AppLocalizations.of(context)!;
    final List<Widget> tabs = [];
    final List<Widget> tabViews = [];
    int tabIndex = 0; // タブのインデックスを自動で振る

    // フラグが true の時だけ「チュートリアル」タブを追加
    if (_showTutorialTab) {
      tabs.add(
        _buildCompactTab(
          l10n.missionTabTutorial,
          Icons.school,
          _hasUnclaimedTutorial,
          tabIndex++,
        ),
      );
      tabViews.add(_buildMissionList(MissionCategory.tutorial));
    }

    // 🌟 デイリーミッションタブを追加
    tabs.add(
      _buildCompactTab(
        l10n.missionTabDaily,
        Icons.event_available,
        _hasUnclaimedDaily,
        tabIndex++,
      ),
    );
    tabViews.add(_buildMissionList(MissionCategory.daily));

    // 「はじめて」と「累計」は常に表示
    tabs.add(
      _buildCompactTab(
        l10n.missionTabFirstTime,
        Icons.star,
        _hasUnclaimedFirstTime,
        tabIndex++,
      ),
    );
    tabViews.add(_buildMissionList(MissionCategory.firstTime));

    tabs.add(
      _buildCompactTab(
        l10n.missionTabCumulative,
        Icons.bar_chart,
        _hasUnclaimedCumulative,
        tabIndex++,
      ),
    );
    tabViews.add(_buildMissionList(MissionCategory.cumulative));

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: Text(
          l10n.missionScreenTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFF7043),
        foregroundColor: Colors.white,
        leading: BlinkingEffect(
          // 🌟 Step 4 で戻るボタンを点滅
          isBlinking: widget.isTutorialMode! && _tutorialStep == 4,
          child: Stack(
            children: [
              IgnorePointer(
                // 🌟 Step 4 以外ではチュートリアル中に戻れないようにする
                ignoring: widget.isTutorialMode! && _tutorialStep != 4,
                child: Opacity(
                  opacity: (widget.isTutorialMode! && _tutorialStep != 4)
                      ? 0.3
                      : 1.0,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      try {
                        SfxManager.instance.playTapSound();
                      } catch (e) {}
                      if (widget.isTutorialMode == true && _tutorialStep == 4) {
                        Navigator.of(
                          context,
                        ).pop('mission_first_promise'); // 全完了の合図を返す
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),
              ),
              if (widget.isTutorialMode! && _tutorialStep == 4)
                const Positioned(
                  right: -10,
                  bottom: -10,
                  child: AnimatedTapFinger(),
                ),
            ],
          ),
        ),
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
          controller: _tabController, // 🌟 追加
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
          SafeArea(
            child: TabBarView(controller: _tabController, children: tabViews),
          ), // 🌟 追加
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
          _buildTutorialBubble(), // 🌟 追加: チュートリアル用の吹き出し
        ],
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

    // 🌟 修正: チュートリアルの最初のボタン。Step0の時のみ活性＆点滅
    final bool isTutorialTargetBtn =
        widget.isTutorialMode! &&
        mission.id == 'mission_first_promise' &&
        mission.isCompleted &&
        !mission.isClaimed &&
        _tutorialStep == 0;

    // 🌟 追加: 「やくそくをたいけんしよう」の「やってみる」ボタンかどうか
    final bool isTryItBlinking =
        mission.id == 'mission_first_promise' &&
        !mission.isCompleted &&
        !mission.isClaimed;

    if (mission.isClaimed) {
      buttonColor = Colors.grey;
      buttonText = l10n.missionButtonCleared;
      onPressed = null;
    } else if (mission.isCompleted) {
      buttonColor = const Color(0xFFFF7043);
      buttonText = l10n.missionButtonClaim;
      onPressed = () => _claimReward(mission);
    } else {
      if (mission.id == 'mission_x_follow') {
        buttonColor = Colors.blue; // X（Twitter）っぽい色に
        buttonText = l10n.missionXFollowButton; // 「フォローする」
        onPressed = () => _executeXFollow(); // 先ほど作ったメソッドを呼ぶ
      } else if (mission.id == 'mission_x_share') {
        buttonColor = Colors.blue;
        buttonText = l10n.missionXShareButton; // 「シェアしてゲット」
        onPressed = () => _executeXShare();
      } else if (mission.category == MissionCategory.tutorial) {
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
                            '${l10n.missionRewardPrefix} ${mission.rewardPoints * _multiplier} ${AppLocalizations.of(context)!.points}',
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
                  // チュートリアル中なら対象ボタン、または「やってみる」ボタンを点滅
                  isBlinking: isTutorialTargetBtn || isTryItBlinking,
                  // 紫色の点滅を表現したい場合は、BlinkingEffectの内部実装によりますが、
                  // 今回はCard自体ではなくボタンを覆うようにIgnorePointer等と組み合わせます
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 🌟 追加: チュートリアル中かつ対象以外のボタンは非活性にする
                      IgnorePointer(
                        ignoring:
                            widget.isTutorialMode! &&
                            !isTutorialTargetBtn &&
                            !isTryItBlinking &&
                            !(mission.isCompleted && !mission.isClaimed),
                        child: Opacity(
                          opacity:
                              (widget.isTutorialMode! &&
                                  !isTutorialTargetBtn &&
                                  !isTryItBlinking &&
                                  !(mission.isCompleted && !mission.isClaimed))
                              ? 0.3
                              : 1.0,
                          child: ElevatedButton(
                            onPressed: onPressed,
                            style: ElevatedButton.styleFrom(
                              // 紫色にしたい場合はここで色を上書き
                              backgroundColor: buttonColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation:
                                  mission.isCompleted && !mission.isClaimed
                                  ? 4
                                  : 0,
                            ),
                            child: Text(
                              buttonText,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (isTutorialTargetBtn || isTryItBlinking)
                        const Positioned(
                          right: -10,
                          bottom: -10,
                          child: AnimatedTapFinger(),
                        ),
                    ],
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
