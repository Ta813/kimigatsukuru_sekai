import 'package:flutter/material.dart';
import 'package:kimigatsukuru_sekai/widgets/ad_banner.dart';
import '../../helpers/shared_prefs_helper.dart'; // 既存のヘルパー
import '../../managers/trophy_manager.dart'; // 先ほど作ったマネージャー
import '../../l10n/app_localizations.dart';

class TrophyScreen extends StatefulWidget {
  const TrophyScreen({super.key});

  @override
  State<TrophyScreen> createState() => _TrophyScreenState();
}

class _TrophyScreenState extends State<TrophyScreen>
    with TickerProviderStateMixin {
  List<String> _unlockedTrophies = [];
  List<TrophyItem> _allTrophies = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 🌟 4つのジャンルに合わせてタブコントローラーを初期化
    _tabController = TabController(length: 4, vsync: this);
    _loadClaimedData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadClaimedData() async {
    final unlockedIds = await SharedPrefsHelper.loadUnlockedTrophies();
    if (!mounted) return;
    setState(() {
      _unlockedTrophies = unlockedIds;
      _allTrophies = TrophyManager.getAllTrophies(context); // マネージャーから全リストを取得
      _isLoading = false;
    });
  }

  // 🌟 特定のジャンル（プレフィックス）のトロフィーだけをフィルタリングするヘルパー
  List<TrophyItem> _filterTrophies(String prefix) {
    return _allTrophies.where((t) => t.id.startsWith(prefix)).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF3E0),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        toolbarHeight: 40,
        title: Text(
          AppLocalizations.of(context)!.trophyRoom,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFF7043),
        foregroundColor: Colors.white,
        // 🌟 ジャンルごとのタブバーを配置
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month, size: 18),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.trophyLogin),
                ],
              ),
            ),
            Tab(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.storefront, size: 18),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.trophyShopping),
                ],
              ),
            ),
            Tab(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.military_tech, size: 18),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.trophyLevel),
                ],
              ),
            ),
            Tab(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.stars, size: 18),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.trophyPoint),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTrophyGrid(_filterTrophies('trophy_login_')),
          _buildTrophyGrid(_filterTrophies('trophy_shop_')),
          _buildTrophyGrid(_filterTrophies('trophy_level_')),
          _buildTrophyGrid(_filterTrophies('trophy_point_')),
        ],
      ),
      // 画面下部にバナーを設置
      bottomNavigationBar: const AdBanner(),
    );
  }

  // 🌟 各タブの中身（グリッド表示）を作る共通メソッド
  Widget _buildTrophyGrid(List<TrophyItem> trophies) {
    if (trophies.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.trophyNone));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7, // 横に3つ並べる
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8, // 少し縦長にして文字を収める
      ),
      itemCount: trophies.length,
      itemBuilder: (context, index) {
        final trophy = trophies[index];
        final isUnlocked = _unlockedTrophies.contains(trophy.id);
        return _buildTrophyCard(trophy, isUnlocked);
      },
    );
  }

  // 🌟 トロフィー1個ずつのカードUI
  Widget _buildTrophyCard(TrophyItem trophy, bool isUnlocked) {
    IconData displayIcon = trophy.icon;

    return Card(
      elevation: isUnlocked ? 4 : 0, // 未達成はペタッとさせて立体感をなくす
      // 🌟 未達成のものは薄暗いグレー（Colors.grey[200]）にする
      color: isUnlocked ? Colors.white : Colors.grey[200]!.withOpacity(0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: (isUnlocked && trophy.rank == TrophyRank.diamond)
            ? const BorderSide(color: Color(0xFFb9f2ff), width: 3)
            : BorderSide.none,
      ),
      child: Opacity(
        // 🌟 未達成のものはコンテンツ全体を少し半透明（薄暗く）にする
        opacity: isUnlocked ? 1.0 : 0.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // トロフィーアイコン（未達成でも鍵ではなく本来のアイコンが見える）
            Icon(
              displayIcon,
              size: 44,
              color: isUnlocked ? trophy.color : Colors.grey[400],
            ),
            const SizedBox(height: 8),
            // トロフィーのタイトル（未達成でも「◯◯ポイント」などの目標値がそのまま表示される）
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                trophy.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isUnlocked ? Colors.black87 : Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 4),
            // 達成・未達成のステータスラベル
            Text(
              isUnlocked ? AppLocalizations.of(context)!.trophyCleared : '',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? Colors.green[700] : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
