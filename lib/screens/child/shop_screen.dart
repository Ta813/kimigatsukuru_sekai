// lib/screens/shop/shop_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:kimigatsukuru_sekai/widgets/ad_banner.dart';
import '../../helpers/shared_prefs_helper.dart';
import '../../managers/sfx_manager.dart';
import '../../models/shop_data.dart';
import '../../l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../widgets/blinking_effect.dart';
import '../../widgets/custom_back_button.dart';

enum ShopMode {
  forGeneral, // ホーム画面からの通常表示
  forHouse, // 家の中からの家具・アイテム表示
  forIsland, // 島からの表示
  forSea, // 海からの表示
  forSky, // 空からの表示
  forSpace, // 宇宙からの表示
}

class ShopScreen extends StatefulWidget {
  final int currentPoints;
  final int currentLevel;
  final ShopMode mode;

  const ShopScreen({
    super.key,
    required this.mode,
    required this.currentPoints,
    required this.currentLevel,
  });

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late int _points; // この画面で管理するポイント数

  List<String> _purchasedItemNames = [];

  bool _isTutorialStepShopShown = true;
  bool _showItemBlinking = false;
  bool _showBackButtonBlinking = false;

  @override
  void initState() {
    super.initState();
    _points = widget.currentPoints;
    _loadPurchasedItems();
    _checkTutorialStep();
  }

  Future<void> _checkTutorialStep() async {
    final isShopShown = await SharedPrefsHelper.isTutorialStepShown(
      SharedPrefsHelper.tutorialStepShopKey,
    );
    bool isShown = await SharedPrefsHelper.isGuideShown();
    setState(() {
      _isTutorialStepShopShown = isShown || isShopShown;
      _showItemBlinking = !isShown && !isShopShown;
    });
  }

  bool _hasPlayedInitialSound = false;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    // ★サウンドがまだ再生されていなければ
    if (!_hasPlayedInitialSound) {
      final lang = AppLocalizations.of(context)!.localeName;
      if (lang == 'ja') {
        try {
          SfxManager.instance.playShopInitSound();
        } catch (e) {
          // エラーが発生した場合
          print('再生エラー: $e');
        }
      } else {
        final List<String> soundsToPlay = [];
        final String voiceDir = SfxManager.instance.getVoiceDir(lang);
        soundsToPlay.addAll(['se/$voiceDir/welcome.mp3']);
        try {
          SfxManager.instance.playSequentialSounds(soundsToPlay);
        } catch (e) {
          // エラーが発生した場合
          print('再生エラー: $e');
        }
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
          title: Text(
            item.getDisplayName(context),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0), // ピーチクリーム
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFF7043).withOpacity(0.5), // オレンジの薄い線
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
              onPressed: () async {
                // チュートリアルで「やめる」ボタンを押したかチェック
                final isTutorialStepShown =
                    await SharedPrefsHelper.isTutorialStepShown(
                      SharedPrefsHelper.tutorialStepShopKey,
                    );
                if (!isTutorialStepShown) {
                  FirebaseAnalytics.instance.logEvent(
                    name: 'tutorial_tap_shop_cancel_buy',
                  );
                }
                try {
                  SfxManager.instance.playTapSound();
                } catch (e) {
                  print('再生エラー: $e');
                }
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.of(context)!.quitAction,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // チュートリアルで「買う」ボタンを押したかチェック
                final isTutorialStepShown =
                    await SharedPrefsHelper.isTutorialStepShown(
                      SharedPrefsHelper.tutorialStepShopKey,
                    );
                if (!isTutorialStepShown) {
                  FirebaseAnalytics.instance.logEvent(
                    name: 'tutorial_tap_shop_confirm_buy',
                  );
                }
                FirebaseAnalytics.instance.logEvent(
                  name: 'start_shop_confirm_buy',
                );
                // ★ 修正: Navigator.pop する前に、必要な情報や管理クラスを取得しておく
                // (pop 後は context が無効になる可能性があるため)
                final l10n = AppLocalizations.of(context);
                final messenger = ScaffoldMessenger.of(context);
                final itemName = item.getDisplayName(context);

                final lang = l10n?.localeName ?? 'en';
                if (lang == 'ja') {
                  try {
                    SfxManager.instance.playShopBuySound();
                  } catch (e) {
                    print('再生エラー: $e');
                  }
                } else {
                  final List<String> soundsToPlay = [];
                  final String voiceDir = SfxManager.instance.getVoiceDir(lang);
                  soundsToPlay.addAll(['se/$voiceDir/thank_you_very_much.mp3']);
                  try {
                    SfxManager.instance.playSequentialSounds(soundsToPlay);
                  } catch (e) {
                    print('再生エラー: $e');
                  }
                }
                final newPoints = _points - item.price;
                await SharedPrefsHelper.savePoints(newPoints);

                await SharedPrefsHelper.addPurchasedItem(item.name);

                if (!mounted) return;

                if (!_isTutorialStepShopShown) {
                  await SharedPrefsHelper.setTutorialPurchasedItem(
                    item.name,
                    item.type,
                  );
                }

                if (!mounted) return;

                setState(() {
                  _points = newPoints;
                  _purchasedItemNames.add(item.name);
                  if (!_isTutorialStepShopShown) {
                    _showItemBlinking = false;
                    _showBackButtonBlinking = true;
                  }
                });

                // ダイアログを閉じる
                Navigator.pop(context);

                // スナックバーを表示
                if (l10n != null) {
                  messenger.showSnackBar(
                    SnackBar(content: Text(l10n.shopExchangeSuccess(itemName))),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7043), // オレンジ
                foregroundColor: Colors.white,
                side: const BorderSide(
                  color: Color(0xFFFFCA28),
                  width: 2,
                ), // 黄色の輪郭
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
    // ★ レベルが足りているか判定
    final bool isLocked = widget.currentLevel < item.requiredLevel;
    // ★このアイテムが購入済みかどうかをチェック
    final bool isPurchased = _purchasedItemNames.contains(item.name);

    Widget card = Card(
      elevation: 2,
      // 購入済みなら、カード全体を少しグレーにする
      color: (isLocked || isPurchased) ? Colors.grey[200] : Colors.white,
      child: InkWell(
        // ★購入済みなら、タップできないようにする (onTap: null)
        onTap: (isLocked || isPurchased)
            ? null
            : () async {
                // チュートリアルで「アイテム」をタップしたかチェック
                final isTutorialStepShown =
                    await SharedPrefsHelper.isTutorialStepShown(
                      SharedPrefsHelper.tutorialStepShopKey,
                    );
                if (!isTutorialStepShown) {
                  FirebaseAnalytics.instance.logEvent(
                    name: 'tutorial_tap_item',
                  );
                }
                FirebaseAnalytics.instance.logEvent(
                  name: 'start_shop_buy_item',
                  parameters: {'item_name': item.name},
                );
                _buyItem(item);
              },
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
                      opacity: (isLocked || isPurchased) ? 0.5 : 1.0,
                      child: Image.asset(item.imagePath),
                    ),
                  ),
                ),
                Text(
                  item.getDisplayName(context),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text('${item.price}P', textAlign: TextAlign.center),
                const SizedBox(height: 10),
              ],
            ),

            if (isLocked)
              Positioned.fill(
                child: Container(
                  // 半透明の黒いマスクをかける
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12), // Cardの角丸に合わせる
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 鍵アイコン
                      const Icon(Icons.lock, color: Colors.white, size: 40),
                      const SizedBox(height: 8),
                      // 解放レベルを表示
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.unlockedAtLevel(item.requiredLevel),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // ★購入済みの場合のみ、「購入済み」ラベルを上に重ねて表示
            if (isPurchased && !isLocked)
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

    if (_showItemBlinking && item.price <= 100 && !isPurchased && !isLocked) {
      return BlinkingEffect(isBlinking: true, child: card);
    }
    return card;
  }

  Widget _buildCategoryGrid(
    List<ShopItem> items, {
    required int crossAxisCount,
  }) {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount, // 1行に表示する数
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        childAspectRatio: 0.8, // アイテムの縦横比
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
    final List<Tab> tabs;
    final List<Widget> tabViews;

    if (widget.mode == ShopMode.forIsland) {
      // 島モードの場合、島限定アイテムのみにする
      final islandItems = shopItems.where((item) => item.isIslandOnly).toList();

      final buildingItems = islandItems
          .where((item) => item.type == 'building')
          .toList();
      final vehicleItems = islandItems
          .where((item) => item.type == 'vehicle')
          .toList();

      tabs = [
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home_work),
              SizedBox(width: 8), // アイコンとテキストの間のスペース
              Text(AppLocalizations.of(context)!.buildings),
            ],
          ),
        ),
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.directions_car),
              SizedBox(width: 8), // アイコンとテキストの間のスペース
              Text(AppLocalizations.of(context)!.vehicles),
            ],
          ),
        ),
      ];

      tabViews = [
        _buildCategoryGrid(buildingItems, crossAxisCount: 7),
        _buildCategoryGrid(vehicleItems, crossAxisCount: 7),
      ];
    } else if (widget.mode == ShopMode.forSea) {
      // 海モードの場合、海限定アイテムのみにする
      final isSeaItems = shopItems.where((item) => item.isSeaOnly).toList();

      final seaItems = isSeaItems
          .where((item) => item.type == 'sea_item')
          .toList();
      final livingItems = isSeaItems
          .where((item) => item.type == 'living')
          .toList();

      tabs = [
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.anchor),
              SizedBox(width: 8), // アイコンとテキストの間のスペース
              Text(AppLocalizations.of(context)!.seaItems),
            ],
          ),
        ),
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(FontAwesomeIcons.fish),
              SizedBox(width: 8), // アイコンとテキストの間のスペース
              Text(AppLocalizations.of(context)!.seaCreatures),
            ],
          ),
        ),
      ];

      tabViews = [
        _buildCategoryGrid(seaItems, crossAxisCount: 7),
        _buildCategoryGrid(livingItems, crossAxisCount: 7),
      ];
    } else if (widget.mode == ShopMode.forSky) {
      // 空モードの場合、空限定アイテムのみにする
      final isSeaItems = shopItems.where((item) => item.isSkyOnly).toList();

      final seaItems = isSeaItems
          .where((item) => item.type == 'sky_item')
          .toList();
      final livingItems = isSeaItems
          .where((item) => item.type == 'sky_living')
          .toList();

      tabs = [
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.flight),
              SizedBox(width: 8), // アイコンとテキストの間のスペース
              Text(AppLocalizations.of(context)!.skyItems),
            ],
          ),
        ),
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(FontAwesomeIcons.dove),
              SizedBox(width: 8), // アイコンとテキストの間のスペース
              Text(AppLocalizations.of(context)!.skyCreatures),
            ],
          ),
        ),
      ];

      tabViews = [
        _buildCategoryGrid(seaItems, crossAxisCount: 7),
        _buildCategoryGrid(livingItems, crossAxisCount: 7),
      ];
    } else if (widget.mode == ShopMode.forSpace) {
      // 空モードの場合、空限定アイテムのみにする
      final isSpaceItems = shopItems.where((item) => item.isSpaceOnly).toList();

      final spaceItems = isSpaceItems
          .where((item) => item.type == 'space_item')
          .toList();
      final livingItems = isSpaceItems
          .where((item) => item.type == 'space_living')
          .toList();

      tabs = [
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.rocket_launch),
              SizedBox(width: 8), // アイコンとテキストの間のスペース
              Text(AppLocalizations.of(context)!.spaceItems),
            ],
          ),
        ),
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(FontAwesomeIcons.redditAlien),
              SizedBox(width: 8), // アイコンとテキストの間のスペース
              Text(AppLocalizations.of(context)!.spaceCreatures),
            ],
          ),
        ),
      ];

      tabViews = [
        _buildCategoryGrid(spaceItems, crossAxisCount: 6),
        _buildCategoryGrid(livingItems, crossAxisCount: 6),
      ];
    } else if (widget.mode == ShopMode.forHouse) {
      // --- 🏠 家の中モードの時の表示 ---

      final items = shopItems
          .where((item) => !item.isIslandOnly && !item.isSeaOnly)
          .toList();
      final furnitureItems = items
          .where((item) => item.type == 'furniture')
          .toList();
      final houseItems = items
          .where((item) => item.type == 'house_item')
          .toList();

      tabs = [
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
      ];

      tabViews = [
        _buildCategoryGrid(furnitureItems, crossAxisCount: 7),
        _buildCategoryGrid(houseItems, crossAxisCount: 7),
      ];
    } else {
      final items = shopItems
          .where((item) => !item.isIslandOnly && !item.isSeaOnly)
          .toList();
      // まず、アイテムをカテゴリ別に分けます
      final clothesItems = items
          .where(
            (item) =>
                item.type == 'clothes' &&
                item.name != 'いつものふく' &&
                item.name != 'おとこのこ',
          )
          .toList();
      final houseItems = items
          .where((item) => item.type == 'house' && item.name != 'さいしょのおうち')
          .toList();
      final characterItems = items
          .where((item) => item.type == 'character' && item.name != 'ウサギ')
          .toList();
      final itemItems = items.where((item) => item.type == 'item').toList();

      tabs = [
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.checkroom),
              SizedBox(width: 8), // アイコンとテキストの間のスペース
              Text(AppLocalizations.of(context)!.customizeTabClothes),
            ],
          ),
        ),
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.house),
              SizedBox(width: 8), // アイコンとテキストの間のスペース
              Text(AppLocalizations.of(context)!.customizeTabHouse),
            ],
          ),
        ),
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.support_agent),
              SizedBox(width: 8), // アイコンとテキストの間のスペース
              Text(AppLocalizations.of(context)!.customizeTabCharacter),
            ],
          ),
        ),
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star),
              SizedBox(width: 8), // アイコンとテキストの間のスペース
              Text(AppLocalizations.of(context)!.customizeTabItem),
            ],
          ),
        ),
      ];

      tabViews = [
        _buildCategoryGrid(clothesItems, crossAxisCount: 6),
        _buildCategoryGrid(houseItems, crossAxisCount: 5),
        _buildCategoryGrid(characterItems, crossAxisCount: 6),
        _buildCategoryGrid(itemItems, crossAxisCount: 7),
      ];
    }

    return DefaultTabController(
      length: widget.mode == ShopMode.forGeneral ? 4 : 2, // ★タブの数
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 40, // ★ 高さを低く設定
          leading: BlinkingEffect(
            isBlinking: _showBackButtonBlinking,
            child: const CustomBackButton(),
          ),
          title: Text(
            AppLocalizations.of(context)!.shopTitle,
            style: const TextStyle(fontSize: 18),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Center(
                child: Text(
                  '$_points ${AppLocalizations.of(context)!.points}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: TabBar(
              isScrollable: true,
              tabs: tabs.map((tab) {
                return Tab(
                  height: 40,
                  child:
                      tab.child ??
                      Row(
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
        // ★bodyをTabBarViewに変更します
        body: SafeArea(
          child: TabBarView(
            children: tabViews, // 各タブの中身となるGridViewを、共通メソッドで生成します
          ),
        ),
        // 画面下部にバナーを設置（初回起動時は広告を表示しない）
        bottomNavigationBar: const AdBanner(),
      ),
    );
  }
}
