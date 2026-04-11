import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ur.dart';

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
    Locale('ar'),
    Locale('bn'),
    Locale('en'),
    Locale('hi'),
    Locale('ja'),
    Locale('ur')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Kids Habit Hero'**
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
  /// **'First, let\'s play like a child!'**
  String get guideWelcomeTitle;

  /// No description provided for @guideWelcomeDesc.
  ///
  /// In en, this message translates to:
  /// **'Experience for yourself how \'Promises\' work!\nI\'ve prepared a \'Trial Promise\' on the bottom bar.\nPress \'Start\' right away and try playing like a child!'**
  String get guideWelcomeDesc;

  /// No description provided for @guideSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Grown-up Settings (Top-left ⚙️ icon)'**
  String get guideSettingsTitle;

  /// No description provided for @guideSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'This is where grown-ups can add or edit promises.\nLet\'s decide on some \'Promises\' together with your child here first!'**
  String get guideSettingsDesc;

  /// No description provided for @tutorialShopTitle.
  ///
  /// In en, this message translates to:
  /// **'You got 100 points! ✨'**
  String get tutorialShopTitle;

  /// No description provided for @tutorialShopDesc.
  ///
  /// In en, this message translates to:
  /// **'You\'ve saved up points!\nLet\'s go buy items at the \'Shop\' using the 🏠 button on the right!'**
  String get tutorialShopDesc;

  /// No description provided for @tutorialCustomizeTitle.
  ///
  /// In en, this message translates to:
  /// **'You got an item! 🎁'**
  String get tutorialCustomizeTitle;

  /// No description provided for @tutorialCustomizeDesc.
  ///
  /// In en, this message translates to:
  /// **'You got an item!\nNext, using the ☺ button on the right, let\'s decorate your room in \'Customize\'!'**
  String get tutorialCustomizeDesc;

  /// No description provided for @tutorialParentSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'All ready! 🎉'**
  String get tutorialParentSetupTitle;

  /// No description provided for @tutorialParentSetupDesc.
  ///
  /// In en, this message translates to:
  /// **'We\'re all set to make them happy!\nLet\'s set up the daily \'Promises\' right away and get started!'**
  String get tutorialParentSetupDesc;

  /// No description provided for @tutorialMoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Move Them! ✨'**
  String get tutorialMoveTitle;

  /// No description provided for @tutorialMoveDesc.
  ///
  /// In en, this message translates to:
  /// **'The items you picked in Dress-up/Customize can be moved with your finger!\nPut them wherever you like.'**
  String get tutorialMoveDesc;

  /// No description provided for @tutorialBtnStart.
  ///
  /// In en, this message translates to:
  /// **'Let\'s do this!'**
  String get tutorialBtnStart;

  /// No description provided for @tutorialBtnShop.
  ///
  /// In en, this message translates to:
  /// **'Go to Shop!'**
  String get tutorialBtnShop;

  /// No description provided for @tutorialBtnCustomize.
  ///
  /// In en, this message translates to:
  /// **'Go Customize!'**
  String get tutorialBtnCustomize;

  /// No description provided for @tutorialBtnMove.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get tutorialBtnMove;

  /// No description provided for @tutorialBtnParent.
  ///
  /// In en, this message translates to:
  /// **'Create a Promise!'**
  String get tutorialBtnParent;

  /// No description provided for @guideTrialPromiseTitle.
  ///
  /// In en, this message translates to:
  /// **'Moms and Dads, try it out! ✨'**
  String get guideTrialPromiseTitle;

  /// No description provided for @guideTrialPromiseDesc.
  ///
  /// In en, this message translates to:
  /// **'Experience for yourself how \'Promises\' work!\nI\'ve prepared a \'Trial Promise\' on the bottom bar.\nPress \'Start\' right away and try playing like a child!'**
  String get guideTrialPromiseDesc;

  /// No description provided for @guideNextPromiseTitle.
  ///
  /// In en, this message translates to:
  /// **'Next Promise (Bottom board)'**
  String get guideNextPromiseTitle;

  /// No description provided for @guideNextPromiseDesc.
  ///
  /// In en, this message translates to:
  /// **'The next \'Promise\' to challenge will be shown here.\nPress \'Start\' and keep challenging them!'**
  String get guideNextPromiseDesc;

  /// No description provided for @guidePromiseBoardTitle.
  ///
  /// In en, this message translates to:
  /// **'Promise Board (Right 📄 icon)'**
  String get guidePromiseBoardTitle;

  /// No description provided for @guidePromiseBoardDesc.
  ///
  /// In en, this message translates to:
  /// **'You can see a list of today\'s promises here.\nYour goal is to collect the \'Done!\' check marks!'**
  String get guidePromiseBoardDesc;

  /// No description provided for @guidePointsTitle.
  ///
  /// In en, this message translates to:
  /// **'Points (Top-right ★)'**
  String get guidePointsTitle;

  /// No description provided for @guidePointsDesc.
  ///
  /// In en, this message translates to:
  /// **'When you complete a promise, you get points here!\nCollect a lot and exchange them for rewards.'**
  String get guidePointsDesc;

  /// No description provided for @guideShopTitle.
  ///
  /// In en, this message translates to:
  /// **'Reward Shop (Right 🏠 icon)'**
  String get guideShopTitle;

  /// No description provided for @guideShopDesc.
  ///
  /// In en, this message translates to:
  /// **'This is where you can exchange the points you\'ve saved for new clothes and houses!'**
  String get guideShopDesc;

  /// No description provided for @guideCustomizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Customize (Right ☺ icon)'**
  String get guideCustomizeTitle;

  /// No description provided for @guideCustomizeDesc.
  ///
  /// In en, this message translates to:
  /// **'You can change your avatar\'s clothes and house with the items you\'ve bought.\nCreate your very own world!'**
  String get guideCustomizeDesc;

  /// No description provided for @guideBgmButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'BGM (♪ Icon on the Right)'**
  String get guideBgmButtonTitle;

  /// No description provided for @guideBgmButtonDesc.
  ///
  /// In en, this message translates to:
  /// **'Press here to choose your favorite music. Change the mood with a fun song!'**
  String get guideBgmButtonDesc;

  /// No description provided for @guideWorldMapButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Outer World (🌎 Icon on the Right)'**
  String get guideWorldMapButtonTitle;

  /// No description provided for @guideWorldMapButtonDesc.
  ///
  /// In en, this message translates to:
  /// **'Press this button to see the whole world map. As you level up, you might unlock new places to go!'**
  String get guideWorldMapButtonDesc;

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
  /// **'No promises yet'**
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
  /// **'Try Again Next Time\n'**
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
  /// **'New Promise'**
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
  /// **'Promise Settings'**
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
  /// **'Promise Settings'**
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
  /// **'Brushing Teeth (Morning)'**
  String get promiseDefault2Title;

  /// No description provided for @promiseDefault3Title.
  ///
  /// In en, this message translates to:
  /// **'Getting Dressed'**
  String get promiseDefault3Title;

  /// No description provided for @promiseDefault4Title.
  ///
  /// In en, this message translates to:
  /// **'Bath'**
  String get promiseDefault4Title;

  /// No description provided for @promiseDefault5Title.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get promiseDefault5Title;

  /// No description provided for @promiseDefault6Title.
  ///
  /// In en, this message translates to:
  /// **'Brushing Teeth (Night)'**
  String get promiseDefault6Title;

  /// No description provided for @promiseDefault7Title.
  ///
  /// In en, this message translates to:
  /// **'Bedtime'**
  String get promiseDefault7Title;

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

  /// No description provided for @normalBgm.
  ///
  /// In en, this message translates to:
  /// **'Normal BGM'**
  String get normalBgm;

  /// No description provided for @focusBgm.
  ///
  /// In en, this message translates to:
  /// **'Focus BGM'**
  String get focusBgm;

  /// No description provided for @passcodeIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect Passcode'**
  String get passcodeIncorrect;

  /// No description provided for @passcodeEnter4Digit.
  ///
  /// In en, this message translates to:
  /// **'Enter 4-digit Passcode'**
  String get passcodeEnter4Digit;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @setAction.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get setAction;

  /// No description provided for @lockMethod.
  ///
  /// In en, this message translates to:
  /// **'Lock Method'**
  String get lockMethod;

  /// No description provided for @multiplication.
  ///
  /// In en, this message translates to:
  /// **'Multiplication'**
  String get multiplication;

  /// No description provided for @fourDigitPasscode.
  ///
  /// In en, this message translates to:
  /// **'4-Digit Passcode'**
  String get fourDigitPasscode;

  /// No description provided for @setPasscode.
  ///
  /// In en, this message translates to:
  /// **'Set Passcode'**
  String get setPasscode;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not Set'**
  String get notSet;

  /// No description provided for @supportThisApp.
  ///
  /// In en, this message translates to:
  /// **'Support this app'**
  String get supportThisApp;

  /// No description provided for @supportEncouragement.
  ///
  /// In en, this message translates to:
  /// **'Your support encourages future development!'**
  String get supportEncouragement;

  /// No description provided for @supportPageOpenError.
  ///
  /// In en, this message translates to:
  /// **'Could not open the page'**
  String get supportPageOpenError;

  /// No description provided for @timerExpChance.
  ///
  /// In en, this message translates to:
  /// **'A chance at 3 EXP!'**
  String get timerExpChance;

  /// No description provided for @timerExpFailure.
  ///
  /// In en, this message translates to:
  /// **'You\'ll get 1 EXP!'**
  String get timerExpFailure;

  /// No description provided for @buildings.
  ///
  /// In en, this message translates to:
  /// **'Buildings'**
  String get buildings;

  /// No description provided for @vehicles.
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get vehicles;

  /// No description provided for @houseSettings.
  ///
  /// In en, this message translates to:
  /// **'House Settings'**
  String get houseSettings;

  /// No description provided for @islandSettings.
  ///
  /// In en, this message translates to:
  /// **'Island Settings'**
  String get islandSettings;

  /// Label to display the current level
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String levelLabel(int level);

  /// Label to display the remaining experience points to the next level
  ///
  /// In en, this message translates to:
  /// **'{exp} next EXP'**
  String expToNextLevel(int exp);

  /// No description provided for @levelUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Level Up!'**
  String get levelUpTitle;

  /// Message shown when the user levels up
  ///
  /// In en, this message translates to:
  /// **'You reached level {newLevel}!🎉\nThere might be something good if you go to the shop✨'**
  String levelUpMessage(int newLevel);

  /// Label indicating a feature unlocks at a specific level
  ///
  /// In en, this message translates to:
  /// **'Unlocks at Level {level}'**
  String unlockedAtLevel(int level);

  /// No description provided for @worldMapGuideTitle1.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get worldMapGuideTitle1;

  /// No description provided for @worldMapGuideContent1.
  ///
  /// In en, this message translates to:
  /// **'This is the world map!\nAs you level up, you\'ll unlock more places to go.'**
  String get worldMapGuideContent1;

  /// No description provided for @worldMapGuideTitle2.
  ///
  /// In en, this message translates to:
  /// **'The Central Island'**
  String get worldMapGuideTitle2;

  /// No description provided for @worldMapGuideContent2.
  ///
  /// In en, this message translates to:
  /// **'Once you reach Level 5, you\'ll be able to tap here to enter the island.'**
  String get worldMapGuideContent2;

  /// No description provided for @worldMapGuideTitle3.
  ///
  /// In en, this message translates to:
  /// **'A Widening World'**
  String get worldMapGuideTitle3;

  /// No description provided for @worldMapGuideContent3.
  ///
  /// In en, this message translates to:
  /// **'You might even be able to visit the sea below or the space far above someday...?\nStay tuned!'**
  String get worldMapGuideContent3;

  /// No description provided for @seaAreaLocked.
  ///
  /// In en, this message translates to:
  /// **'You\'ll be able to enter at Level 10!'**
  String get seaAreaLocked;

  /// No description provided for @skyAreaLocked.
  ///
  /// In en, this message translates to:
  /// **'You\'ll be able to enter at Level 15!'**
  String get skyAreaLocked;

  /// No description provided for @islandLocked.
  ///
  /// In en, this message translates to:
  /// **'You\'ll be able to enter at Level 5!'**
  String get islandLocked;

  /// No description provided for @itemHouse1.
  ///
  /// In en, this message translates to:
  /// **'House 1'**
  String get itemHouse1;

  /// No description provided for @itemHouse2.
  ///
  /// In en, this message translates to:
  /// **'House 2'**
  String get itemHouse2;

  /// No description provided for @itemHouse3.
  ///
  /// In en, this message translates to:
  /// **'House 3'**
  String get itemHouse3;

  /// No description provided for @itemHouse4.
  ///
  /// In en, this message translates to:
  /// **'House 4'**
  String get itemHouse4;

  /// No description provided for @itemHouse5.
  ///
  /// In en, this message translates to:
  /// **'House 5'**
  String get itemHouse5;

  /// No description provided for @itemHouse6.
  ///
  /// In en, this message translates to:
  /// **'House 6'**
  String get itemHouse6;

  /// No description provided for @itemHouse7.
  ///
  /// In en, this message translates to:
  /// **'House 7'**
  String get itemHouse7;

  /// No description provided for @itemConvenienceStore.
  ///
  /// In en, this message translates to:
  /// **'Convenience Store'**
  String get itemConvenienceStore;

  /// No description provided for @itemSupermarket.
  ///
  /// In en, this message translates to:
  /// **'Supermarket'**
  String get itemSupermarket;

  /// No description provided for @itemHospital.
  ///
  /// In en, this message translates to:
  /// **'Hospital'**
  String get itemHospital;

  /// No description provided for @itemPoliceStation.
  ///
  /// In en, this message translates to:
  /// **'Police Station'**
  String get itemPoliceStation;

  /// No description provided for @itemPark1.
  ///
  /// In en, this message translates to:
  /// **'Park 1'**
  String get itemPark1;

  /// No description provided for @itemPark2.
  ///
  /// In en, this message translates to:
  /// **'Park 2'**
  String get itemPark2;

  /// No description provided for @itemCastle.
  ///
  /// In en, this message translates to:
  /// **'Castle'**
  String get itemCastle;

  /// No description provided for @itemCarIsland.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get itemCarIsland;

  /// No description provided for @itemTaxiIsland.
  ///
  /// In en, this message translates to:
  /// **'Taxi'**
  String get itemTaxiIsland;

  /// No description provided for @itemBusIsland.
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get itemBusIsland;

  /// No description provided for @itemHelicopterIsland.
  ///
  /// In en, this message translates to:
  /// **'Helicopter'**
  String get itemHelicopterIsland;

  /// No description provided for @itemAirship1Island.
  ///
  /// In en, this message translates to:
  /// **'Airship 1'**
  String get itemAirship1Island;

  /// No description provided for @itemAirship2Island.
  ///
  /// In en, this message translates to:
  /// **'Airship 2'**
  String get itemAirship2Island;

  /// No description provided for @itemClothesRedDress.
  ///
  /// In en, this message translates to:
  /// **'Red Dress'**
  String get itemClothesRedDress;

  /// No description provided for @itemClothesBlueDress.
  ///
  /// In en, this message translates to:
  /// **'Blue Dress'**
  String get itemClothesBlueDress;

  /// No description provided for @itemClothesPinkDress.
  ///
  /// In en, this message translates to:
  /// **'Pink Dress'**
  String get itemClothesPinkDress;

  /// No description provided for @itemClothesBear.
  ///
  /// In en, this message translates to:
  /// **'Bear Costume'**
  String get itemClothesBear;

  /// No description provided for @itemClothesDinosaur.
  ///
  /// In en, this message translates to:
  /// **'Dinosaur Costume'**
  String get itemClothesDinosaur;

  /// No description provided for @itemClothesPrince.
  ///
  /// In en, this message translates to:
  /// **'Prince Outfit'**
  String get itemClothesPrince;

  /// No description provided for @itemClothesAdventurer.
  ///
  /// In en, this message translates to:
  /// **'Adventurer Outfit'**
  String get itemClothesAdventurer;

  /// No description provided for @itemClothesHero.
  ///
  /// In en, this message translates to:
  /// **'Hero Costume'**
  String get itemClothesHero;

  /// No description provided for @itemClothesCowboy.
  ///
  /// In en, this message translates to:
  /// **'Cowboy Outfit'**
  String get itemClothesCowboy;

  /// No description provided for @itemClothesWarrior.
  ///
  /// In en, this message translates to:
  /// **'Warrior Armor'**
  String get itemClothesWarrior;

  /// No description provided for @charGirl.
  ///
  /// In en, this message translates to:
  /// **'Girl'**
  String get charGirl;

  /// No description provided for @charPrincess.
  ///
  /// In en, this message translates to:
  /// **'Princess'**
  String get charPrincess;

  /// No description provided for @charPrince.
  ///
  /// In en, this message translates to:
  /// **'Prince'**
  String get charPrince;

  /// No description provided for @charDinosaur.
  ///
  /// In en, this message translates to:
  /// **'Dinosaur'**
  String get charDinosaur;

  /// No description provided for @charRobot.
  ///
  /// In en, this message translates to:
  /// **'Robot'**
  String get charRobot;

  /// No description provided for @disclosureTitle.
  ///
  /// In en, this message translates to:
  /// **'About Your Data'**
  String get disclosureTitle;

  /// No description provided for @disclosureMessage.
  ///
  /// In en, this message translates to:
  /// **'To show ads and improve app performance, this app may collect and share information about installed apps and your device\'s Advertising ID.'**
  String get disclosureMessage;

  /// No description provided for @disagreeAction.
  ///
  /// In en, this message translates to:
  /// **'Disagree'**
  String get disagreeAction;

  /// No description provided for @agreeAction.
  ///
  /// In en, this message translates to:
  /// **'Agree and Continue'**
  String get agreeAction;

  /// No description provided for @nameSettingHint.
  ///
  /// In en, this message translates to:
  /// **'Set a name so the character can cheer for you!'**
  String get nameSettingHint;

  /// No description provided for @nameSetting.
  ///
  /// In en, this message translates to:
  /// **'Name Setting'**
  String get nameSetting;

  /// No description provided for @nameAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This name and honorific combination is already registered.'**
  String get nameAlreadyExists;

  /// No description provided for @backButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButtonLabel;

  /// No description provided for @childNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get childNameLabel;

  /// No description provided for @childNameSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Child\'s Name Settings'**
  String get childNameSettingsTitle;

  /// No description provided for @enterNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get enterNameHint;

  /// No description provided for @addAction.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addAction;

  /// No description provided for @editAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editAction;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @howToUseLabel.
  ///
  /// In en, this message translates to:
  /// **'How to Use'**
  String get howToUseLabel;

  /// No description provided for @promiseSettingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get promiseSettingsLabel;

  /// No description provided for @registeredNamesLabel.
  ///
  /// In en, this message translates to:
  /// **'Registered Names:'**
  String get registeredNamesLabel;

  /// No description provided for @noNamesRegistered.
  ///
  /// In en, this message translates to:
  /// **'No names registered yet.'**
  String get noNamesRegistered;

  /// No description provided for @seaItems.
  ///
  /// In en, this message translates to:
  /// **'Sea Items'**
  String get seaItems;

  /// No description provided for @seaCreatures.
  ///
  /// In en, this message translates to:
  /// **'Sea Creatures'**
  String get seaCreatures;

  /// No description provided for @seaSettings.
  ///
  /// In en, this message translates to:
  /// **'Sea Settings'**
  String get seaSettings;

  /// No description provided for @itemSeaBottle.
  ///
  /// In en, this message translates to:
  /// **'Bottle'**
  String get itemSeaBottle;

  /// No description provided for @itemSeaAnchor.
  ///
  /// In en, this message translates to:
  /// **'Anchor'**
  String get itemSeaAnchor;

  /// No description provided for @itemSeaShell.
  ///
  /// In en, this message translates to:
  /// **'Seashell'**
  String get itemSeaShell;

  /// No description provided for @itemSeaKelp1.
  ///
  /// In en, this message translates to:
  /// **'Kelp 1'**
  String get itemSeaKelp1;

  /// No description provided for @itemSeaKelp2.
  ///
  /// In en, this message translates to:
  /// **'Kelp 2'**
  String get itemSeaKelp2;

  /// No description provided for @itemSeaCoral1.
  ///
  /// In en, this message translates to:
  /// **'Coral 1'**
  String get itemSeaCoral1;

  /// No description provided for @itemSeaCoral2.
  ///
  /// In en, this message translates to:
  /// **'Coral 2'**
  String get itemSeaCoral2;

  /// No description provided for @itemSeaTreasure.
  ///
  /// In en, this message translates to:
  /// **'Treasure Chest'**
  String get itemSeaTreasure;

  /// No description provided for @itemSeaTrident.
  ///
  /// In en, this message translates to:
  /// **'Trident'**
  String get itemSeaTrident;

  /// No description provided for @itemSeaPot.
  ///
  /// In en, this message translates to:
  /// **'Pot'**
  String get itemSeaPot;

  /// No description provided for @itemSeaSubmarine.
  ///
  /// In en, this message translates to:
  /// **'Submarine'**
  String get itemSeaSubmarine;

  /// No description provided for @itemSeaSunkenShip.
  ///
  /// In en, this message translates to:
  /// **'Sunken Ship'**
  String get itemSeaSunkenShip;

  /// No description provided for @livingPufferfish.
  ///
  /// In en, this message translates to:
  /// **'Pufferfish'**
  String get livingPufferfish;

  /// No description provided for @livingStarfish.
  ///
  /// In en, this message translates to:
  /// **'Starfish'**
  String get livingStarfish;

  /// No description provided for @livingSquid.
  ///
  /// In en, this message translates to:
  /// **'Squid'**
  String get livingSquid;

  /// No description provided for @livingDolphin.
  ///
  /// In en, this message translates to:
  /// **'Dolphin'**
  String get livingDolphin;

  /// No description provided for @livingTurtle.
  ///
  /// In en, this message translates to:
  /// **'Turtle'**
  String get livingTurtle;

  /// No description provided for @livingCrab.
  ///
  /// In en, this message translates to:
  /// **'Crab'**
  String get livingCrab;

  /// No description provided for @livingJellyfish.
  ///
  /// In en, this message translates to:
  /// **'Jellyfish'**
  String get livingJellyfish;

  /// No description provided for @livingFish1.
  ///
  /// In en, this message translates to:
  /// **'Fish 1'**
  String get livingFish1;

  /// No description provided for @livingFish2.
  ///
  /// In en, this message translates to:
  /// **'Fish 2'**
  String get livingFish2;

  /// No description provided for @livingFish3.
  ///
  /// In en, this message translates to:
  /// **'Fish 3'**
  String get livingFish3;

  /// No description provided for @livingFish4.
  ///
  /// In en, this message translates to:
  /// **'Fish 4'**
  String get livingFish4;

  /// No description provided for @livingShark1.
  ///
  /// In en, this message translates to:
  /// **'Shark 1'**
  String get livingShark1;

  /// No description provided for @livingShark2.
  ///
  /// In en, this message translates to:
  /// **'Shark 2'**
  String get livingShark2;

  /// No description provided for @livingSeahorse.
  ///
  /// In en, this message translates to:
  /// **'Seahorse'**
  String get livingSeahorse;

  /// No description provided for @livingHermitCrab.
  ///
  /// In en, this message translates to:
  /// **'Hermit Crab'**
  String get livingHermitCrab;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @skyItems.
  ///
  /// In en, this message translates to:
  /// **'Sky Items'**
  String get skyItems;

  /// No description provided for @skyCreatures.
  ///
  /// In en, this message translates to:
  /// **'Sky Creatures'**
  String get skyCreatures;

  /// No description provided for @skyBalloon1.
  ///
  /// In en, this message translates to:
  /// **'Balloon 1'**
  String get skyBalloon1;

  /// No description provided for @skyBalloon2.
  ///
  /// In en, this message translates to:
  /// **'Balloon 2'**
  String get skyBalloon2;

  /// No description provided for @skyBalloon3.
  ///
  /// In en, this message translates to:
  /// **'Balloon 3'**
  String get skyBalloon3;

  /// No description provided for @skyBalloon4.
  ///
  /// In en, this message translates to:
  /// **'Balloon 4'**
  String get skyBalloon4;

  /// No description provided for @skyCloud.
  ///
  /// In en, this message translates to:
  /// **'Cloud'**
  String get skyCloud;

  /// No description provided for @skyHelicopter.
  ///
  /// In en, this message translates to:
  /// **'Helicopter'**
  String get skyHelicopter;

  /// No description provided for @skyAirplane1.
  ///
  /// In en, this message translates to:
  /// **'Airplane 1'**
  String get skyAirplane1;

  /// No description provided for @skyAirplane2.
  ///
  /// In en, this message translates to:
  /// **'Airplane 2'**
  String get skyAirplane2;

  /// No description provided for @skyAirplane3.
  ///
  /// In en, this message translates to:
  /// **'Airplane 3'**
  String get skyAirplane3;

  /// No description provided for @skyAirplane4.
  ///
  /// In en, this message translates to:
  /// **'Airplane 4'**
  String get skyAirplane4;

  /// No description provided for @skyAirship.
  ///
  /// In en, this message translates to:
  /// **'Airship'**
  String get skyAirship;

  /// No description provided for @skyBalloonRide.
  ///
  /// In en, this message translates to:
  /// **'Hot Air Balloon'**
  String get skyBalloonRide;

  /// No description provided for @skyFighter1.
  ///
  /// In en, this message translates to:
  /// **'Fighter Jet 1'**
  String get skyFighter1;

  /// No description provided for @skyFighter2.
  ///
  /// In en, this message translates to:
  /// **'Fighter Jet 2'**
  String get skyFighter2;

  /// No description provided for @skyBee.
  ///
  /// In en, this message translates to:
  /// **'Bee'**
  String get skyBee;

  /// No description provided for @skyOwl.
  ///
  /// In en, this message translates to:
  /// **'Owl'**
  String get skyOwl;

  /// No description provided for @skyBat.
  ///
  /// In en, this message translates to:
  /// **'Bat'**
  String get skyBat;

  /// No description provided for @skyFlyingSquirrel.
  ///
  /// In en, this message translates to:
  /// **'Flying Squirrel'**
  String get skyFlyingSquirrel;

  /// No description provided for @skyParrot.
  ///
  /// In en, this message translates to:
  /// **'Parrot'**
  String get skyParrot;

  /// No description provided for @skySparrow.
  ///
  /// In en, this message translates to:
  /// **'Sparrow'**
  String get skySparrow;

  /// No description provided for @skyLadybug.
  ///
  /// In en, this message translates to:
  /// **'Ladybug'**
  String get skyLadybug;

  /// No description provided for @skyDragonfly.
  ///
  /// In en, this message translates to:
  /// **'Dragonfly'**
  String get skyDragonfly;

  /// No description provided for @skyCrane.
  ///
  /// In en, this message translates to:
  /// **'Crane'**
  String get skyCrane;

  /// No description provided for @skyButterfly.
  ///
  /// In en, this message translates to:
  /// **'Butterfly'**
  String get skyButterfly;

  /// No description provided for @skyEagle.
  ///
  /// In en, this message translates to:
  /// **'Eagle'**
  String get skyEagle;

  /// No description provided for @spaceItems.
  ///
  /// In en, this message translates to:
  /// **'Space Items'**
  String get spaceItems;

  /// No description provided for @spaceCreatures.
  ///
  /// In en, this message translates to:
  /// **'Space Creatures'**
  String get spaceCreatures;

  /// No description provided for @spaceMeteorite1.
  ///
  /// In en, this message translates to:
  /// **'Meteorite 1'**
  String get spaceMeteorite1;

  /// No description provided for @spaceMeteorite2.
  ///
  /// In en, this message translates to:
  /// **'Meteorite 2'**
  String get spaceMeteorite2;

  /// No description provided for @spaceMeteorite3.
  ///
  /// In en, this message translates to:
  /// **'Meteorite 3'**
  String get spaceMeteorite3;

  /// No description provided for @spaceSatellite1.
  ///
  /// In en, this message translates to:
  /// **'Satellite 1'**
  String get spaceSatellite1;

  /// No description provided for @spaceSatellite2.
  ///
  /// In en, this message translates to:
  /// **'Satellite 2'**
  String get spaceSatellite2;

  /// No description provided for @spacePlanet1.
  ///
  /// In en, this message translates to:
  /// **'Planet 1'**
  String get spacePlanet1;

  /// No description provided for @spacePlanet2.
  ///
  /// In en, this message translates to:
  /// **'Planet 2'**
  String get spacePlanet2;

  /// No description provided for @spacePlanet3.
  ///
  /// In en, this message translates to:
  /// **'Planet 3'**
  String get spacePlanet3;

  /// No description provided for @spaceRocket.
  ///
  /// In en, this message translates to:
  /// **'Rocket'**
  String get spaceRocket;

  /// No description provided for @spaceShuttle.
  ///
  /// In en, this message translates to:
  /// **'Space Shuttle'**
  String get spaceShuttle;

  /// No description provided for @spaceUfo.
  ///
  /// In en, this message translates to:
  /// **'UFO'**
  String get spaceUfo;

  /// No description provided for @spaceAlien1.
  ///
  /// In en, this message translates to:
  /// **'Alien 1'**
  String get spaceAlien1;

  /// No description provided for @spaceAlien2.
  ///
  /// In en, this message translates to:
  /// **'Alien 2'**
  String get spaceAlien2;

  /// No description provided for @spaceAlien3.
  ///
  /// In en, this message translates to:
  /// **'Alien 3'**
  String get spaceAlien3;

  /// No description provided for @spaceAlien4.
  ///
  /// In en, this message translates to:
  /// **'Alien 4'**
  String get spaceAlien4;

  /// No description provided for @spaceAlien5.
  ///
  /// In en, this message translates to:
  /// **'Alien 5'**
  String get spaceAlien5;

  /// No description provided for @spaceAlien6.
  ///
  /// In en, this message translates to:
  /// **'Alien 6'**
  String get spaceAlien6;

  /// No description provided for @spaceAlien7.
  ///
  /// In en, this message translates to:
  /// **'Alien 7'**
  String get spaceAlien7;

  /// No description provided for @spaceAlien8.
  ///
  /// In en, this message translates to:
  /// **'Alien 8'**
  String get spaceAlien8;

  /// No description provided for @spaceAlien9.
  ///
  /// In en, this message translates to:
  /// **'Alien 9'**
  String get spaceAlien9;

  /// No description provided for @skySettings.
  ///
  /// In en, this message translates to:
  /// **'Sky Settings'**
  String get skySettings;

  /// No description provided for @spaceSettings.
  ///
  /// In en, this message translates to:
  /// **'Space Settings'**
  String get spaceSettings;

  /// No description provided for @samplePromiseTitle.
  ///
  /// In en, this message translates to:
  /// **'Please Set Up Promises!'**
  String get samplePromiseTitle;

  /// No description provided for @samplePromiseDesc.
  ///
  /// In en, this message translates to:
  /// **'We\'ve set up some sample \'promises\' for you! Please change the settings to suit your child.'**
  String get samplePromiseDesc;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @firstTimeBonus.
  ///
  /// In en, this message translates to:
  /// **'🌟 First Time Bonus! 🌟'**
  String get firstTimeBonus;

  /// No description provided for @parentSettings.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get parentSettings;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @navPromiseBoard.
  ///
  /// In en, this message translates to:
  /// **'Promises'**
  String get navPromiseBoard;

  /// No description provided for @navDressUp.
  ///
  /// In en, this message translates to:
  /// **'Dress Up'**
  String get navDressUp;

  /// No description provided for @navShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get navShop;

  /// No description provided for @navMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get navMusic;

  /// No description provided for @navWorldMap.
  ///
  /// In en, this message translates to:
  /// **'World'**
  String get navWorldMap;

  /// No description provided for @navBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get navBack;

  /// No description provided for @loginBonusTitle.
  ///
  /// In en, this message translates to:
  /// **'Login Bonus'**
  String get loginBonusTitle;

  /// No description provided for @loginBonusMessage.
  ///
  /// In en, this message translates to:
  /// **'Day {count} login this week!\nYou got 10 points!'**
  String loginBonusMessage(int count);

  /// No description provided for @loginBonusWeeklyTitle.
  ///
  /// In en, this message translates to:
  /// **'✨ This Week\'s Login Bonus ✨'**
  String get loginBonusWeeklyTitle;

  /// No description provided for @loginBonusResetNote.
  ///
  /// In en, this message translates to:
  /// **'*Resets every Monday'**
  String get loginBonusResetNote;

  /// No description provided for @loginBonusDay.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String loginBonusDay(int day);

  /// No description provided for @trialPromiseTitle.
  ///
  /// In en, this message translates to:
  /// **'Promise (Trial)'**
  String get trialPromiseTitle;

  /// No description provided for @loginBonusCongrats.
  ///
  /// In en, this message translates to:
  /// **'Yay!'**
  String get loginBonusCongrats;

  /// No description provided for @loginBonusReceive.
  ///
  /// In en, this message translates to:
  /// **'Get it!'**
  String get loginBonusReceive;

  /// No description provided for @cheerLabel.
  ///
  /// In en, this message translates to:
  /// **'Cheer'**
  String get cheerLabel;

  /// No description provided for @sadLabel.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get sadLabel;

  /// No description provided for @backupRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Backup and Restore'**
  String get backupRestoreTitle;

  /// No description provided for @backupServiceLinked.
  ///
  /// In en, this message translates to:
  /// **'Linked to this service'**
  String get backupServiceLinked;

  /// No description provided for @backupServiceGoogleDriveDesc.
  ///
  /// In en, this message translates to:
  /// **'Save data to Google Drive'**
  String get backupServiceGoogleDriveDesc;

  /// No description provided for @backupAction.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backupAction;

  /// No description provided for @restoreAction.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restoreAction;

  /// No description provided for @backupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup completed'**
  String get backupSuccess;

  /// No description provided for @backupFailure.
  ///
  /// In en, this message translates to:
  /// **'Backup failed'**
  String get backupFailure;

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data restored'**
  String get restoreSuccess;

  /// No description provided for @restoreFailure.
  ///
  /// In en, this message translates to:
  /// **'Restore failed'**
  String get restoreFailure;

  /// No description provided for @minutesLabel.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutesLabel;

  /// No description provided for @okAction.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okAction;

  /// No description provided for @notificationRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications? 🔔'**
  String get notificationRequestTitle;

  /// No description provided for @notificationRequestMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ll get a notification when it\'s time for a promise!\nTurn on notifications and keep having fun together✨'**
  String get notificationRequestMessage;

  /// No description provided for @notificationLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get notificationLater;

  /// No description provided for @notificationAccept.
  ///
  /// In en, this message translates to:
  /// **'Sure!'**
  String get notificationAccept;

  /// No description provided for @resetPromisesAction.
  ///
  /// In en, this message translates to:
  /// **'Reset Promises to Defaults'**
  String get resetPromisesAction;

  /// No description provided for @resetPromisesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all regular promises to their default values? This cannot be undone.'**
  String get resetPromisesConfirm;

  /// No description provided for @resetPromisesSuccess.
  ///
  /// In en, this message translates to:
  /// **'Regular promises have been reset.'**
  String get resetPromisesSuccess;

  /// No description provided for @tutorialStartBubble.
  ///
  /// In en, this message translates to:
  /// **'Starting your\n\'Promise\' here!'**
  String get tutorialStartBubble;

  /// No description provided for @tutorialShopBubble.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go\nshopping!'**
  String get tutorialShopBubble;

  /// No description provided for @tutorialCustomizeBubble.
  ///
  /// In en, this message translates to:
  /// **'You can change\nclothes here!'**
  String get tutorialCustomizeBubble;

  /// No description provided for @tutorialParentSettingsBubble.
  ///
  /// In en, this message translates to:
  /// **'Create your promises from here!'**
  String get tutorialParentSettingsBubble;

  /// No description provided for @helpMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'How to Play'**
  String get helpMenuTitle;

  /// No description provided for @helpMenuYakusoku.
  ///
  /// In en, this message translates to:
  /// **'Promise'**
  String get helpMenuYakusoku;

  /// No description provided for @helpMenuShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get helpMenuShop;

  /// No description provided for @helpMenuCustomize.
  ///
  /// In en, this message translates to:
  /// **'Dress-up'**
  String get helpMenuCustomize;

  /// No description provided for @helpMenuOthers.
  ///
  /// In en, this message translates to:
  /// **'Others (Settings, etc.)'**
  String get helpMenuOthers;

  /// No description provided for @helpMenuClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get helpMenuClose;

  /// No description provided for @tutorialParentRegularBubble.
  ///
  /// In en, this message translates to:
  /// **'Set promises\nfrom here!'**
  String get tutorialParentRegularBubble;

  /// No description provided for @tutorialParentAddBubble.
  ///
  /// In en, this message translates to:
  /// **'Tap this button\nto add a promise!'**
  String get tutorialParentAddBubble;

  /// No description provided for @tutorialParentDeleteBubble.
  ///
  /// In en, this message translates to:
  /// **'Tap this button\nto remove a promise!'**
  String get tutorialParentDeleteBubble;

  /// No description provided for @tutorialParentBackBubble.
  ///
  /// In en, this message translates to:
  /// **'Go back\nfrom here!'**
  String get tutorialParentBackBubble;

  /// No description provided for @tutorialParentStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Try with a sample promise!'**
  String get tutorialParentStep3Title;

  /// No description provided for @tutorialParentStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap the **+ button** on the left to add a promise.\nTry adding **\"Trial promise\"**!'**
  String get tutorialParentStep3Desc;

  /// No description provided for @tutorialParentStep5Title.
  ///
  /// In en, this message translates to:
  /// **'Time to set up promises!'**
  String get tutorialParentStep5Title;

  /// No description provided for @tutorialParentStep5Desc.
  ///
  /// In en, this message translates to:
  /// **'Use the suggestions or \"Custom Add\" to set up **promises that suit your child**.\nWhen you\'re done, tap **\"Back\"** to return to the home screen!'**
  String get tutorialParentStep5Desc;

  /// No description provided for @tutorialParentCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Promises are ready!'**
  String get tutorialParentCompleteTitle;

  /// No description provided for @tutorialParentCompleteDesc.
  ///
  /// In en, this message translates to:
  /// **'The **promise setup** is complete!\nLet\'s try the promises on the home screen!'**
  String get tutorialParentCompleteDesc;

  /// No description provided for @promiseNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Time for \"{title}\"!'**
  String promiseNotificationTitle(String title);

  /// No description provided for @promiseNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'{icon} Let\'s start your promise!'**
  String promiseNotificationBody(String icon);

  /// No description provided for @weeklyNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'How are this week\'s Promises? 🌟'**
  String get weeklyNotificationTitle;

  /// No description provided for @weeklyNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Taking a quick break? ☕️ Let\'s check your child\'s progress in the app!'**
  String get weeklyNotificationBody;

  /// No description provided for @alreadyAddedPromise.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" is already added'**
  String alreadyAddedPromise(String title);

  /// No description provided for @customAdd.
  ///
  /// In en, this message translates to:
  /// **'Custom Add'**
  String get customAdd;

  /// No description provided for @recommendedTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommendedTitle;

  /// No description provided for @currentPromiseTitle.
  ///
  /// In en, this message translates to:
  /// **'Current Promises'**
  String get currentPromiseTitle;

  /// No description provided for @dragToAddInstruction.
  ///
  /// In en, this message translates to:
  /// **'Drag from the left\nto add!'**
  String get dragToAddInstruction;

  /// No description provided for @recPromiseToilet.
  ///
  /// In en, this message translates to:
  /// **'Go to the toilet'**
  String get recPromiseToilet;

  /// No description provided for @recPromiseBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get recPromiseBreakfast;

  /// No description provided for @recPromiseBrushTeethMorning.
  ///
  /// In en, this message translates to:
  /// **'Brush teeth (Morning)'**
  String get recPromiseBrushTeethMorning;

  /// No description provided for @recPromiseGetDressed.
  ///
  /// In en, this message translates to:
  /// **'Get dressed'**
  String get recPromiseGetDressed;

  /// No description provided for @recPromiseShoes.
  ///
  /// In en, this message translates to:
  /// **'Arrange shoes'**
  String get recPromiseShoes;

  /// No description provided for @recPromiseLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get recPromiseLunch;

  /// No description provided for @recPromiseWashHands.
  ///
  /// In en, this message translates to:
  /// **'Wash hands'**
  String get recPromiseWashHands;

  /// No description provided for @recPromiseHomework.
  ///
  /// In en, this message translates to:
  /// **'Homework'**
  String get recPromiseHomework;

  /// No description provided for @recPromisePractice.
  ///
  /// In en, this message translates to:
  /// **'Practice / Lessons'**
  String get recPromisePractice;

  /// No description provided for @recPromiseReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get recPromiseReading;

  /// No description provided for @recPromiseHelp.
  ///
  /// In en, this message translates to:
  /// **'Help out'**
  String get recPromiseHelp;

  /// No description provided for @recPromiseCleanUp.
  ///
  /// In en, this message translates to:
  /// **'Clean up'**
  String get recPromiseCleanUp;

  /// No description provided for @recPromiseBath.
  ///
  /// In en, this message translates to:
  /// **'Take a bath'**
  String get recPromiseBath;

  /// No description provided for @recPromisePajamas.
  ///
  /// In en, this message translates to:
  /// **'Change to pajamas'**
  String get recPromisePajamas;

  /// No description provided for @recPromiseDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get recPromiseDinner;

  /// No description provided for @recPromiseBrushTeethNight.
  ///
  /// In en, this message translates to:
  /// **'Brush teeth (Night)'**
  String get recPromiseBrushTeethNight;

  /// No description provided for @recPromisePrepareNextDay.
  ///
  /// In en, this message translates to:
  /// **'Prepare for tomorrow'**
  String get recPromisePrepareNextDay;

  /// No description provided for @recPromiseSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get recPromiseSleep;

  /// No description provided for @recPromiseReadBook.
  ///
  /// In en, this message translates to:
  /// **'Read a book'**
  String get recPromiseReadBook;

  /// No description provided for @recPromiseBathCleaning.
  ///
  /// In en, this message translates to:
  /// **'Clean the bath'**
  String get recPromiseBathCleaning;

  /// No description provided for @recPromiseErrand.
  ///
  /// In en, this message translates to:
  /// **'Run an errand'**
  String get recPromiseErrand;

  /// No description provided for @durationAndPoints.
  ///
  /// In en, this message translates to:
  /// **'{duration} min / {points} pt'**
  String durationAndPoints(String duration, String points);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'bn', 'en', 'hi', 'ja', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'bn': return AppLocalizationsBn();
    case 'en': return AppLocalizationsEn();
    case 'hi': return AppLocalizationsHi();
    case 'ja': return AppLocalizationsJa();
    case 'ur': return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
