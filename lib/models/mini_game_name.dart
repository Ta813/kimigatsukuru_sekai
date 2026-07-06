import 'package:flutter/material.dart';
import 'package:kimigatsukuru_sekai/l10n/app_localizations.dart';

class MiniGameName {
  static String getMiniGameName(String minigameName, BuildContext context) {
    String localizedName;
    switch (minigameName) {
      case 'いつものせかい':
        localizedName = AppLocalizations.of(context)!.courseNameWorld;
        break;
      case 'おおきなしま':
        localizedName = AppLocalizations.of(context)!.courseNameIsland;
        break;
      case 'うみ':
        localizedName = AppLocalizations.of(context)!.courseNameSea;
        break;
      case 'そら':
        localizedName = AppLocalizations.of(context)!.courseNameSky;
        break;
      case 'うちゅう':
        localizedName = AppLocalizations.of(context)!.courseNameSpace;
        break;
      case 'ジャングル':
        localizedName = AppLocalizations.of(context)!.courseNameJungle;
        break;
      case 'さばく':
        localizedName = AppLocalizations.of(context)!.courseNameDesert;
        break;
      default:
        localizedName = minigameName;
    }
    return localizedName;
  }
}
