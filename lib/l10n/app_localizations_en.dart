// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'The World You Create';

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
  String get guideWelcomeTitle => 'Welcome!';

  @override
  String get guideWelcomeDesc => 'Let\'s explain how to play \'The World You Create\'!';

  @override
  String get guideSettingsTitle => '① Parent Settings (Top-left ⚙️ icon)';

  @override
  String get guideSettingsDesc => 'This is where parents can add or edit promises.\nTry deciding on the promises together with your child first!';

  @override
  String get guideNextPromiseTitle => '② Next Promise (Bottom bar)';

  @override
  String get guideNextPromiseDesc => 'The next promise you need to do is displayed here.\nPress \'Start\' to begin the challenge!';

  @override
  String get guidePromiseBoardTitle => '③ Promise Board (Right 📄 icon)';

  @override
  String get guidePromiseBoardDesc => 'You can see a list of today\'s promises here.\nYour goal is to collect the \'Done!\' check marks!';

  @override
  String get guidePointsTitle => '④ Points (Top-right ★)';

  @override
  String get guidePointsDesc => 'When you complete a promise, you get points here!\nCollect a lot and exchange them for rewards.';

  @override
  String get guideShopTitle => '⑤ Reward Shop (Right 🏠 icon)';

  @override
  String get guideShopDesc => 'This is where you can exchange the points you\'ve saved for new clothes and houses!';

  @override
  String get guideCustomizeTitle => '⑥ Customize (Right ☺ icon)';

  @override
  String get guideCustomizeDesc => 'You can change your avatar\'s clothes and house with the items you\'ve bought.\nCreate your very own world!';

  @override
  String get guideHelpTitle => '⑦ Help (Left ? icon)';

  @override
  String get guideHelpDesc => 'If you get stuck, you can press this button\nto see this explanation again.';

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
  String get noRegularPromises => 'No regular promises yet';

  @override
  String get untitled => 'Untitled';

  @override
  String get rouletteCongrats => 'Congratulations!\n2x Points!';

  @override
  String get rouletteTryAgain => 'Try Again Next Time';

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
  String get addRegularPromiseTitle => 'New Regular Promise';

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
  String get regularPromiseSettingsButton => 'Regular Promise Settings';

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
  String get regularPromiseSettingsTitle => 'Regular Promise Settings';

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
  String get promiseDefault2Title => 'Get Ready for School';

  @override
  String get promiseDefault3Title => 'Get Ready for Bath';

  @override
  String get promiseDefault4Title => 'Dinner';

  @override
  String get promiseDefault5Title => 'Brush Teeth';

  @override
  String get promiseDefault6Title => 'Get Ready for Bed';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageSetting => 'Language';
}
