// lib/screens/shop/shop_screen.dart

import 'package:flutter/material.dart';
import '../../helpers/shared_prefs_helper.dart';
import '../../managers/sfx_manager.dart';

// ショップに並べるアイテムのデータ構造を定義
class ShopItem {
  final String name;
  final String imagePath;
  final int price;
  final String type; // 'clothes' or 'house'

  ShopItem({
    required this.name,
    required this.imagePath,
    required this.price,
    required this.type,
  });
}

// ショップのカタログデータ（仮）
final List<ShopItem> shopItems = [
  ShopItem(
    name: 'あおいふく',
    imagePath: 'assets/images/clothes_blue.gif',
    price: 50,
    type: 'clothes',
  ),
  ShopItem(
    name: 'あかいふく',
    imagePath: 'assets/images/clothes_red.gif',
    price: 50,
    type: 'clothes',
  ),
  ShopItem(
    name: 'みどりのふく',
    imagePath: 'assets/images/clothes_green.gif',
    price: 50,
    type: 'clothes',
  ),
  ShopItem(
    name: 'ふつうのおうち',
    imagePath: 'assets/images/house_normal.png',
    price: 500,
    type: 'house',
  ),
  ShopItem(
    name: 'りっぱなおうち',
    imagePath: 'assets/images/house_rich.png',
    price: 1500,
    type: 'house',
  ),
];

class ShopScreen extends StatefulWidget {
  final int currentPoints;

  const ShopScreen({super.key, required this.currentPoints});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late int _points; // この画面で管理するポイント数

  List<String> _purchasedItemNames = [];

  @override
  void initState() {
    super.initState();
    SfxManager.instance.playShopInitSound();
    _points = widget.currentPoints;
    _loadPurchasedItems();
  }

  Future<void> _loadPurchasedItems() async {
    final items = await SharedPrefsHelper.loadPurchasedItems();
    setState(() {
      _purchasedItemNames = items;
    });
  }

  // 購入処理
  void _buyItem(ShopItem item) {
    if (_points >= item.price) {
      // ポイントが足りる場合
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(item.name),
          content: Text('${item.price}ポイントつかって、こうかんしますか？'),
          actions: [
            TextButton(
              onPressed: () {
                SfxManager.instance.playTapSound();
                Navigator.pop(context);
              },
              child: const Text('やめる'),
            ),
            ElevatedButton(
              onPressed: () async {
                SfxManager.instance.playShopBuySound();
                final newPoints = _points - item.price;
                await SharedPrefsHelper.savePoints(newPoints);

                // ★購入済みアイテムとして保存する処理を追加
                await SharedPrefsHelper.addPurchasedItem(item.name);

                if (!mounted) return;

                // 画面の状態を更新
                setState(() {
                  _points = newPoints;
                  _purchasedItemNames.add(item.name); // 画面上のリストにも追加
                });

                Navigator.pop(context); // ダイアログを閉じる

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item.name}とこうかんしたよ！')),
                );
              },

              child: const Text('こうかんする'),
            ),
          ],
        ),
      );
    } else {
      // ポイントが足りない場合
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ポイントがたりないみたい…')));
    }
  }

  Widget _buildShopItemCard(ShopItem item) {
    // ★このアイテムが購入済みかどうかをチェック
    final bool isPurchased = _purchasedItemNames.contains(item.name);

    return Card(
      elevation: 2,
      // 購入済みなら、カード全体を少しグレーにする
      color: isPurchased ? Colors.grey[200] : Colors.white,
      child: InkWell(
        // ★購入済みなら、タップできないようにする (onTap: null)
        onTap: isPurchased ? null : () => _buyItem(item),
        child: Stack(
          // ★重ねて表示するためにStackを使用
          children: [
            // アイテム情報（Column）
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    // ★購入済みなら、画像も少しグレーにする
                    child: Opacity(
                      opacity: isPurchased ? 0.5 : 1.0,
                      child: Image.asset(item.imagePath),
                    ),
                  ),
                ),
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text('${item.price} ポイント', textAlign: TextAlign.center),
                const SizedBox(height: 10),
              ],
            ),
            // ★購入済みの場合のみ、「購入済み」ラベルを上に重ねて表示
            if (isPurchased)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'こうかんずみ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // まず、アイテムをカテゴリ別に分けます
    final clothesItems = shopItems
        .where((item) => item.type == 'clothes')
        .toList();
    final houseItems = shopItems.where((item) => item.type == 'house').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ごほうびショップ'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Center(
              child: Text(
                '$_points ポイント',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      // 画面全体をスクロールできるようにします
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 服のカテゴリ ---
            const Text(
              'きせかえ',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: GridView.builder(
                shrinkWrap: true, // 他のウィジェットの中で使うためのおまじない
                physics:
                    const NeverScrollableScrollPhysics(), // GridView自体はスクロールしない
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5, // 服は1行に5つ
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: clothesItems.length,
                itemBuilder: (context, index) {
                  final item = clothesItems[index];
                  // ★アイテム表示部分は共通なので、別のウィジェットに切り出します（後述）
                  return _buildShopItemCard(item);
                },
              ),
            ),

            const SizedBox(height: 24), // カテゴリ間のスペース
            // --- 家のカテゴリ ---
            const Text(
              'おうち',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5, // 家は1行に5つ
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.9,
                ),
                itemCount: houseItems.length,
                itemBuilder: (context, index) {
                  final item = houseItems[index];
                  return _buildShopItemCard(item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
