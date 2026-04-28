// lib/screens/child/furniture_customize_screen.dart

import 'package:flutter/material.dart';
import 'package:kimigatsukuru_sekai/widgets/ad_banner.dart';
import '../../widgets/custom_back_button.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../../models/shop_data.dart';
import '../../helpers/shared_prefs_helper.dart';
import '../../managers/sfx_manager.dart';
import '../../l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../managers/purchase_manager.dart'; // 🌟 追加: プレミアムプランの判定用

enum CustomizeMode {
  house, // 家の中モード
  island, // 島モード
  sea, // 海モード
  sky, // 空モード
  space, // 宇宙モード
}

class FurnitureCustomizeScreen extends StatefulWidget {
  final CustomizeMode mode;

  const FurnitureCustomizeScreen({super.key, required this.mode});

  @override
  State<FurnitureCustomizeScreen> createState() =>
      _FurnitureCustomizeScreenState();
}

class _FurnitureCustomizeScreenState extends State<FurnitureCustomizeScreen> {
  List<String> _purchasedItemNames = [];

  // 🌟 追加: レベルとポイントを管理
  int _currentLevel = 1;
  int _currentPoints = 0;

  List<String> _equippedFurniture = [];
  List<String> _equippedHouseItems = [];
  List<String> _equippedBuildings = [];
  List<String> _equippedVehicles = [];
  List<String> _equippedSeaItems = [];
  List<String> _equippedLivings = [];
  List<String> _equippedSkyItems = [];
  List<String> _equippedSkyLivings = [];
  List<String> _equippedSpaceItems = [];
  List<String> _equippedSpaceLivings = [];

  @override
  void initState() {
    super.initState();
    _loadEquippedItems();
  }

  Future<void> _loadEquippedItems() async {
    final purchased = await SharedPrefsHelper.loadPurchasedItems();
    // 🌟 追加: 現在のレベルとポイントを読み込む
    final level = await SharedPrefsHelper.loadLevel();
    final points = await SharedPrefsHelper.loadPoints();

    final furniture = await SharedPrefsHelper.loadEquippedFurniture();
    final houseItems = await SharedPrefsHelper.loadEquippedHouseItems();
    final buildings = await SharedPrefsHelper.loadEquippedBuildings();
    final vehicles = await SharedPrefsHelper.loadEquippedVehicles();
    final seaItems = await SharedPrefsHelper.loadEquippedSeaItems();
    final livings = await SharedPrefsHelper.loadEquippedLivings();
    final skyItems = await SharedPrefsHelper.loadEquippedSkyItems();
    final skyLivings = await SharedPrefsHelper.loadEquippedSkyLivings();
    final spaceItems = await SharedPrefsHelper.loadEquippedSpaceItems();
    final spaceLivings = await SharedPrefsHelper.loadEquippedSpaceLivings();

    setState(() {
      _purchasedItemNames = purchased;
      _currentLevel = level;
      _currentPoints = points;

      _equippedFurniture = furniture;
      _equippedHouseItems = houseItems;
      _equippedBuildings = buildings;
      _equippedVehicles = vehicles;
      _equippedSeaItems = seaItems;
      _equippedLivings = livings;
      _equippedSkyItems = skyItems;
      _equippedSkyLivings = skyLivings;
      _equippedSpaceItems = spaceItems;
      _equippedSpaceLivings = spaceLivings;
    });
  }

  // 🌟 アプリバーに表示するポイント部分の共通化
  List<Widget> _buildAppBarActions() {
    return [
      Padding(
        padding: const EdgeInsets.only(right: 20.0),
        child: Center(
          child: Text(
            '$_currentPoints ${AppLocalizations.of(context)?.points ?? "P"}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ];
  }

  // 🌟 アイテムの装備・解除を行う共通処理
  Future<void> _toggleEquip(
    ShopItem item,
    List<String> selected,
    String type,
  ) async {
    FirebaseAnalytics.instance.logEvent(
      name: 'start_furniture_customize_select',
      parameters: {'item_name': item.name, 'item_type': type},
    );
    try {
      SfxManager.instance.playTapSound();
    } catch (e) {
      print('再生エラー: $e');
    }
    setState(() {
      if (selected.contains(item.imagePath)) {
        selected.remove(item.imagePath); // 選択解除
      } else {
        selected.add(item.imagePath); // 選択追加
      }
    });

    if (type == 'furniture') {
      await SharedPrefsHelper.saveEquippedFurniture(selected);
    } else if (type == 'house_item') {
      await SharedPrefsHelper.saveEquippedHouseItems(selected);
    } else if (type == 'building') {
      await SharedPrefsHelper.saveEquippedBuildings(selected);
    } else if (type == 'vehicle') {
      await SharedPrefsHelper.saveEquippedVehicles(selected);
    } else if (type == 'sea_item') {
      await SharedPrefsHelper.saveEquippedSeaItems(selected);
    } else if (type == 'living') {
      await SharedPrefsHelper.saveEquippedLivings(selected);
    } else if (type == 'sky_item') {
      await SharedPrefsHelper.saveEquippedSkyItems(selected);
    } else if (type == 'sky_living') {
      await SharedPrefsHelper.saveEquippedSkyLivings(selected);
    } else if (type == 'space_item') {
      await SharedPrefsHelper.saveEquippedSpaceItems(selected);
    } else if (type == 'space_living') {
      await SharedPrefsHelper.saveEquippedSpaceLivings(selected);
    }
  }

  // 🌟 未購入のアイテムをタップした時の処理
  void _handlePurchaseAttempt(
    ShopItem item,
    List<String> selected,
    String type,
  ) async {
    final bool isLevelLocked = _currentLevel < item.requiredLevel;
    final bool isLocked =
        isLevelLocked && !PurchaseManager.instance.isPremium.value;

    if (isLocked) {
      // プレミアム誘導ダイアログ
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.upgradeToPremium,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFF7043).withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(
                    context,
                  )!.shopLevelLockMessage(item.requiredLevel),
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.premiumShopUnlockMessage,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await PurchaseManager.instance.showPaywall();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7043),
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFFFCA28), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
              ),
              child: Text(
                AppLocalizations.of(context)!.seeDetails,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
      return;
    }

    // 購入確認ダイアログ
    if (_currentPoints < item.price) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.shopNotEnoughPoints),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          item.getDisplayName(context),
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFF7043).withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Text(
            AppLocalizations.of(context)!.shopConfirmExchange(item.price),
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              try {
                SfxManager.instance.playTapSound();
              } catch (e) {}
              Navigator.pop(context);
            },
            child: Text(
              AppLocalizations.of(context)!.quitAction,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              FirebaseAnalytics.instance.logEvent(
                name: 'start_customize_buy_item',
              );

              final l10n = AppLocalizations.of(context);
              final lang = l10n?.localeName ?? 'en';
              if (lang == 'ja') {
                try {
                  SfxManager.instance.playShopBuySound();
                } catch (e) {}
              } else {
                final String voiceDir = SfxManager.instance.getVoiceDir(lang);
                try {
                  SfxManager.instance.playSequentialSounds([
                    'se/$voiceDir/thank_you_very_much.mp3',
                  ]);
                } catch (e) {}
              }

              // ポイント消費・アイテム追加・装備をまとめて行う
              final newPoints = _currentPoints - item.price;
              await SharedPrefsHelper.savePoints(newPoints);
              await SharedPrefsHelper.addPurchasedItem(item.name);
              SharedPrefsHelper.incrementShopCount();

              if (mounted) {
                Navigator.pop(context);
                setState(() {
                  _currentPoints = newPoints;
                  _purchasedItemNames.add(item.name);
                });
                _toggleEquip(item, selected, type); // 買ってすぐ装備！
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7043),
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFFFCA28), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
            ),
            child: Text(
              AppLocalizations.of(context)!.exchange,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // 🌟 複数選択・未購入対応のグリッド
  Widget _buildMultiSelectionGrid(
    List<ShopItem> options,
    List<String> selected,
    String type,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75, // 縦を少し長めに
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final item = options[index];
        final isSelected = selected.contains(item.imagePath);

        final bool isPurchased = _purchasedItemNames.contains(item.name);
        final bool isLevelLocked = _currentLevel < item.requiredLevel;
        final bool isLocked =
            isLevelLocked && !PurchaseManager.instance.isPremium.value;

        return Card(
          elevation: isSelected ? 4 : 2,
          color: isPurchased ? Colors.white : Colors.grey[200],
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: isSelected ? Colors.blueAccent : Colors.transparent,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              if (isPurchased) {
                _toggleEquip(item, selected, type);
              } else {
                _handlePurchaseAttempt(item, selected, type);
              }
            },
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Opacity(
                          opacity: (!isPurchased || isLocked) ? 0.5 : 1.0,
                          child: Image.asset(item.imagePath),
                        ),
                      ),
                    ),
                    // 未購入なら値段を表示
                    if (!isPurchased) ...[
                      Text(
                        '${item.price}P',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    // 装備中ならラベルを表示
                    if (isSelected) ...[
                      Container(
                        color: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          AppLocalizations.of(
                            context,
                          )!.labelPlaced, // 分かりやすいテキスト
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ] else if (isPurchased) ...[
                      const SizedBox(height: 16), // レイアウト崩れ防止
                    ],
                  ],
                ),
                // ロック状態なら鍵アイコンをオーバーレイ
                if (isLocked)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock, color: Colors.white, size: 28),
                          const SizedBox(height: 4),
                          Text(
                            'Lv.${item.requiredLevel}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🌟 プレミアムプランの変更を監視して即時UIを更新する
    return ValueListenableBuilder<bool>(
      valueListenable: PurchaseManager.instance.isPremium,
      builder: (context, isPremium, child) {
        final List<Tab> tabs;
        final List<Widget> tabViews;

        if (widget.mode == CustomizeMode.house) {
          // 🌟 変更: 未購入のものを含めるためフィルターを type だけで判定
          final allFurniture = shopItems
              .where((item) => item.type == 'furniture')
              .toList();
          final allHouseItems = shopItems
              .where((item) => item.type == 'house_item')
              .toList();

          tabs = [
            Tab(
              text: AppLocalizations.of(context)!.furniture,
              icon: const Icon(Icons.chair),
            ),
            Tab(
              text: AppLocalizations.of(context)!.houseItems,
              icon: const Icon(Icons.widgets),
            ),
          ];
          tabViews = [
            _buildMultiSelectionGrid(
              allFurniture,
              _equippedFurniture,
              'furniture',
            ),
            _buildMultiSelectionGrid(
              allHouseItems,
              _equippedHouseItems,
              'house_item',
            ),
          ];
        } else if (widget.mode == CustomizeMode.island) {
          final allBuildings = shopItems
              .where((item) => item.type == 'building')
              .toList();
          final allVehicles = shopItems
              .where((item) => item.type == 'vehicle')
              .toList();

          tabs = [
            Tab(
              text: AppLocalizations.of(context)!.buildings,
              icon: const Icon(Icons.home_work),
            ),
            Tab(
              text: AppLocalizations.of(context)!.vehicles,
              icon: const Icon(Icons.directions_car),
            ),
          ];
          tabViews = [
            _buildMultiSelectionGrid(
              allBuildings,
              _equippedBuildings,
              'building',
            ),
            _buildMultiSelectionGrid(allVehicles, _equippedVehicles, 'vehicle'),
          ];
        } else if (widget.mode == CustomizeMode.sea) {
          final allSeaItems = shopItems
              .where((item) => item.type == 'sea_item')
              .toList();
          final allLiving = shopItems
              .where((item) => item.type == 'living')
              .toList();

          tabs = [
            Tab(
              text: AppLocalizations.of(context)!.seaItems,
              icon: const Icon(Icons.anchor),
            ),
            Tab(
              text: AppLocalizations.of(context)!.seaCreatures,
              icon: const FaIcon(FontAwesomeIcons.fish),
            ),
          ];
          tabViews = [
            _buildMultiSelectionGrid(
              allSeaItems,
              _equippedSeaItems,
              'sea_item',
            ),
            _buildMultiSelectionGrid(allLiving, _equippedLivings, 'living'),
          ];
        } else if (widget.mode == CustomizeMode.sky) {
          final allSkyItems = shopItems
              .where((item) => item.type == 'sky_item')
              .toList();
          final allSkyLiving = shopItems
              .where((item) => item.type == 'sky_living')
              .toList();

          tabs = [
            Tab(
              text: AppLocalizations.of(context)!.skyItems,
              icon: const Icon(Icons.flight),
            ),
            Tab(
              text: AppLocalizations.of(context)!.skyCreatures,
              icon: const FaIcon(FontAwesomeIcons.dove),
            ),
          ];
          tabViews = [
            _buildMultiSelectionGrid(
              allSkyItems,
              _equippedSkyItems,
              'sky_item',
            ),
            _buildMultiSelectionGrid(
              allSkyLiving,
              _equippedSkyLivings,
              'sky_living',
            ),
          ];
        } else {
          // space
          final allSpaceItems = shopItems
              .where((item) => item.type == 'space_item')
              .toList();
          final allSpaceLiving = shopItems
              .where((item) => item.type == 'space_living')
              .toList();

          tabs = [
            Tab(
              text: AppLocalizations.of(context)!.spaceItems,
              icon: const Icon(Icons.rocket_launch),
            ),
            Tab(
              text: AppLocalizations.of(context)!.spaceCreatures,
              icon: const FaIcon(FontAwesomeIcons.redditAlien),
            ),
          ];
          tabViews = [
            _buildMultiSelectionGrid(
              allSpaceItems,
              _equippedSpaceItems,
              'space_item',
            ),
            _buildMultiSelectionGrid(
              allSpaceLiving,
              _equippedSpaceLivings,
              'space_living',
            ),
          ];
        }

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 40,
              leading: const CustomBackButton(),
              title: Text(
                widget.mode == CustomizeMode.house
                    ? AppLocalizations.of(context)!.houseSettings
                    : widget.mode == CustomizeMode.island
                    ? AppLocalizations.of(context)!.islandSettings
                    : widget.mode == CustomizeMode.sea
                    ? AppLocalizations.of(context)!.seaSettings
                    : widget.mode == CustomizeMode.sky
                    ? AppLocalizations.of(context)!.skySettings
                    : AppLocalizations.of(context)!.spaceSettings,
                style: const TextStyle(fontSize: 18),
              ),
              actions: _buildAppBarActions(), // 🌟 追加: 右上のポイント表示
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(40),
                child: TabBar(
                  tabs: tabs.map((tab) {
                    return Tab(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (tab.icon != null) ...[
                            IconTheme(
                              data: const IconThemeData(size: 18),
                              child: tab.icon!,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(tab.text ?? ""),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            body: SafeArea(child: TabBarView(children: tabViews)),
            bottomNavigationBar: const AdBanner(),
          ),
        );
      },
    );
  }
}
