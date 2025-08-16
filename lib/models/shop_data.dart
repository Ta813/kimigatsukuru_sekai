// lib/models/shop_data.dart

// ショップに並べるアイテムのデータ構造を定義
class ShopItem {
  final String name;
  final String imagePath;
  final int price;
  final String type; // 'clothes' or 'house'

  ShopItem({
    required this.name,
    required this.imagePath,
    required this.price,
    required this.type,
  });
}

// ショップのカタログデータ
final List<ShopItem> shopItems = [
  ShopItem(
    name: 'あおいふく',
    imagePath: 'assets/images/clothes_blue.png',
    price: 50,
    type: 'clothes',
  ),
  ShopItem(
    name: 'あかいふく',
    imagePath: 'assets/images/clothes_red.png',
    price: 50,
    type: 'clothes',
  ),
  ShopItem(
    name: 'みどりのふく',
    imagePath: 'assets/images/clothes_green.png',
    price: 50,
    type: 'clothes',
  ),
  ShopItem(
    name: 'ふつうのおうち',
    imagePath: 'assets/images/house_normal.png',
    price: 100,
    type: 'house',
  ),
  ShopItem(
    name: 'りっぱなおうち',
    imagePath: 'assets/images/house_rich.png',
    price: 200,
    type: 'house',
  ),
  // 必要であれば、ここにデフォルトの服と家も追加しておくと便利です
  ShopItem(
    name: 'いつものふく',
    imagePath: 'assets/images/avatar.png',
    price: 0,
    type: 'clothes',
  ),
  ShopItem(
    name: 'さいしょのおうち',
    imagePath: 'assets/images/house.png',
    price: 0,
    type: 'house',
  ),
];
