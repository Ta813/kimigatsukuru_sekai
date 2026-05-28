// lib/screens/house_interior/house_interior_screen.dart

import 'dart:ui' as import_ui;

import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:kimigatsukuru_sekai/helpers/shared_prefs_helper.dart';
import 'package:kimigatsukuru_sekai/widgets/avatar_display.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/draggable_character.dart';
import 'furniture_customize_screen.dart';
import '../../managers/sfx_manager.dart';
import '../../widgets/round_menu_button.dart';
import '../../helpers/image_share_helper.dart';

class HouseInteriorScreen extends StatefulWidget {
  // ★ホーム画面から、現在装備中の家の画像パスを受け取る
  final String equippedHousePath;
  final int requiredExpForNextLevel;
  final int experience;
  final double experienceFraction;

  const HouseInteriorScreen({
    super.key,
    required this.equippedHousePath,
    required this.requiredExpForNextLevel,
    required this.experience,
    required this.experienceFraction,
  });

  @override
  State<HouseInteriorScreen> createState() => _HouseInteriorScreenState();
}

class _HouseInteriorScreenState extends State<HouseInteriorScreen> {
  // ★ 装備中の家具・アイテムのリスト
  List<String> _equippedFurniture = [];
  List<String> _equippedHouseItems = [];
  // ★ 各アイテムの位置を管理するマップ
  Map<String, Offset> _itemPositionsMap = {};
  // 装備中の家パスに基づいて、家の中の背景画像を決定するヘルパーメソッド
  String _equippedFace = 'assets/images/face/face_default.png';
  String _equippedHair = 'assets/images/hair/hair_default.png';
  String _equippedClothes = 'assets/images/clothes/clothes_default.png';
  String? _equippedHeadgear;
  String? _equippedAccessory;
  Offset _avatarPosition = const Offset(100, 150); // デフォルトの位置

  List<String> _equippedCharacters = [];
  Map<String, Offset> _characterPositionsMap = {};

  bool _isDrawingMode = false; // おえかきモードかどうか
  List<DrawingPoint?> _drawingPoints = []; // 描いた線のデータ
  Color _selectedColor = Colors.redAccent; // とりあえず最初は赤色
  final double _strokeWidth = 6.0; // 線の太さ

  bool _isEraserMode = false;
  final List<Color> _paletteColors = [
    Colors.redAccent,
    Colors.orangeAccent,
    Colors.yellowAccent,
    Colors.greenAccent,
    Colors.blueAccent,
    Colors.white,
    Colors.black87,
  ];

  // ポイント数の状態を管理するための変数
  int _points = 0;
  int _level = 1;

  // 画像として切り取る枠を指定するためのキー
  final GlobalKey _shareKey = GlobalKey();

  bool _showWatermarkForCapture = false;

  String _getInteriorBackgroundImage(String houseAssetPath) {
    switch (houseAssetPath) {
      case 'assets/images/house.png': // さいしょのおうち
        return 'assets/images/house_interior/normal_interior.png';
      case 'assets/images/house_normal.png': // ふつうのおうち
        return 'assets/images/house_interior/normal_interior.png';
      case 'assets/images/house_rich.png': // りっぱなおうち
        return 'assets/images/house_interior/rich_interior.png';
      case 'assets/images/house_sea_kaigara.png': // うみのおうち（かいがら）
        return 'assets/images/house_interior/sea_interior.png';
      case 'assets/images/house_sea_kurage.png': // うみのおうち（くらげ）
        return 'assets/images/house_interior/sea_interior.png';
      case 'assets/images/house_sky_dome.png': // そらのおうち（ドーム）
        return 'assets/images/house_interior/sky_interior.png';
      case 'assets/images/house_sky_kumo.png': // そらのおうち（くも）
        return 'assets/images/house_interior/sky_interior.png';
      default:
        return 'assets/images/house_interior/default_interior.png';
    }
  }

  @override
  void initState() {
    super.initState();
    // ★ 画面の初期化時にアイテムと位置情報を読み込む
    _loadItemsAndPositions();
  }

  // ★ アイテムと位置情報を読み込むメソッド
  Future<void> _loadItemsAndPositions() async {
    final loadedPoints = await SharedPrefsHelper.loadPoints();
    final loadedLevel = await SharedPrefsHelper.loadLevel();
    final furniture = await SharedPrefsHelper.loadEquippedFurniture();
    final houseItems = await SharedPrefsHelper.loadEquippedHouseItems();
    // アバターの服を読み込む
    final face = await SharedPrefsHelper.loadEquippedFace();
    final hair = await SharedPrefsHelper.loadEquippedHairstyle();
    final clothes = await SharedPrefsHelper.loadEquippedClothes();
    final headgear = await SharedPrefsHelper.loadEquippedHeadgear();
    final accessory = await SharedPrefsHelper.loadEquippedAccessory();
    // アバターの「家の中での」位置を読み込む
    Offset? position = await SharedPrefsHelper.loadCharacterPosition(
      'avatar_in_house',
    );

    final characters = await SharedPrefsHelper.loadEquippedCharacters();

    late double screenWidth;
    late double screenHeight;

    // 画面サイズを取得
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    // 位置が画面外にある場合はリセット
    if (position != null &&
        (position.dx > screenWidth ||
            position.dy > screenHeight ||
            position.dx < 0 ||
            position.dy < 0)) {
      position = null; // 範囲外ならリセット
    }

    final allItems = [...furniture, ...houseItems];
    final loadedPositions = {};

    for (var itemPath in allItems) {
      // SharedPrefsHelperから各アイテムの位置を読み込む
      final position = await SharedPrefsHelper.loadCharacterPosition(itemPath);
      // 位置が保存されていなかった場合の初期位置を決める
      loadedPositions[itemPath] = position ?? const Offset(100, 150);
    }

    final charactersToLoad = characters.isEmpty
        ? ['assets/images/character_usagi.gif']
        : characters;

    for (var charPath in charactersToLoad) {
      final loadedPos = await SharedPrefsHelper.loadCharacterPosition(
        'house_$charPath',
      );
      loadedPositions[charPath] = loadedPos ?? Offset(100, 150);
    }

    setState(() {
      _points = loadedPoints;
      _level = loadedLevel;
      _equippedFurniture = furniture;
      _equippedHouseItems = houseItems;
      _itemPositionsMap = {};
      for (var itemPath in allItems) {
        if (loadedPositions[itemPath] != null &&
            (loadedPositions[itemPath].dx > screenWidth ||
                loadedPositions[itemPath].dy > screenHeight ||
                loadedPositions[itemPath].dx < 0 ||
                loadedPositions[itemPath].dy < 0)) {
          loadedPositions[itemPath] = null; // 範囲外ならリセット
        }
        _itemPositionsMap[itemPath] =
            loadedPositions[itemPath] ?? Offset(100, 150); // 読み込んだ位置を保存
      }
      _equippedFace = face ?? 'assets/images/face/face_default.png';
      _equippedHair = hair ?? 'assets/images/hair/hair_default.png';
      _equippedClothes = clothes ?? 'assets/images/clothes/clothes_default.png';
      _equippedHeadgear = headgear;
      _equippedAccessory = accessory;
      _avatarPosition = position ?? const Offset(100, 150); // 読み込んだ位置、なければデフォルト
      _equippedCharacters = characters;
      _characterPositionsMap = {}; // 一旦クリア
      for (var charPath in _equippedCharacters) {
        if (loadedPositions[charPath] != null &&
            (loadedPositions[charPath].dx > screenWidth ||
                loadedPositions[charPath].dy > screenHeight ||
                loadedPositions[charPath].dx < 0 ||
                loadedPositions[charPath].dy < 0)) {
          loadedPositions[charPath] = null; // 範囲外ならリセット
        }
        _characterPositionsMap[charPath] =
            loadedPositions[charPath] ?? Offset(100, 150); // 読み込んだ位置を保存
      }
    });
  }

  // ★ ホーム画面から持ってきたアイテムサイズ決定ロジック (必要に応じて調整)
  double _getItemSize(String itemPath) {
    if (itemPath.contains('/house_interior_items/banana.png')) return 30.0;
    if (itemPath.contains('/house_interior_items/takarabako.png')) return 60.0;
    if (itemPath.contains('/house_interior_items/mokuba.png')) return 60.0;
    if (itemPath.contains('/house_interior_items/kumanonuigurumi.png'))
      return 60.0;
    if (itemPath.contains('/house_interior_items/sea_kagami.png')) return 80.0;
    if (itemPath.contains('/house_interior_items/sky_hoshi.png')) return 80.0;
    if (itemPath.contains('/house_interior_items/sky_kakejiku.png'))
      return 80.0;
    if (itemPath.contains('/house_interior_items/sky_cap.png')) return 30.0;
    if (itemPath.contains('/house_interior_items/')) return 40.0;
    if (itemPath.contains('/house_interior_furniture/rantan.png')) return 70.0;
    if (itemPath.contains('/house_interior_furniture/sea_isu.png')) return 80.0;
    if (itemPath.contains('/house_interior_furniture/sea_isu2.png'))
      return 60.0;
    if (itemPath.contains('/house_interior_furniture/sea_table.png'))
      return 80.0;
    if (itemPath.contains('/house_interior_furniture/sky_isu2.png'))
      return 60.0;
    return 100.0; // デフォルトサイズ
  }

  @override
  Widget build(BuildContext context) {
    // ★受け取った家のパスから、表示すべき背景画像を決定
    final backgroundImagePath = _getInteriorBackgroundImage(
      widget.equippedHousePath,
    );

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(backgroundImagePath), // ★決定された背景画像を使用
                fit: BoxFit.cover,
              ),
            ),
          ),

          if (!_isDrawingMode)
            // 戻るボタン
            Positioned(
              top: 20.0,
              left: 20.0,
              child: SafeArea(
                child: RoundMenuButton(
                  icon: Icons.keyboard_return,
                  label: AppLocalizations.of(context)!.navBack,
                  iconColor: const Color(0xFF5D4037),
                  backgroundColor: const Color(0xFFCFD8DC), // ブルーグレー
                  onTap: () {
                    FirebaseAnalytics.instance.logEvent(
                      name: 'start_house_interior_back',
                    );
                    try {
                      SfxManager.instance.playTapSound();
                    } catch (e) {
                      print('再生エラー: $e');
                    }
                    Navigator.pop(context);
                  },
                ),
              ),
            ),

          if (!_isDrawingMode)
            Positioned(
              top: 25,
              right: 10,
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  SafeArea(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          // 少し影をつけて立体感を出す
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            '$_points', // ポイント数を表示
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (!_isDrawingMode)
            Positioned(
              top: 30, // ポイント表示の下あたり
              left: 0, // 左端を画面の左端に合わせる
              right: 0, // 右端を画面の右端に合わせる
              child: Center(
                // ★ Centerウィジェットで中央に配置
                child: Container(
                  // ★ ここからが白い枠のデザイン設定
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9), // 少し半透明の白
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      // ポイント表示と同じような影をつける
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 220, // ★ 例として横幅を200に設定（画面に合わせて調整してください）
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min, // Rowが中身のサイズに合わせる
                              children: [
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.levelLabel(_level),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            //経験値バー
                            LinearProgressIndicator(
                              value: widget.experienceFraction, // 現在の経験値の割合
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // ==========================================
          // 📸 画像として切り取る「世界」のレイヤー
          // ==========================================
          RepaintBoundary(
            key: _shareKey,
            child: Stack(
              children: [
                // 画像の背景画像
                if (_showWatermarkForCapture)
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(backgroundImagePath), // ★決定された背景画像を使用
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                // ★ 配置された家具のリストを表示 (ホーム画面と全く同じ仕組み)
                ..._equippedFurniture.map((itemPath) {
                  return DraggableCharacter(
                    id: itemPath, // IDとして画像パスを使う
                    imagePath: itemPath,
                    position:
                        _itemPositionsMap[itemPath] ?? const Offset(100, 150),
                    size: _getItemSize(itemPath),
                    onPositionChanged: (delta) {
                      setState(() {
                        final currentPos =
                            _itemPositionsMap[itemPath] ??
                            const Offset(100, 150);
                        _itemPositionsMap[itemPath] = currentPos + delta;
                      });
                    },
                  );
                }).toList(),

                // ★ 配置された家のアイテムのリストを表示
                ..._equippedHouseItems.map((itemPath) {
                  return DraggableCharacter(
                    id: itemPath,
                    imagePath: itemPath,
                    position:
                        _itemPositionsMap[itemPath] ?? const Offset(150, 200),
                    size: _getItemSize(itemPath),
                    onPositionChanged: (delta) {
                      setState(() {
                        final currentPos =
                            _itemPositionsMap[itemPath] ??
                            const Offset(150, 200);
                        _itemPositionsMap[itemPath] = currentPos + delta;
                      });
                    },
                  );
                }).toList(),

                DraggableCharacter(
                  id: 'avatar_in_house', // ★ 家の中専用のユニークID
                  customWidget: AvatarDisplay(
                    face: _equippedFace,
                    clothes: _equippedClothes,
                    hair: _equippedHair,
                    headgear: _equippedHeadgear,
                    accessory: _equippedAccessory,
                    size: 80,
                  ),
                  position: _avatarPosition,
                  size: 80.0, // ホーム画面と同じサイズ感
                  onPositionChanged: (delta) {
                    setState(() {
                      _avatarPosition += delta;
                    });
                  },
                ),

                // ★応援キャラクターの表示と操作
                ..._equippedCharacters.map((charPath) {
                  return DraggableCharacter(
                    id: 'house_$charPath', // IDとして画像パスを使う
                    imagePath: charPath,
                    position:
                        _characterPositionsMap[charPath] ?? Offset(490, 190),
                    size: 80,
                    onPositionChanged: (delta) {
                      setState(() {
                        // ★位置の更新
                        _characterPositionsMap[charPath] =
                            (_characterPositionsMap[charPath] ??
                                const Offset(490, 190)) +
                            delta;
                      });
                    },
                  );
                }).toList(),

                // ==========================================
                // 🎨 追加: おえかきキャンバスレイヤー
                // ==========================================
                if (_isDrawingMode)
                  // モードONの時：指の動きを検知して線を描く
                  GestureDetector(
                    onPanStart: (details) {
                      setState(() {
                        RenderBox renderBox =
                            context.findRenderObject() as RenderBox;
                        _drawingPoints.add(
                          DrawingPoint(
                            offset: renderBox.globalToLocal(
                              details.globalPosition,
                            ),
                            paint: Paint()
                              // 🌟 変更: 消しゴムモードなら透明色と「削る（clear）」設定にする
                              ..color = _isEraserMode
                                  ? Colors.transparent
                                  : _selectedColor
                              ..blendMode = _isEraserMode
                                  ? BlendMode.clear
                                  : BlendMode.srcOver
                              ..strokeCap = StrokeCap.round
                              // お子さんが消しやすいように消しゴムは太めに設定
                              ..strokeWidth = _isEraserMode
                                  ? _strokeWidth * 3
                                  : _strokeWidth,
                          ),
                        );
                      });
                    },
                    onPanUpdate: (details) {
                      setState(() {
                        RenderBox renderBox =
                            context.findRenderObject() as RenderBox;
                        _drawingPoints.add(
                          DrawingPoint(
                            offset: renderBox.globalToLocal(
                              details.globalPosition,
                            ),
                            paint: Paint()
                              // 🌟 変更: 消しゴムモードなら透明色と「削る（clear）」設定にする
                              ..color = _isEraserMode
                                  ? Colors.transparent
                                  : _selectedColor
                              ..blendMode = _isEraserMode
                                  ? BlendMode.clear
                                  : BlendMode.srcOver
                              ..strokeCap = StrokeCap.round
                              // お子さんが消しやすいように消しゴムは太めに設定
                              ..strokeWidth = _isEraserMode
                                  ? _strokeWidth * 3
                                  : _strokeWidth,
                          ),
                        );
                      });
                    },
                    onPanEnd: (details) {
                      setState(() {
                        _drawingPoints.add(null); // 指を離したら線を切る
                      });
                    },
                    child: Container(
                      color: Colors.white.withOpacity(
                        0.01,
                      ), // 透明だと検知しない場合があるためごく僅かに色をつける
                      width: double.infinity,
                      height: double.infinity,
                      child: CustomPaint(
                        painter: DrawingPainter(points: _drawingPoints),
                      ),
                    ),
                  )
                else
                  // モードOFFの時：線は表示するが、タッチは家具に貫通させる
                  IgnorePointer(
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: CustomPaint(
                        painter: DrawingPainter(points: _drawingPoints),
                      ),
                    ),
                  ),

                // シェア画像にだけ写る「宣伝用ロゴ（ウォーターマーク）」
                if (_showWatermarkForCapture)
                  Positioned(
                    bottom: 16.0,
                    right: 16.0,
                    child: Text(
                      AppLocalizations.of(context)!.appName,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        shadows: const [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 4,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (!_showWatermarkForCapture)
            // 右側のボタン群
            if (!_isDrawingMode)
              Positioned(
                top: 80.0,
                right: 20.0,
                child: SafeArea(
                  child: Column(
                    children: [
                      // 家具設定ボタン
                      RoundMenuButton(
                        icon: Icons.chair,
                        label: AppLocalizations.of(context)!.navDressUp,
                        iconColor: const Color(0xFF5D4037),
                        backgroundColor: const Color(0xFFD1F2E1), // ライトミントグリーン
                        onTap: () {
                          FirebaseAnalytics.instance.logEvent(
                            name: 'start_house_interior_customize',
                          );
                          try {
                            SfxManager.instance.playTapSound();
                          } catch (e) {
                            print('再生エラー: $e');
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const FurnitureCustomizeScreen(
                                    mode: CustomizeMode.house,
                                  ),
                            ),
                          ).then((_) {
                            // ★ショップ画面から戻ってきたら、必ずデータを再読み込みする
                            _loadItemsAndPositions();
                          });
                        },
                      ),
                      RoundMenuButton(
                        icon: Icons.brush,
                        label: AppLocalizations.of(context)!.drawingButton,
                        iconColor: Colors.white,
                        backgroundColor: Colors.pinkAccent, // 目立つ黄色
                        onTap: () async {
                          setState(() {
                            _isDrawingMode = true; // おえかきモードON
                          });
                          try {
                            SfxManager.instance.playTapSound();
                          } catch (_) {}
                        },
                      ),
                    ],
                  ),
                ),
              ),

          // 🎨 おえかきモード中のボタン群
          if (_isDrawingMode)
            Positioned(
              top: 10.0,
              right: 10.0,
              child: SafeArea(
                child: Column(
                  children: [
                    // 全消しボタン
                    RoundMenuButton(
                      icon: Icons.delete_outline,
                      label: AppLocalizations.of(context)!.drawingClear,
                      iconColor: Colors.white,
                      backgroundColor: Colors.grey,
                      onTap: () {
                        setState(() {
                          _drawingPoints.clear();
                        });
                        try {
                          SfxManager.instance.playTapSound();
                        } catch (_) {}
                      },
                    ),
                    const SizedBox(height: 16),
                    // シェアボタン
                    RoundMenuButton(
                      icon: Icons.camera_alt,
                      label: AppLocalizations.of(context)!.shareLabel,
                      iconColor: const Color(0xFF5D4037),
                      backgroundColor: const Color(0xFFFFD54F), // 目立つ黄色
                      onTap: () async {
                        // モードを終了しつつ、すぐにシェア処理へ移行
                        setState(() {
                          _isDrawingMode = false;
                        });

                        FirebaseAnalytics.instance.logEvent(
                          name: 'share_house_interior_image',
                        );
                        try {
                          SfxManager.instance.playTapSound();
                        } catch (_) {}

                        // 1. ロード画面を表示 (画面のチカつきを隠す)
                        if (!mounted) return;
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) =>
                              const Center(child: CircularProgressIndicator()),
                        );

                        // 2. フラグを true にして build メソッドでロゴを表示させる
                        if (mounted) {
                          setState(() {
                            _showWatermarkForCapture = true;
                          });
                        }

                        // 3. 次のフレームの描画（ロゴあり状態のペイント）が完了するのを待つ
                        await WidgetsBinding.instance.endOfFrame;

                        // 4. 画像を切り取ってシェアする処理 (ImageShareHelper の中で boundary.toImage() が呼ばれる)
                        await ImageShareHelper.shareWidget(
                          globalKey: _shareKey,
                          shareText: AppLocalizations.of(
                            context,
                          )!.shareHouseText,
                        );

                        // 5. OSのシェアメニューが開いたら（またはエラーになっても）、ロード画面を閉じる
                        if (mounted) {
                          Navigator.of(context).pop(); // ロード画面を閉じる
                        }

                        // 6. フラグを false に戻して build メソッドでロゴを非表示にする
                        if (mounted) {
                          setState(() {
                            _showWatermarkForCapture = false;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // やめる（キャンセル）ボタン
                    RoundMenuButton(
                      icon: Icons.close,
                      label: AppLocalizations.of(context)!.drawingCancel,
                      iconColor: Colors.white,
                      backgroundColor: Colors.red,
                      onTap: () {
                        try {
                          SfxManager.instance.playTapSound();
                        } catch (_) {}
                        setState(() {
                          _isDrawingMode = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

          // ==========================================
          // 🎨 追加: カラーパレット ＆ 消しゴム
          // ==========================================
          if (_isDrawingMode)
            Positioned(
              top: 0.0, // ウォーターマークよりも少し上に配置
              left: 0,
              right: 0,
              child: SafeArea(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ① カラーボタンのリスト
                        ..._paletteColors.map((color) {
                          final isSelected =
                              !_isEraserMode && _selectedColor == color;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColor = color;
                                _isEraserMode = false; // 消しゴムを解除
                              });
                              try {
                                SfxManager.instance.playTapSound();
                              } catch (_) {}
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              width: isSelected ? 36 : 28,
                              height: isSelected ? 36 : 28,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.black54
                                      : Colors.grey[300]!,
                                  width: isSelected ? 3 : 1,
                                ),
                              ),
                            ),
                          );
                        }).toList(),

                        // 縦の仕切り線
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 2,
                          height: 30,
                          color: Colors.grey[400],
                        ),

                        // ② 消しゴムボタン
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isEraserMode = true; // 消しゴムモードON
                            });
                            try {
                              SfxManager.instance.playTapSound();
                            } catch (_) {}
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: _isEraserMode ? 40 : 32,
                            height: _isEraserMode ? 40 : 32,
                            decoration: BoxDecoration(
                              color: _isEraserMode
                                  ? Colors.pink[100]
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _isEraserMode
                                    ? Colors.pink
                                    : Colors.grey[400]!,
                                width: _isEraserMode ? 2 : 1,
                              ),
                            ),
                            child: Icon(
                              Icons.cleaning_services_rounded,
                              size: 20,
                              color: _isEraserMode
                                  ? Colors.pink
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ==========================================
// 🎨 追加: おえかき用のデータクラスとペインター
// ==========================================
class DrawingPoint {
  final Offset offset;
  final Paint paint;
  DrawingPoint({required this.offset, required this.paint});
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint?> points;
  DrawingPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    // 🌟 追加: キャンバスを独立レイヤーとして保存（消しゴムの切り抜きバグを防ぐ）
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(
          points[i]!.offset,
          points[i + 1]!.offset,
          points[i]!.paint,
        );
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawPoints(import_ui.PointMode.points, [
          points[i]!.offset,
        ], points[i]!.paint);
      }
    }

    // 🌟 追加: レイヤーを確定
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
