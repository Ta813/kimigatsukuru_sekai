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
  String get guideBgmButtonTitle => '⑦ BGM「右の♪マーク」';

  @override
  String get guideBgmButtonDesc => 'ここを押すと、好きな音楽を選べるよ。楽しい音楽で気分を変えてみよう！';

  @override
  String get guideWorldMapButtonTitle => '⑧ 外の世界「右の🌎マーク」';

  @override
  String get guideWorldMapButtonDesc => 'このボタンを押すと、世界の全体図が見られるよ。レベルが上がると行ける場所が増えるかも！';

  @override
  String get guideHelpTitle => '⑨ ヘルプ「左の？マーク」';

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
  String get rouletteTryAgain => 'またチャレンジしてね\n';

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

  @override
  String get longPressToEnter => '長押しで入れるよ！';

  @override
  String get insideTheHouse => 'おうちの中';

  @override
  String get roomIsEmpty => 'まだ何もないみたい…\nこれからどんなお部屋にしようかな？';

  @override
  String get furniture => 'かぐ';

  @override
  String get houseItems => 'いえのアイテム';

  @override
  String get itemBed => 'ベット';

  @override
  String get itemChair1 => 'いす１';

  @override
  String get itemChair2 => 'いす２';

  @override
  String get itemChair3 => 'いす３';

  @override
  String get itemKitchen => 'キッチン';

  @override
  String get itemLantern => 'ランタン';

  @override
  String get itemCupboard => 'しょっきだな';

  @override
  String get itemTable => 'テーブル';

  @override
  String get itemShelf => 'たな';

  @override
  String get itemBanana => 'バナナ';

  @override
  String get itemGrapes => 'ぶどう';

  @override
  String get itemPineapple => 'パイナップル';

  @override
  String get itemApple => 'リンゴ';

  @override
  String get itemBottle => 'びん';

  @override
  String get itemMilk => 'ぎゅうにゅう';

  @override
  String get itemCup => 'コップ';

  @override
  String get itemPot => 'なべ';

  @override
  String get itemBowl => 'ボール';

  @override
  String get itemBook => 'ほん';

  @override
  String get itemVase => 'かびん';

  @override
  String get itemStuffedAnimal => 'ぬいぐるみ';

  @override
  String get itemRockingHorse => 'もくば';

  @override
  String get itemToy => 'おもちゃ';

  @override
  String get itemTablet => 'タブレット';

  @override
  String get itemBlocks => 'つみき';

  @override
  String get bgmMain => 'いつものBGM';

  @override
  String get bgmFun => 'たのしいBGM';

  @override
  String get bgmCute => 'かわいいBGM';

  @override
  String get bgmRelaxing => 'ゆったりなBGM';

  @override
  String get bgmEnergetic => 'げんきなBGM';

  @override
  String get bgmSparkly => 'キラキラなBGM';

  @override
  String get bgmNone => 'BGMなし';

  @override
  String get focusBgmDefault => 'デフォルト';

  @override
  String get focusBgmCute => '可愛いBGM';

  @override
  String get focusBgmCool => 'カッコいいBGM';

  @override
  String get focusBgmHurry => '急ぐBGM';

  @override
  String get focusBgmNature => '自然のBGM';

  @override
  String get focusBgmRelaxing => '心地よいBGM';

  @override
  String get selectBgmTitle => 'BGMをえらぶ';

  @override
  String get focusBgmSettingTitle => 'タイマーの音楽（集中BGM）';

  @override
  String get normalBgm => 'ふだんのBGM';

  @override
  String get focusBgm => 'しゅうちゅうBGM';

  @override
  String get passcodeIncorrect => 'パスワードが違います';

  @override
  String get passcodeEnter4Digit => '4桁のパスワードを入力';

  @override
  String get cancelAction => 'キャンセル';

  @override
  String get setAction => '設定する';

  @override
  String get lockMethod => 'ロック方法';

  @override
  String get multiplication => '掛け算';

  @override
  String get fourDigitPasscode => '4桁パスワード';

  @override
  String get setPasscode => 'パスワードを設定';

  @override
  String get notSet => '未設定';

  @override
  String get supportThisApp => 'このアプリを支援する';

  @override
  String get supportEncouragement => '今後の開発の励みになります！';

  @override
  String get supportPageOpenError => 'ページを開けませんでした';

  @override
  String get timerExpChance => 'EXP 3 ゲットのチャンス！';

  @override
  String get timerExpFailure => 'EXPは 1 になるよ！';

  @override
  String get buildings => 'たてもの';

  @override
  String get vehicles => 'のりもの';

  @override
  String get houseSettings => 'いえのせってい';

  @override
  String get islandSettings => 'しまのせってい';

  @override
  String levelLabel(int level) {
    return 'レベル $level';
  }

  @override
  String expToNextLevel(int exp) {
    return 'あと$exp EXP';
  }

  @override
  String get levelUpTitle => 'レベルアップ！';

  @override
  String levelUpMessage(int newLevel) {
    return 'レベルが $newLevel にあがった！';
  }

  @override
  String unlockedAtLevel(int level) {
    return 'レベル $level で解放';
  }

  @override
  String get worldMapGuideTitle1 => 'ようこそ！';

  @override
  String get worldMapGuideContent1 => 'ここは世界の全体図だよ！\nレベルが上がると行ける場所が増えるんだ。';

  @override
  String get worldMapGuideTitle2 => 'まんなかの島';

  @override
  String get worldMapGuideContent2 => 'レベル5になったら、ここをタップして島に入れるようになるんだ。';

  @override
  String get worldMapGuideTitle3 => 'まだまだ広がる世界';

  @override
  String get worldMapGuideContent3 => '下にある海や、ずーっと上の宇宙にも、いつか行けるようになるかも…？\nお楽しみに！';

  @override
  String get seaAreaLocked => 'レベル10になると入れるようになります！';

  @override
  String get skyAreaLocked => 'レベル15になると入れるようになります！';

  @override
  String get islandLocked => 'レベル5になると入れるようになります！';

  @override
  String get itemHouse1 => 'いえ１';

  @override
  String get itemHouse2 => 'いえ２';

  @override
  String get itemHouse3 => 'いえ３';

  @override
  String get itemHouse4 => 'いえ４';

  @override
  String get itemHouse5 => 'いえ５';

  @override
  String get itemHouse6 => 'いえ６';

  @override
  String get itemHouse7 => 'いえ７';

  @override
  String get itemConvenienceStore => 'コンビニ';

  @override
  String get itemSupermarket => 'スーパー';

  @override
  String get itemHospital => 'びょういん';

  @override
  String get itemPoliceStation => 'けいさつしょ';

  @override
  String get itemPark1 => 'こうえん１';

  @override
  String get itemPark2 => 'こうえん２';

  @override
  String get itemCastle => 'おしろ';

  @override
  String get itemCarIsland => 'くるま';

  @override
  String get itemTaxiIsland => 'タクシー';

  @override
  String get itemBusIsland => 'バス';

  @override
  String get itemHelicopterIsland => 'ヘリコプター';

  @override
  String get itemAirship1Island => 'ひこうせん１';

  @override
  String get itemAirship2Island => 'ひこうせん２';

  @override
  String get itemClothesRedDress => 'あかのドレス';

  @override
  String get itemClothesBlueDress => 'あおのドレス';

  @override
  String get itemClothesPinkDress => 'ピンクドレス';

  @override
  String get itemClothesBear => 'くま';

  @override
  String get itemClothesDinosaur => 'きょうりゅう';

  @override
  String get itemClothesPrince => 'おうじさま';

  @override
  String get itemClothesAdventurer => 'ぼうけんしゃ';

  @override
  String get itemClothesHero => 'ヒーロー';

  @override
  String get itemClothesCowboy => 'カウボーイ';

  @override
  String get itemClothesWarrior => 'せんし';

  @override
  String get charGirl => 'おんなのこ';

  @override
  String get charPrincess => 'おひめさま';

  @override
  String get charPrince => 'おうじさま';

  @override
  String get charDinosaur => 'きょうりゅう';

  @override
  String get charRobot => 'ロボット';

  @override
  String get disclosureTitle => 'データの取り扱いについて';

  @override
  String get disclosureMessage => 'このアプリは、広告の表示とアプリのパフォーマンス改善を目的として、インストール済みのアプリに関する情報や、デバイスの広告IDを収集・共有することがあります。';

  @override
  String get disagreeAction => '同意しない';

  @override
  String get agreeAction => '同意して利用する';

  @override
  String get nameSettingHint => '名前を設定すると、応援のときに名前を呼んでもらえるよ！';

  @override
  String get nameAlreadyExists => '同じ名前と敬称の組み合わせはすでに登録されています。';

  @override
  String get childNameSettingsTitle => 'お子様の名前設定';

  @override
  String get enterNameHint => '名前を入力';

  @override
  String get addAction => '追加';

  @override
  String get registeredNamesLabel => '登録中の名前:';

  @override
  String get noNamesRegistered => 'まだ名前が登録されていません。';

  @override
  String get seaItems => 'うみのアイテム';

  @override
  String get seaCreatures => 'うみのいきもの';

  @override
  String get seaSettings => 'うみのせってい';

  @override
  String get itemSeaBottle => 'びん';

  @override
  String get itemSeaAnchor => 'イカリ';

  @override
  String get itemSeaShell => 'かいがら';

  @override
  String get itemSeaKelp1 => 'こんぶ１';

  @override
  String get itemSeaKelp2 => 'こんぶ２';

  @override
  String get itemSeaCoral1 => 'さんご１';

  @override
  String get itemSeaCoral2 => 'さんご２';

  @override
  String get itemSeaTreasure => 'たからばこ';

  @override
  String get itemSeaTrident => 'トライデント';

  @override
  String get itemSeaPot => 'つぼ';

  @override
  String get itemSeaSubmarine => 'せんすいかん';

  @override
  String get itemSeaSunkenShip => 'ちんぼつせん';

  @override
  String get livingPufferfish => 'ふぐ';

  @override
  String get livingStarfish => 'ひとで';

  @override
  String get livingSquid => 'いか';

  @override
  String get livingDolphin => 'イルカ';

  @override
  String get livingTurtle => 'かめ';

  @override
  String get livingCrab => 'かに';

  @override
  String get livingJellyfish => 'クラゲ';

  @override
  String get livingFish1 => 'さかな１';

  @override
  String get livingFish2 => 'さかな２';

  @override
  String get livingFish3 => 'さかな３';

  @override
  String get livingFish4 => 'さかな４';

  @override
  String get livingShark1 => 'サメ１';

  @override
  String get livingShark2 => 'サメ２';

  @override
  String get livingSeahorse => 'たつのおとしご';

  @override
  String get livingHermitCrab => 'ヤドカリ';

  @override
  String get skip => 'スキップ';

  @override
  String get skyItems => 'そらのアイテム';

  @override
  String get skyCreatures => 'そらのいきもの';

  @override
  String get skyBalloon1 => 'ふうせん１';

  @override
  String get skyBalloon2 => 'ふうせん２';

  @override
  String get skyBalloon3 => 'ふうせん３';

  @override
  String get skyBalloon4 => 'ふうせん４';

  @override
  String get skyCloud => 'くも';

  @override
  String get skyHelicopter => 'ヘリコプター';

  @override
  String get skyAirplane1 => 'ひこうき１';

  @override
  String get skyAirplane2 => 'ひこうき２';

  @override
  String get skyAirplane3 => 'ひこうき３';

  @override
  String get skyAirplane4 => 'ひこうき４';

  @override
  String get skyAirship => 'ひこうせん';

  @override
  String get skyBalloonRide => 'ききゅう';

  @override
  String get skyFighter1 => 'せんとうき１';

  @override
  String get skyFighter2 => 'せんとうき２';

  @override
  String get skyBee => 'はち';

  @override
  String get skyOwl => 'フクロウ';

  @override
  String get skyBat => 'コウモリ';

  @override
  String get skyFlyingSquirrel => 'モモンガ';

  @override
  String get skyParrot => 'オウム';

  @override
  String get skySparrow => 'スズメ';

  @override
  String get skyLadybug => 'てんとうむし';

  @override
  String get skyDragonfly => 'とんぼ';

  @override
  String get skyCrane => 'ツル';

  @override
  String get skyButterfly => 'ちょうちょ';

  @override
  String get skyEagle => 'ワシ';

  @override
  String get spaceItems => 'うちゅうのアイテム';

  @override
  String get spaceCreatures => 'うちゅうのいきもの';

  @override
  String get spaceMeteorite1 => 'いんせき１';

  @override
  String get spaceMeteorite2 => 'いんせき２';

  @override
  String get spaceMeteorite3 => 'いんせき３';

  @override
  String get spaceSatellite1 => 'えいせい１';

  @override
  String get spaceSatellite2 => 'えいせい２';

  @override
  String get spacePlanet1 => 'わくせい１';

  @override
  String get spacePlanet2 => 'わくせい２';

  @override
  String get spacePlanet3 => 'わくせい３';

  @override
  String get spaceRocket => 'ロケット';

  @override
  String get spaceShuttle => 'シャトル';

  @override
  String get spaceUfo => 'ユーフォー';

  @override
  String get spaceAlien1 => 'うちゅうじん１';

  @override
  String get spaceAlien2 => 'うちゅうじん２';

  @override
  String get spaceAlien3 => 'うちゅうじん３';

  @override
  String get spaceAlien4 => 'うちゅうじん４';

  @override
  String get spaceAlien5 => 'うちゅうじん５';

  @override
  String get spaceAlien6 => 'うちゅうじん６';

  @override
  String get spaceAlien7 => 'うちゅうじん７';

  @override
  String get spaceAlien8 => 'うちゅうじん８';

  @override
  String get spaceAlien9 => 'うちゅうじん９';

  @override
  String get skySettings => 'そらのせってい';

  @override
  String get spaceSettings => 'うちゅうのせってい';
}
