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
import '../../managers/purchase_manager.dart';

enum ShopMode {
  forGeneral, // ホーム画面からの通常表示
  forHouse, // 家の中からの家具・アイテム表示
  forIsland, // 島からの表示
  forSea, // 海からの表示
  forSky, // 空からの表示
  forSpace, // 宇宙からの表示
}

// 🌟 ショップの画面遷移用モードを追加
enum ShopView { menu, avatar, support, world }

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
  // 🌟 現在表示している画面（初期値はメニュー）
  ShopView _currentView = ShopView.menu;

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
    bool isShown =
        await SharedPrefsHelper.getChildTutorial() ==
        SharedPrefsHelper.tutorialPhaseStart;
    setState(() {
      _isTutorialStepShopShown = !(isShown && !isShopShown);
      _showItemBlinking = isShown && !isShopShown;
    });
  }

  bool _hasPlayedInitialSound = false;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (!_hasPlayedInitialSound) {
      final lang = AppLocalizations.of(context)!.localeName;
      if (lang == 'ja') {
        try {
          SfxManager.instance.playShopInitSound();
        } catch (e) {
          print('再生エラー: $e');
        }
      } else {
        final List<String> soundsToPlay = [];
        final String voiceDir = SfxManager.instance.getVoiceDir(lang);
        soundsToPlay.addAll(['se/$voiceDir/welcome.mp3']);
        try {
          SfxManager.instance.playSequentialSounds(soundsToPlay);
        } catch (e) {
          print('再生エラー: $e');
        }
      }
      _hasPlayedInitialSound = true;
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
              onPressed: () async {
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

                final l10n = AppLocalizations.of(context);
                final lang = l10n?.localeName ?? 'en';

                if (lang == 'ja') {
                  try {
                    SfxManager.instance.playShopBuySound();
                  } catch (e) {}
                } else {
                  final List<String> soundsToPlay = [];
                  final String voiceDir = SfxManager.instance.getVoiceDir(lang);
                  soundsToPlay.addAll(['se/$voiceDir/thank_you_very_much.mp3']);
                  try {
                    SfxManager.instance.playSequentialSounds(soundsToPlay);
                  } catch (e) {}
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

                SharedPrefsHelper.incrementShopCount();
                Navigator.pop(context);
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
    final bool isLevelLocked = widget.currentLevel < item.requiredLevel;
    final bool isLocked =
        isLevelLocked && !PurchaseManager.instance.isPremium.value;
    final bool isPurchased = _purchasedItemNames.contains(item.name);

    Widget card = Card(
      elevation: 2,
      color: (isLocked || isPurchased) ? Colors.grey[200] : Colors.white,
      child: InkWell(
        onTap: isPurchased
            ? null
            : () async {
                if (isLocked && !isPurchased) {
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
                              AppLocalizations.of(
                                context,
                              )!.premiumShopUnlockMessage,
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
                            side: const BorderSide(
                              color: Color(0xFFFFCA28),
                              width: 2,
                            ),
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
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Opacity(
                      opacity: (isLocked || isPurchased) ? 0.5 : 1.0,
                      child: Builder(
                        builder: (context) {
                          if (item.type == 'face' || item.type == 'headgear') {
                            return ClipRect(
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: ClipRect(
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    heightFactor: 0.5,
                                    child: Image.asset(item.imagePath),
                                  ),
                                ),
                              ),
                            );
                          } else if (item.type == 'hair') {
                            return ClipRect(
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: ClipRect(
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    heightFactor: 0.7,
                                    child: Image.asset(item.imagePath),
                                  ),
                                ),
                              ),
                            );
                          } else if (item.type == 'clothes') {
                            return ClipRect(
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: ClipRect(
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    heightFactor: 0.5,
                                    child: Image.asset(item.imagePath),
                                  ),
                                ),
                              ),
                            );
                          } else if (item.type == 'accessory') {
                            return ClipRect(
                              child: Transform.scale(
                                scale: 2.0,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: ClipRect(
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      heightFactor: 0.5,
                                      child: ClipRect(
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          heightFactor: 0.5,
                                          child: Image.asset(item.imagePath),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          return Image.asset(item.imagePath);
                        },
                      ),
                    ),
                  ),
                ),
                Text('${item.price}P', textAlign: TextAlign.center),
                const SizedBox(height: 10),
              ],
            ),
            if (isLocked && !isPurchased)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock, color: Colors.white, size: 40),
                      const SizedBox(height: 8),
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
                    style: const TextStyle(
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
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildShopItemCard(item);
      },
    );
  }

  // アプリバーに表示するポイント部分の共通化
  List<Widget> _buildAppBarActions() {
    return [
      Padding(
        padding: const EdgeInsets.only(right: 20.0),
        child: Center(
          child: Text(
            '$_points ${AppLocalizations.of(context)!.points}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: PurchaseManager.instance.isPremium,
      builder: (context, isPremium, child) {
        // 🌟 ホームからの通常アクセスでない場合（島や家の中など）は、メニューを出さずに従来のタブ表示へ
        if (widget.mode != ShopMode.forGeneral) {
          return _buildSpecialShopScreen();
        }

        // 🌟 ホームからのアクセスの場合はメニュー方式を適用
        return PopScope(
          canPop: _currentView == ShopView.menu,
          onPopInvoked: (didPop) {
            if (!didPop) {
              setState(() {
                _currentView = ShopView.menu;
              });
            }
          },
          child: _buildCurrentView(),
        );
      },
    );
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case ShopView.menu:
        return _buildMenuScreen();
      case ShopView.avatar:
        return _buildAvatarShopScreen();
      case ShopView.support:
        return _buildSupportShopScreen();
      case ShopView.world:
        return _buildWorldShopScreen();
    }
  }

  // ==========================================
  // 1. トップメニュー画面
  // ==========================================
  Widget _buildMenuScreen() {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        toolbarHeight: 40,
        leading: BlinkingEffect(
          isBlinking: _showBackButtonBlinking,
          child: const CustomBackButton(),
        ),
        title: Text(
          AppLocalizations.of(context)?.shopTitle ?? 'おみせ',
          style: const TextStyle(fontSize: 18),
        ),
        actions: _buildAppBarActions(),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMenuButton(
                  localizations.menuCustomizeAvatar,
                  localizations.menuCustomizeAvatarSub,
                  Icons.checkroom,
                  ShopView.avatar,
                  Colors.pinkAccent,
                ),
                const SizedBox(width: 20),
                _buildMenuButton(
                  localizations.menuSupportChar,
                  localizations.menuSupportCharSub,
                  Icons.support_agent,
                  ShopView.support,
                  Colors.orangeAccent,
                ),
                const SizedBox(width: 20),
                _buildMenuButton(
                  localizations.menuYourWorld,
                  localizations.menuYourWorldSub,
                  Icons.public,
                  ShopView.world,
                  Colors.lightBlue,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AdBanner(),
    );
  }

  Widget _buildMenuButton(
    String title,
    String subtitle,
    IconData icon,
    ShopView targetView,
    Color color,
  ) {
    // チュートリアル中はとりあえずアバター画面（きせかえ）へ誘導
    final isBlinking = _showItemBlinking && targetView == ShopView.avatar;

    Widget button = SizedBox(
      width: 180,
      height: 180,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
          padding: const EdgeInsets.all(12),
        ),
        onPressed: () {
          try {
            SfxManager.instance.playTapSound();
          } catch (e) {}
          setState(() {
            _currentView = targetView;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    if (isBlinking) {
      return BlinkingEffect(isBlinking: true, child: button);
    }
    return button;
  }

  Widget _buildSubBackButton() {
    return BlinkingEffect(
      isBlinking: _showBackButtonBlinking,
      child: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () {
          try {
            SfxManager.instance.playTapSound();
          } catch (e) {}
          setState(() {
            _currentView = ShopView.menu;
          });
        },
      ),
    );
  }

  // ==========================================
  // 2. きせかえ（アバター）ショップ画面
  // ==========================================
  Widget _buildAvatarShopScreen() {
    final localizations = AppLocalizations.of(context)!;
    final items = shopItems
        .where((item) => !item.isIslandOnly && !item.isSeaOnly)
        .toList();

    // デフォルトアイテムは販売リストから除外
    final faceItems = items
        .where(
          (item) =>
              item.type == 'face' &&
              item.name != 'いつものかお' &&
              item.name != '頑張るかお' &&
              item.name != '困ったかお' &&
              item.name != 'ウインクしているかお',
        )
        .toList();
    final hairItems = items
        .where(
          (item) =>
              item.type == 'hair' &&
              item.name != 'いつものかみがた' &&
              item.name != 'ポニーテールかみがた' &&
              item.name != 'おとこのこのかみがた' &&
              item.name != 'アシメかみがた',
        )
        .toList();
    final clothesItems = items
        .where(
          (item) =>
              item.type == 'clothes' &&
              item.name != 'いつものふく' &&
              item.name != 'おとこのこ',
        )
        .toList();
    final headgearItems = items
        .where((item) => item.type == 'headgear')
        .toList();
    final accessoryItems = items
        .where((item) => item.type == 'accessory')
        .toList();

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 40,
          leading: _buildSubBackButton(),
          title: Text(
            localizations.menuCustomizeAvatar,
            style: TextStyle(fontSize: 18),
          ),
          actions: _buildAppBarActions(),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.center,
              tabs: [
                // 🌟 タブ作成時に、特定のアイテムタイプなら点滅させるロジックを追加
                _buildTabAvatar(localizations.tabFace, Icons.face, 'face'),
                _buildTabAvatar(localizations.tabHair, Icons.cut, 'hair'),
                _buildTabAvatar(
                  localizations.tabHeadgear,
                  Icons.theater_comedy,
                  'headgear',
                ),
                _buildTabAvatar(
                  localizations.tabClothes,
                  Icons.checkroom,
                  'clothes',
                ),
                _buildTabAvatar(
                  localizations.tabAccessory,
                  Icons.backpack,
                  'accessory',
                ),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              _buildCategoryGrid(faceItems, crossAxisCount: 6),
              _buildCategoryGrid(hairItems, crossAxisCount: 6),
              _buildCategoryGrid(headgearItems, crossAxisCount: 6),
              _buildCategoryGrid(clothesItems, crossAxisCount: 6),
              _buildCategoryGrid(accessoryItems, crossAxisCount: 6),
            ],
          ),
        ),
        bottomNavigationBar: const AdBanner(),
      ),
    );
  }

  // 🌟 追加: タブ作成と点滅判定を行うヘルパーメソッド
  Widget _buildTabAvatar(String title, IconData icon, String targetType) {
    Widget tab = Tab(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(title)],
      ),
    );

    // チュートリアル中であり、かつ購入してほしい対象のタイプが一致していれば点滅
    if (_showItemBlinking &&
        ('clothes' == targetType || 'accessory' == targetType)) {
      return BlinkingEffect(isBlinking: true, child: tab);
    }
    return tab;
  }

  // ==========================================
  // 3. おうえんキャラクターショップ画面
  // ==========================================
  Widget _buildSupportShopScreen() {
    final localizations = AppLocalizations.of(context)!;
    final items = shopItems
        .where((item) => !item.isIslandOnly && !item.isSeaOnly)
        .toList();
    // デフォルトのウサギは除外
    final characterItems = items
        .where((item) => item.type == 'character')
        .toList();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        leading: _buildSubBackButton(),
        title: Text(
          localizations.menuSupportChar,
          style: TextStyle(fontSize: 18),
        ),
        actions: _buildAppBarActions(),
      ),
      body: SafeArea(
        child: _buildCategoryGrid(characterItems, crossAxisCount: 6),
      ),
      bottomNavigationBar: const AdBanner(),
    );
  }

  // ==========================================
  // 4. きみのせかいショップ画面
  // ==========================================
  Widget _buildWorldShopScreen() {
    final localizations = AppLocalizations.of(context)!;
    final items = shopItems
        .where((item) => !item.isIslandOnly && !item.isSeaOnly)
        .toList();
    // デフォルトのおうちは除外
    final houseItems = items
        .where((item) => item.type == 'house' && item.name != 'さいしょのおうち')
        .toList();
    final itemItems = items.where((item) => item.type == 'item').toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 40,
          leading: _buildSubBackButton(),
          title: Text(
            localizations.menuYourWorld,
            style: TextStyle(fontSize: 18),
          ),
          actions: _buildAppBarActions(),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: TabBar(
              tabs: [
                _buildTab(localizations.tabHouse, Icons.house),
                _buildTab(localizations.tabItem, Icons.star),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              _buildCategoryGrid(houseItems, crossAxisCount: 4),
              _buildCategoryGrid(itemItems, crossAxisCount: 6),
            ],
          ),
        ),
        bottomNavigationBar: const AdBanner(),
      ),
    );
  }

  // サブ画面用のタブ作成ヘルパー
  Widget _buildTab(String title, IconData icon) {
    return Tab(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(title)],
      ),
    );
  }

  // ==========================================
  // 5. 特殊モードのショップ画面（島や海などから開いた場合）
  // ==========================================
  Widget _buildSpecialShopScreen() {
    final List<Widget> tabs;
    final List<Widget> tabViews;

    if (widget.mode == ShopMode.forIsland) {
      final islandItems = shopItems.where((item) => item.isIslandOnly).toList();
      final buildingItems = islandItems
          .where((item) => item.type == 'building')
          .toList();
      final vehicleItems = islandItems
          .where((item) => item.type == 'vehicle')
          .toList();

      tabs = [
        _buildTab(AppLocalizations.of(context)!.buildings, Icons.home_work),
        _buildTab(AppLocalizations.of(context)!.vehicles, Icons.directions_car),
      ];
      tabViews = [
        _buildCategoryGrid(buildingItems, crossAxisCount: 8),
        _buildCategoryGrid(vehicleItems, crossAxisCount: 8),
      ];
    } else if (widget.mode == ShopMode.forSea) {
      final isSeaItems = shopItems.where((item) => item.isSeaOnly).toList();
      final seaItems = isSeaItems
          .where((item) => item.type == 'sea_item')
          .toList();
      final livingItems = isSeaItems
          .where((item) => item.type == 'living')
          .toList();

      tabs = [
        _buildTab(AppLocalizations.of(context)!.seaItems, Icons.anchor),
        _buildTab(
          AppLocalizations.of(context)!.seaCreatures,
          FontAwesomeIcons.fish,
        ),
      ];
      tabViews = [
        _buildCategoryGrid(seaItems, crossAxisCount: 8),
        _buildCategoryGrid(livingItems, crossAxisCount: 8),
      ];
    } else if (widget.mode == ShopMode.forSky) {
      final isSeaItems = shopItems.where((item) => item.isSkyOnly).toList();
      final seaItems = isSeaItems
          .where((item) => item.type == 'sky_item')
          .toList();
      final livingItems = isSeaItems
          .where((item) => item.type == 'sky_living')
          .toList();

      tabs = [
        _buildTab(AppLocalizations.of(context)!.skyItems, Icons.flight),
        _buildTab(
          AppLocalizations.of(context)!.skyCreatures,
          FontAwesomeIcons.dove,
        ),
      ];
      tabViews = [
        _buildCategoryGrid(seaItems, crossAxisCount: 8),
        _buildCategoryGrid(livingItems, crossAxisCount: 8),
      ];
    } else if (widget.mode == ShopMode.forSpace) {
      final isSpaceItems = shopItems.where((item) => item.isSpaceOnly).toList();
      final spaceItems = isSpaceItems
          .where((item) => item.type == 'space_item')
          .toList();
      final livingItems = isSpaceItems
          .where((item) => item.type == 'space_living')
          .toList();

      tabs = [
        _buildTab(
          AppLocalizations.of(context)!.spaceItems,
          Icons.rocket_launch,
        ),
        _buildTab(
          AppLocalizations.of(context)!.spaceCreatures,
          FontAwesomeIcons.redditAlien,
        ),
      ];
      tabViews = [
        _buildCategoryGrid(spaceItems, crossAxisCount: 8),
        _buildCategoryGrid(livingItems, crossAxisCount: 8),
      ];
    } else {
      // forHouse
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
        _buildTab(AppLocalizations.of(context)!.furniture, Icons.chair),
        _buildTab(AppLocalizations.of(context)!.houseItems, Icons.widgets),
      ];
      tabViews = [
        _buildCategoryGrid(furnitureItems, crossAxisCount: 8),
        _buildCategoryGrid(houseItems, crossAxisCount: 8),
      ];
    }

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 40,
          leading: BlinkingEffect(
            isBlinking: _showBackButtonBlinking,
            child: const CustomBackButton(),
          ),
          title: Text(
            AppLocalizations.of(context)!.shopTitle,
            style: const TextStyle(fontSize: 18),
          ),
          actions: _buildAppBarActions(),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: TabBar(isScrollable: true, tabs: tabs),
          ),
        ),
        body: SafeArea(child: TabBarView(children: tabViews)),
        bottomNavigationBar: const AdBanner(),
      ),
    );
  }
}
