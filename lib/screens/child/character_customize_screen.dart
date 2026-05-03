// lib/screens/child/character_customize_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:kimigatsukuru_sekai/screens/premium_paywall_screen.dart';
import 'package:kimigatsukuru_sekai/widgets/ad_banner.dart';
import '../../models/shop_data.dart';
import '../../helpers/shared_prefs_helper.dart';
import '../../managers/sfx_manager.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/blinking_effect.dart';
import '../../widgets/custom_back_button.dart';
import '../../widgets/avatar_display.dart';
import '../../managers/purchase_manager.dart';

enum CustomizeView { menu, avatar, support, world, initialSetup }

class CharacterCustomizeScreen extends StatefulWidget {
  final bool isInitialSetup;

  const CharacterCustomizeScreen({super.key, this.isInitialSetup = false});

  @override
  State<CharacterCustomizeScreen> createState() =>
      _CharacterCustomizeScreenState();
}

class _CharacterCustomizeScreenState extends State<CharacterCustomizeScreen> {
  late CustomizeView _currentView;

  List<String> _purchasedItemNames = [];

  int _currentLevel = 1;
  int _currentPoints = 0;

  int _setupStep = 0;
  String? _setupSelectedCharacter;

  String? _equippedFace;
  String? _equippedHair;
  String? _equippedClothes;
  String? _equippedHeadgear;
  String? _equippedAccessory;

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
    _currentView = widget.isInitialSetup
        ? CustomizeView.initialSetup
        : CustomizeView.menu;

    _loadEquippedItems();
    if (!widget.isInitialSetup) {
      _checkTutorialStep();
    }
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
    final level = await SharedPrefsHelper.loadLevel();
    final points = await SharedPrefsHelper.loadPoints();

    final face = await SharedPrefsHelper.loadEquippedFace();
    final hair = await SharedPrefsHelper.loadEquippedHairstyle();
    final clothes = await SharedPrefsHelper.loadEquippedClothes();
    final headgear = await SharedPrefsHelper.loadEquippedHeadgear();
    final accessory = await SharedPrefsHelper.loadEquippedAccessory();

    final house = await SharedPrefsHelper.loadEquippedHouse();
    final characters = await SharedPrefsHelper.loadEquippedCharacters();
    final items = await SharedPrefsHelper.loadEquippedItems();

    if (!purchased.contains('いつものかお')) purchased.add('いつものかお');
    if (!purchased.contains('頑張るかお')) purchased.add('頑張るかお');
    if (!purchased.contains('困ったかお')) purchased.add('困ったかお');
    if (!purchased.contains('ウインクしているかお')) purchased.add('ウインクしているかお');
    if (!purchased.contains('いつものかみがた')) purchased.add('いつものかみがた');
    if (!purchased.contains('ポニーテールかみがた')) purchased.add('ポニーテールかみがた');
    if (!purchased.contains('おとこのこのかみがた')) purchased.add('おとこのこのかみがた');
    if (!purchased.contains('アシメかみがた')) purchased.add('アシメかみがた');
    if (!purchased.contains('いつものふく')) purchased.add('いつものふく');
    if (!purchased.contains('おとこのこ')) purchased.add('おとこのこ');
    if (!purchased.contains('さいしょのおうち')) purchased.add('さいしょのおうち');

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

      _setupSelectedCharacter = characters.isNotEmpty
          ? characters.first
          : 'assets/images/character_usagi.gif';
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

  void _handlePurchaseAttempt(ShopItem item) async {
    final bool isLevelLocked = _currentLevel < item.requiredLevel;
    final bool isLocked =
        isLevelLocked && !PurchaseManager.instance.isPremium.value;

    if (isLocked) {
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
                FirebaseAnalytics.instance.logEvent(
                  name: 'premium_open_character_customize',
                );
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PremiumPaywallScreen(),
                  ),
                );
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
                _equipItem(item);
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
    return ValueListenableBuilder<bool>(
      valueListenable: PurchaseManager.instance.isPremium,
      builder: (context, isPremium, child) {
        return PopScope(
          canPop: !widget.isInitialSetup && _currentView == CustomizeView.menu,
          onPopInvoked: (didPop) {
            if (!didPop && !widget.isInitialSetup) {
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
      case CustomizeView.initialSetup:
        return _buildInitialSetupScreen();
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
  // 🌟 初回起動時のセットアップ（ウィザード）画面
  // ==========================================
  Widget _buildInitialSetupScreen() {
    final localizations = AppLocalizations.of(context)!;

    if (_setupStep == 0) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF3E0),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AvatarDisplay(
                      face: _equippedFace,
                      hair: _equippedHair,
                      clothes: _equippedClothes,
                      size: 100,
                    ),
                    const SizedBox(width: 20),
                    Image.asset(
                      'assets/images/character_usagi.gif',
                      height: 100,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  localizations.setupWelcomeMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    try {
                      SfxManager.instance.playTapSound();
                    } catch (e) {}
                    setState(() {
                      _setupStep++;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7043),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    localizations.chooseButton,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    List<ShopItem> currentItems = [];
    String title = '';
    String? currentEquippedPath;

    if (_setupStep == 1) {
      title = localizations.setupHairTitle;
      currentItems = shopItems.where((i) => i.type == 'hair').toList();
      currentEquippedPath = _equippedHair;
    } else if (_setupStep == 2) {
      title = localizations.setupFaceTitle;
      currentItems = shopItems.where((i) => i.type == 'face').toList();
      currentEquippedPath = _equippedFace;
    } else if (_setupStep == 3) {
      title = localizations.setupClothesTitle;
      currentItems = shopItems.where((i) => i.type == 'clothes').toList();
      currentEquippedPath = _equippedClothes;
    } else if (_setupStep == 4) {
      title = localizations.setupCompanionTitle;
      currentItems = shopItems.where((i) => i.type == 'character').toList();
      currentEquippedPath = _setupSelectedCharacter;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        toolbarHeight: 50,
        automaticallyImplyLeading: false,
        title: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 40,
                          height: 8,
                          decoration: BoxDecoration(
                            color: (_setupStep - 1) >= index
                                ? const Color(0xFFFF7043)
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.8,
                          ),
                      itemCount: currentItems.length,
                      itemBuilder: (context, index) {
                        final item = currentItems[index];
                        final isSelected =
                            item.imagePath == currentEquippedPath;

                        return Card(
                          elevation: isSelected ? 6 : 2,
                          color: isSelected
                              ? const Color(0xFFFFF9C4)
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.amber
                                  : Colors.transparent,
                              width: 4,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              try {
                                SfxManager.instance.playTapSound();
                              } catch (e) {}
                              setState(() {
                                if (_setupStep == 1)
                                  _equippedHair = item.imagePath;
                                else if (_setupStep == 2)
                                  _equippedFace = item.imagePath;
                                else if (_setupStep == 3)
                                  _equippedClothes = item.imagePath;
                                else if (_setupStep == 4)
                                  _setupSelectedCharacter = item.imagePath;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _buildItemPreviewImage(item),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  left: BorderSide(color: Colors.grey.shade300, width: 2),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_setupStep == 1 ||
                      _setupStep == 2 ||
                      _setupStep == 3) ...[
                    Text(
                      localizations.currentAppearance,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AvatarDisplay(
                      face: _equippedFace,
                      hair: _equippedHair,
                      clothes: _equippedClothes,
                      size: 100,
                    ),
                  ],
                  if (_setupStep == 4 && _setupSelectedCharacter != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      localizations.companionLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Image.asset(_setupSelectedCharacter!, height: 100),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () async {
            try {
              SfxManager.instance.playTapSound();
            } catch (e) {}

            ShopItem? selectedItem;
            if (_setupStep == 1 && _equippedHair != null) {
              selectedItem = shopItems.firstWhere(
                (i) => i.imagePath == _equippedHair,
              );
              await SharedPrefsHelper.saveEquippedHairstyle(_equippedHair!);
            }
            if (_setupStep == 2 && _equippedFace != null) {
              selectedItem = shopItems.firstWhere(
                (i) => i.imagePath == _equippedFace,
              );
              await SharedPrefsHelper.saveEquippedFace(_equippedFace!);
            } else if (_setupStep == 3 && _equippedClothes != null) {
              selectedItem = shopItems.firstWhere(
                (i) => i.imagePath == _equippedClothes,
              );
              await SharedPrefsHelper.saveEquippedClothes(_equippedClothes!);
            } else if (_setupStep == 4 && _setupSelectedCharacter != null) {
              selectedItem = shopItems.firstWhere(
                (i) => i.imagePath == _setupSelectedCharacter,
              );
              await SharedPrefsHelper.saveEquippedCharacters([
                _setupSelectedCharacter!,
              ]);
            }

            if (selectedItem != null &&
                !_purchasedItemNames.contains(selectedItem.name)) {
              await SharedPrefsHelper.addPurchasedItem(selectedItem.name);
              _purchasedItemNames.add(selectedItem.name);
            }

            if (_setupStep < 4) {
              if (_setupStep == 0) {
                FirebaseAnalytics.instance.logEvent(name: 'setup_1_start');
              } else if (_setupStep == 1) {
                FirebaseAnalytics.instance.logEvent(name: 'setup_2_start');
              } else if (_setupStep == 2) {
                FirebaseAnalytics.instance.logEvent(name: 'setup_3_start');
              } else if (_setupStep == 3) {
                FirebaseAnalytics.instance.logEvent(name: 'setup_4_start');
              } else if (_setupStep == 4) {
                FirebaseAnalytics.instance.logEvent(name: 'setup_5_start');
              }
              setState(() {
                _setupStep++;
              });
            } else {
              // 🌟 変更: ここのダイアログ表示を削除し、すぐに呼び出し元（司令塔）に返します
              FirebaseAnalytics.instance.logEvent(name: 'setup_child_finish');
              if (!mounted) return;
              Navigator.pop(context, true); // trueを返して完了を知らせる
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF7043),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 4,
          ),
          child: Text(
            _setupStep == 4
                ? localizations.startWithThis
                : localizations.nextButton,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildItemPreviewImage(ShopItem item) {
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
  }

  // ==========================================
  // 通常のカスタマイズ画面（以下、既存のまま）
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
          localizations.customizeTitle,
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
                  CustomizeView.avatar,
                  Colors.pinkAccent,
                ),
                const SizedBox(width: 20),
                _buildMenuButton(
                  localizations.menuSupportChar,
                  localizations.menuSupportCharSub,
                  Icons.support_agent,
                  CustomizeView.support,
                  Colors.orangeAccent,
                ),
                const SizedBox(width: 20),
                _buildMenuButton(
                  localizations.menuYourWorld,
                  localizations.menuYourWorldSub,
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

  Widget _buildAvatarScreen() {
    final localizations = AppLocalizations.of(context)!;
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
          title: Text(
            localizations.menuCustomizeAvatar,
            style: const TextStyle(fontSize: 18),
          ),
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
                        _buildTab(localizations.tabFace, Icons.face, 'face'),
                        _buildTab(localizations.tabHair, Icons.cut, 'hair'),
                        _buildTab(
                          localizations.tabHeadgear,
                          Icons.theater_comedy,
                          'headgear',
                        ),
                        _buildTab(
                          localizations.tabClothes,
                          Icons.checkroom,
                          'clothes',
                        ),
                        _buildTab(
                          localizations.tabAccessory,
                          Icons.backpack,
                          'accessory',
                        ),
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
                    Text(
                      localizations.currentAppearance,
                      style: const TextStyle(
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

  Widget _buildSupportScreen() {
    final localizations = AppLocalizations.of(context)!;
    final allCharacters = shopItems
        .where((item) => item.type == 'character')
        .toList();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        leading: _buildSubBackButton(),
        title: Text(
          localizations.menuSupportChar,
          style: const TextStyle(fontSize: 18),
        ),
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

  Widget _buildWorldScreen() {
    final localizations = AppLocalizations.of(context)!;
    final allHouses = shopItems.where((item) => item.type == 'house').toList();
    final allItems = shopItems.where((item) => item.type == 'item').toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 40,
          leading: _buildSubBackButton(),
          title: Text(
            localizations.menuYourWorld,
            style: const TextStyle(fontSize: 18),
          ),
          actions: _buildAppBarActions(),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: TabBar(
              tabs: [
                _buildTab(localizations.tabHouse, Icons.house, 'house'),
                _buildTab(localizations.tabItem, Icons.star, 'item'),
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
        crossAxisCount: 7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isEquipped = item.imagePath == equippedItemPath;

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
                _handlePurchaseAttempt(item);
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
                          opacity: (!isPurchased && isLocked) ? 0.5 : 1.0,
                          child: _buildItemPreviewImage(item),
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
                    ],
                    if (isEquipped) ...[
                      Container(
                        color: Colors.amber,
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          AppLocalizations.of(context)!.labelEquipped,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ] else if (isPurchased) ...[
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
                if (!isPurchased && isLocked)
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
    int crossAxisCount = type == 'item' ? 8 : 7;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
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
              _handlePurchaseAttempt(item);
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
                          child: _buildItemPreviewImage(item),
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
                if (isSelected)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        AppLocalizations.of(context)!.labelPlaced,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
