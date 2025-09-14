// lib/screens/house_interior/house_interior_screen.dart

import 'package:flutter/material.dart';
import 'package:kimigatsukuru_sekai/helpers/shared_prefs_helper.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/draggable_character.dart';
import 'furniture_customize_screen.dart';
import 'shop_screen.dart';

class HouseInteriorScreen extends StatefulWidget {
  // ★ホーム画面から、現在装備中の家の画像パスを受け取る
  final String equippedHousePath;
  final int currentPoints;

  const HouseInteriorScreen({
    super.key,
    required this.equippedHousePath,
    required this.currentPoints,
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
  String _equippedClothesPath = 'assets/images/avatar.png'; // デフォルトの服
  Offset _avatarPosition = const Offset(100, 150); // デフォルトの位置
  String _getInteriorBackgroundImage(String houseAssetPath) {
    switch (houseAssetPath) {
      case 'assets/images/house.png': // さいしょのおうち
        return 'assets/images/house_interior/default_interior.png';
      case 'assets/images/house_normal.png': // ふつうのおうち
        return 'assets/images/house_interior/normal_interior.png';
      case 'assets/images/house_rich.png': // りっぱなおうち
        return 'assets/images/house_interior/rich_interior.png';
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
    final furniture = await SharedPrefsHelper.loadEquippedFurniture();
    final houseItems = await SharedPrefsHelper.loadEquippedHouseItems();
    // アバターの服を読み込む
    final clothes = await SharedPrefsHelper.loadEquippedClothes();
    // アバターの「家の中での」位置を読み込む
    Offset? position = await SharedPrefsHelper.loadCharacterPosition(
      'avatar_in_house',
    );

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

    setState(() {
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
      _equippedClothesPath =
          clothes ?? 'assets/images/avatar.png'; // 読み込んだ服、なければデフォルト
      _avatarPosition = position ?? const Offset(100, 150); // 読み込んだ位置、なければデフォルト
    });
  }

  // ★ ホーム画面から持ってきたアイテムサイズ決定ロジック (必要に応じて調整)
  double _getItemSize(String itemPath) {
    if (itemPath.contains('/house_interior_items/banana.png')) return 30.0;
    if (itemPath.contains('/house_interior_items/takarabako.png')) return 60.0;
    if (itemPath.contains('/house_interior_items/mokuba.png')) return 60.0;
    if (itemPath.contains('/house_interior_items/kumanonuigurumi.png'))
      return 60.0;
    if (itemPath.contains('/house_interior_items/')) return 40.0;
    if (itemPath.contains('/house_interior_furniture/rantan.png')) return 70.0;
    return 100.0; // デフォルトサイズ
  }

  @override
  Widget build(BuildContext context) {
    // ★受け取った家のパスから、表示すべき背景画像を決定
    final backgroundImagePath = _getInteriorBackgroundImage(
      widget.equippedHousePath,
    );

    final bool areItemsPlaced =
        _equippedFurniture.isNotEmpty || _equippedHouseItems.isNotEmpty;

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

          if (!areItemsPlaced)
            Center(
              child: Text(
                AppLocalizations.of(context)!.roomIsEmpty,
                style: const TextStyle(
                  color: Colors.white, // 背景に合わせてテキストの色を調整
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(blurRadius: 4, color: Colors.black54),
                  ], // 影をつけて読みやすく
                ),
                textAlign: TextAlign.center,
              ),
            ),

          // 左上の「ホームに戻る」ボタン
          Positioned(
            top: 20.0, // 上からの距離
            left: 20.0, // 左からの距離
            child: Container(
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
                        '${widget.currentPoints}', // ポイント数を表示
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

          // ★ 配置された家具のリストを表示 (ホーム画面と全く同じ仕組み)
          ..._equippedFurniture.map((itemPath) {
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

          // ★ 配置された家のアイテムのリストを表示
          ..._equippedHouseItems.map((itemPath) {
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

          DraggableCharacter(
            id: 'avatar_in_house', // ★ 家の中専用のユニークID
            imagePath: _equippedClothesPath,
            position: _avatarPosition,
            size: 80.0, // ホーム画面と同じサイズ感
            onPositionChanged: (delta) {
              setState(() {
                _avatarPosition += delta;
              });
            },
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
                      Icons.chair,
                      size: 40,
                      color: Color(0xFFFFCA28),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const FurnitureCustomizeScreen(),
                        ),
                      ).then((_) {
                        // ★ショップ画面から戻ってきたら、必ずデータを再読み込みする
                        _loadItemsAndPositions();
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
                            currentPoints: widget.currentPoints, // ユーザーの所持ポイント
                            mode: ShopMode.forHouse, // ★家の中モードを指定
                          ),
                        ),
                      ).then((_) {
                        // ★ショップ画面から戻ってきたら、必ずデータを再読み込みする
                        _loadItemsAndPositions();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
