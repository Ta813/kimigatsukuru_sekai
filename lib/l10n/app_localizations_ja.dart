// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'きみがつくる世界';

  @override
  String get customizeTitle => 'きせかえ・もようがえ';

  @override
  String get customizeTabClothes => 'きせかえ';

  @override
  String get customizeTabHouse => 'おうち';

  @override
  String get customizeTabCharacter => '応援キャラ';

  @override
  String get customizeTabItem => 'アイテム';

  @override
  String get guideWelcomeTitle => 'ようこそ！';

  @override
  String get guideWelcomeDesc => 'これから「きみがつくる世界」の遊び方を説明するね！';

  @override
  String get guideSettingsTitle => '① おうちのひと設定「左上の⚙マーク」';

  @override
  String get guideSettingsDesc => 'やくそくの追加や編集など、\nおうちのひとが詳しい設定をするためのボタンだよ。\n最初にここで「やくそく」をこどもと一緒に決めてみてね！';

  @override
  String get guideNextPromiseTitle => '② つぎのやくそく「下のボード」';

  @override
  String get guideNextPromiseDesc => '次にやるべきやくそくが表示されるよ。\n「はじめる」を押して挑戦しよう！';

  @override
  String get guidePromiseBoardTitle => '③ やくそくボード「右の📄マーク」';

  @override
  String get guidePromiseBoardDesc => '今日のやくそくの一覧が見れるよ。\n「できた！」マークを集めるのが目標だ！';

  @override
  String get guidePointsTitle => '④ ポイント「右上の★」';

  @override
  String get guidePointsDesc => 'ここにやくそくを達成すると、ポイントがもらえるよ！\nたくさん集めて、ごほうびと交換しよう。';

  @override
  String get guideShopTitle => '⑤ ごほうびショップ「右の🏠マーク」';

  @override
  String get guideShopDesc => '貯めたポイントで、新しい服やおうちと交換できる場所だよ！';

  @override
  String get guideCustomizeTitle => '⑥ きせかえ・もようがえ「右の☺マーク」';

  @override
  String get guideCustomizeDesc => '買ったアイテムで、アバターの服やおうちを変えられるよ！\n自分だけの世界をつくろう。';

  @override
  String get guideHelpTitle => '⑦ ヘルプ「左の？マーク」';

  @override
  String get guideHelpDesc => 'わからなくなったら、このボタンを押して、\nもう一度この説明を見れるよ。';

  @override
  String get emergency => 'きんきゅう！';

  @override
  String get nextPromise => 'つぎのやくそく';

  @override
  String get points => 'ポイント';

  @override
  String get didNotDo => 'やらなかった';

  @override
  String get startNow => 'すぐにはじめる';

  @override
  String get allPromisesDone => '今日のやくそくは、すべておわりました！✨';

  @override
  String get startPromise => 'はじめる';

  @override
  String get lockIncorrectAnswer => 'ざんねん、ちがうみたい';

  @override
  String get cancel => 'やめる';

  @override
  String get promiseBoard => 'やくそくボード';

  @override
  String get noRegularPromises => '定例のやくそくがまだありません';

  @override
  String get untitled => '名称未設定';

  @override
  String get rouletteCongrats => 'おめでとう！\nポイント2ばい！';

  @override
  String get rouletteTryAgain => 'またチャレンジしてね';

  @override
  String get rouletteTitle => 'ポイントアップチャンス！';

  @override
  String get rouletteQuestion => 'ルーレットをまわす？';

  @override
  String get rouletteWin => 'あたり → ';

  @override
  String get rouletteLose => '\nはずれ → ';

  @override
  String get rouletteSpin => 'まわす！';

  @override
  String shopConfirmExchange(int itemPrice) {
    return '$itemPriceポイントつかって、こうかんしますか？';
  }

  @override
  String get quitAction => 'やめる';

  @override
  String shopExchangeSuccess(String itemName) {
    return '$itemNameとこうかんしたよ！';
  }

  @override
  String get exchange => 'こうかんする';

  @override
  String get shopNotEnoughPoints => 'ポイントがたりないみたい…';

  @override
  String get shopTitle => 'ごほうびショップ';

  @override
  String get itemPurchased => 'こうかんずみ';

  @override
  String get confirmation => 'かくにん';

  @override
  String askIfFinished(String promiseTitle) {
    return '$promiseTitle は、ちゃんとおわったかな？';
  }

  @override
  String get notYet => 'まだだよ';

  @override
  String get yesFinished => 'おわったよ！';

  @override
  String challengingPromise(String promiseTitle) {
    return '$promiseTitle に挑戦中！';
  }

  @override
  String pointsHalf(String points) {
    return 'おしい！ポイントは$pointsになるよ！';
  }

  @override
  String pointsChance(int points) {
    return '$pointsポイント ゲットのチャンス！';
  }

  @override
  String get finished => 'おわった！';

  @override
  String get addRegularPromiseTitle => 'あたらしい定例やくそく';

  @override
  String get editRegularPromiseTitle => 'やくそくを編集';

  @override
  String get promiseNameLabel => 'やくそくの名前';

  @override
  String get promiseNameHint => 'やくそくの名前を入力してください';

  @override
  String get startTimeLabel => '開始時間';

  @override
  String get durationLabel => '時間（分）';

  @override
  String get registerButton => 'とうろくする';

  @override
  String get adviceScreenTitle => 'やくそく設定のヒント';

  @override
  String get adviceMainTitle => '「できた！」を増やすためのヒント💡';

  @override
  String get advice1Title => 'やくそくは、お子さんと一緒に決める';

  @override
  String get advice1Desc => '「何を」「いつまでに」「何ポイントで」やるか、お子さんと一緒に話しながら決めてみましょう。自分で決めたルールだからこそ、挑戦する気持ちが芽生えます。';

  @override
  String get advice2Title => '最初は「かんたん」から始めよう';

  @override
  String get advice2Desc => 'まずは、お子さんが絶対にクリアできる簡単なやくそくから始めましょう。「できた！」という成功体験を積み重ねることが、自信に繋がります。';

  @override
  String get advice3Title => '時間は「少しだけ多め」に設定';

  @override
  String get advice3Desc => '「急がなきゃ！」と焦らせるのではなく、「時間内にできた！」という達成感を味わえるように、最初のうちは挑戦時間を少しだけ長めに設定してあげるのがコツです。';

  @override
  String get advice4Title => 'ポイントは「特別感」を大切に';

  @override
  String get advice4Desc => '難しいやくそくほど、もらえるポイントを少しだけ高く設定してみましょう。「このミッションは特別だ！」と感じることで、お子さんの挑戦意欲を引き出します。';

  @override
  String get advice5Title => '一番のごほうびは「言葉」です';

  @override
  String get advice5Desc => 'アプリでのポイントも大切ですが、やくそくを達成したときには、ぜひ「よくできたね！」「すごい！」と、直接言葉で褒めてあげてください。それが、お子さんにとって最高のエネルギーになります。';

  @override
  String emergencyPromiseSet(String promiseTitle) {
    return '「$promiseTitle」を緊急やくそくに設定しました。';
  }

  @override
  String get emergencyPromiseSettingsTitle => '緊急のやくそく設定';

  @override
  String get promiseNameExampleHint => 'やくそくの名前（例: おもちゃのかたづけ）';

  @override
  String get setThisPromiseButton => 'このやくそくをセットする';

  @override
  String get parentScreenTitle => 'おやが見る画面';

  @override
  String get readFirstButton => '最初にお読みください';

  @override
  String get regularPromiseSettingsButton => '定例のやくそく設定';

  @override
  String get emergencyPromiseSettingsButton => '緊急のやくそく設定';

  @override
  String promiseDeleted(String promiseTitle) {
    return '「$promiseTitle」を削除しました。';
  }

  @override
  String promiseAdded(String promiseTitle) {
    return '「$promiseTitle」を追加しました。';
  }

  @override
  String promiseUpdated(String promiseTitle) {
    return '「$promiseTitle」を更新しました。';
  }

  @override
  String get regularPromiseSettingsTitle => '定例のやくそく設定';

  @override
  String get timeLabel => '時間';

  @override
  String get itemClothesBlue => 'あおいふく';

  @override
  String get itemClothesRed => 'あかいふく';

  @override
  String get itemClothesGreen => 'みどりのふく';

  @override
  String get itemClothesLightBlue => 'みずいろのふく';

  @override
  String get itemHouseNormal => 'ふつうのおうち';

  @override
  String get itemHouseGrand => 'りっぱなおうち';

  @override
  String get itemClothesDefault => 'いつものふく';

  @override
  String get itemHouseDefault => 'さいしょのおうち';

  @override
  String get itemAvatarBoy => 'おとこのこ';

  @override
  String get charRabbit => 'ウサギ';

  @override
  String get charCat => 'ネコ';

  @override
  String get charGiraffe => 'キリン';

  @override
  String get charElephant => 'ゾウ';

  @override
  String get charBear => 'クマ';

  @override
  String get charPanda => 'パンダ';

  @override
  String get charMonkey => 'サル';

  @override
  String get itemFlower1 => 'はな１';

  @override
  String get itemFlower2 => 'はな２';

  @override
  String get itemLeaf1 => 'はっぱ１';

  @override
  String get itemLeaf2 => 'はっぱ２';

  @override
  String get itemPotPlant => 'はちうえ';

  @override
  String get itemGrass1 => 'くさ1';

  @override
  String get itemGrass2 => 'くさ2';

  @override
  String get itemTree => 'き';

  @override
  String get itemWateringCan => 'じょうろ';

  @override
  String get itemCoin => 'コイン';

  @override
  String get itemTreasureChest => 'たからばこ';

  @override
  String get itemBall => 'ボール';

  @override
  String get itemSun => 'たいよう';

  @override
  String get itemMoon => 'つき';

  @override
  String get itemStar => 'ほし';

  @override
  String get itemBicycle => 'じてんしゃ';

  @override
  String get itemCar => 'くるま';

  @override
  String get promiseDefault1Title => 'あさごはん';

  @override
  String get promiseDefault2Title => 'ようちえんのじゅんび';

  @override
  String get promiseDefault3Title => 'おふろじゅんび';

  @override
  String get promiseDefault4Title => 'よるごはん';

  @override
  String get promiseDefault5Title => 'はみがき';

  @override
  String get promiseDefault6Title => 'ねるじゅんび';

  @override
  String get settingsTitle => '設定';

  @override
  String get languageSetting => '言語設定';
}
