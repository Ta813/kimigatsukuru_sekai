// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Kids Habit Hero';

  @override
  String get customizeTitle => 'Customize';

  @override
  String get customizeTabClothes => 'Clothes';

  @override
  String get customizeTabHouse => 'House';

  @override
  String get customizeTabCharacter => 'Supporter';

  @override
  String get customizeTabItem => 'Items';

  @override
  String get guideWelcomeTitle => 'First, let\'s play like a child!';

  @override
  String get guideWelcomeDesc => 'Experience for yourself how \'Promises\' work!\nI\'ve prepared a \'Trial Promise\' on the bottom bar.\nPress \'Start\' right away and try playing like a child!';

  @override
  String get guideSettingsTitle => 'Grown-up Settings (Top-left ⚙️ icon)';

  @override
  String get guideSettingsDesc => 'This is where grown-ups can add or edit promises.\nLet\'s decide on some \'Promises\' together with your child here first!';

  @override
  String get tutorialShopTitle => 'You got 100 points! ✨';

  @override
  String get tutorialShopDesc => 'You\'ve saved up points!\nLet\'s go buy items at the \'Shop\' using the 🏠 button on the right!';

  @override
  String get tutorialCustomizeTitle => 'You got an item! 🎁';

  @override
  String get tutorialCustomizeDesc => 'You got an item!\nNext, using the ☺ button on the right, let\'s decorate your room in \'Customize\'!';

  @override
  String get tutorialParentSetupTitle => 'All ready! 🎉';

  @override
  String get tutorialParentSetupDesc => 'We\'re all set to make them happy!\nLet\'s set up the daily \'Promises\' right away and get started!';

  @override
  String get tutorialMoveTitle => 'Let\'s Move Them! ✨';

  @override
  String get tutorialMoveDesc => 'The items you picked in Dress-up/Customize can be moved with your finger!\nPut them wherever you like.';

  @override
  String get tutorialBtnStart => 'Let\'s do this!';

  @override
  String get tutorialBtnShop => 'Go to Shop!';

  @override
  String get tutorialBtnCustomize => 'Go Customize!';

  @override
  String get tutorialBtnMove => 'Got it!';

  @override
  String get tutorialBtnParent => 'Create a Promise!';

  @override
  String get guideTrialPromiseTitle => 'Moms and Dads, try it out! ✨';

  @override
  String get guideTrialPromiseDesc => 'Experience for yourself how \'Promises\' work!\nI\'ve prepared a \'Trial Promise\' on the bottom bar.\nPress \'Start\' right away and try playing like a child!';

  @override
  String get guideNextPromiseTitle => 'Next Promise (Bottom board)';

  @override
  String get guideNextPromiseDesc => 'The next \'Promise\' to challenge will be shown here.\nPress \'Start\' and keep challenging them!';

  @override
  String get guidePromiseBoardTitle => 'Promise Board (Right 📄 icon)';

  @override
  String get guidePromiseBoardDesc => 'You can see a list of today\'s promises here.\nYour goal is to collect the \'Done!\' check marks!';

  @override
  String get guidePointsTitle => 'Points (Top-right ★)';

  @override
  String get guidePointsDesc => 'When you complete a promise, you get points here!\nCollect a lot and exchange them for rewards.';

  @override
  String get guideShopTitle => 'Reward Shop (Right 🏠 icon)';

  @override
  String get guideShopDesc => 'This is where you can exchange the points you\'ve saved for new clothes and houses!';

  @override
  String get guideCustomizeTitle => 'Customize (Right ☺ icon)';

  @override
  String get guideCustomizeDesc => 'You can change your avatar\'s clothes and house with the items you\'ve bought.\nCreate your very own world!';

  @override
  String get guideBgmButtonTitle => 'BGM (♪ Icon on the Right)';

  @override
  String get guideBgmButtonDesc => 'Press here to choose your favorite music. Change the mood with a fun song!';

  @override
  String get guideWorldMapButtonTitle => 'Outer World (🌎 Icon on the Right)';

  @override
  String get guideWorldMapButtonDesc => 'Press this button to see the whole world map. As you level up, you might unlock new places to go!';

  @override
  String get emergency => 'EMERGENCY!';

  @override
  String get nextPromise => 'Next Promise';

  @override
  String get points => 'Points';

  @override
  String get didNotDo => 'Didn\'t Do';

  @override
  String get startNow => 'Start Now';

  @override
  String get allPromisesDone => 'All of today\'s promises are done! ✨';

  @override
  String get startPromise => 'Start';

  @override
  String get lockIncorrectAnswer => 'Sorry, that\'s not right';

  @override
  String get cancel => 'Cancel';

  @override
  String get promiseBoard => 'Promise Board';

  @override
  String get noRegularPromises => 'No promises yet';

  @override
  String get untitled => 'Untitled';

  @override
  String get rouletteCongrats => 'Congratulations!\n2x Points!';

  @override
  String get rouletteTryAgain => 'Try Again Next Time\n';

  @override
  String get rouletteTitle => 'Point Up Chance!';

  @override
  String get rouletteQuestion => 'Spin the roulette?';

  @override
  String get rouletteWin => 'Win → ';

  @override
  String get rouletteLose => '\nLose → ';

  @override
  String get rouletteSpin => 'Spin!';

  @override
  String shopConfirmExchange(int itemPrice) {
    return 'Exchange for $itemPrice points?';
  }

  @override
  String get quitAction => 'Cancel';

  @override
  String shopExchangeSuccess(String itemName) {
    return 'You got the $itemName!';
  }

  @override
  String get exchange => 'Exchange';

  @override
  String get shopNotEnoughPoints => 'Not enough points...';

  @override
  String get shopTitle => 'Reward Shop';

  @override
  String get itemPurchased => 'Purchased';

  @override
  String get confirmation => 'Confirmation';

  @override
  String askIfFinished(String promiseTitle) {
    return 'Are you really done with $promiseTitle?';
  }

  @override
  String get notYet => 'Not Yet';

  @override
  String get yesFinished => 'All Done!';

  @override
  String challengingPromise(String promiseTitle) {
    return 'Challenging $promiseTitle!';
  }

  @override
  String pointsHalf(String points) {
    return 'So close! You get $points points!';
  }

  @override
  String pointsChance(int points) {
    return 'Chance to get $points points!';
  }

  @override
  String get finished => 'Finished!';

  @override
  String get addRegularPromiseTitle => 'New Promise';

  @override
  String get editRegularPromiseTitle => 'Edit Promise';

  @override
  String get promiseNameLabel => 'Promise Name';

  @override
  String get promiseNameHint => 'Please enter a name for the promise';

  @override
  String get startTimeLabel => 'Start Time';

  @override
  String get durationLabel => 'Duration (minutes)';

  @override
  String get registerButton => 'Register';

  @override
  String get adviceScreenTitle => 'Tips for Promise Settings';

  @override
  String get adviceMainTitle => 'Tips for Increasing \"I did it!\" Moments 💡';

  @override
  String get advice1Title => 'Decide on Promises Together with Your Child';

  @override
  String get advice1Desc => 'Try deciding \"what,\" \"by when,\" and \"for how many points\" together with your child. Having rules they helped create sparks their motivation to take on the challenge.';

  @override
  String get advice2Title => 'Start with \"Easy\" Tasks First';

  @override
  String get advice2Desc => 'Begin with simple promises your child can definitely complete. Building up successful experiences of \"I did it!\" leads to confidence.';

  @override
  String get advice3Title => 'Set the Time a \"Little Generously\"';

  @override
  String get advice3Desc => 'Instead of making them rush, the key is to set the challenge time a little longer at first so they can feel the accomplishment of \"I did it within the time!\"';

  @override
  String get advice4Title => 'Treat Points as Something \"Special\"';

  @override
  String get advice4Desc => 'For more difficult promises, try setting the points a little higher. Feeling that \"this mission is special!\" will boost your child\'s motivation to try.';

  @override
  String get advice5Title => 'The Best Reward is \"Praise\"';

  @override
  String get advice5Desc => 'While points in the app are important, when your child completes a promise, please praise them directly with words like \"Well done!\" or \"Amazing!\". That will be their greatest source of energy.';

  @override
  String emergencyPromiseSet(String promiseTitle) {
    return 'Set \"$promiseTitle\" as the emergency promise.';
  }

  @override
  String get emergencyPromiseSettingsTitle => 'Emergency Promise Settings';

  @override
  String get promiseNameExampleHint => 'Promise Name (e.g., Tidy up toys)';

  @override
  String get setThisPromiseButton => 'Set This Promise';

  @override
  String get parentScreenTitle => 'Parent Mode';

  @override
  String get readFirstButton => 'Read Me First';

  @override
  String get regularPromiseSettingsButton => 'Promise Settings';

  @override
  String get emergencyPromiseSettingsButton => 'Emergency Promise Settings';

  @override
  String promiseDeleted(String promiseTitle) {
    return 'Deleted \"$promiseTitle\".';
  }

  @override
  String promiseAdded(String promiseTitle) {
    return 'Added \"$promiseTitle\".';
  }

  @override
  String promiseUpdated(String promiseTitle) {
    return 'Updated \"$promiseTitle\".';
  }

  @override
  String get regularPromiseSettingsTitle => 'Promise Settings';

  @override
  String get timeLabel => 'Time';

  @override
  String get itemClothesBlue => 'Blue Clothes';

  @override
  String get itemClothesRed => 'Red Clothes';

  @override
  String get itemClothesGreen => 'Green Clothes';

  @override
  String get itemClothesLightBlue => 'Light Blue Clothes';

  @override
  String get itemHouseNormal => 'Normal House';

  @override
  String get itemHouseGrand => 'Grand House';

  @override
  String get itemClothesDefault => 'Default Clothes';

  @override
  String get itemHouseDefault => 'First House';

  @override
  String get itemAvatarBoy => 'Boy';

  @override
  String get charRabbit => 'Rabbit';

  @override
  String get charCat => 'Cat';

  @override
  String get charGiraffe => 'Giraffe';

  @override
  String get charElephant => 'Elephant';

  @override
  String get charBear => 'Bear';

  @override
  String get charPanda => 'Panda';

  @override
  String get charMonkey => 'Monkey';

  @override
  String get itemFlower1 => 'Flower 1';

  @override
  String get itemFlower2 => 'Flower 2';

  @override
  String get itemLeaf1 => 'Leaf 1';

  @override
  String get itemLeaf2 => 'Leaf 2';

  @override
  String get itemPotPlant => 'Potted Plant';

  @override
  String get itemGrass1 => 'Grass 1';

  @override
  String get itemGrass2 => 'Grass 2';

  @override
  String get itemTree => 'Tree';

  @override
  String get itemWateringCan => 'Watering Can';

  @override
  String get itemCoin => 'Coin';

  @override
  String get itemTreasureChest => 'Treasure Chest';

  @override
  String get itemBall => 'Ball';

  @override
  String get itemSun => 'Sun';

  @override
  String get itemMoon => 'Moon';

  @override
  String get itemStar => 'Star';

  @override
  String get itemBicycle => 'Bicycle';

  @override
  String get itemCar => 'Car';

  @override
  String get promiseDefault1Title => 'Breakfast';

  @override
  String get promiseDefault2Title => 'Brushing Teeth (Morning)';

  @override
  String get promiseDefault3Title => 'Getting Dressed';

  @override
  String get promiseDefault4Title => 'Bath';

  @override
  String get promiseDefault5Title => 'Dinner';

  @override
  String get promiseDefault6Title => 'Brushing Teeth (Night)';

  @override
  String get promiseDefault7Title => 'Bedtime';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageSetting => 'Language';

  @override
  String get longPressToEnter => 'Long press to enter!';

  @override
  String get insideTheHouse => 'Inside the House';

  @override
  String get roomIsEmpty => 'Looks like there\'s nothing here yet...\nWhat kind of room should we make?';

  @override
  String get furniture => 'Furniture';

  @override
  String get houseItems => 'House Items';

  @override
  String get itemBed => 'Bed';

  @override
  String get itemChair1 => 'Chair 1';

  @override
  String get itemChair2 => 'Chair 2';

  @override
  String get itemChair3 => 'Chair 3';

  @override
  String get itemKitchen => 'Kitchen';

  @override
  String get itemLantern => 'Lantern';

  @override
  String get itemCupboard => 'Cupboard';

  @override
  String get itemTable => 'Table';

  @override
  String get itemShelf => 'Shelf';

  @override
  String get itemBanana => 'Banana';

  @override
  String get itemGrapes => 'Grapes';

  @override
  String get itemPineapple => 'Pineapple';

  @override
  String get itemApple => 'Apple';

  @override
  String get itemBottle => 'Bottle';

  @override
  String get itemMilk => 'Milk';

  @override
  String get itemCup => 'Cup';

  @override
  String get itemPot => 'Pot';

  @override
  String get itemBowl => 'Bowl';

  @override
  String get itemBook => 'Book';

  @override
  String get itemVase => 'Vase';

  @override
  String get itemStuffedAnimal => 'Stuffed Animal';

  @override
  String get itemRockingHorse => 'Rocking Horse';

  @override
  String get itemToy => 'Toy';

  @override
  String get itemTablet => 'Tablet';

  @override
  String get itemBlocks => 'Building Blocks';

  @override
  String get bgmMain => 'Default BGM';

  @override
  String get bgmFun => 'Fun BGM';

  @override
  String get bgmCute => 'Cute BGM';

  @override
  String get bgmRelaxing => 'Relaxing BGM';

  @override
  String get bgmEnergetic => 'Energetic BGM';

  @override
  String get bgmSparkly => 'Sparkly BGM';

  @override
  String get bgmNone => 'No BGM';

  @override
  String get focusBgmDefault => 'Default';

  @override
  String get focusBgmCute => 'Cute BGM';

  @override
  String get focusBgmCool => 'Cool BGM';

  @override
  String get focusBgmHurry => 'Hurry BGM';

  @override
  String get focusBgmNature => 'Nature BGM';

  @override
  String get focusBgmRelaxing => 'Comfortable BGM';

  @override
  String get selectBgmTitle => 'Select BGM';

  @override
  String get focusBgmSettingTitle => 'Timer Music (Focus BGM)';

  @override
  String get normalBgm => 'Normal BGM';

  @override
  String get focusBgm => 'Focus BGM';

  @override
  String get passcodeIncorrect => 'Incorrect Passcode';

  @override
  String get passcodeEnter4Digit => 'Enter 4-digit Passcode';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get setAction => 'Set';

  @override
  String get lockMethod => 'Lock Method';

  @override
  String get multiplication => 'Multiplication';

  @override
  String get fourDigitPasscode => '4-Digit Passcode';

  @override
  String get setPasscode => 'Set Passcode';

  @override
  String get notSet => 'Not Set';

  @override
  String get supportThisApp => 'Support this app';

  @override
  String get supportEncouragement => 'Your support encourages future development!';

  @override
  String get supportPageOpenError => 'Could not open the page';

  @override
  String get timerExpChance => 'A chance at 3 EXP!';

  @override
  String get timerExpFailure => 'You\'ll get 1 EXP!';

  @override
  String get buildings => 'Buildings';

  @override
  String get vehicles => 'Vehicles';

  @override
  String get houseSettings => 'House Settings';

  @override
  String get islandSettings => 'Island Settings';

  @override
  String levelLabel(int level) {
    return 'Level $level';
  }

  @override
  String expToNextLevel(int exp) {
    return '$exp next EXP';
  }

  @override
  String get levelUpTitle => 'Level Up!';

  @override
  String levelUpMessage(int newLevel) {
    return 'You reached level $newLevel!🎉\nThere might be something good if you go to the shop✨';
  }

  @override
  String unlockedAtLevel(int level) {
    return 'Unlocks at Level $level';
  }

  @override
  String get worldMapGuideTitle1 => 'Welcome!';

  @override
  String get worldMapGuideContent1 => 'This is the world map!\nAs you level up, you\'ll unlock more places to go.';

  @override
  String get worldMapGuideTitle2 => 'The Central Island';

  @override
  String get worldMapGuideContent2 => 'Once you reach Level 5, you\'ll be able to tap here to enter the island.';

  @override
  String get worldMapGuideTitle3 => 'A Widening World';

  @override
  String get worldMapGuideContent3 => 'You might even be able to visit the sea below or the space far above someday...?\nStay tuned!';

  @override
  String get seaAreaLocked => 'You\'ll be able to enter at Level 10!';

  @override
  String get skyAreaLocked => 'You\'ll be able to enter at Level 15!';

  @override
  String get islandLocked => 'You\'ll be able to enter at Level 5!';

  @override
  String get itemHouse1 => 'House 1';

  @override
  String get itemHouse2 => 'House 2';

  @override
  String get itemHouse3 => 'House 3';

  @override
  String get itemHouse4 => 'House 4';

  @override
  String get itemHouse5 => 'House 5';

  @override
  String get itemHouse6 => 'House 6';

  @override
  String get itemHouse7 => 'House 7';

  @override
  String get itemConvenienceStore => 'Convenience Store';

  @override
  String get itemSupermarket => 'Supermarket';

  @override
  String get itemHospital => 'Hospital';

  @override
  String get itemPoliceStation => 'Police Station';

  @override
  String get itemPark1 => 'Park 1';

  @override
  String get itemPark2 => 'Park 2';

  @override
  String get itemCastle => 'Castle';

  @override
  String get itemCarIsland => 'Car';

  @override
  String get itemTaxiIsland => 'Taxi';

  @override
  String get itemBusIsland => 'Bus';

  @override
  String get itemHelicopterIsland => 'Helicopter';

  @override
  String get itemAirship1Island => 'Airship 1';

  @override
  String get itemAirship2Island => 'Airship 2';

  @override
  String get itemClothesRedDress => 'Red Dress';

  @override
  String get itemClothesBlueDress => 'Blue Dress';

  @override
  String get itemClothesPinkDress => 'Pink Dress';

  @override
  String get itemClothesBear => 'Bear Costume';

  @override
  String get itemClothesDinosaur => 'Dinosaur Costume';

  @override
  String get itemClothesPrince => 'Prince Outfit';

  @override
  String get itemClothesAdventurer => 'Adventurer Outfit';

  @override
  String get itemClothesHero => 'Hero Costume';

  @override
  String get itemClothesCowboy => 'Cowboy Outfit';

  @override
  String get itemClothesWarrior => 'Warrior Armor';

  @override
  String get charGirl => 'Girl';

  @override
  String get charPrincess => 'Princess';

  @override
  String get charPrince => 'Prince';

  @override
  String get charDinosaur => 'Dinosaur';

  @override
  String get charRobot => 'Robot';

  @override
  String get disclosureTitle => 'About Your Data';

  @override
  String get disclosureMessage => 'To show ads and improve app performance, this app may collect and share information about installed apps and your device\'s Advertising ID.';

  @override
  String get disagreeAction => 'Disagree';

  @override
  String get agreeAction => 'Agree and Continue';

  @override
  String get nameSettingHint => 'Set a name so the character can cheer for you!';

  @override
  String get nameSetting => 'Name Setting';

  @override
  String get nameAlreadyExists => 'This name and honorific combination is already registered.';

  @override
  String get backButtonLabel => 'Back';

  @override
  String get childNameLabel => 'Name';

  @override
  String get childNameSettingsTitle => 'Child\'s Name Settings';

  @override
  String get enterNameHint => 'Enter name';

  @override
  String get addAction => 'Add';

  @override
  String get editAction => 'Edit';

  @override
  String get deleteAction => 'Delete';

  @override
  String get howToUseLabel => 'How to Use';

  @override
  String get promiseSettingsLabel => 'Settings';

  @override
  String get registeredNamesLabel => 'Registered Names:';

  @override
  String get noNamesRegistered => 'No names registered yet.';

  @override
  String get seaItems => 'Sea Items';

  @override
  String get seaCreatures => 'Sea Creatures';

  @override
  String get seaSettings => 'Sea Settings';

  @override
  String get itemSeaBottle => 'Bottle';

  @override
  String get itemSeaAnchor => 'Anchor';

  @override
  String get itemSeaShell => 'Seashell';

  @override
  String get itemSeaKelp1 => 'Kelp 1';

  @override
  String get itemSeaKelp2 => 'Kelp 2';

  @override
  String get itemSeaCoral1 => 'Coral 1';

  @override
  String get itemSeaCoral2 => 'Coral 2';

  @override
  String get itemSeaTreasure => 'Treasure Chest';

  @override
  String get itemSeaTrident => 'Trident';

  @override
  String get itemSeaPot => 'Pot';

  @override
  String get itemSeaSubmarine => 'Submarine';

  @override
  String get itemSeaSunkenShip => 'Sunken Ship';

  @override
  String get livingPufferfish => 'Pufferfish';

  @override
  String get livingStarfish => 'Starfish';

  @override
  String get livingSquid => 'Squid';

  @override
  String get livingDolphin => 'Dolphin';

  @override
  String get livingTurtle => 'Turtle';

  @override
  String get livingCrab => 'Crab';

  @override
  String get livingJellyfish => 'Jellyfish';

  @override
  String get livingFish1 => 'Fish 1';

  @override
  String get livingFish2 => 'Fish 2';

  @override
  String get livingFish3 => 'Fish 3';

  @override
  String get livingFish4 => 'Fish 4';

  @override
  String get livingShark1 => 'Shark 1';

  @override
  String get livingShark2 => 'Shark 2';

  @override
  String get livingSeahorse => 'Seahorse';

  @override
  String get livingHermitCrab => 'Hermit Crab';

  @override
  String get skip => 'Skip';

  @override
  String get skyItems => 'Sky Items';

  @override
  String get skyCreatures => 'Sky Creatures';

  @override
  String get skyBalloon1 => 'Balloon 1';

  @override
  String get skyBalloon2 => 'Balloon 2';

  @override
  String get skyBalloon3 => 'Balloon 3';

  @override
  String get skyBalloon4 => 'Balloon 4';

  @override
  String get skyCloud => 'Cloud';

  @override
  String get skyHelicopter => 'Helicopter';

  @override
  String get skyAirplane1 => 'Airplane 1';

  @override
  String get skyAirplane2 => 'Airplane 2';

  @override
  String get skyAirplane3 => 'Airplane 3';

  @override
  String get skyAirplane4 => 'Airplane 4';

  @override
  String get skyAirship => 'Airship';

  @override
  String get skyBalloonRide => 'Hot Air Balloon';

  @override
  String get skyFighter1 => 'Fighter Jet 1';

  @override
  String get skyFighter2 => 'Fighter Jet 2';

  @override
  String get skyBee => 'Bee';

  @override
  String get skyOwl => 'Owl';

  @override
  String get skyBat => 'Bat';

  @override
  String get skyFlyingSquirrel => 'Flying Squirrel';

  @override
  String get skyParrot => 'Parrot';

  @override
  String get skySparrow => 'Sparrow';

  @override
  String get skyLadybug => 'Ladybug';

  @override
  String get skyDragonfly => 'Dragonfly';

  @override
  String get skyCrane => 'Crane';

  @override
  String get skyButterfly => 'Butterfly';

  @override
  String get skyEagle => 'Eagle';

  @override
  String get spaceItems => 'Space Items';

  @override
  String get spaceCreatures => 'Space Creatures';

  @override
  String get spaceMeteorite1 => 'Meteorite 1';

  @override
  String get spaceMeteorite2 => 'Meteorite 2';

  @override
  String get spaceMeteorite3 => 'Meteorite 3';

  @override
  String get spaceSatellite1 => 'Satellite 1';

  @override
  String get spaceSatellite2 => 'Satellite 2';

  @override
  String get spacePlanet1 => 'Planet 1';

  @override
  String get spacePlanet2 => 'Planet 2';

  @override
  String get spacePlanet3 => 'Planet 3';

  @override
  String get spaceRocket => 'Rocket';

  @override
  String get spaceShuttle => 'Space Shuttle';

  @override
  String get spaceUfo => 'UFO';

  @override
  String get spaceAlien1 => 'Alien 1';

  @override
  String get spaceAlien2 => 'Alien 2';

  @override
  String get spaceAlien3 => 'Alien 3';

  @override
  String get spaceAlien4 => 'Alien 4';

  @override
  String get spaceAlien5 => 'Alien 5';

  @override
  String get spaceAlien6 => 'Alien 6';

  @override
  String get spaceAlien7 => 'Alien 7';

  @override
  String get spaceAlien8 => 'Alien 8';

  @override
  String get spaceAlien9 => 'Alien 9';

  @override
  String get skySettings => 'Sky Settings';

  @override
  String get spaceSettings => 'Space Settings';

  @override
  String get samplePromiseTitle => 'Please Set Up Promises!';

  @override
  String get samplePromiseDesc => 'We\'ve set up some sample \'promises\' for you! Please change the settings to suit your child.';

  @override
  String get gotIt => 'Got it';

  @override
  String get firstTimeBonus => '🌟 First Time Bonus! 🌟';

  @override
  String get parentSettings => 'Parent';

  @override
  String get help => 'Help';

  @override
  String get navPromiseBoard => 'Promises';

  @override
  String get navDressUp => 'Dress Up';

  @override
  String get navShop => 'Shop';

  @override
  String get navMusic => 'Music';

  @override
  String get navWorldMap => 'World';

  @override
  String get navBack => 'Back';

  @override
  String get loginBonusTitle => 'Login Bonus';

  @override
  String loginBonusMessage(int count) {
    return 'Day $count login this week!\nYou got 10 points!';
  }

  @override
  String get loginBonusWeeklyTitle => '✨ This Week\'s Login Bonus ✨';

  @override
  String get loginBonusResetNote => '*Resets every Monday';

  @override
  String loginBonusDay(int day) {
    return 'Day $day';
  }

  @override
  String get trialPromiseTitle => 'Promise (Trial)';

  @override
  String get loginBonusCongrats => 'Yay!';

  @override
  String get loginBonusReceive => 'Get it!';

  @override
  String get cheerLabel => 'Cheer';

  @override
  String get sadLabel => 'Sad';

  @override
  String get backupRestoreTitle => 'Data Backup and Restore';

  @override
  String get backupServiceLinked => 'Linked to this service';

  @override
  String get backupServiceGoogleDriveDesc => 'Save data to Google Drive';

  @override
  String get backupAction => 'Backup';

  @override
  String get restoreAction => 'Restore';

  @override
  String get backupSuccess => 'Backup completed';

  @override
  String get backupFailure => 'Backup failed';

  @override
  String get restoreSuccess => 'Data restored';

  @override
  String get restoreFailure => 'Restore failed';

  @override
  String get minutesLabel => 'min';

  @override
  String get okAction => 'OK';

  @override
  String get notificationRequestTitle => 'Receive notifications? 🔔';

  @override
  String get notificationRequestMessage => 'We\'ll send you weekly updates on your child\'s progress and news about new items to your phone!\n\nTurn on notifications and enjoy the journey together! ✨';

  @override
  String get notificationLater => 'Later';

  @override
  String get notificationAccept => 'Sure!';

  @override
  String get resetPromisesAction => 'Reset Promises to Defaults';

  @override
  String get resetPromisesConfirm => 'Are you sure you want to reset all regular promises to their default values? This cannot be undone.';

  @override
  String get resetPromisesSuccess => 'Regular promises have been reset.';

  @override
  String get tutorialStartBubble => 'Starting your\n\'Promise\' here!';

  @override
  String get tutorialShopBubble => 'Let\'s go\nshopping!';

  @override
  String get tutorialCustomizeBubble => 'You can change\nclothes here!';

  @override
  String get tutorialParentSettingsBubble => 'Create your promises from here!';

  @override
  String get helpMenuTitle => 'How to Play';

  @override
  String get helpMenuYakusoku => 'Promise';

  @override
  String get helpMenuShop => 'Shop';

  @override
  String get helpMenuCustomize => 'Dress-up';

  @override
  String get helpMenuOthers => 'Others (Settings, etc.)';

  @override
  String get helpMenuClose => 'Close';

  @override
  String get tutorialParentRegularBubble => 'Set promises\nfrom here!';

  @override
  String get tutorialParentAddBubble => 'Tap this button\nto add a promise!';

  @override
  String get tutorialParentDeleteBubble => 'Tap this button\nto remove a promise!';

  @override
  String get tutorialParentBackBubble => 'Go back\nfrom here!';

  @override
  String get tutorialParentStep3Title => 'Try with a sample promise!';

  @override
  String get tutorialParentStep3Desc => 'Tap the **+ button** on the left to add a promise.\nTry adding **\"Trial promise\"**!';

  @override
  String get tutorialParentStep5Title => 'Time to set up promises!';

  @override
  String get tutorialParentStep5Desc => 'Use the suggestions or \"Custom Add\" to set up **promises that suit your child**.\nWhen you\'re done, tap **\"Back\"** to return to the home screen!';

  @override
  String get tutorialParentCompleteTitle => 'Promises are ready!';

  @override
  String get tutorialParentCompleteDesc => 'The **promise setup** is complete!\nLet\'s try the promises on the home screen!';

  @override
  String promiseNotificationTitle(String title) {
    return 'Time for \"$title\"!';
  }

  @override
  String promiseNotificationBody(String icon) {
    return '$icon Let\'s start your promise!';
  }

  @override
  String get weeklyNotificationTitle => 'How are this week\'s Promises? 🌟';

  @override
  String get weeklyNotificationBody => 'Taking a quick break? ☕️ Let\'s check your child\'s progress in the app!';

  @override
  String alreadyAddedPromise(String title) {
    return '\"$title\" is already added';
  }

  @override
  String get customAdd => 'Custom Add';

  @override
  String get recommendedTitle => 'Recommended';

  @override
  String get currentPromiseTitle => 'Current Promises';

  @override
  String get dragToAddInstruction => 'Drag from the left\nto add!';

  @override
  String get recPromiseToilet => 'Go to the toilet';

  @override
  String get recPromiseBreakfast => 'Breakfast';

  @override
  String get recPromiseBrushTeethMorning => 'Brush teeth (Morning)';

  @override
  String get recPromiseGetDressed => 'Get dressed';

  @override
  String get recPromiseShoes => 'Arrange shoes';

  @override
  String get recPromiseLunch => 'Lunch';

  @override
  String get recPromiseWashHands => 'Wash hands';

  @override
  String get recPromiseHomework => 'Homework';

  @override
  String get recPromisePractice => 'Practice / Lessons';

  @override
  String get recPromiseReading => 'Reading';

  @override
  String get recPromiseHelp => 'Help out';

  @override
  String get recPromiseCleanUp => 'Clean up';

  @override
  String get recPromiseBath => 'Take a bath';

  @override
  String get recPromisePajamas => 'Change to pajamas';

  @override
  String get recPromiseDinner => 'Dinner';

  @override
  String get recPromiseBrushTeethNight => 'Brush teeth (Night)';

  @override
  String get recPromisePrepareNextDay => 'Prepare for tomorrow';

  @override
  String get recPromiseSleep => 'Sleep';

  @override
  String get recPromiseReadBook => 'Read a book';

  @override
  String get recPromiseBathCleaning => 'Clean the bath';

  @override
  String get recPromiseErrand => 'Run an errand';

  @override
  String durationAndPoints(String duration, String points) {
    return '$duration min / $points pt';
  }
}
