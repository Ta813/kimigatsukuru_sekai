// lib/screens/child/furniture_customize_screen.dart

import 'package:flutter/material.dart';
import '../../models/shop_data.dart';
import '../../helpers/shared_prefs_helper.dart';
import '../../managers/sfx_manager.dart';
import '../../widgets/ad_banner.dart';
import '../../l10n/app_localizations.dart';

enum CustomizeMode {
  house, // 家の中モード
  island, // 島モード
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

    setState(() {
      _purchasedItemNames = purchased;
      _equippedFurniture = furniture;
      _equippedHouseItems = houseItems;
      _equippedBuildings = buildings;
      _equippedVehicles = vehicles;
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
    } else {
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
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.mode == CustomizeMode.house
                ? AppLocalizations.of(context)!.houseSettings
                : AppLocalizations.of(context)!.islandSettings,
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
