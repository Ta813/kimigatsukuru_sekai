import 'package:flutter/material.dart';
import '../../helpers/shared_prefs_helper.dart';
import '../../widgets/draggable_character.dart';
import 'shop_screen.dart'; // ショップ画面
import 'furniture_customize_screen.dart'; // 家具設定画面
import '../../l10n/app_localizations.dart';

class IslandScreen extends StatefulWidget {
  final int currentLevel;
  final int currentPoints;
  final int requiredExpForNextLevel;
  final int experience;
  final double experienceFraction;

  const IslandScreen({
    super.key,
    required this.currentLevel,
    required this.currentPoints,
    required this.requiredExpForNextLevel,
    required this.experience,
    required this.experienceFraction,
  });

  @override
  State<IslandScreen> createState() => _IslandScreenState();
}

class _IslandScreenState extends State<IslandScreen> {
  // --- 配置するアイテムの状態を管理する変数 ---
  String? _equippedClothesPath;
  List<String> _equippedBuildings = [];
  List<String> _equippedVehicles = [];

  Offset _avatarPosition = const Offset(150, 200);
  Map<String, Offset> _itemPositionsMap = {};

  // ポイント数の状態を管理するための変数
  int _points = 0;
  int _level = 1;

  List<String> _equippedCharacters = [];
  Map<String, Offset> _characterPositionsMap = {};

  @override
  void initState() {
    super.initState();
    _loadPlacedItems();
  }

  // 配置するアイテムとその位置情報を読み込む
  Future<void> _loadPlacedItems() async {
    // --- 装備情報の読み込み ---
    final loadedPoints = await SharedPrefsHelper.loadPoints();
    final loadedLevel = await SharedPrefsHelper.loadLevel();
    final clothes = await SharedPrefsHelper.loadEquippedClothes();
    final buildings = await SharedPrefsHelper.loadEquippedBuildings();
    final vehicles = await SharedPrefsHelper.loadEquippedVehicles();

    // --- 位置情報の読み込み ---
    Offset? avatarPos = await SharedPrefsHelper.loadCharacterPosition(
      'avatar_on_island',
    );

    final characters = await SharedPrefsHelper.loadEquippedCharacters();

    late double screenWidth;
    late double screenHeight;

    // 画面サイズを取得
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    // 位置が画面外にある場合はリセット
    if (avatarPos != null &&
        (avatarPos.dx > screenWidth ||
            avatarPos.dy > screenHeight ||
            avatarPos.dx < 0 ||
            avatarPos.dy < 0)) {
      avatarPos = null; // 範囲外ならリセット
    }

    // 全てのアイテムのパスを結合
    final allItems = [...buildings, ...vehicles];
    final loadedPositions = {};

    for (var itemPath in allItems) {
      // SharedPrefsHelperから各アイテムの位置を読み込む
      final position = await SharedPrefsHelper.loadCharacterPosition(itemPath);
      // 位置が保存されていなかった場合の初期位置を決める
      loadedPositions[itemPath] =
          position ?? Offset(screenWidth / 2, screenHeight * 2 / 3);
    }

    final charactersToLoad = characters.isEmpty
        ? ['assets/images/character_usagi.gif']
        : characters;

    for (var charPath in charactersToLoad) {
      final loadedPos = await SharedPrefsHelper.loadCharacterPosition(
        'island_$charPath',
      );
      loadedPositions[charPath] =
          loadedPos ?? Offset(screenWidth / 2, screenHeight * 2 / 3);
    }

    if (mounted) {
      setState(() {
        _points = loadedPoints;
        _level = loadedLevel;
        _equippedClothesPath = clothes ?? 'assets/images/avatar.png';
        _avatarPosition =
            avatarPos ?? Offset(screenWidth / 2, screenHeight * 2 / 3);
        _equippedBuildings = buildings;
        _equippedVehicles = vehicles;
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
              loadedPositions[itemPath] ??
              Offset(screenWidth / 2, screenHeight * 2 / 3); // 読み込んだ位置を保存
        }
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
              loadedPositions[charPath] ??
              Offset(screenWidth / 2, screenHeight * 2 / 3); // 読み込んだ位置を保存
        }
      });
    }
  }

  // アイテムごとのサイズを返すヘルパーメソッド
  double _getItemSize(String itemPath) {
    if (itemPath.contains('avatar')) return 30.0;
    if (itemPath.contains('clothes_')) return 30.0;
    if (itemPath.contains('character')) return 30.0;
    if (itemPath.contains('building_keisatsu')) return 80.0;
    if (itemPath.contains('building_byoin')) return 80.0;
    if (itemPath.contains('building_kouen')) return 80.0;
    if (itemPath.contains('building_konbini')) return 70.0;
    if (itemPath.contains('building_su-pa-')) return 70.0;
    if (itemPath.contains('building_oshiro')) return 200.0;
    if (itemPath.contains('building')) return 100.0;
    if (itemPath.contains('vehicle_takushi-')) return 50.0;
    if (itemPath.contains('vehicle_kuruma')) return 50.0;
    if (itemPath.contains('vehicle_herikoputa-')) return 50.0;
    if (itemPath.contains('vehicle_bus')) return 50.0;
    if (itemPath.contains('vehicle')) return 100.0;
    // ... 他のアイテムのサイズ ...
    return 60.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            // 島の背景画像を設定します
            decoration: const BoxDecoration(
              image: DecorationImage(
                //「世界の全貌」の背景画像を指定
                image: AssetImage('assets/images/island.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Positioned(
            top: 20.0, // 上からの距離
            left: 20.0, // 左からの距離
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFFF7043).withOpacity(0.9), // 半透明の黒い背景
                    shape: BoxShape.circle, // 形を円にする
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.keyboard_return,
                      size: 40,
                      color: Color(0xFFFFCA28),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),

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
                      width: 200, // ★ 例として横幅を200に設定（画面に合わせて調整してください）
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min, // Rowが中身のサイズに合わせる
                            children: [
                              Text(
                                AppLocalizations.of(
                                  context,
                                )!.levelLabel(widget.currentLevel),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                // ★ 次のレベルまでの必要経験値を計算して表示
                                // _requiredExpForNextLevelは次のレベルに必要な「累計」経験値
                                AppLocalizations.of(context)!.expToNextLevel(
                                  widget.requiredExpForNextLevel -
                                      widget.experience,
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
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

          Positioned(
            top: 25,
            right: 10,
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
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
              ],
            ),
          ),

          // 右側のボタン群
          Positioned(
            top: 80.0, // 上からの距離
            right: 20.0, // 右からの距離
            // Columnでウィジェットを縦に並べます
            child: Column(
              children: [
                // 家具設定ボタン
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFFF7043).withOpacity(0.9), // 半透明の黒い背景
                    shape: BoxShape.circle, // 形を円にする
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.home_work,
                      size: 40,
                      color: Color(0xFFFFCA28),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FurnitureCustomizeScreen(
                            mode: CustomizeMode.island,
                          ),
                        ),
                      ).then((_) {
                        // ★ショップ画面から戻ってきたら、必ずデータを再読み込みする
                        _loadPlacedItems();
                      });
                    },
                  ),
                ),
                // ボタンの間に少し隙間を空けます
                const SizedBox(height: 10),

                // ショップボタン
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFFF7043).withOpacity(0.9), // 半透明の黒い背景
                    shape: BoxShape.circle, // 形を円にする
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.store,
                      size: 40,
                      color: Color(0xFFFFCA28),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShopScreen(
                            currentPoints: _points, // ユーザーの所持ポイント
                            currentLevel: _level, // ユーザーレベルも渡す
                            mode: ShopMode.forIsland, // ★家の中モードを指定
                          ),
                        ),
                      ).then((_) {
                        // ★ショップ画面から戻ってきたら、必ずデータを再読み込みする
                        _loadPlacedItems();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // 配置された建物のリストを表示 (ホーム画面と全く同じ仕組み)
          ..._equippedBuildings.map((itemPath) {
            return DraggableCharacter(
              id: itemPath, // IDとして画像パスを使う
              imagePath: itemPath,
              position: _itemPositionsMap[itemPath] ?? const Offset(100, 150),
              size: _getItemSize(itemPath),
              onPositionChanged: (delta) {
                setState(() {
                  final currentPos =
                      _itemPositionsMap[itemPath] ?? const Offset(100, 150);
                  _itemPositionsMap[itemPath] = currentPos + delta;
                });
              },
            );
          }).toList(),

          // 配置された乗り物のアイテムのリストを表示
          ..._equippedVehicles.map((itemPath) {
            return DraggableCharacter(
              id: itemPath,
              imagePath: itemPath,
              position: _itemPositionsMap[itemPath] ?? const Offset(150, 200),
              size: _getItemSize(itemPath),
              onPositionChanged: (delta) {
                setState(() {
                  final currentPos =
                      _itemPositionsMap[itemPath] ?? const Offset(150, 200);
                  _itemPositionsMap[itemPath] = currentPos + delta;
                });
              },
            );
          }).toList(),

          // --- アバターの表示 ---
          if (_equippedClothesPath != null)
            DraggableCharacter(
              id: 'avatar_on_island',
              imagePath: _equippedClothesPath!,
              position: _avatarPosition,
              size: _getItemSize(_equippedClothesPath!),
              onPositionChanged: (delta) {
                setState(() => _avatarPosition += delta);
              },
            ),

          // ★応援キャラクターの表示と操作
          ..._equippedCharacters.map((charPath) {
            return DraggableCharacter(
              id: 'island_$charPath', // IDとして画像パスを使う
              imagePath: charPath,
              position: _characterPositionsMap[charPath] ?? Offset(490, 190),
              size: _getItemSize(charPath),
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
        ],
      ),
    );
  }
}
