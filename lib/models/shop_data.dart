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
    imagePath: 'assets/images/clothes_blue.gif',
    price: 50,
    type: 'clothes',
  ),
  ShopItem(
    name: 'あかいふく',
    imagePath: 'assets/images/clothes_red.gif',
    price: 50,
    type: 'clothes',
  ),
  ShopItem(
    name: 'みどりのふく',
    imagePath: 'assets/images/clothes_green.gif',
    price: 50,
    type: 'clothes',
  ),
  ShopItem(
    name: 'ふつうのおうち',
    imagePath: 'assets/images/house_normal.png',
    price: 500,
    type: 'house',
  ),
  ShopItem(
    name: 'りっぱなおうち',
    imagePath: 'assets/images/house_rich.png',
    price: 1500,
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
  ShopItem(
    name: 'ウサギ',
    imagePath: 'assets/images/character_usagi.gif',
    price: 300,
    type: 'character',
  ),
  ShopItem(
    name: 'ネコ',
    imagePath: 'assets/images/character_neko.gif',
    price: 300,
    type: 'character',
  ),
  ShopItem(
    name: 'キリン',
    imagePath: 'assets/images/character_kirin.gif',
    price: 300,
    type: 'character',
  ),
  ShopItem(
    name: 'ゾウ',
    imagePath: 'assets/images/character_zou.gif',
    price: 300,
    type: 'character',
  ),
  ShopItem(
    name: 'クマ',
    imagePath: 'assets/images/character_kuma.gif',
    price: 300,
    type: 'character',
  ),
  ShopItem(
    name: 'パンダ',
    imagePath: 'assets/images/character_panda.gif',
    price: 300,
    type: 'character',
  ),
  ShopItem(
    name: 'サル',
    imagePath: 'assets/images/character_saru.gif',
    price: 300,
    type: 'character',
  ),
];
