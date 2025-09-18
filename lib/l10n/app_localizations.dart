import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'The World You Create'**
  String get appName;

  /// No description provided for @customizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Customize'**
  String get customizeTitle;

  /// No description provided for @customizeTabClothes.
  ///
  /// In en, this message translates to:
  /// **'Clothes'**
  String get customizeTabClothes;

  /// No description provided for @customizeTabHouse.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get customizeTabHouse;

  /// No description provided for @customizeTabCharacter.
  ///
  /// In en, this message translates to:
  /// **'Supporter'**
  String get customizeTabCharacter;

  /// No description provided for @customizeTabItem.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get customizeTabItem;

  /// No description provided for @guideWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get guideWelcomeTitle;

  /// No description provided for @guideWelcomeDesc.
  ///
  /// In en, this message translates to:
  /// **'Let\'s explain how to play \'The World You Create\'!'**
  String get guideWelcomeDesc;

  /// No description provided for @guideSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'① Parent Settings (Top-left ⚙️ icon)'**
  String get guideSettingsTitle;

  /// No description provided for @guideSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'This is where parents can add or edit promises.\nTry deciding on the promises together with your child first!'**
  String get guideSettingsDesc;

  /// No description provided for @guideNextPromiseTitle.
  ///
  /// In en, this message translates to:
  /// **'② Next Promise (Bottom bar)'**
  String get guideNextPromiseTitle;

  /// No description provided for @guideNextPromiseDesc.
  ///
  /// In en, this message translates to:
  /// **'The next promise you need to do is displayed here.\nPress \'Start\' to begin the challenge!'**
  String get guideNextPromiseDesc;

  /// No description provided for @guidePromiseBoardTitle.
  ///
  /// In en, this message translates to:
  /// **'③ Promise Board (Right 📄 icon)'**
  String get guidePromiseBoardTitle;

  /// No description provided for @guidePromiseBoardDesc.
  ///
  /// In en, this message translates to:
  /// **'You can see a list of today\'s promises here.\nYour goal is to collect the \'Done!\' check marks!'**
  String get guidePromiseBoardDesc;

  /// No description provided for @guidePointsTitle.
  ///
  /// In en, this message translates to:
  /// **'④ Points (Top-right ★)'**
  String get guidePointsTitle;

  /// No description provided for @guidePointsDesc.
  ///
  /// In en, this message translates to:
  /// **'When you complete a promise, you get points here!\nCollect a lot and exchange them for rewards.'**
  String get guidePointsDesc;

  /// No description provided for @guideShopTitle.
  ///
  /// In en, this message translates to:
  /// **'⑤ Reward Shop (Right 🏠 icon)'**
  String get guideShopTitle;

  /// No description provided for @guideShopDesc.
  ///
  /// In en, this message translates to:
  /// **'This is where you can exchange the points you\'ve saved for new clothes and houses!'**
  String get guideShopDesc;

  /// No description provided for @guideCustomizeTitle.
  ///
  /// In en, this message translates to:
  /// **'⑥ Customize (Right ☺ icon)'**
  String get guideCustomizeTitle;

  /// No description provided for @guideCustomizeDesc.
  ///
  /// In en, this message translates to:
  /// **'You can change your avatar\'s clothes and house with the items you\'ve bought.\nCreate your very own world!'**
  String get guideCustomizeDesc;

  /// No description provided for @guideHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'⑦ Help (Left ? icon)'**
  String get guideHelpTitle;

  /// No description provided for @guideHelpDesc.
  ///
  /// In en, this message translates to:
  /// **'If you get stuck, you can press this button\nto see this explanation again.'**
  String get guideHelpDesc;

  /// No description provided for @emergency.
  ///
  /// In en, this message translates to:
  /// **'EMERGENCY!'**
  String get emergency;

  /// No description provided for @nextPromise.
  ///
  /// In en, this message translates to:
  /// **'Next Promise'**
  String get nextPromise;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @didNotDo.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t Do'**
  String get didNotDo;

  /// No description provided for @startNow.
  ///
  /// In en, this message translates to:
  /// **'Start Now'**
  String get startNow;

  /// No description provided for @allPromisesDone.
  ///
  /// In en, this message translates to:
  /// **'All of today\'s promises are done! ✨'**
  String get allPromisesDone;

  /// No description provided for @startPromise.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startPromise;

  /// No description provided for @lockIncorrectAnswer.
  ///
  /// In en, this message translates to:
  /// **'Sorry, that\'s not right'**
  String get lockIncorrectAnswer;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @promiseBoard.
  ///
  /// In en, this message translates to:
  /// **'Promise Board'**
  String get promiseBoard;

  /// No description provided for @noRegularPromises.
  ///
  /// In en, this message translates to:
  /// **'No regular promises yet'**
  String get noRegularPromises;

  /// No description provided for @untitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitled;

  /// No description provided for @rouletteCongrats.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!\n2x Points!'**
  String get rouletteCongrats;

  /// No description provided for @rouletteTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again Next Time'**
  String get rouletteTryAgain;

  /// No description provided for @rouletteTitle.
  ///
  /// In en, this message translates to:
  /// **'Point Up Chance!'**
  String get rouletteTitle;

  /// No description provided for @rouletteQuestion.
  ///
  /// In en, this message translates to:
  /// **'Spin the roulette?'**
  String get rouletteQuestion;

  /// No description provided for @rouletteWin.
  ///
  /// In en, this message translates to:
  /// **'Win → '**
  String get rouletteWin;

  /// No description provided for @rouletteLose.
  ///
  /// In en, this message translates to:
  /// **'\nLose → '**
  String get rouletteLose;

  /// No description provided for @rouletteSpin.
  ///
  /// In en, this message translates to:
  /// **'Spin!'**
  String get rouletteSpin;

  /// No description provided for @shopConfirmExchange.
  ///
  /// In en, this message translates to:
  /// **'Exchange for {itemPrice} points?'**
  String shopConfirmExchange(int itemPrice);

  /// No description provided for @quitAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get quitAction;

  /// No description provided for @shopExchangeSuccess.
  ///
  /// In en, this message translates to:
  /// **'You got the {itemName}!'**
  String shopExchangeSuccess(String itemName);

  /// No description provided for @exchange.
  ///
  /// In en, this message translates to:
  /// **'Exchange'**
  String get exchange;

  /// No description provided for @shopNotEnoughPoints.
  ///
  /// In en, this message translates to:
  /// **'Not enough points...'**
  String get shopNotEnoughPoints;

  /// No description provided for @shopTitle.
  ///
  /// In en, this message translates to:
  /// **'Reward Shop'**
  String get shopTitle;

  /// No description provided for @itemPurchased.
  ///
  /// In en, this message translates to:
  /// **'Purchased'**
  String get itemPurchased;

  /// No description provided for @confirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get confirmation;

  /// No description provided for @askIfFinished.
  ///
  /// In en, this message translates to:
  /// **'Are you really done with {promiseTitle}?'**
  String askIfFinished(String promiseTitle);

  /// No description provided for @notYet.
  ///
  /// In en, this message translates to:
  /// **'Not Yet'**
  String get notYet;

  /// No description provided for @yesFinished.
  ///
  /// In en, this message translates to:
  /// **'All Done!'**
  String get yesFinished;

  /// No description provided for @challengingPromise.
  ///
  /// In en, this message translates to:
  /// **'Challenging {promiseTitle}!'**
  String challengingPromise(String promiseTitle);

  /// No description provided for @pointsHalf.
  ///
  /// In en, this message translates to:
  /// **'So close! You get {points} points!'**
  String pointsHalf(String points);

  /// No description provided for @pointsChance.
  ///
  /// In en, this message translates to:
  /// **'Chance to get {points} points!'**
  String pointsChance(int points);

  /// No description provided for @finished.
  ///
  /// In en, this message translates to:
  /// **'Finished!'**
  String get finished;

  /// No description provided for @addRegularPromiseTitle.
  ///
  /// In en, this message translates to:
  /// **'New Regular Promise'**
  String get addRegularPromiseTitle;

  /// No description provided for @editRegularPromiseTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Promise'**
  String get editRegularPromiseTitle;

  /// No description provided for @promiseNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Promise Name'**
  String get promiseNameLabel;

  /// No description provided for @promiseNameHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name for the promise'**
  String get promiseNameHint;

  /// No description provided for @startTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTimeLabel;

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration (minutes)'**
  String get durationLabel;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @adviceScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Tips for Promise Settings'**
  String get adviceScreenTitle;

  /// No description provided for @adviceMainTitle.
  ///
  /// In en, this message translates to:
  /// **'Tips for Increasing \"I did it!\" Moments 💡'**
  String get adviceMainTitle;

  /// No description provided for @advice1Title.
  ///
  /// In en, this message translates to:
  /// **'Decide on Promises Together with Your Child'**
  String get advice1Title;

  /// No description provided for @advice1Desc.
  ///
  /// In en, this message translates to:
  /// **'Try deciding \"what,\" \"by when,\" and \"for how many points\" together with your child. Having rules they helped create sparks their motivation to take on the challenge.'**
  String get advice1Desc;

  /// No description provided for @advice2Title.
  ///
  /// In en, this message translates to:
  /// **'Start with \"Easy\" Tasks First'**
  String get advice2Title;

  /// No description provided for @advice2Desc.
  ///
  /// In en, this message translates to:
  /// **'Begin with simple promises your child can definitely complete. Building up successful experiences of \"I did it!\" leads to confidence.'**
  String get advice2Desc;

  /// No description provided for @advice3Title.
  ///
  /// In en, this message translates to:
  /// **'Set the Time a \"Little Generously\"'**
  String get advice3Title;

  /// No description provided for @advice3Desc.
  ///
  /// In en, this message translates to:
  /// **'Instead of making them rush, the key is to set the challenge time a little longer at first so they can feel the accomplishment of \"I did it within the time!\"'**
  String get advice3Desc;

  /// No description provided for @advice4Title.
  ///
  /// In en, this message translates to:
  /// **'Treat Points as Something \"Special\"'**
  String get advice4Title;

  /// No description provided for @advice4Desc.
  ///
  /// In en, this message translates to:
  /// **'For more difficult promises, try setting the points a little higher. Feeling that \"this mission is special!\" will boost your child\'s motivation to try.'**
  String get advice4Desc;

  /// No description provided for @advice5Title.
  ///
  /// In en, this message translates to:
  /// **'The Best Reward is \"Praise\"'**
  String get advice5Title;

  /// No description provided for @advice5Desc.
  ///
  /// In en, this message translates to:
  /// **'While points in the app are important, when your child completes a promise, please praise them directly with words like \"Well done!\" or \"Amazing!\". That will be their greatest source of energy.'**
  String get advice5Desc;

  /// No description provided for @emergencyPromiseSet.
  ///
  /// In en, this message translates to:
  /// **'Set \"{promiseTitle}\" as the emergency promise.'**
  String emergencyPromiseSet(String promiseTitle);

  /// No description provided for @emergencyPromiseSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency Promise Settings'**
  String get emergencyPromiseSettingsTitle;

  /// No description provided for @promiseNameExampleHint.
  ///
  /// In en, this message translates to:
  /// **'Promise Name (e.g., Tidy up toys)'**
  String get promiseNameExampleHint;

  /// No description provided for @setThisPromiseButton.
  ///
  /// In en, this message translates to:
  /// **'Set This Promise'**
  String get setThisPromiseButton;

  /// No description provided for @parentScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Parent Mode'**
  String get parentScreenTitle;

  /// No description provided for @readFirstButton.
  ///
  /// In en, this message translates to:
  /// **'Read Me First'**
  String get readFirstButton;

  /// No description provided for @regularPromiseSettingsButton.
  ///
  /// In en, this message translates to:
  /// **'Regular Promise Settings'**
  String get regularPromiseSettingsButton;

  /// No description provided for @emergencyPromiseSettingsButton.
  ///
  /// In en, this message translates to:
  /// **'Emergency Promise Settings'**
  String get emergencyPromiseSettingsButton;

  /// No description provided for @promiseDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted \"{promiseTitle}\".'**
  String promiseDeleted(String promiseTitle);

  /// No description provided for @promiseAdded.
  ///
  /// In en, this message translates to:
  /// **'Added \"{promiseTitle}\".'**
  String promiseAdded(String promiseTitle);

  /// No description provided for @promiseUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated \"{promiseTitle}\".'**
  String promiseUpdated(String promiseTitle);

  /// No description provided for @regularPromiseSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Regular Promise Settings'**
  String get regularPromiseSettingsTitle;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @itemClothesBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue Clothes'**
  String get itemClothesBlue;

  /// No description provided for @itemClothesRed.
  ///
  /// In en, this message translates to:
  /// **'Red Clothes'**
  String get itemClothesRed;

  /// No description provided for @itemClothesGreen.
  ///
  /// In en, this message translates to:
  /// **'Green Clothes'**
  String get itemClothesGreen;

  /// No description provided for @itemClothesLightBlue.
  ///
  /// In en, this message translates to:
  /// **'Light Blue Clothes'**
  String get itemClothesLightBlue;

  /// No description provided for @itemHouseNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal House'**
  String get itemHouseNormal;

  /// No description provided for @itemHouseGrand.
  ///
  /// In en, this message translates to:
  /// **'Grand House'**
  String get itemHouseGrand;

  /// No description provided for @itemClothesDefault.
  ///
  /// In en, this message translates to:
  /// **'Default Clothes'**
  String get itemClothesDefault;

  /// No description provided for @itemHouseDefault.
  ///
  /// In en, this message translates to:
  /// **'First House'**
  String get itemHouseDefault;

  /// No description provided for @itemAvatarBoy.
  ///
  /// In en, this message translates to:
  /// **'Boy'**
  String get itemAvatarBoy;

  /// No description provided for @charRabbit.
  ///
  /// In en, this message translates to:
  /// **'Rabbit'**
  String get charRabbit;

  /// No description provided for @charCat.
  ///
  /// In en, this message translates to:
  /// **'Cat'**
  String get charCat;

  /// No description provided for @charGiraffe.
  ///
  /// In en, this message translates to:
  /// **'Giraffe'**
  String get charGiraffe;

  /// No description provided for @charElephant.
  ///
  /// In en, this message translates to:
  /// **'Elephant'**
  String get charElephant;

  /// No description provided for @charBear.
  ///
  /// In en, this message translates to:
  /// **'Bear'**
  String get charBear;

  /// No description provided for @charPanda.
  ///
  /// In en, this message translates to:
  /// **'Panda'**
  String get charPanda;

  /// No description provided for @charMonkey.
  ///
  /// In en, this message translates to:
  /// **'Monkey'**
  String get charMonkey;

  /// No description provided for @itemFlower1.
  ///
  /// In en, this message translates to:
  /// **'Flower 1'**
  String get itemFlower1;

  /// No description provided for @itemFlower2.
  ///
  /// In en, this message translates to:
  /// **'Flower 2'**
  String get itemFlower2;

  /// No description provided for @itemLeaf1.
  ///
  /// In en, this message translates to:
  /// **'Leaf 1'**
  String get itemLeaf1;

  /// No description provided for @itemLeaf2.
  ///
  /// In en, this message translates to:
  /// **'Leaf 2'**
  String get itemLeaf2;

  /// No description provided for @itemPotPlant.
  ///
  /// In en, this message translates to:
  /// **'Potted Plant'**
  String get itemPotPlant;

  /// No description provided for @itemGrass1.
  ///
  /// In en, this message translates to:
  /// **'Grass 1'**
  String get itemGrass1;

  /// No description provided for @itemGrass2.
  ///
  /// In en, this message translates to:
  /// **'Grass 2'**
  String get itemGrass2;

  /// No description provided for @itemTree.
  ///
  /// In en, this message translates to:
  /// **'Tree'**
  String get itemTree;

  /// No description provided for @itemWateringCan.
  ///
  /// In en, this message translates to:
  /// **'Watering Can'**
  String get itemWateringCan;

  /// No description provided for @itemCoin.
  ///
  /// In en, this message translates to:
  /// **'Coin'**
  String get itemCoin;

  /// No description provided for @itemTreasureChest.
  ///
  /// In en, this message translates to:
  /// **'Treasure Chest'**
  String get itemTreasureChest;

  /// No description provided for @itemBall.
  ///
  /// In en, this message translates to:
  /// **'Ball'**
  String get itemBall;

  /// No description provided for @itemSun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get itemSun;

  /// No description provided for @itemMoon.
  ///
  /// In en, this message translates to:
  /// **'Moon'**
  String get itemMoon;

  /// No description provided for @itemStar.
  ///
  /// In en, this message translates to:
  /// **'Star'**
  String get itemStar;

  /// No description provided for @itemBicycle.
  ///
  /// In en, this message translates to:
  /// **'Bicycle'**
  String get itemBicycle;

  /// No description provided for @itemCar.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get itemCar;

  /// No description provided for @promiseDefault1Title.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get promiseDefault1Title;

  /// No description provided for @promiseDefault2Title.
  ///
  /// In en, this message translates to:
  /// **'Get Ready for School'**
  String get promiseDefault2Title;

  /// No description provided for @promiseDefault3Title.
  ///
  /// In en, this message translates to:
  /// **'Get Ready for Bath'**
  String get promiseDefault3Title;

  /// No description provided for @promiseDefault4Title.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get promiseDefault4Title;

  /// No description provided for @promiseDefault5Title.
  ///
  /// In en, this message translates to:
  /// **'Brush Teeth'**
  String get promiseDefault5Title;

  /// No description provided for @promiseDefault6Title.
  ///
  /// In en, this message translates to:
  /// **'Get Ready for Bed'**
  String get promiseDefault6Title;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @languageSetting.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSetting;

  /// No description provided for @longPressToEnter.
  ///
  /// In en, this message translates to:
  /// **'Long press to enter!'**
  String get longPressToEnter;

  /// No description provided for @insideTheHouse.
  ///
  /// In en, this message translates to:
  /// **'Inside the House'**
  String get insideTheHouse;

  /// No description provided for @roomIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Looks like there\'s nothing here yet...\nWhat kind of room should we make?'**
  String get roomIsEmpty;

  /// No description provided for @furniture.
  ///
  /// In en, this message translates to:
  /// **'Furniture'**
  String get furniture;

  /// No description provided for @houseItems.
  ///
  /// In en, this message translates to:
  /// **'House Items'**
  String get houseItems;

  /// No description provided for @itemBed.
  ///
  /// In en, this message translates to:
  /// **'Bed'**
  String get itemBed;

  /// No description provided for @itemChair1.
  ///
  /// In en, this message translates to:
  /// **'Chair 1'**
  String get itemChair1;

  /// No description provided for @itemChair2.
  ///
  /// In en, this message translates to:
  /// **'Chair 2'**
  String get itemChair2;

  /// No description provided for @itemChair3.
  ///
  /// In en, this message translates to:
  /// **'Chair 3'**
  String get itemChair3;

  /// No description provided for @itemKitchen.
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get itemKitchen;

  /// No description provided for @itemLantern.
  ///
  /// In en, this message translates to:
  /// **'Lantern'**
  String get itemLantern;

  /// No description provided for @itemCupboard.
  ///
  /// In en, this message translates to:
  /// **'Cupboard'**
  String get itemCupboard;

  /// No description provided for @itemTable.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get itemTable;

  /// No description provided for @itemShelf.
  ///
  /// In en, this message translates to:
  /// **'Shelf'**
  String get itemShelf;

  /// No description provided for @itemBanana.
  ///
  /// In en, this message translates to:
  /// **'Banana'**
  String get itemBanana;

  /// No description provided for @itemGrapes.
  ///
  /// In en, this message translates to:
  /// **'Grapes'**
  String get itemGrapes;

  /// No description provided for @itemPineapple.
  ///
  /// In en, this message translates to:
  /// **'Pineapple'**
  String get itemPineapple;

  /// No description provided for @itemApple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get itemApple;

  /// No description provided for @itemBottle.
  ///
  /// In en, this message translates to:
  /// **'Bottle'**
  String get itemBottle;

  /// No description provided for @itemMilk.
  ///
  /// In en, this message translates to:
  /// **'Milk'**
  String get itemMilk;

  /// No description provided for @itemCup.
  ///
  /// In en, this message translates to:
  /// **'Cup'**
  String get itemCup;

  /// No description provided for @itemPot.
  ///
  /// In en, this message translates to:
  /// **'Pot'**
  String get itemPot;

  /// No description provided for @itemBowl.
  ///
  /// In en, this message translates to:
  /// **'Bowl'**
  String get itemBowl;

  /// No description provided for @itemBook.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get itemBook;

  /// No description provided for @itemVase.
  ///
  /// In en, this message translates to:
  /// **'Vase'**
  String get itemVase;

  /// No description provided for @itemStuffedAnimal.
  ///
  /// In en, this message translates to:
  /// **'Stuffed Animal'**
  String get itemStuffedAnimal;

  /// No description provided for @itemRockingHorse.
  ///
  /// In en, this message translates to:
  /// **'Rocking Horse'**
  String get itemRockingHorse;

  /// No description provided for @itemToy.
  ///
  /// In en, this message translates to:
  /// **'Toy'**
  String get itemToy;

  /// No description provided for @itemTablet.
  ///
  /// In en, this message translates to:
  /// **'Tablet'**
  String get itemTablet;

  /// No description provided for @itemBlocks.
  ///
  /// In en, this message translates to:
  /// **'Building Blocks'**
  String get itemBlocks;

  /// No description provided for @bgmMain.
  ///
  /// In en, this message translates to:
  /// **'Default BGM'**
  String get bgmMain;

  /// No description provided for @bgmFun.
  ///
  /// In en, this message translates to:
  /// **'Fun BGM'**
  String get bgmFun;

  /// No description provided for @bgmCute.
  ///
  /// In en, this message translates to:
  /// **'Cute BGM'**
  String get bgmCute;

  /// No description provided for @bgmRelaxing.
  ///
  /// In en, this message translates to:
  /// **'Relaxing BGM'**
  String get bgmRelaxing;

  /// No description provided for @bgmEnergetic.
  ///
  /// In en, this message translates to:
  /// **'Energetic BGM'**
  String get bgmEnergetic;

  /// No description provided for @bgmSparkly.
  ///
  /// In en, this message translates to:
  /// **'Sparkly BGM'**
  String get bgmSparkly;

  /// No description provided for @bgmNone.
  ///
  /// In en, this message translates to:
  /// **'No BGM'**
  String get bgmNone;

  /// No description provided for @focusBgmDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get focusBgmDefault;

  /// No description provided for @focusBgmCute.
  ///
  /// In en, this message translates to:
  /// **'Cute BGM'**
  String get focusBgmCute;

  /// No description provided for @focusBgmCool.
  ///
  /// In en, this message translates to:
  /// **'Cool BGM'**
  String get focusBgmCool;

  /// No description provided for @focusBgmHurry.
  ///
  /// In en, this message translates to:
  /// **'Hurry BGM'**
  String get focusBgmHurry;

  /// No description provided for @focusBgmNature.
  ///
  /// In en, this message translates to:
  /// **'Nature BGM'**
  String get focusBgmNature;

  /// No description provided for @focusBgmRelaxing.
  ///
  /// In en, this message translates to:
  /// **'Comfortable BGM'**
  String get focusBgmRelaxing;

  /// No description provided for @selectBgmTitle.
  ///
  /// In en, this message translates to:
  /// **'Select BGM'**
  String get selectBgmTitle;

  /// No description provided for @focusBgmSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Timer Music (Focus BGM)'**
  String get focusBgmSettingTitle;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ja': return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
