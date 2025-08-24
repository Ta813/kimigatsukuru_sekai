// lib/screens/character_customize/character_customize_screen.dart

import 'package:flutter/material.dart';
import '../../models/shop_data.dart';
import '../../helpers/shared_prefs_helper.dart';
import '../../managers/sfx_manager.dart';
import '../../widgets/ad_banner.dart';

class CharacterCustomizeScreen extends StatefulWidget {
  const CharacterCustomizeScreen({super.key});

  @override
  State<CharacterCustomizeScreen> createState() =>
      _CharacterCustomizeScreenState();
}

class _CharacterCustomizeScreenState extends State<CharacterCustomizeScreen> {
  List<String> _purchasedItemNames = [];
  String? _equippedClothes;
  String? _equippedHouse;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final purchased = await SharedPrefsHelper.loadPurchasedItems();
    final clothes = await SharedPrefsHelper.loadEquippedClothes();
    final house = await SharedPrefsHelper.loadEquippedHouse();
    // デフォルトのアイテムも「購入済み」として扱えるように追加
    if (!purchased.contains('いつものふく')) purchased.add('いつものふく');
    if (!purchased.contains('さいしょのおうち')) purchased.add('さいしょのおうち');

    setState(() {
      _purchasedItemNames = purchased;
      _equippedClothes = clothes ?? 'assets/images/avatar.png'; // デフォルトを設定
      _equippedHouse = house ?? 'assets/images/house.png'; // デフォルトを設定
    });
  }

  void _equipItem(ShopItem item) async {
    SfxManager.instance.playTapSound();
    await SharedPrefsHelper.saveEquippedItem(item.type, item.imagePath);
    _loadData(); // データを再読み込みして画面を更新
  }

  @override
  Widget build(BuildContext context) {
    final ownedClothes = shopItems
        .where(
          (item) =>
              item.type == 'clothes' && _purchasedItemNames.contains(item.name),
        )
        .toList();
    final ownedHouses = shopItems
        .where(
          (item) =>
              item.type == 'house' && _purchasedItemNames.contains(item.name),
        )
        .toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('きせかえ・もようがえ'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'きせかえ', icon: Icon(Icons.checkroom)),
              Tab(text: 'おうち', icon: Icon(Icons.house)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 服の選択グリッド
            _buildItemGrid(ownedClothes, _equippedClothes),
            // 家の選択グリッド
            _buildItemGrid(ownedHouses, _equippedHouse),
          ],
        ),
        // 画面下部にバナーを設置
        bottomNavigationBar: const AdBanner(),
      ),
    );
  }

  Widget _buildItemGrid(List<ShopItem> items, String? equippedItemPath) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isEquipped = item.imagePath == equippedItemPath;

        return Card(
          shape: RoundedRectangleBorder(
            // 装備中なら枠線をつける
            side: BorderSide(
              color: isEquipped ? Colors.amber : Colors.transparent,
              width: 4,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _equipItem(item),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Image.asset(item.imagePath)),
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}
