// lib/screens/child/furniture_customize_screen.dart

import 'package:flutter/material.dart';
import '../../models/shop_data.dart';
import '../../helpers/shared_prefs_helper.dart';
import '../../managers/sfx_manager.dart';
import '../../widgets/ad_banner.dart';
import '../../l10n/app_localizations.dart';

class FurnitureCustomizeScreen extends StatefulWidget {
  const FurnitureCustomizeScreen({super.key});

  @override
  State<FurnitureCustomizeScreen> createState() =>
      _FurnitureCustomizeScreenState();
}

class _FurnitureCustomizeScreenState extends State<FurnitureCustomizeScreen> {
  List<String> _purchasedItemNames = [];
  List<String> _equippedFurniture = [];
  List<String> _equippedHouseItems = [];

  @override
  void initState() {
    super.initState();
    _loadEquippedItems();
  }

  Future<void> _loadEquippedItems() async {
    final purchased = await SharedPrefsHelper.loadPurchasedItems();
    final furniture = await SharedPrefsHelper.loadEquippedFurniture();
    final houseItems = await SharedPrefsHelper.loadEquippedHouseItems();

    setState(() {
      _purchasedItemNames = purchased;
      _equippedFurniture = furniture;
      _equippedHouseItems = houseItems;
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
            SfxManager.instance.playTapSound();
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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.customizeTitle),
          bottom: TabBar(
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chair),
                    SizedBox(width: 8), // アイコンとテキストの間のスペース
                    Text(AppLocalizations.of(context)!.furniture),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.widgets),
                    SizedBox(width: 8), // アイコンとテキストの間のスペース
                    Text(AppLocalizations.of(context)!.houseItems),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 家具の選択グリッド
            _buildMultiSelectionGrid(
              ownedFurniture,
              _equippedFurniture,
              'furniture',
            ),
            // 家のアイテムの選択グリッド
            _buildMultiSelectionGrid(
              ownedHouseItems,
              _equippedHouseItems,
              'house_item',
            ),
          ],
        ),
        // 画面下部にバナーを設置
        bottomNavigationBar: const AdBanner(),
      ),
    );
  }
}
