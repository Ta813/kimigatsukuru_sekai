import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:kimigatsukuru_sekai/widgets/ad_banner.dart';
import '../../models/shop_data.dart';
import '../../helpers/shared_prefs_helper.dart';
import '../../managers/sfx_manager.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/blinking_effect.dart';
import '../../widgets/custom_back_button.dart';
import '../../widgets/avatar_display.dart';
import '../../managers/purchase_manager.dart'; // 🌟 追加: プレミアムプランの判定用

// 表示する画面を切り替えるためのモード
enum CustomizeView { menu, avatar, support, world }

class CharacterCustomizeScreen extends StatefulWidget {
  const CharacterCustomizeScreen({super.key});

  @override
  State<CharacterCustomizeScreen> createState() =>
      _CharacterCustomizeScreenState();
}

class _CharacterCustomizeScreenState extends State<CharacterCustomizeScreen> {
  CustomizeView _currentView = CustomizeView.menu;

  List<String> _purchasedItemNames = [];

  // 🌟 追加: レベルとポイントを管理
  int _currentLevel = 1;
  int _currentPoints = 0;

  // アバターパーツ
  String? _equippedFace;
  String? _equippedHair;
  String? _equippedClothes;
  String? _equippedHeadgear;
  String? _equippedAccessory;

  // 世界・応援キャラパーツ
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
    bool isShown =
        await SharedPrefsHelper.getChildTutorial() ==
        SharedPrefsHelper.tutorialPhaseStart;
    final purchasedItemName =
        await SharedPrefsHelper.getTutorialPurchasedItem();
    final purchasedItemType =
        await SharedPrefsHelper.getTutorialPurchasedType();
    setState(() {
      _isTutorialStepCustomizeShown = !(isShown && !isCustomizeShown);
      _tutorialPurchasedItemName = purchasedItemName;
      _tutorialPurchasedItemType = purchasedItemType;
      _showTabBlinking = isShown && !isCustomizeShown;
      _showItemBlinking = isShown && !isCustomizeShown;
    });
  }

  Future<void> _loadEquippedItems() async {
    final purchased = await SharedPrefsHelper.loadPurchasedItems();

    // 🌟 追加: 現在のレベルとポイントを読み込む
    final level = await SharedPrefsHelper.loadLevel();
    final points = await SharedPrefsHelper.loadPoints();

    // 読み込み処理
    final face = await SharedPrefsHelper.loadEquippedFace();
    final hair = await SharedPrefsHelper.loadEquippedHairstyle();
    final clothes = await SharedPrefsHelper.loadEquippedClothes();
    final headgear = await SharedPrefsHelper.loadEquippedHeadgear();
    final accessory = await SharedPrefsHelper.loadEquippedAccessory();

    final house = await SharedPrefsHelper.loadEquippedHouse();
    final characters = await SharedPrefsHelper.loadEquippedCharacters();
    final items = await SharedPrefsHelper.loadEquippedItems();

    // デフォルトアイテム
    if (!purchased.contains('いつものかお')) purchased.add('いつものかお');
    if (!purchased.contains('頑張るかお')) purchased.add('頑張るかお');
    if (!purchased.contains('困ったかお')) purchased.add('困ったかお');
    if (!purchased.contains('ウインクしているかお')) purchased.add('ウインクしているかお');
    if (!purchased.contains('いつものかみがた')) purchased.add('いつものかみがた');
    if (!purchased.contains('ポニーテールかみがた')) purchased.add('ポニーテールかみがた');
    if (!purchased.contains('おとこのこのかみがた')) purchased.add('おとこのこのかみがた');
    if (!purchased.contains('アシメかみがた')) purchased.add('アシメかみがた');
    if (!purchased.contains('いつものふく')) purchased.add('いつものふく');
    if (!purchased.contains('さいしょのおうち')) purchased.add('さいしょのおうち');
    if (!purchased.contains('ウサギ')) purchased.add('ウサギ');
    if (!purchased.contains('おとこのこ')) purchased.add('おとこのこ');

    setState(() {
      _purchasedItemNames = purchased;
      _currentLevel = level;
      _currentPoints = points;

      _equippedFace = face ?? 'assets/images/face/face_default.png';
      _equippedHair = hair ?? 'assets/images/hair/hair_default.png';
      _equippedClothes = clothes ?? 'assets/images/clothes/clothes_default.png';
      _equippedHeadgear = headgear;
      _equippedAccessory = accessory;

      _equippedHouse = house ?? 'assets/images/house.png';
      _equippedCharacters = characters;
      _equippedItems = items;
    });
  }

  bool _shouldBlinkMenu(CustomizeView view) {
    if (!_showTabBlinking) return false;
    if (view == CustomizeView.avatar) {
      return [
        'face_shape',
        'hair',
        'eyes',
        'clothes',
        'headgear',
        'accessory',
      ].contains(_tutorialPurchasedItemType);
    } else if (view == CustomizeView.support) {
      return _tutorialPurchasedItemType == 'character';
    } else if (view == CustomizeView.world) {
      return ['house', 'item'].contains(_tutorialPurchasedItemType);
    }
    return false;
  }

  void _equipItem(ShopItem item) async {
    final isTutorialStepShown = await SharedPrefsHelper.isTutorialStepShown(
      SharedPrefsHelper.tutorialStepCustomizeKey,
    );
    if (!isTutorialStepShown) {
      FirebaseAnalytics.instance.logEvent(name: 'tutorial_tap_customize_item');
    }
    try {
      SfxManager.instance.playTapSound();
    } catch (e) {}

    if (item.type == 'face') {
      await SharedPrefsHelper.saveEquippedFace(item.imagePath);
    } else if (item.type == 'hair') {
      await SharedPrefsHelper.saveEquippedHairstyle(item.imagePath);
    } else if (item.type == 'clothes') {
      await SharedPrefsHelper.saveEquippedClothes(item.imagePath);
    } else if (item.type == 'headgear') {
      if (_equippedHeadgear == item.imagePath) {
        await SharedPrefsHelper.saveEquippedHeadgear('');
      } else {
        await SharedPrefsHelper.saveEquippedHeadgear(item.imagePath);
      }
    } else if (item.type == 'accessory') {
      if (_equippedAccessory == item.imagePath) {
        await SharedPrefsHelper.saveEquippedAccessory('');
      } else {
        await SharedPrefsHelper.saveEquippedAccessory(item.imagePath);
      }
    } else if (item.type == 'house') {
      await SharedPrefsHelper.saveEquippedItem('house', item.imagePath);
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
    _loadEquippedItems();
  }

  // 🌟 追加: 未購入のアイテムをタップした時の処理（ショップと同じ）
  void _handlePurchaseAttempt(ShopItem item) async {
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
                _equipItem(item); // 買ってすぐ装備！
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

  @override
  Widget build(BuildContext context) {
    // 🌟 追加: プレミアムプランの変更を監視して即時UIを更新する
    return ValueListenableBuilder<bool>(
      valueListenable: PurchaseManager.instance.isPremium,
      builder: (context, isPremium, child) {
        return PopScope(
          canPop: _currentView == CustomizeView.menu,
          onPopInvoked: (didPop) {
            if (!didPop) {
              setState(() {
                _currentView = CustomizeView.menu;
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
      case CustomizeView.menu:
        return _buildMenuScreen();
      case CustomizeView.avatar:
        return _buildAvatarScreen();
      case CustomizeView.support:
        return _buildSupportScreen();
      case CustomizeView.world:
        return _buildWorldScreen();
    }
  }

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

  // ==========================================
  // 1. トップメニュー画面
  // ==========================================
  Widget _buildMenuScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        toolbarHeight: 40,
        leading: BlinkingEffect(
          isBlinking: _showBackButtonBlinking,
          child: const CustomBackButton(),
        ),
        title: Text(
          AppLocalizations.of(context)?.customizeTitle ?? 'カスタマイズ',
          style: const TextStyle(fontSize: 18),
        ),
        // 🌟 修正: 共通メソッドを使用
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
                  'きせかえ',
                  'アバターをへんこう',
                  Icons.checkroom,
                  CustomizeView.avatar,
                  Colors.pinkAccent,
                ),
                const SizedBox(width: 20),
                _buildMenuButton(
                  'おうえんキャラクター',
                  'キャラクターをえらぶ',
                  Icons.support_agent,
                  CustomizeView.support,
                  Colors.orangeAccent,
                ),
                const SizedBox(width: 20),
                _buildMenuButton(
                  'きみのせかい',
                  'おうち・アイテムを\nへんこう',
                  Icons.public,
                  CustomizeView.world,
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
    CustomizeView targetView,
    Color color,
  ) {
    final isBlinking = _shouldBlinkMenu(targetView);
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
            _currentView = CustomizeView.menu;
          });
        },
      ),
    );
  }

  // ==========================================
  // 2. きせかえ（アバター）画面
  // ==========================================
  Widget _buildAvatarScreen() {
    final allFaces = shopItems.where((item) => item.type == 'face').toList();
    final allHair = shopItems.where((item) => item.type == 'hair').toList();
    final allClothes = shopItems
        .where((item) => item.type == 'clothes')
        .toList();
    final allHeadgear = shopItems
        .where((item) => item.type == 'headgear')
        .toList();
    final allAccessories = shopItems
        .where((item) => item.type == 'accessory')
        .toList();

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 40,
          leading: _buildSubBackButton(),
          title: const Text('きせかえ', style: TextStyle(fontSize: 18)),
          // 🌟 修正: 共通メソッドを使用
          actions: _buildAppBarActions(),
        ),
        body: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.center,
                      labelColor: const Color(0xFFFF7043),
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: const Color(0xFFFF7043),
                      tabs: [
                        _buildTab('かお', Icons.face, 'face'),
                        _buildTab('かみがた', Icons.cut, 'hair'),
                        _buildTab('かぶるもの', Icons.theater_comedy, 'headgear'),
                        _buildTab('ふくそう', Icons.checkroom, 'clothes'),
                        _buildTab('アクセサリー', Icons.backpack, 'accessory'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildItemGrid(allFaces, _equippedFace),
                          _buildItemGrid(allHair, _equippedHair),
                          _buildItemGrid(allHeadgear, _equippedHeadgear),
                          _buildItemGrid(allClothes, _equippedClothes),
                          _buildItemGrid(allAccessories, _equippedAccessory),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  border: Border(
                    left: BorderSide(color: Colors.grey.shade300, width: 2),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'いまのすがた',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AvatarDisplay(
                      face: _equippedFace,
                      hair: _equippedHair,
                      clothes: _equippedClothes,
                      headgear: _equippedHeadgear,
                      accessory: _equippedAccessory,
                      size: 100,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const AdBanner(),
      ),
    );
  }

  // ==========================================
  // 3. おうえんキャラクター画面
  // ==========================================
  Widget _buildSupportScreen() {
    final allCharacters = shopItems
        .where((item) => item.type == 'character')
        .toList();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        leading: _buildSubBackButton(),
        title: const Text('おうえんキャラクター', style: TextStyle(fontSize: 18)),
        // 🌟 追加: 共通メソッドを使用
        actions: _buildAppBarActions(),
      ),
      body: SafeArea(
        child: _buildMultiSelectionGrid(
          allCharacters,
          _equippedCharacters,
          'character',
        ),
      ),
      bottomNavigationBar: const AdBanner(),
    );
  }

  // ==========================================
  // 4. きみのせかい（家・アイテム）画面
  // ==========================================
  Widget _buildWorldScreen() {
    final allHouses = shopItems.where((item) => item.type == 'house').toList();
    final allItems = shopItems.where((item) => item.type == 'item').toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 40,
          leading: _buildSubBackButton(),
          title: const Text('きみのせかい', style: TextStyle(fontSize: 18)),
          // 🌟 追加: 共通メソッドを使用
          actions: _buildAppBarActions(),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: TabBar(
              tabs: [
                _buildTab('おうち', Icons.house, 'house'),
                _buildTab('アイテム', Icons.star, 'item'),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              _buildItemGrid(allHouses, _equippedHouse),
              _buildMultiSelectionGrid(allItems, _equippedItems, 'item'),
            ],
          ),
        ),
        bottomNavigationBar: const AdBanner(),
      ),
    );
  }

  Widget _buildTab(String title, IconData icon, String targetType) {
    Widget tab = Tab(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(title)],
      ),
    );
    if (_showTabBlinking && _tutorialPurchasedItemType == targetType) {
      return BlinkingEffect(isBlinking: true, child: tab);
    }
    return tab;
  }

  Widget _buildItemGrid(List<ShopItem> items, String? equippedItemPath) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.75, // 縦を少し長めに
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isEquipped = item.imagePath == equippedItemPath;

        // ロック・未購入の判定
        final bool isPurchased = _purchasedItemNames.contains(item.name);
        final bool isLevelLocked = _currentLevel < item.requiredLevel;
        final bool isLocked =
            isLevelLocked && !PurchaseManager.instance.isPremium.value;

        Widget card = Card(
          elevation: isEquipped ? 4 : 2,
          color: isPurchased ? Colors.white : Colors.grey[200],
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: isEquipped ? Colors.amber : Colors.transparent,
              width: 4,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              if (isPurchased) {
                _equipItem(item);
              } else {
                _handlePurchaseAttempt(item); // 未購入なら購入処理へ
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
                          child: Builder(
                            builder: (context) {
                              if (item.type == 'face' ||
                                  item.type == 'headgear') {
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
                                              child: Image.asset(
                                                item.imagePath,
                                              ),
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
                    if (isEquipped) ...[
                      Container(
                        color: Colors.amber,
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: const Text(
                          'そうび中',
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

        if (_showItemBlinking && _tutorialPurchasedItemName == item.name) {
          return BlinkingEffect(isBlinking: true, child: card);
        }
        return card;
      },
    );
  }

  Widget _buildMultiSelectionGrid(
    List<ShopItem> options,
    List<String> selected,
    String type,
  ) {
    // 🌟 修正: 8や6だと多すぎて潰れるため、安全な4に統一します
    int crossAxisCount = type == 'item' ? 8 : 6;

    return GridView.builder(
      padding: const EdgeInsets.all(16), // 🌟 追加: GridView自体に余白を持たせます
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final item = options[index];
        final isSelected = selected.contains(item.imagePath);

        final bool isPurchased = _purchasedItemNames.contains(item.name);
        final bool isLevelLocked = _currentLevel < item.requiredLevel;
        final bool isLocked =
            isLevelLocked && !PurchaseManager.instance.isPremium.value;

        Widget itemWidget = GestureDetector(
          onTap: () async {
            if (isPurchased) {
              try {
                SfxManager.instance.playTapSound();
              } catch (e) {}
              setState(() {
                if (isSelected) {
                  selected.remove(item.imagePath);
                } else {
                  selected.add(item.imagePath);
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
            } else {
              _handlePurchaseAttempt(item); // 未購入なら購入処理へ
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: isPurchased ? Colors.white : Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? Colors.blueAccent : Colors.transparent,
                width: isSelected ? 3 : 0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                      ),
                    ]
                  : [const BoxShadow(color: Colors.black12, blurRadius: 2)],
            ),
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
                    ] else ...[
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
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

        if (_showItemBlinking && _tutorialPurchasedItemName == item.name) {
          return BlinkingEffect(isBlinking: true, child: itemWidget);
        }
        return itemWidget;
      },
    );
  }
}
