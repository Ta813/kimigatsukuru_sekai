// lib/screens/character_customize/character_customize_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:kimigatsukuru_sekai/widgets/ad_banner.dart';
import '../../models/shop_data.dart';
import '../../helpers/shared_prefs_helper.dart';
import '../../managers/sfx_manager.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/blinking_effect.dart';
import '../../widgets/custom_back_button.dart';

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
  List<String> _equippedCharacters = [];
  List<String> _equippedItems = [];

  bool _isTutorialStepCustomizeShown = true;
  String? _tutorialPurchasedItemName;
  String? _tutorialPurchasedItemType;
  bool _showTabBlinking = false;
  bool _showItemBlinking = false;
  bool _showBackButtonBlinking = false;

  @override
  void initState() {
    super.initState();
    _loadEquippedItems();
    _checkTutorialStep();
  }

  Future<void> _checkTutorialStep() async {
    final isCustomizeShown = await SharedPrefsHelper.isTutorialStepShown(
      SharedPrefsHelper.tutorialStepCustomizeKey,
    );
    bool isShown = await SharedPrefsHelper.isGuideShown();
    final purchasedItemName =
        await SharedPrefsHelper.getTutorialPurchasedItem();
    final purchasedItemType =
        await SharedPrefsHelper.getTutorialPurchasedType();
    setState(() {
      _isTutorialStepCustomizeShown = isShown || isCustomizeShown;
      _tutorialPurchasedItemName = purchasedItemName;
      _tutorialPurchasedItemType = purchasedItemType;
      _showTabBlinking = !isShown && !isCustomizeShown;
      _showItemBlinking = !isShown && !isCustomizeShown;
    });
  }

  Future<void> _loadEquippedItems() async {
    final purchased = await SharedPrefsHelper.loadPurchasedItems();
    final clothes = await SharedPrefsHelper.loadEquippedClothes();
    final house = await SharedPrefsHelper.loadEquippedHouse();
    final characters = await SharedPrefsHelper.loadEquippedCharacters();
    final items = await SharedPrefsHelper.loadEquippedItems();
    // デフォルトのアイテムも「購入済み」として扱えるように追加
    if (!purchased.contains('いつものふく')) purchased.add('いつものふく');
    if (!purchased.contains('さいしょのおうち')) purchased.add('さいしょのおうち');
    if (!purchased.contains('ウサギ')) purchased.add('ウサギ');
    if (!purchased.contains('おとこのこ')) purchased.add('おとこのこ');

    setState(() {
      _purchasedItemNames = purchased;
      _equippedClothes = clothes ?? 'assets/images/avatar.png'; // デフォルトを設定
      _equippedHouse = house ?? 'assets/images/house.png'; // デフォルトを設定
      _equippedCharacters = characters;
      _equippedItems = items;
    });
  }

  // ★応援キャラ選択用のグリッドビューを構築するメソッド
  Widget _buildMultiSelectionGrid(
    List<ShopItem> options,
    List<String> selected,
    String type,
  ) {
    int crossAxisCount = 5;
    if (type == 'item') {
      crossAxisCount = 8;
    }

    return GridView.builder(
      shrinkWrap: true, // GridViewが親の高さに合わせるようにする
      physics: const NeverScrollableScrollPhysics(), // GridView自体のスクロールを無効にする
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount, // 1行に表示するアイテム数
        crossAxisSpacing: 20, // アイテム間の横スペース
        mainAxisSpacing: 20, // アイテム間の縦スペース
        childAspectRatio: 1.0, // アイテムの縦横比 (正方形)
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final item = options[index];
        final isSelected = selected.contains(item.imagePath); // ★選択されているかチェック

        Widget itemWidget = GestureDetector(
          onTap: () async {
            FirebaseAnalytics.instance.logEvent(
              name: 'start_character_customize_equip',
              parameters: {'item_name': item.name, 'item_type': type},
            );
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
            if (type == 'character') {
              await SharedPrefsHelper.saveEquippedCharacters(selected);
            } else if (type == 'item') {
              await SharedPrefsHelper.saveEquippedItems(selected);
            }

            if (!_isTutorialStepCustomizeShown) {
              if (mounted) {
                setState(() {
                  _showTabBlinking = false;
                  _showItemBlinking = false;
                  _showBackButtonBlinking = true;
                });
              }
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

        if (_showItemBlinking && _tutorialPurchasedItemName == item.name) {
          return BlinkingEffect(isBlinking: true, child: itemWidget);
        }
        return itemWidget;
      },
    );
  }

  void _equipItem(ShopItem item) async {
    try {
      SfxManager.instance.playTapSound();
    } catch (e) {
      // エラーが発生した場合
      print('再生エラー: $e');
    }
    await SharedPrefsHelper.saveEquippedItem(item.type, item.imagePath);
    if (!_isTutorialStepCustomizeShown) {
      if (mounted) {
        setState(() {
          _showTabBlinking = false;
          _showItemBlinking = false;
          _showBackButtonBlinking = true;
        });
      }
    }
    _loadEquippedItems(); // データを再読み込みして画面を更新
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
    final ownedCharacters = shopItems
        .where(
          (item) =>
              item.type == 'character' &&
              _purchasedItemNames.contains(item.name),
        )
        .toList();
    final ownedItems = shopItems
        .where(
          (item) =>
              item.type == 'item' && _purchasedItemNames.contains(item.name),
        )
        .toList();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 40, // ★ 高さを低く設定
          leading: BlinkingEffect(
            isBlinking: _showBackButtonBlinking,
            child: const CustomBackButton(),
          ),
          title: Text(
            AppLocalizations.of(context)!.customizeTitle,
            style: const TextStyle(fontSize: 18),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: TabBar(
              tabs: [
                BlinkingEffect(
                  isBlinking:
                      _showTabBlinking &&
                      _tutorialPurchasedItemType == 'clothes',
                  child: Tab(
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.checkroom, size: 18),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.customizeTabClothes),
                      ],
                    ),
                  ),
                ),
                BlinkingEffect(
                  isBlinking:
                      _showTabBlinking && _tutorialPurchasedItemType == 'house',
                  child: Tab(
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.house, size: 18),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.customizeTabHouse),
                      ],
                    ),
                  ),
                ),
                BlinkingEffect(
                  isBlinking:
                      _showTabBlinking &&
                      _tutorialPurchasedItemType == 'character',
                  child: Tab(
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.support_agent, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.customizeTabCharacter,
                        ),
                      ],
                    ),
                  ),
                ),
                BlinkingEffect(
                  isBlinking:
                      _showTabBlinking && _tutorialPurchasedItemType == 'item',
                  child: Tab(
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, size: 18),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.customizeTabItem),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              // 服の選択グリッド
              _buildItemGrid(ownedClothes, _equippedClothes),
              // 家の選択グリッド
              _buildItemGrid(ownedHouses, _equippedHouse),
              // キャラクターの選択グリッド
              _buildMultiSelectionGrid(
                ownedCharacters,
                _equippedCharacters,
                'character',
              ),
              // アイテムの選択グリッド
              _buildMultiSelectionGrid(ownedItems, _equippedItems, 'item'),
            ],
          ),
        ),
        // 画面下部にバナーを設置（初回起動時は広告を表示しない）
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

        Widget card = Card(
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
                  item.getDisplayName(context),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );

        if (_showItemBlinking && _tutorialPurchasedItemName == item.name) {
          return BlinkingEffect(isBlinking: true, child: card);
        }
        return card;
      },
    );
  }
}
