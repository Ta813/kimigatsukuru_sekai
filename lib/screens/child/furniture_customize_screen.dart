// lib/screens/child/furniture_customize_screen.dart

import 'package:flutter/material.dart';
import '../../models/shop_data.dart';
import '../../helpers/shared_prefs_helper.dart';
import '../../managers/sfx_manager.dart';
import '../../widgets/ad_banner.dart';
import '../../l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum CustomizeMode {
  house, // 家の中モード
  island, // 島モード
  sea, // 海モード
  sky, // 空モード
  space, // 宇宙モード
}

class FurnitureCustomizeScreen extends StatefulWidget {
  final CustomizeMode mode; // ★ どのモードで開かれたかを受け取る

  const FurnitureCustomizeScreen({
    super.key,
    required this.mode, // ★ コンストラクタで必須にする
  });

  @override
  State<FurnitureCustomizeScreen> createState() =>
      _FurnitureCustomizeScreenState();
}

class _FurnitureCustomizeScreenState extends State<FurnitureCustomizeScreen> {
  List<String> _purchasedItemNames = [];
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

  // ★応援キャラ選択用のグリッドビューを構築するメソッド
  Widget _buildMultiSelectionGrid(
    List<ShopItem> options,
    List<String> selected,
    String type,
  ) {
    return GridView.builder(
      shrinkWrap: true, // GridViewが親の高さに合わせるようにする
      physics: const NeverScrollableScrollPhysics(), // GridView自体のスクロールを無効にする
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8, // 1行に表示するアイテム数
        crossAxisSpacing: 20, // アイテム間の横スペース
        mainAxisSpacing: 20, // アイテム間の縦スペース
        childAspectRatio: 1.0, // アイテムの縦横比 (正方形)
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final item = options[index];
        final isSelected = selected.contains(item.imagePath); // ★選択されているかチェック

        return GestureDetector(
          onTap: () async {
            try {
              SfxManager.instance.playTapSound();
            } catch (e) {
              // エラーが発生した場合
              print('再生エラー: $e');
            }
            setState(() {
              if (isSelected) {
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
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? Colors.blueAccent
                    : Colors.grey, // 選択状態によって色を変える
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                      ),
                    ]
                  : [],
            ),
            child: Image.asset(item.imagePath, fit: BoxFit.contain),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Tab> tabs;
    final List<Widget> tabViews;

    if (widget.mode == CustomizeMode.house) {
      final ownedFurniture = shopItems
          .where(
            (item) =>
                item.type == 'furniture' &&
                _purchasedItemNames.contains(item.name),
          )
          .toList();
      final ownedHouseItems = shopItems
          .where(
            (item) =>
                item.type == 'house_item' &&
                _purchasedItemNames.contains(item.name),
          )
          .toList();

      tabs = [
        Tab(
          text: AppLocalizations.of(context)!.furniture,
          icon: Icon(Icons.chair),
        ),
        Tab(
          text: AppLocalizations.of(context)!.houseItems,
          icon: Icon(Icons.widgets),
        ),
      ];

      tabViews = [
        _buildMultiSelectionGrid(
          ownedFurniture,
          _equippedFurniture,
          'furniture',
        ),
        _buildMultiSelectionGrid(
          ownedHouseItems,
          _equippedHouseItems,
          'house_item',
        ),
      ];
    } else if (widget.mode == CustomizeMode.island) {
      final ownedBuildings = shopItems
          .where(
            (item) =>
                item.type == 'building' &&
                _purchasedItemNames.contains(item.name),
          )
          .toList();
      final ownedVehicles = shopItems
          .where(
            (item) =>
                item.type == 'vehicle' &&
                _purchasedItemNames.contains(item.name),
          )
          .toList();

      tabs = [
        Tab(
          text: AppLocalizations.of(context)!.buildings,
          icon: Icon(Icons.home_work),
        ),
        Tab(
          text: AppLocalizations.of(context)!.vehicles,
          icon: Icon(Icons.directions_car),
        ),
      ];

      tabViews = [
        _buildMultiSelectionGrid(
          ownedBuildings,
          _equippedBuildings,
          'building',
        ),
        _buildMultiSelectionGrid(ownedVehicles, _equippedVehicles, 'vehicle'),
      ];
    } else if (widget.mode == CustomizeMode.sea) {
      final ownedSeaItems = shopItems
          .where(
            (item) =>
                item.type == 'sea_item' &&
                _purchasedItemNames.contains(item.name),
          )
          .toList();
      final ownedLiving = shopItems
          .where(
            (item) =>
                item.type == 'living' &&
                _purchasedItemNames.contains(item.name),
          )
          .toList();

      tabs = [
        Tab(
          text: AppLocalizations.of(context)!.seaItems,
          icon: Icon(Icons.anchor),
        ),
        Tab(
          text: AppLocalizations.of(context)!.seaCreatures,
          icon: FaIcon(FontAwesomeIcons.fish),
        ),
      ];

      tabViews = [
        _buildMultiSelectionGrid(ownedSeaItems, _equippedSeaItems, 'sea_item'),
        _buildMultiSelectionGrid(ownedLiving, _equippedLivings, 'living'),
      ];
    } else if (widget.mode == CustomizeMode.sky) {
      final ownedSeaItems = shopItems
          .where(
            (item) =>
                item.type == 'sky_item' &&
                _purchasedItemNames.contains(item.name),
          )
          .toList();
      final ownedLiving = shopItems
          .where(
            (item) =>
                item.type == 'sky_living' &&
                _purchasedItemNames.contains(item.name),
          )
          .toList();

      tabs = [
        Tab(
          text: AppLocalizations.of(context)!.skyItems,
          icon: Icon(Icons.flight),
        ),
        Tab(
          text: AppLocalizations.of(context)!.skyCreatures,
          icon: FaIcon(FontAwesomeIcons.dove),
        ),
      ];

      tabViews = [
        _buildMultiSelectionGrid(ownedSeaItems, _equippedSkyItems, 'sky_item'),
        _buildMultiSelectionGrid(
          ownedLiving,
          _equippedSkyLivings,
          'sky_living',
        ),
      ];
    } else {
      final ownedSeaItems = shopItems
          .where(
            (item) =>
                item.type == 'space_item' &&
                _purchasedItemNames.contains(item.name),
          )
          .toList();
      final ownedLiving = shopItems
          .where(
            (item) =>
                item.type == 'space_living' &&
                _purchasedItemNames.contains(item.name),
          )
          .toList();

      tabs = [
        Tab(
          text: AppLocalizations.of(context)!.spaceItems,
          icon: Icon(Icons.rocket_launch),
        ),
        Tab(
          text: AppLocalizations.of(context)!.spaceCreatures,
          icon: FaIcon(FontAwesomeIcons.redditAlien),
        ),
      ];

      tabViews = [
        _buildMultiSelectionGrid(
          ownedSeaItems,
          _equippedSpaceItems,
          'space_item',
        ),
        _buildMultiSelectionGrid(
          ownedLiving,
          _equippedSpaceLivings,
          'space_living',
        ),
      ];
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
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
          ),
          bottom: TabBar(
            tabs: tabs, // ★ 準備したタブリストを使用
          ),
        ),
        body: SafeArea(child: TabBarView(children: tabViews)),
        // 画面下部にバナーを設置
        bottomNavigationBar: const AdBanner(),
      ),
    );
  }
}
