// lib/models/shop_data.dart

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

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

  String getDisplayName(BuildContext context) {
    // AppLocalizationsを使って、翻訳された文字列を返します
    final l10n = AppLocalizations.of(context)!;
    switch (name) {
      case 'あおいふく':
        return l10n.itemClothesBlue;
      case 'あかいふく':
        return l10n.itemClothesRed;
      case 'みどりのふく':
        return l10n.itemClothesGreen;
      case 'みずいろのふく':
        return l10n.itemClothesLightBlue;
      case 'ふつうのおうち':
        return l10n.itemHouseNormal;
      case 'りっぱなおうち':
        return l10n.itemHouseGrand;
      case 'いつものふく':
        return l10n.itemClothesDefault;
      case 'さいしょのおうち':
        return l10n.itemHouseDefault;
      case 'おとこのこ':
        return l10n.itemAvatarBoy;
      case 'ウサギ':
        return l10n.charRabbit;
      case 'ネコ':
        return l10n.charCat;
      case 'キリン':
        return l10n.charGiraffe;
      case 'ゾウ':
        return l10n.charElephant;
      case 'クマ':
        return l10n.charBear;
      case 'パンダ':
        return l10n.charPanda;
      case 'サル':
        return l10n.charMonkey;
      case 'はな１':
        return l10n.itemFlower1;
      case 'はな２':
        return l10n.itemFlower2;
      case 'はっぱ１':
        return l10n.itemLeaf1;
      case 'はっぱ２':
        return l10n.itemLeaf2;
      case 'はちうえ':
        return l10n.itemPotPlant;
      case 'くさ1':
        return l10n.itemGrass1;
      case 'くさ2':
        return l10n.itemGrass2;
      case 'き':
        return l10n.itemTree;
      case 'じょうろ':
        return l10n.itemWateringCan;
      case 'コイン':
        return l10n.itemCoin;
      case 'たからばこ':
        return l10n.itemTreasureChest;
      case 'ボール':
        return l10n.itemBall;
      case 'たいよう':
        return l10n.itemSun;
      case 'つき':
        return l10n.itemMoon;
      case 'ほし':
        return l10n.itemStar;
      case 'じてんしゃ':
        return l10n.itemBicycle;
      case 'くるま':
        return l10n.itemCar;
      default:
        return name;
    }
  }
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
    name: 'おとこのこ',
    imagePath: 'assets/images/avatar_boy.png',
    price: 0,
    type: 'clothes',
  ),
  ShopItem(
    name: 'みどりのふく',
    imagePath: 'assets/images/clothes_boy_green.gif',
    price: 50,
    type: 'clothes',
  ),
  ShopItem(
    name: 'あかいふく',
    imagePath: 'assets/images/clothes_boy_red.gif',
    price: 50,
    type: 'clothes',
  ),
  ShopItem(
    name: 'みずいろのふく',
    imagePath: 'assets/images/clothes_boy_water.gif',
    price: 50,
    type: 'clothes',
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
  ShopItem(
    name: 'はな１',
    imagePath: 'assets/images/item_hana1.png',
    price: 50,
    type: 'item',
  ),
  ShopItem(
    name: 'はな２',
    imagePath: 'assets/images/item_hana2.png',
    price: 50,
    type: 'item',
  ),
  ShopItem(
    name: 'はっぱ１',
    imagePath: 'assets/images/item_happa1.png',
    price: 50,
    type: 'item',
  ),
  ShopItem(
    name: 'はっぱ２',
    imagePath: 'assets/images/item_happa2.png',
    price: 50,
    type: 'item',
  ),
  ShopItem(
    name: 'はちうえ',
    imagePath: 'assets/images/item_hatiue.png',
    price: 50,
    type: 'item',
  ),
  ShopItem(
    name: 'くさ1',
    imagePath: 'assets/images/item_kusa1.png',
    price: 50,
    type: 'item',
  ),
  ShopItem(
    name: 'くさ2',
    imagePath: 'assets/images/item_kusa2.png',
    price: 50,
    type: 'item',
  ),
  ShopItem(
    name: 'き',
    imagePath: 'assets/images/item_ki.png',
    price: 50,
    type: 'item',
  ),
  ShopItem(
    name: 'じょうろ',
    imagePath: 'assets/images/item_jouro.png',
    price: 50,
    type: 'item',
  ),
  ShopItem(
    name: 'コイン',
    imagePath: 'assets/images/item_koin.png',
    price: 50,
    type: 'item',
  ),
  ShopItem(
    name: 'たからばこ',
    imagePath: 'assets/images/item_takarabako.png',
    price: 50,
    type: 'item',
  ),
  ShopItem(
    name: 'ボール',
    imagePath: 'assets/images/item_bo-ru.png',
    price: 50,
    type: 'item',
  ),
  ShopItem(
    name: 'たいよう',
    imagePath: 'assets/images/item_taiyou.png',
    price: 50,
    type: 'item',
  ),
  ShopItem(
    name: 'つき',
    imagePath: 'assets/images/item_tsuki.png',
    price: 50,
    type: 'item',
  ),
  ShopItem(
    name: 'ほし',
    imagePath: 'assets/images/item_hoshi.png',
    price: 50,
    type: 'item',
  ),
  ShopItem(
    name: 'じてんしゃ',
    imagePath: 'assets/images/item_jitensya.png',
    price: 100,
    type: 'item',
  ),
  ShopItem(
    name: 'くるま',
    imagePath: 'assets/images/item_kuruma.png',
    price: 100,
    type: 'item',
  ),
];
