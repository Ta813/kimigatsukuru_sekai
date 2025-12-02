// lib/models/shop_data.dart

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

// ショップに並べるアイテムのデータ構造を定義
class ShopItem {
  final String name;
  final String imagePath;
  final int price;
  final String type; // 'clothes' or 'house'
  final int requiredLevel;
  final bool isIslandOnly;
  final bool isSeaOnly;
  final bool isSkyOnly;

  ShopItem({
    required this.name,
    required this.imagePath,
    required this.price,
    required this.type,
    this.requiredLevel = 1,
    this.isIslandOnly = false,
    this.isSeaOnly = false,
    this.isSkyOnly = false,
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
      case 'ベット':
        return l10n.itemBed;
      case 'いす１':
        return l10n.itemChair1;
      case 'いす２':
        return l10n.itemChair2;
      case 'いす３':
        return l10n.itemChair3;
      case 'キッチン':
        return l10n.itemKitchen;
      case 'ランタン':
        return l10n.itemLantern;
      case 'しょっきだな':
        return l10n.itemCupboard;
      case 'テーブル':
        return l10n.itemTable;
      case 'たな':
        return l10n.itemShelf;
      case 'バナナ':
        return l10n.itemBanana;
      case 'ぶどう':
        return l10n.itemGrapes;
      case 'パイナップル':
        return l10n.itemPineapple;
      case 'リンゴ':
        return l10n.itemApple;
      case 'びん':
        return l10n.itemBottle;
      case 'ぎゅうにゅう':
        return l10n.itemMilk;
      case 'コップ':
        return l10n.itemCup;
      case 'なべ':
        return l10n.itemPot;
      case 'ほん':
        return l10n.itemBook;
      case 'かびん':
        return l10n.itemVase;
      case 'ぬいぐるみ':
        return l10n.itemStuffedAnimal;
      case 'もくば':
        return l10n.itemRockingHorse;
      case 'おもちゃ':
        return l10n.itemToy;
      case 'タブレット':
        return l10n.itemTablet;
      case 'つみき':
        return l10n.itemBlocks;
      case 'いえ１':
        return l10n.itemHouse1;
      case 'いえ２':
        return l10n.itemHouse2;
      case 'いえ３':
        return l10n.itemHouse3;
      case 'いえ４':
        return l10n.itemHouse4;
      case 'いえ５':
        return l10n.itemHouse5;
      case 'いえ６':
        return l10n.itemHouse6;
      case 'いえ７':
        return l10n.itemHouse7;
      case 'コンビニ':
        return l10n.itemConvenienceStore;
      case 'スーパー':
        return l10n.itemSupermarket;
      case 'びょういん':
        return l10n.itemHospital;
      case 'けいさつしょ':
        return l10n.itemPoliceStation;
      case 'こうえん１':
        return l10n.itemPark1;
      case 'こうえん２':
        return l10n.itemPark2;
      case 'おしろ':
        return l10n.itemCastle;
      case 'くるま（しま）':
        return l10n.itemCarIsland;
      case 'タクシー（しま）':
        return l10n.itemTaxiIsland;
      case 'バス（しま）':
        return l10n.itemBusIsland;
      case 'ヘリコプター（しま）':
        return l10n.itemHelicopterIsland;
      case 'ひこうせん１（しま）':
        return l10n.itemAirship1Island;
      case 'ひこうせん２（しま）':
        return l10n.itemAirship2Island;
      case 'あかのドレス':
        return l10n.itemClothesRedDress;
      case 'あおのドレス':
        return l10n.itemClothesBlueDress;
      case 'ピンクドレス':
        return l10n.itemClothesPinkDress;
      case 'くま':
        return l10n.itemClothesBear;
      case 'きょうりゅう':
        return l10n.itemClothesDinosaur;
      case 'おうじさま':
        return l10n.itemClothesPrince;
      case 'ぼうけんしゃ':
        return l10n.itemClothesAdventurer;
      case 'ヒーロー':
        return l10n.itemClothesHero;
      case 'カウボーイ':
        return l10n.itemClothesCowboy;
      case 'せんし':
        return l10n.itemClothesWarrior;
      case 'おんなのこ':
        return l10n.charGirl;
      case 'おひめさま':
        return l10n.charPrincess;
      case 'おうじさま（おうえん）':
        return l10n.charPrince;
      case 'きょうりゅう（おうえん）':
        return l10n.charDinosaur;
      case 'ロボット':
        return l10n.charRobot;
      case 'びん（うみ）':
        return l10n.itemSeaBottle;
      case 'イカリ（うみ）':
        return l10n.itemSeaAnchor;
      case 'かいがら（うみ）':
        return l10n.itemSeaShell;
      case 'こんぶ１（うみ）':
        return l10n.itemSeaKelp1;
      case 'こんぶ２（うみ）':
        return l10n.itemSeaKelp2;
      case 'さんご１（うみ）':
        return l10n.itemSeaCoral1;
      case 'さんご２（うみ）':
        return l10n.itemSeaCoral2;
      case 'たからばこ（うみ）':
        return l10n.itemSeaTreasure;
      case 'トライデント（うみ）':
        return l10n.itemSeaTrident;
      case 'つぼ（うみ）':
        return l10n.itemSeaPot;
      case 'せんすいかん（うみ）':
        return l10n.itemSeaSubmarine;
      case 'ちんぼつせん（うみ）':
        return l10n.itemSeaSunkenShip;
      case 'ふぐ':
        return l10n.livingPufferfish;
      case 'ひとで':
        return l10n.livingStarfish;
      case 'いか':
        return l10n.livingSquid;
      case 'イルカ':
        return l10n.livingDolphin;
      case 'かめ':
        return l10n.livingTurtle;
      case 'かに':
        return l10n.livingCrab;
      case 'クラゲ':
        return l10n.livingJellyfish;
      case 'さかな１':
        return l10n.livingFish1;
      case 'さかな２':
        return l10n.livingFish2;
      case 'さかな３':
        return l10n.livingFish3;
      case 'さかな４':
        return l10n.livingFish4;
      case 'サメ１':
        return l10n.livingShark1;
      case 'サメ２':
        return l10n.livingShark2;
      case 'たつのおとしご':
        return l10n.livingSeahorse;
      case 'ヤドカリ':
        return l10n.livingHermitCrab;
      case 'ふうせん１（そら）':
        return l10n.skyBalloon1;
      case 'ふうせん２（そら）':
        return l10n.skyBalloon2;
      case 'ふうせん３（そら）':
        return l10n.skyBalloon3;
      case 'ふうせん４（そら）':
        return l10n.skyBalloon4;
      case 'くも（そら）':
        return l10n.skyCloud;
      case 'ヘリコプター（そら）':
        return l10n.skyHelicopter;
      case 'ひこうき１（そら）':
        return l10n.skyAirplane1;
      case 'ひこうき２（そら）':
        return l10n.skyAirplane2;
      case 'ひこうき３（そら）':
        return l10n.skyAirplane3;
      case 'ひこうき４（そら）':
        return l10n.skyAirplane4;
      case 'ひこうせん（そら）':
        return l10n.skyAirship;
      case 'ききゅう（そら）':
        return l10n.skyBalloonRide;
      case 'せんとうき１（そら）':
        return l10n.skyFighter1;
      case 'せんとうき２（そら）':
        return l10n.skyFighter2;
      case 'はち（そら）':
        return l10n.skyBee;
      case 'フクロウ（そら）':
        return l10n.skyOwl;
      case 'コウモリ（そら）':
        return l10n.skyBat;
      case 'モモンガ（そら）':
        return l10n.skyFlyingSquirrel;
      case 'オウム（そら）':
        return l10n.skyParrot;
      case 'スズメ（そら）':
        return l10n.skySparrow;
      case 'てんとうむし（そら）':
        return l10n.skyLadybug;
      case 'とんぼ（そら）':
        return l10n.skyDragonfly;
      case 'ツル（そら）':
        return l10n.skyCrane;
      case 'ちょうちょ（そら）':
        return l10n.skyButterfly;
      case 'ワシ（そら）':
        return l10n.skyEagle;
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
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'あかいふく',
    imagePath: 'assets/images/clothes_red.gif',
    price: 50,
    type: 'clothes',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'みどりのふく',
    imagePath: 'assets/images/clothes_green.gif',
    price: 50,
    type: 'clothes',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'ふつうのおうち',
    imagePath: 'assets/images/house_normal.png',
    price: 500,
    type: 'house',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'りっぱなおうち',
    imagePath: 'assets/images/house_rich.png',
    price: 1500,
    type: 'house',
    requiredLevel: 1,
  ),
  // 必要であれば、ここにデフォルトの服と家も追加しておくと便利です
  ShopItem(
    name: 'いつものふく',
    imagePath: 'assets/images/avatar.png',
    price: 0,
    type: 'clothes',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'さいしょのおうち',
    imagePath: 'assets/images/house.png',
    price: 0,
    type: 'house',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'おとこのこ',
    imagePath: 'assets/images/avatar_boy.png',
    price: 0,
    type: 'clothes',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'みどりのふく',
    imagePath: 'assets/images/clothes_boy_green.gif',
    price: 50,
    type: 'clothes',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'あかいふく',
    imagePath: 'assets/images/clothes_boy_red.gif',
    price: 50,
    type: 'clothes',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'みずいろのふく',
    imagePath: 'assets/images/clothes_boy_water.gif',
    price: 50,
    type: 'clothes',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'あかのドレス',
    imagePath: 'assets/images/clothes_dress_red.gif',
    price: 200,
    type: 'clothes',
    requiredLevel: 5,
  ),
  ShopItem(
    name: 'あおのドレス',
    imagePath: 'assets/images/clothes_dress_blue.gif',
    price: 200,
    type: 'clothes',
    requiredLevel: 5,
  ),
  ShopItem(
    name: 'ピンクドレス',
    imagePath: 'assets/images/clothes_dress_pink.gif',
    price: 200,
    type: 'clothes',
    requiredLevel: 5,
  ),
  ShopItem(
    name: 'くま',
    imagePath: 'assets/images/clothes_kuma.gif',
    price: 200,
    type: 'clothes',
    requiredLevel: 5,
  ),
  ShopItem(
    name: 'きょうりゅう',
    imagePath: 'assets/images/clothes_kyoryu.gif',
    price: 200,
    type: 'clothes',
    requiredLevel: 5,
  ),
  ShopItem(
    name: 'おうじさま',
    imagePath: 'assets/images/clothes_boy_oujisama.gif',
    price: 200,
    type: 'clothes',
    requiredLevel: 5,
  ),
  ShopItem(
    name: 'ぼうけんしゃ',
    imagePath: 'assets/images/clothes_boy_boukensya.gif',
    price: 200,
    type: 'clothes',
    requiredLevel: 5,
  ),
  ShopItem(
    name: 'ヒーロー',
    imagePath: 'assets/images/clothes_boy_hiro.gif',
    price: 200,
    type: 'clothes',
    requiredLevel: 5,
  ),
  ShopItem(
    name: 'カウボーイ',
    imagePath: 'assets/images/clothes_boy_kauboy.gif',
    price: 200,
    type: 'clothes',
    requiredLevel: 5,
  ),
  ShopItem(
    name: 'せんし',
    imagePath: 'assets/images/clothes_boy_senshi.gif',
    price: 200,
    type: 'clothes',
    requiredLevel: 5,
  ),
  ShopItem(
    name: 'ウサギ',
    imagePath: 'assets/images/character_usagi.gif',
    price: 300,
    type: 'character',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'ネコ',
    imagePath: 'assets/images/character_neko.gif',
    price: 300,
    type: 'character',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'キリン',
    imagePath: 'assets/images/character_kirin.gif',
    price: 300,
    type: 'character',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'ゾウ',
    imagePath: 'assets/images/character_zou.gif',
    price: 300,
    type: 'character',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'クマ',
    imagePath: 'assets/images/character_kuma.gif',
    price: 300,
    type: 'character',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'パンダ',
    imagePath: 'assets/images/character_panda.gif',
    price: 300,
    type: 'character',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'サル',
    imagePath: 'assets/images/character_saru.gif',
    price: 300,
    type: 'character',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'おんなのこ',
    imagePath: 'assets/images/character_girl.gif',
    price: 450,
    type: 'character',
    requiredLevel: 5,
  ),
  ShopItem(
    name: 'おひめさま',
    imagePath: 'assets/images/character_hime.gif',
    price: 450,
    type: 'character',
    requiredLevel: 5,
  ),
  ShopItem(
    name: 'おうじさま（おうえん）',
    imagePath: 'assets/images/character_ouji.gif',
    price: 450,
    type: 'character',
    requiredLevel: 5,
  ),
  ShopItem(
    name: 'きょうりゅう（おうえん）',
    imagePath: 'assets/images/character_kyoryu.gif',
    price: 450,
    type: 'character',
    requiredLevel: 5,
  ),
  ShopItem(
    name: 'ロボット',
    imagePath: 'assets/images/character_robo.gif',
    price: 450,
    type: 'character',
    requiredLevel: 5,
  ),
  ShopItem(
    name: 'はな１',
    imagePath: 'assets/images/item_hana1.png',
    price: 50,
    type: 'item',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'はな２',
    imagePath: 'assets/images/item_hana2.png',
    price: 50,
    type: 'item',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'はっぱ１',
    imagePath: 'assets/images/item_happa1.png',
    price: 50,
    type: 'item',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'はっぱ２',
    imagePath: 'assets/images/item_happa2.png',
    price: 50,
    type: 'item',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'はちうえ',
    imagePath: 'assets/images/item_hatiue.png',
    price: 50,
    type: 'item',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'くさ1',
    imagePath: 'assets/images/item_kusa1.png',
    price: 50,
    type: 'item',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'くさ2',
    imagePath: 'assets/images/item_kusa2.png',
    price: 50,
    type: 'item',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'き',
    imagePath: 'assets/images/item_ki.png',
    price: 50,
    type: 'item',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'じょうろ',
    imagePath: 'assets/images/item_jouro.png',
    price: 50,
    type: 'item',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'コイン',
    imagePath: 'assets/images/item_koin.png',
    price: 50,
    type: 'item',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'たからばこ',
    imagePath: 'assets/images/item_takarabako.png',
    price: 50,
    type: 'item',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'ボール',
    imagePath: 'assets/images/item_bo-ru.png',
    price: 50,
    type: 'item',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'たいよう',
    imagePath: 'assets/images/item_taiyou.png',
    price: 50,
    type: 'item',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'つき',
    imagePath: 'assets/images/item_tsuki.png',
    price: 50,
    type: 'item',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'ほし',
    imagePath: 'assets/images/item_hoshi.png',
    price: 50,
    type: 'item',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'じてんしゃ',
    imagePath: 'assets/images/item_jitensya.png',
    price: 100,
    type: 'item',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'くるま',
    imagePath: 'assets/images/item_kuruma.png',
    price: 100,
    type: 'item',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'ベット',
    type: 'furniture',
    price: 150,
    imagePath: 'assets/images/house_interior_furniture/bet.png',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'いす１',
    type: 'furniture',
    price: 150,
    imagePath: 'assets/images/house_interior_furniture/isu1.png',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'いす２',
    type: 'furniture',
    price: 150,
    imagePath: 'assets/images/house_interior_furniture/isu2.png',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'いす３',
    type: 'furniture',
    price: 150,
    imagePath: 'assets/images/house_interior_furniture/isu3.png',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'キッチン',
    type: 'furniture',
    price: 150,
    imagePath: 'assets/images/house_interior_furniture/kicchin.png',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'ランタン',
    type: 'furniture',
    price: 150,
    imagePath: 'assets/images/house_interior_furniture/rantan.png',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'しょっきだな',
    type: 'furniture',
    price: 150,
    imagePath: 'assets/images/house_interior_furniture/syokkidana.png',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'テーブル',
    type: 'furniture',
    price: 150,
    imagePath: 'assets/images/house_interior_furniture/table.png',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'たな',
    type: 'furniture',
    price: 150,
    imagePath: 'assets/images/house_interior_furniture/tana.png',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'バナナ',
    type: 'house_item',
    price: 50,
    imagePath: 'assets/images/house_interior_items/banana.png',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'ぶどう',
    type: 'house_item',
    price: 50,
    imagePath: 'assets/images/house_interior_items/budou.png',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'パイナップル',
    type: 'house_item',
    price: 50,
    imagePath: 'assets/images/house_interior_items/painappuru.png',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'リンゴ',
    type: 'house_item',
    price: 50,
    imagePath: 'assets/images/house_interior_items/ringo.png',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'びん',
    type: 'house_item',
    price: 50,
    imagePath: 'assets/images/house_interior_items/bin.png',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'ぎゅうにゅう',
    type: 'house_item',
    price: 50,
    imagePath: 'assets/images/house_interior_items/gyunyubin.png',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'コップ',
    type: 'house_item',
    price: 50,
    imagePath: 'assets/images/house_interior_items/koppu.png',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'なべ',
    type: 'house_item',
    price: 50,
    imagePath: 'assets/images/house_interior_items/nabe.png',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'ボール',
    type: 'house_item',
    price: 50,
    imagePath: 'assets/images/house_interior_items/bool.png',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'ほん',
    type: 'house_item',
    price: 50,
    imagePath: 'assets/images/house_interior_items/hon.png',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'かびん',
    type: 'house_item',
    price: 50,
    imagePath: 'assets/images/house_interior_items/kabin.png',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'ぬいぐるみ',
    type: 'house_item',
    price: 50,
    imagePath: 'assets/images/house_interior_items/kumanonuigurumi.png',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'もくば',
    type: 'house_item',
    price: 50,
    imagePath: 'assets/images/house_interior_items/mokuba.png',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'おもちゃ',
    type: 'house_item',
    price: 50,
    imagePath: 'assets/images/house_interior_items/omotya1.png',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'タブレット',
    type: 'house_item',
    price: 50,
    imagePath: 'assets/images/house_interior_items/taburetto.png',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'たからばこ',
    type: 'house_item',
    price: 50,
    imagePath: 'assets/images/house_interior_items/takarabako.png',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'つみき',
    type: 'house_item',
    price: 50,
    imagePath: 'assets/images/house_interior_items/tumiki.png',
    requiredLevel: 1,
  ),
  ShopItem(
    name: 'いえ１',
    type: 'building',
    price: 150,
    imagePath: 'assets/images/island/building_house1.png',
    requiredLevel: 5,
    isIslandOnly: true,
  ),
  ShopItem(
    name: 'いえ２',
    type: 'building',
    price: 150,
    imagePath: 'assets/images/island/building_house2.png',
    requiredLevel: 5,
    isIslandOnly: true,
  ),
  ShopItem(
    name: 'いえ３',
    type: 'building',
    price: 150,
    imagePath: 'assets/images/island/building_house3.png',
    requiredLevel: 5,
    isIslandOnly: true,
  ),
  ShopItem(
    name: 'いえ４',
    type: 'building',
    price: 150,
    imagePath: 'assets/images/island/building_house4.png',
    requiredLevel: 5,
    isIslandOnly: true,
  ),
  ShopItem(
    name: 'いえ５',
    type: 'building',
    price: 150,
    imagePath: 'assets/images/island/building_house5.png',
    requiredLevel: 5,
    isIslandOnly: true,
  ),
  ShopItem(
    name: 'いえ６',
    type: 'building',
    price: 300,
    imagePath: 'assets/images/island/building_house6.png',
    requiredLevel: 8,
    isIslandOnly: true,
  ),
  ShopItem(
    name: 'いえ７',
    type: 'building',
    price: 300,
    imagePath: 'assets/images/island/building_house7.png',
    requiredLevel: 8,
    isIslandOnly: true,
  ),
  ShopItem(
    name: 'コンビニ',
    type: 'building',
    price: 150,
    imagePath: 'assets/images/island/building_konbini.png',
    requiredLevel: 5,
    isIslandOnly: true,
  ),
  ShopItem(
    name: 'スーパー',
    type: 'building',
    price: 150,
    imagePath: 'assets/images/island/building_su-pa-.png',
    requiredLevel: 5,
    isIslandOnly: true,
  ),
  ShopItem(
    name: 'びょういん',
    type: 'building',
    price: 300,
    imagePath: 'assets/images/island/building_byoin.png',
    requiredLevel: 8,
    isIslandOnly: true,
  ),
  ShopItem(
    name: 'けいさつしょ',
    type: 'building',
    price: 300,
    imagePath: 'assets/images/island/building_keisatsu.png',
    requiredLevel: 8,
    isIslandOnly: true,
  ),
  ShopItem(
    name: 'こうえん１',
    type: 'building',
    price: 150,
    imagePath: 'assets/images/island/building_kouen1.png',
    requiredLevel: 5,
    isIslandOnly: true,
  ),
  ShopItem(
    name: 'こうえん２',
    type: 'building',
    price: 150,
    imagePath: 'assets/images/island/building_kouen2.png',
    requiredLevel: 5,
    isIslandOnly: true,
  ),
  ShopItem(
    name: 'おしろ',
    type: 'building',
    price: 1000,
    imagePath: 'assets/images/island/building_oshiro.png',
    requiredLevel: 10,
    isIslandOnly: true,
  ),
  ShopItem(
    name: 'くるま（しま）',
    type: 'vehicle',
    price: 150,
    imagePath: 'assets/images/island/vehicle_kuruma.png',
    requiredLevel: 5,
    isIslandOnly: true,
  ),
  ShopItem(
    name: 'タクシー（しま）',
    type: 'vehicle',
    price: 150,
    imagePath: 'assets/images/island/vehicle_takushi-.png',
    requiredLevel: 5,
    isIslandOnly: true,
  ),
  ShopItem(
    name: 'バス（しま）',
    type: 'vehicle',
    price: 200,
    imagePath: 'assets/images/island/vehicle_bus.png',
    requiredLevel: 8,
    isIslandOnly: true,
  ),
  ShopItem(
    name: 'ヘリコプター（しま）',
    type: 'vehicle',
    price: 150,
    imagePath: 'assets/images/island/vehicle_herikoputa-.png',
    requiredLevel: 5,
    isIslandOnly: true,
  ),
  ShopItem(
    name: 'ひこうせん１（しま）',
    type: 'vehicle',
    price: 500,
    imagePath: 'assets/images/island/vehicle_hikousen1.png',
    requiredLevel: 8,
    isIslandOnly: true,
  ),
  ShopItem(
    name: 'ひこうせん２（しま）',
    type: 'vehicle',
    price: 500,
    imagePath: 'assets/images/island/vehicle_hikousen2.png',
    requiredLevel: 8,
    isIslandOnly: true,
  ),
  ShopItem(
    name: 'びん（うみ）',
    type: 'sea_item',
    price: 100,
    imagePath: 'assets/images/sea/item_bin.png',
    requiredLevel: 10,
    isSeaOnly: true,
  ),
  ShopItem(
    name: 'イカリ（うみ）',
    type: 'sea_item',
    price: 100,
    imagePath: 'assets/images/sea/item_ikari.png',
    requiredLevel: 10,
    isSeaOnly: true,
  ),
  ShopItem(
    name: 'かいがら（うみ）',
    type: 'sea_item',
    price: 100,
    imagePath: 'assets/images/sea/item_kaigara.png',
    requiredLevel: 10,
    isSeaOnly: true,
  ),
  ShopItem(
    name: 'こんぶ１（うみ）',
    type: 'sea_item',
    price: 100,
    imagePath: 'assets/images/sea/item_konbu1.png',
    requiredLevel: 10,
    isSeaOnly: true,
  ),
  ShopItem(
    name: 'こんぶ２（うみ）',
    type: 'sea_item',
    price: 100,
    imagePath: 'assets/images/sea/item_konbu2.png',
    requiredLevel: 10,
    isSeaOnly: true,
  ),
  ShopItem(
    name: 'さんご１（うみ）',
    type: 'sea_item',
    price: 100,
    imagePath: 'assets/images/sea/item_sango1.png',
    requiredLevel: 10,
    isSeaOnly: true,
  ),
  ShopItem(
    name: 'さんご２（うみ）',
    type: 'sea_item',
    price: 100,
    imagePath: 'assets/images/sea/item_sango2.png',
    requiredLevel: 10,
    isSeaOnly: true,
  ),
  ShopItem(
    name: 'たからばこ（うみ）',
    type: 'sea_item',
    price: 100,
    imagePath: 'assets/images/sea/item_takarabako.png',
    requiredLevel: 10,
    isSeaOnly: true,
  ),
  ShopItem(
    name: 'トライデント（うみ）',
    type: 'sea_item',
    price: 100,
    imagePath: 'assets/images/sea/item_toraidento.png',
    requiredLevel: 10,
    isSeaOnly: true,
  ),
  ShopItem(
    name: 'つぼ（うみ）',
    type: 'sea_item',
    price: 100,
    imagePath: 'assets/images/sea/item_tubo.png',
    requiredLevel: 10,
    isSeaOnly: true,
  ),
  ShopItem(
    name: 'せんすいかん（うみ）',
    type: 'sea_item',
    price: 500,
    imagePath: 'assets/images/sea/item_sensuikan.png',
    requiredLevel: 15,
    isSeaOnly: true,
  ),
  ShopItem(
    name: 'ちんぼつせん（うみ）',
    type: 'sea_item',
    price: 500,
    imagePath: 'assets/images/sea/item_tinbotsusen.png',
    requiredLevel: 15,
    isSeaOnly: true,
  ),
  ShopItem(
    name: 'ふぐ',
    type: 'living',
    price: 200,
    imagePath: 'assets/images/sea/living_fugu.png',
    requiredLevel: 10,
    isSeaOnly: true,
  ),
  ShopItem(
    name: 'ひとで',
    type: 'living',
    price: 200,
    imagePath: 'assets/images/sea/living_hitode.png',
    requiredLevel: 10,
    isSeaOnly: true,
  ),
  ShopItem(
    name: 'いか',
    type: 'living',
    price: 200,
    imagePath: 'assets/images/sea/living_ika.png',
    requiredLevel: 10,
    isSeaOnly: true,
  ),
  ShopItem(
    name: 'イルカ',
    type: 'living',
    price: 200,
    imagePath: 'assets/images/sea/living_iruka.png',
    requiredLevel: 10,
    isSeaOnly: true,
  ),
  ShopItem(
    name: 'かめ',
    type: 'living',
    price: 200,
    imagePath: 'assets/images/sea/living_kame.png',
    requiredLevel: 10,
    isSeaOnly: true,
  ),
  ShopItem(
    name: 'かに',
    type: 'living',
    price: 200,
    imagePath: 'assets/images/sea/living_kani.png',
    requiredLevel: 10,
    isSeaOnly: true,
  ),
  ShopItem(
    name: 'クラゲ',
    type: 'living',
    price: 200,
    imagePath: 'assets/images/sea/living_kurage.png',
    requiredLevel: 10,
    isSeaOnly: true,
  ),
  ShopItem(
    name: 'さかな１',
    type: 'living',
    price: 200,
    imagePath: 'assets/images/sea/living_sakana1.png',
    requiredLevel: 10,
    isSeaOnly: true,
  ),
  ShopItem(
    name: 'さかな２',
    type: 'living',
    price: 200,
    imagePath: 'assets/images/sea/living_sakana2.png',
    requiredLevel: 10,
    isSeaOnly: true,
  ),
  ShopItem(
    name: 'さかな３',
    type: 'living',
    price: 200,
    imagePath: 'assets/images/sea/living_sakana3.png',
    requiredLevel: 10,
    isSeaOnly: true,
  ),
  ShopItem(
    name: 'さかな４',
    type: 'living',
    price: 200,
    imagePath: 'assets/images/sea/living_sakana4.png',
    requiredLevel: 10,
    isSeaOnly: true,
  ),
  ShopItem(
    name: 'サメ１',
    type: 'living',
    price: 200,
    imagePath: 'assets/images/sea/living_same1.png',
    requiredLevel: 10,
    isSeaOnly: true,
  ),
  ShopItem(
    name: 'サメ２',
    type: 'living',
    price: 200,
    imagePath: 'assets/images/sea/living_same2.png',
    requiredLevel: 10,
    isSeaOnly: true,
  ),
  ShopItem(
    name: 'たつのおとしご',
    type: 'living',
    price: 200,
    imagePath: 'assets/images/sea/living_tatsunootoshigo.png',
    requiredLevel: 10,
    isSeaOnly: true,
  ),
  ShopItem(
    name: 'ヤドカリ',
    type: 'living',
    price: 200,
    imagePath: 'assets/images/sea/living_yadokari.png',
    requiredLevel: 10,
    isSeaOnly: true,
  ),
  ShopItem(
    name: 'ふうせん１（そら）',
    type: 'sky_item',
    price: 100,
    imagePath: 'assets/images/sky/item_huusen1.png',
    requiredLevel: 15,
    isSkyOnly: true,
  ),
  ShopItem(
    name: 'ふうせん２（そら）',
    type: 'sky_item',
    price: 100,
    imagePath: 'assets/images/sky/item_huusen2.png',
    requiredLevel: 15,
    isSkyOnly: true,
  ),
  ShopItem(
    name: 'ふうせん３（そら）',
    type: 'sky_item',
    price: 100,
    imagePath: 'assets/images/sky/item_huusen3.png',
    requiredLevel: 15,
    isSkyOnly: true,
  ),
  ShopItem(
    name: 'ふうせん４（そら）',
    type: 'sky_item',
    price: 100,
    imagePath: 'assets/images/sky/item_huusen4.png',
    requiredLevel: 15,
    isSkyOnly: true,
  ),
  ShopItem(
    name: 'くも（そら）',
    type: 'sky_item',
    price: 100,
    imagePath: 'assets/images/sky/item_kumo.png',
    requiredLevel: 15,
    isSkyOnly: true,
  ),
  ShopItem(
    name: 'ヘリコプター（そら）',
    type: 'sky_item',
    price: 200,
    imagePath: 'assets/images/sky/item_herikoputa-.png',
    requiredLevel: 15,
    isSkyOnly: true,
  ),
  ShopItem(
    name: 'ひこうき１（そら）',
    type: 'sky_item',
    price: 200,
    imagePath: 'assets/images/sky/item_hikouki1.png',
    requiredLevel: 15,
    isSkyOnly: true,
  ),
  ShopItem(
    name: 'ひこうき２（そら）',
    type: 'sky_item',
    price: 200,
    imagePath: 'assets/images/sky/item_hikouki2.png',
    requiredLevel: 15,
    isSkyOnly: true,
  ),
  ShopItem(
    name: 'ひこうき３（そら）',
    type: 'sky_item',
    price: 400,
    imagePath: 'assets/images/sky/item_hikouki3.png',
    requiredLevel: 18,
    isSkyOnly: true,
  ),
  ShopItem(
    name: 'ひこうき４（そら）',
    type: 'sky_item',
    price: 400,
    imagePath: 'assets/images/sky/item_hikouki4.png',
    requiredLevel: 18,
    isSkyOnly: true,
  ),
  ShopItem(
    name: 'ひこうせん（そら）',
    type: 'sky_item',
    price: 200,
    imagePath: 'assets/images/sky/item_hikousen.png',
    requiredLevel: 15,
    isSkyOnly: true,
  ),
  ShopItem(
    name: 'ききゅう（そら）',
    type: 'sky_item',
    price: 200,
    imagePath: 'assets/images/sky/item_kikyuu.png',
    requiredLevel: 15,
    isSkyOnly: true,
  ),
  ShopItem(
    name: 'せんとうき１（そら）',
    type: 'sky_item',
    price: 300,
    imagePath: 'assets/images/sky/item_sentouki1.png',
    requiredLevel: 15,
    isSkyOnly: true,
  ),
  ShopItem(
    name: 'せんとうき２（そら）',
    type: 'sky_item',
    price: 500,
    imagePath: 'assets/images/sky/item_sentouki2.png',
    requiredLevel: 18,
    isSkyOnly: true,
  ),
  ShopItem(
    name: 'はち（そら）',
    type: 'sky_living',
    price: 200,
    imagePath: 'assets/images/sky/living_hati.png',
    requiredLevel: 15,
    isSkyOnly: true,
  ),
  ShopItem(
    name: 'フクロウ（そら）',
    type: 'sky_living',
    price: 200,
    imagePath: 'assets/images/sky/living_hukurou.png',
    requiredLevel: 15,
    isSkyOnly: true,
  ),
  ShopItem(
    name: 'コウモリ（そら）',
    type: 'sky_living',
    price: 200,
    imagePath: 'assets/images/sky/living_koumori.png',
    requiredLevel: 15,
    isSkyOnly: true,
  ),
  ShopItem(
    name: 'モモンガ（そら）',
    type: 'sky_living',
    price: 200,
    imagePath: 'assets/images/sky/living_momonga.png',
    requiredLevel: 15,
    isSkyOnly: true,
  ),
  ShopItem(
    name: 'オウム（そら）',
    type: 'sky_living',
    price: 200,
    imagePath: 'assets/images/sky/living_oumu.png',
    requiredLevel: 15,
    isSkyOnly: true,
  ),
  ShopItem(
    name: 'スズメ（そら）',
    type: 'sky_living',
    price: 200,
    imagePath: 'assets/images/sky/living_suzume.png',
    requiredLevel: 15,
    isSkyOnly: true,
  ),
  ShopItem(
    name: 'てんとうむし（そら）',
    type: 'sky_living',
    price: 200,
    imagePath: 'assets/images/sky/living_tentoumushi.png',
    requiredLevel: 15,
    isSkyOnly: true,
  ),
  ShopItem(
    name: 'とんぼ（そら）',
    type: 'sky_living',
    price: 200,
    imagePath: 'assets/images/sky/living_tonbo.png',
    requiredLevel: 15,
    isSkyOnly: true,
  ),
  ShopItem(
    name: 'ツル（そら）',
    type: 'sky_living',
    price: 200,
    imagePath: 'assets/images/sky/living_tsuru.png',
    requiredLevel: 15,
    isSkyOnly: true,
  ),
  ShopItem(
    name: 'ちょうちょ（そら）',
    type: 'sky_living',
    price: 200,
    imagePath: 'assets/images/sky/living_tyoutyo.png',
    requiredLevel: 15,
    isSkyOnly: true,
  ),
  ShopItem(
    name: 'ワシ（そら）',
    type: 'sky_living',
    price: 200,
    imagePath: 'assets/images/sky/living_washi.png',
    requiredLevel: 15,
    isSkyOnly: true,
  ),
];
