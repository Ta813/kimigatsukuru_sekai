// lib/screens/shop/shop_screen.dart

import 'package:flutter/material.dart';
import '../../helpers/shared_prefs_helper.dart';
import '../../managers/sfx_manager.dart';
import '../../widgets/ad_banner.dart';
import '../../models/shop_data.dart';
import '../../l10n/app_localizations.dart';

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
    _points = widget.currentPoints;
    _loadPurchasedItems();
  }

  bool _hasPlayedInitialSound = false;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    // ★サウンドがまだ再生されていなければ
    if (!_hasPlayedInitialSound) {
      final lang = AppLocalizations.of(context)!.localeName;
      if (lang == 'ja') {
        SfxManager.instance.playShopInitSound();
      } else {
        final List<String> soundsToPlay = [];
        soundsToPlay.addAll(['se/english/welcome.mp3']);
        SfxManager.instance.playSequentialSounds(soundsToPlay);
      }
      _hasPlayedInitialSound = true; // ★再生済みの旗を立てる
    }
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
          title: Text(item.getDisplayName(context)),
          content: Text(
            AppLocalizations.of(context)!.shopConfirmExchange(item.price),
          ),
          actions: [
            TextButton(
              onPressed: () {
                SfxManager.instance.playTapSound();
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.quitAction),
            ),
            ElevatedButton(
              onPressed: () async {
                final lang = AppLocalizations.of(context)!.localeName;
                if (lang == 'ja') {
                  SfxManager.instance.playShopBuySound();
                } else {
                  final List<String> soundsToPlay = [];
                  soundsToPlay.addAll(['se/english/thank_you_very_much.mp3']);
                  SfxManager.instance.playSequentialSounds(soundsToPlay);
                }
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
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(
                        context,
                      )!.shopExchangeSuccess(item.getDisplayName(context)),
                    ),
                  ),
                );
              },

              child: Text(AppLocalizations.of(context)!.exchange),
            ),
          ],
        ),
      );
    } else {
      // ポイントが足りない場合
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.shopNotEnoughPoints),
        ),
      );
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
                  item.getDisplayName(context),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '${item.price} ${AppLocalizations.of(context)!.points}',
                  textAlign: TextAlign.center,
                ),
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
                  child: Text(
                    AppLocalizations.of(context)!.itemPurchased,
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

  Widget _buildCategoryGrid(
    List<ShopItem> items, {
    required int crossAxisCount,
  }) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount, // 1行に表示する数
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.9, // アイテムの縦横比
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildShopItemCard(item); // 既存のアイテムカードウィジェットを再利用
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // まず、アイテムをカテゴリ別に分けます
    final clothesItems = shopItems
        .where(
          (item) =>
              item.type == 'clothes' &&
              item.name != 'いつものふく' &&
              item.name != 'おとこのこ',
        )
        .toList();
    final houseItems = shopItems
        .where((item) => item.type == 'house' && item.name != 'さいしょのおうち')
        .toList();
    final characterItems = shopItems
        .where((item) => item.type == 'character' && item.name != 'ウサギ')
        .toList();
    final itemItems = shopItems.where((item) => item.type == 'item').toList();

    return DefaultTabController(
      length: 4, // ★タブの数
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.shopTitle),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Center(
                child: Text(
                  '$_points ${AppLocalizations.of(context)!.points}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
          // ★AppBarの下にTabBarを設置します
          bottom: TabBar(
            isScrollable: true, // タブが多くなってもスクロールできるようにする
            tabs: [
              Tab(
                text: AppLocalizations.of(context)!.customizeTabClothes,
                icon: Icon(Icons.checkroom),
              ),
              Tab(
                text: AppLocalizations.of(context)!.customizeTabHouse,
                icon: Icon(Icons.house),
              ),
              Tab(
                text: AppLocalizations.of(context)!.customizeTabCharacter,
                icon: Icon(Icons.support_agent),
              ),
              Tab(
                text: AppLocalizations.of(context)!.customizeTabItem,
                icon: Icon(Icons.star),
              ),
            ],
          ),
        ),
        // ★bodyをTabBarViewに変更します
        body: TabBarView(
          children: [
            // 各タブの中身となるGridViewを、共通メソッドで生成します
            _buildCategoryGrid(clothesItems, crossAxisCount: 5),
            _buildCategoryGrid(houseItems, crossAxisCount: 5),
            _buildCategoryGrid(characterItems, crossAxisCount: 5),
            _buildCategoryGrid(itemItems, crossAxisCount: 6),
          ],
        ),
        bottomNavigationBar: const AdBanner(),
      ),
    );
  }
}
