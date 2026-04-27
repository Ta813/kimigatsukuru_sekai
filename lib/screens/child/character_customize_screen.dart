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

// 🌟 追加: 表示する画面を切り替えるためのモード
enum CustomizeView { menu, avatar, support, world }

class CharacterCustomizeScreen extends StatefulWidget {
  const CharacterCustomizeScreen({super.key});

  @override
  State<CharacterCustomizeScreen> createState() =>
      _CharacterCustomizeScreenState();
}

class _CharacterCustomizeScreenState extends State<CharacterCustomizeScreen> {
  // 現在表示している画面（初期値はメニュー）
  CustomizeView _currentView = CustomizeView.menu;

  List<String> _purchasedItemNames = [];

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
    if (!purchased.contains('いつものふく')) purchased.add('いつものふく');
    if (!purchased.contains('さいしょのおうち')) purchased.add('さいしょのおうち');
    if (!purchased.contains('ウサギ')) purchased.add('ウサギ');
    if (!purchased.contains('おとこのこ')) purchased.add('おとこのこ');

    setState(() {
      _purchasedItemNames = purchased;

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

  // トップメニューでどのボタンを点滅させるか判定するロジック
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

    // アイテムのタイプに応じて保存
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

  @override
  Widget build(BuildContext context) {
    // 🌟 Androidシステムの戻るボタンやスワイプ戻りをハンドリング
    return PopScope(
      canPop: _currentView == CustomizeView.menu,
      onPopInvoked: (didPop) {
        if (!didPop) {
          setState(() {
            _currentView = CustomizeView.menu; // サブ画面ならメニューに戻す
          });
        }
      },
      child: _buildCurrentView(),
    );
  }

  // 現在のモードに応じて画面を切り替え
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
          child: const CustomBackButton(), // ここで押せばホーム画面に戻る
        ),
        title: Text(
          AppLocalizations.of(context)?.customizeTitle ?? 'カスタマイズ',
          style: const TextStyle(fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Center(
          // 🌟 ColumnからRowに変更し、画面からはみ出ても横スクロールできるように設定
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24), // 両端の余白
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
                const SizedBox(width: 20), // 🌟 縦の隙間(height)から横の隙間(width)に変更
                _buildMenuButton(
                  'おうえんキャラクター',
                  'キャラクターをえらぶ',
                  Icons.support_agent,
                  CustomizeView.support,
                  Colors.orangeAccent,
                ),
                const SizedBox(width: 20), // 🌟 横の隙間
                _buildMenuButton(
                  'きみのせかい',
                  'おうち・アイテムを\nへんこう', // 🌟 横幅に収まるよう改行を追加
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

  // 🌟 メニュー画面の大きなボタン（横並び用にデザインを四角いカード風に変更）
  Widget _buildMenuButton(
    String title,
    String subtitle,
    IconData icon,
    CustomizeView targetView,
    Color color,
  ) {
    final isBlinking = _shouldBlinkMenu(targetView);

    Widget button = SizedBox(
      width: 180, // 🌟 横幅を少し縮める
      height: 180, // 🌟 縦幅を広げて正方形に近い形にする
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
          padding: const EdgeInsets.all(12), // 枠内の余白を追加
        ),
        onPressed: () {
          try {
            SfxManager.instance.playTapSound();
          } catch (e) {}
          setState(() {
            _currentView = targetView; // 画面を切り替える
          });
        },
        // 🌟 RowからColumnに変更し、アイコンと文字を縦に並べる
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56), // アイコンを大きく目立たせる
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

  // ==========================================
  // サブ画面用の共通戻るボタン（メニューに戻る）
  // ==========================================
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
    final ownedFaces = shopItems
        .where(
          (item) =>
              item.type == 'face' && _purchasedItemNames.contains(item.name),
        )
        .toList();
    final ownedHair = shopItems
        .where(
          (item) =>
              item.type == 'hair' && _purchasedItemNames.contains(item.name),
        )
        .toList();
    final ownedClothes = shopItems
        .where(
          (item) =>
              item.type == 'clothes' && _purchasedItemNames.contains(item.name),
        )
        .toList();
    final ownedHeadgear = shopItems
        .where(
          (item) =>
              item.type == 'headgear' &&
              _purchasedItemNames.contains(item.name),
        )
        .toList();
    final ownedAccessories = shopItems
        .where(
          (item) =>
              item.type == 'accessory' &&
              _purchasedItemNames.contains(item.name),
        )
        .toList();

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 40,
          leading: _buildSubBackButton(),
          title: const Text('きせかえ', style: TextStyle(fontSize: 18)),
          // 🌟 削除: AppBarの下にくっついていた `bottom: TabBar(...)` を消します
        ),
        body: SafeArea(
          // 🌟 追加: Rowを使って画面を左右に分割
          child: Row(
            children: [
              // ==============================
              // 🌟 左側：タブとアイテムリスト
              // ==============================
              Expanded(
                child: Column(
                  children: [
                    // AppBarから移動してきたTabBarをここに配置
                    TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.center,
                      labelColor: const Color(0xFFFF7043), // 選択中の文字色（オレンジ）
                      unselectedLabelColor: Colors.grey, // 未選択の文字色
                      indicatorColor: const Color(0xFFFF7043), // 下線の色
                      tabs: [
                        _buildTab('かお', Icons.face, 'face'),
                        _buildTab('かみがた', Icons.cut, 'hair'),
                        _buildTab('かぶるもの', Icons.theater_comedy, 'headgear'),
                        _buildTab('ふくそう', Icons.checkroom, 'clothes'),
                        _buildTab('アクセサリー', Icons.backpack, 'accessory'),
                      ],
                    ),
                    // アイテムのグリッド
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildItemGrid(ownedFaces, _equippedFace),
                          _buildItemGrid(ownedHair, _equippedHair),
                          _buildItemGrid(ownedHeadgear, _equippedHeadgear),
                          _buildItemGrid(ownedClothes, _equippedClothes),
                          _buildItemGrid(ownedAccessories, _equippedAccessory),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ==============================
              // 🌟 右側：アバタープレビュー領域
              // ==============================
              Container(
                width: 140, // 🌟 右側の幅を固定（画面に合わせて120〜160くらいで調整してください）
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0), // 背景を少し違う色にして区別する
                  border: Border(
                    left: BorderSide(
                      color: Colors.grey.shade300,
                      width: 2,
                    ), // 左側に区切り線
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
                    // 🌟 先ほど作った共通のアバター表示ウィジェットを呼び出す
                    AvatarDisplay(
                      face: _equippedFace,
                      hair: _equippedHair,
                      clothes: _equippedClothes,
                      headgear: _equippedHeadgear,
                      accessory: _equippedAccessory,
                      size: 100, // アイテム枠より少し大きめに表示
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
    final ownedCharacters = shopItems
        .where(
          (item) =>
              item.type == 'character' &&
              _purchasedItemNames.contains(item.name),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        leading: _buildSubBackButton(),
        title: const Text('おうえんキャラクター', style: TextStyle(fontSize: 18)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildMultiSelectionGrid(
            ownedCharacters,
            _equippedCharacters,
            'character',
          ),
        ),
      ),
      bottomNavigationBar: const AdBanner(),
    );
  }

  // ==========================================
  // 4. きみのせかい（家・アイテム）画面
  // ==========================================
  Widget _buildWorldScreen() {
    final ownedHouses = shopItems
        .where(
          (item) =>
              item.type == 'house' && _purchasedItemNames.contains(item.name),
        )
        .toList();
    final ownedItems = shopItems
        .where(
          (item) =>
              item.type == 'item' && _purchasedItemNames.contains(item.name),
        )
        .toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 40,
          leading: _buildSubBackButton(),
          title: const Text('きみのせかい', style: TextStyle(fontSize: 18)),
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
              _buildItemGrid(ownedHouses, _equippedHouse),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildMultiSelectionGrid(
                  ownedItems,
                  _equippedItems,
                  'item',
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
  // 各種UIビルドヘルパー
  // ==========================================
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

  // 1つだけ選択するパーツ用グリッド
  Widget _buildItemGrid(List<ShopItem> items, String? equippedItemPath) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isEquipped = item.imagePath == equippedItemPath;

        Widget card = Card(
          shape: RoundedRectangleBorder(
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
                Expanded(
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
                const SizedBox(height: 4),
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

  // 複数選択するパーツ（応援キャラ・アイテム）用グリッド
  Widget _buildMultiSelectionGrid(
    List<ShopItem> options,
    List<String> selected,
    String type,
  ) {
    int crossAxisCount = 8;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final item = options[index];
        final isSelected = selected.contains(item.imagePath);

        Widget itemWidget = GestureDetector(
          onTap: () async {
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
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? Colors.blueAccent : Colors.grey,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Image.asset(item.imagePath)),
                const SizedBox(height: 8),
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
