// lib/shared_prefs_helper.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/lock_mode.dart';

// ★ 連携サービスの種類を定義
enum BackupServiceKbn { none, googleDrive, icloud }

class SharedPrefsHelper {
  // SharedPreferencesのインスタンスを取得するためのキー
  static const String _regularPromisesKey = 'regular_promises';

  static Future<List<Map<String, dynamic>>> checkAndSaveDefaultPromises(
    BuildContext context,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? stringList = prefs.getStringList(_regularPromisesKey);

    // もし何も保存されていなかったら（初回起動時など）
    if (stringList == null || stringList.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      final defaultPromises = [
        {
          'title': l10n.promiseDefault1Title,
          'time': '07:00',
          'duration': 30,
          'points': 20,
        },
        {
          'title': l10n.promiseDefault2Title,
          'time': '07:30',
          'duration': 10,
          'points': 10,
        },
        {
          'title': l10n.promiseDefault3Title,
          'time': '18:00',
          'duration': 10,
          'points': 10,
        },
        {
          'title': l10n.promiseDefault4Title,
          'time': '19:00',
          'duration': 30,
          'points': 20,
        },
        {
          'title': l10n.promiseDefault5Title,
          'time': '19:30',
          'duration': 10,
          'points': 10,
        },
        {
          'title': l10n.promiseDefault6Title,
          'time': '20:00',
          'duration': 10,
          'points': 10,
        },
      ];
      // デフォルトのサンプルやくそくをSharedPreferencesに保存
      await saveRegularPromises(defaultPromises);
      return defaultPromises;
    }

    // すでにデータがあれば、それを読み込んで返す
    return stringList
        .map((string) => json.decode(string) as Map<String, dynamic>)
        .toList();
  }

  // やくそくリストを保存する
  static Future<void> saveRegularPromises(
    List<Map<String, dynamic>> promises,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    // List<Map> を、保存できる形式（文字列のリスト）に変換します
    final List<String> stringList = promises
        .map((promise) => json.encode(promise))
        .toList();
    await prefs.setStringList(_regularPromisesKey, stringList);
  }

  // やくそくリストを読み込む
  static Future<List<Map<String, dynamic>>> loadRegularPromises(
    BuildContext context,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? stringList = prefs.getStringList(_regularPromisesKey);

    if (stringList == null || stringList.isEmpty) {
      // デフォルトのサンプルやくそくをSharedPreferencesに保存しつつ、それを返す
      return checkAndSaveDefaultPromises(context);
    }

    // 文字列のリストを、元の List<Map> に戻します
    final List<Map<String, dynamic>> promises = stringList
        .map((string) => json.decode(string) as Map<String, dynamic>)
        .toList();
    return promises;
  }

  // --- ここから緊急のやくそく関連 ---
  static const String _emergencyPromiseKey = 'emergency_promise';

  // 緊急のやくそくを保存する (1つだけ)
  static Future<void> saveEmergencyPromise(
    Map<String, dynamic>? promise,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    if (promise == null) {
      // もしnullなら、保存されているデータを削除
      await prefs.remove(_emergencyPromiseKey);
    } else {
      // Mapを文字列に変換して保存
      await prefs.setString(_emergencyPromiseKey, json.encode(promise));
    }
  }

  // 緊急のやくそくを読み込む
  static Future<Map<String, dynamic>?> loadEmergencyPromise() async {
    final prefs = await SharedPreferences.getInstance();
    final String? promiseString = prefs.getString(_emergencyPromiseKey);

    if (promiseString == null) {
      // 何も保存されていなければ、nullを返す
      return null;
    }
    // 文字列をMapに戻して返す
    return json.decode(promiseString) as Map<String, dynamic>;
  }

  // --- ここからポイント関連を追加 ---
  static const String _pointsKey = 'user_points';

  // ポイントを保存する
  static Future<void> savePoints(int points) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pointsKey, points);
  }

  // ポイントを読み込む
  static Future<int> loadPoints() async {
    final prefs = await SharedPreferences.getInstance();
    // 保存された値がなければ、初期値として0を返す
    return prefs.getInt(_pointsKey) ?? 0;
  }

  // ここから達成記録関連 ---
  static const String _completedPromisesKey = 'completed_promises';

  // 新しい達成記録を追加する
  static Future<void> addCompletionRecord(String promiseTitle) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    // 日付を '2025-8-12' のような文字列で記録
    final todayString = "${today.year}-${today.month}-${today.day}";

    final newRecord = {'title': promiseTitle, 'date': todayString};

    // 既存の記録を読み込む
    final List<String> recordsString =
        prefs.getStringList(_completedPromisesKey) ?? [];
    recordsString.add(json.encode(newRecord));

    // 新しい記録を追加して保存
    await prefs.setStringList(_completedPromisesKey, recordsString);
  }

  // 今日の達成済みやくそくの「名前リスト」を読み込む
  static Future<List<String>> loadTodaysCompletedPromiseTitles() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayString = "${today.year}-${today.month}-${today.day}";

    final List<String> recordsString =
        prefs.getStringList(_completedPromisesKey) ?? [];
    if (recordsString.isEmpty) return [];

    // 文字列リストを元のMapリストに戻し、今日の日付のものだけをフィルタリング
    return recordsString
        .map((record) => json.decode(record) as Map<String, dynamic>)
        .where((record) => record['date'] == todayString)
        .map((record) => record['title'] as String)
        .toList();
  }

  // --- ここから購入済みアイテム関連を追加 ---
  static const String _purchasedItemsKey = 'purchased_items';

  // 購入済みアイテムのリストを読み込む
  static Future<List<String>> loadPurchasedItems() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_purchasedItemsKey) ?? [];
  }

  // 購入済みアイテムを追加する
  static Future<void> addPurchasedItem(String itemName) async {
    final prefs = await SharedPreferences.getInstance();
    // まず現在のリストを読み込む
    final List<String> items = await loadPurchasedItems();
    // 新しいアイテムを追加して、重複がなければ保存
    if (!items.contains(itemName)) {
      items.add(itemName);
      await prefs.setStringList(_purchasedItemsKey, items);
    }
  }

  // --- ここから装備中アイテム関連を追加 ---
  static const String _equippedClothesKey = 'equipped_clothes';
  static const String _equippedHouseKey = 'equipped_house';
  static const String _equippedCharactersKey = 'equippedCharacters';
  static const String _characterPositionsKey = 'characterPositions';
  static const String _equippedItemsKey = 'equipped_items';

  // 装備中のアイテムを保存する
  static Future<void> saveEquippedItem(String type, String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    if (type == 'clothes') {
      await prefs.setString(_equippedClothesKey, imagePath);
    } else if (type == 'house') {
      await prefs.setString(_equippedHouseKey, imagePath);
    }
  }

  // 装備中の服を読み込む
  static Future<String?> loadEquippedClothes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_equippedClothesKey);
  }

  // 装備中の家を読み込む
  static Future<String?> loadEquippedHouse() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_equippedHouseKey);
  }

  // ★複数応援キャラのパスを保存するメソッド
  static Future<void> saveEquippedCharacters(List<String> paths) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_equippedCharactersKey, paths);
  }

  // ★複数応援キャラのパスを読み込むメソッド
  static Future<List<String>> loadEquippedCharacters() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_equippedCharactersKey) ??
        ['assets/images/character_usagi.gif'];
  }

  // キャラクターの位置情報 (avatarと、各応援キャラのIDで管理できるように修正)
  static Future<void> saveCharacterPosition(String id, Offset position) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_characterPositionsKey:$id';
    await prefs.setString(key, '${position.dx},${position.dy}');
  }

  static Future<Offset?> loadCharacterPosition(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_characterPositionsKey:$id';
    final positionString = prefs.getString(key);
    if (positionString != null) {
      final parts = positionString.split(',');
      if (parts.length == 2) {
        return Offset(double.parse(parts[0]), double.parse(parts[1]));
      }
    }
    return null;
  }

  // ガイド表示済みフラグのキー
  static const String _guideShownKey = 'guide_shown';

  // ガイドがすでに表示されたかチェックする
  static Future<bool> isGuideShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_guideShownKey) ?? false;
  }

  // ガイドを表示済みにセットする
  static Future<void> setGuideShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_guideShownKey, true);
  }

  // 配置するアイテムのリストを保存するメソッド
  static Future<void> saveEquippedItems(List<String> paths) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_equippedItemsKey, paths);
  }

  // 配置するアイテムのリストを読み込むメソッド
  static Future<List<String>> loadEquippedItems() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_equippedItemsKey) ?? [];
  }

  // ★言語設定用のキーを追加
  static const String _localeKey = 'locale';

  // ★言語設定を保存するメソッドを追加
  static Future<void> saveLocale(String? languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    if (languageCode == null) {
      await prefs.remove(_localeKey);
    } else {
      await prefs.setString(_localeKey, languageCode);
    }
  }

  // ★保存された言語設定を読み込むメソッドを追加
  static Future<String?> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localeKey);
  }

  // 家具の装備情報を保存
  static Future<void> saveEquippedFurniture(List<String> furniture) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('equipped_furniture', furniture);
  }

  // 家具の装備情報を読み込み
  static Future<List<String>> loadEquippedFurniture() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('equipped_furniture') ?? [];
  }

  // 家のアイテムの装備情報を保存
  static Future<void> saveEquippedHouseItems(List<String> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('equipped_house_items', items);
  }

  // 家のアイテムの装備情報を読み込み
  static Future<List<String>> loadEquippedHouseItems() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('equipped_house_items') ?? [];
  }

  // 「家に入ったことがあるか」を保存する
  static Future<void> setHasEnteredHouse(bool hasEntered) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_entered_house', hasEntered);
  }

  // 「家に入ったことがあるか」を読み込む
  static Future<bool> getHasEnteredHouse() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_entered_house') ?? false; // デフォルトはfalse
  }

  static Future<void> saveSelectedBgm(String trackName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_bgm', trackName);
  }

  static Future<String?> loadSelectedBgm() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selected_bgm');
  }

  static Future<void> saveSelectedFocusBgm(String trackName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_focus_bgm', trackName);
  }

  static Future<String?> loadSelectedFocusBgm() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selected_focus_bgm');
  }

  // ロックモードを保存
  static Future<void> saveLockMode(LockMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lock_mode', mode.name); // enumの名前を文字列として保存
  }

  // ロックモードを読み込み
  static Future<LockMode> loadLockMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeName = prefs.getString('lock_mode');
    // 保存された文字列からenumに変換。保存されていなければデフォルトでmathを返す
    return LockMode.values.firstWhere(
      (e) => e.name == modeName,
      orElse: () => LockMode.math,
    );
  }

  // 4桁パスワードを保存
  static Future<void> savePasscode(String passcode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('parent_passcode', passcode);
  }

  // 4桁パスワードを読み込み
  static Future<String?> loadPasscode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('parent_passcode');
  }

  // レベルを保存
  static Future<void> saveLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('player_level', level);
  }

  // レベルを読み込み (保存されていなければレベル1を返す)
  static Future<int> loadLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('player_level') ?? 1;
  }

  // 経験値を保存
  static Future<void> saveExperience(int exp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('player_experience', exp);
  }

  // 経験値を読み込み
  static Future<int> loadExperience() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('player_experience') ?? 0;
  }

  // 世界地図画面のガイドを表示したかを保存
  static Future<void> setWorldMapGuideShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('world_map_guide_shown', true);
  }

  // 世界地図画面のガイドを表示したかを取得
  static Future<bool> getWorldMapGuideShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('world_map_guide_shown') ?? false; // デフォルトはfalse
  }

  // 建物の装備情報を保存
  static Future<void> saveEquippedBuildings(List<String> furniture) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('equipped_buildings', furniture);
  }

  // 建物の装備情報を読み込み
  static Future<List<String>> loadEquippedBuildings() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('equipped_buildings') ?? [];
  }

  // 乗り物の装備情報を保存
  static Future<void> saveEquippedVehicles(List<String> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('equipped_vehicles', items);
  }

  // 乗り物の装備情報を読み込み
  static Future<List<String>> loadEquippedVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('equipped_vehicles') ?? [];
  }

  // 最後にアプリを利用した日付を保存
  static Future<void> saveLastActiveDate(String dateString) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_active_date', dateString);
  }

  // 最後にアプリを利用した日付を読み込み
  static Future<String?> loadLastActiveDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_active_date');
  }

  // 今日の達成済みやくそくの記録をクリアする
  static Future<void> clearTodaysCompletedPromises() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('todays_completed_titles');
  }

  // データ収集の同意状況を保存
  static Future<void> setDataCollectionConsent(bool consented) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('data_collection_consent', consented);
  }

  // データ収集の同意状況を読み込み
  static Future<bool> hasConsentedToDataCollection() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('data_collection_consent') ?? false;
  }

  static Future<void> saveChildNames(List<Map<String, String>> names) async {
    final prefs = await SharedPreferences.getInstance();
    // ★ MapのリストをJSON文字列にエンコードして保存
    String jsonString = jsonEncode(names);
    await prefs.setString(
      'child_names_with_honorifics',
      jsonString,
    ); // ★ キー名を変更
  }

  static Future<List<Map<String, String>>> loadChildNames() async {
    final prefs = await SharedPreferences.getInstance();
    // ★ JSON文字列を読み込み
    String? jsonString = prefs.getString(
      'child_names_with_honorifics',
    ); // ★ キー名を変更
    if (jsonString != null) {
      try {
        // ★ JSON文字列をMapのリストにデコードして返す
        List<dynamic> decodedList = jsonDecode(jsonString);
        // 型を明示的に変換
        List<Map<String, String>> namesList = decodedList
            .map((item) => Map<String, String>.from(item))
            .toList();
        return namesList;
      } catch (e) {
        print('Error decoding child names: $e');
        return []; // デコード失敗時は空リスト
      }
    }
    return []; // 保存されていなければ空リスト
  }

  // 名前設定画面に遷移したことがあるかを保存
  static Future<void> setHasVisitedChildNameSettings(bool visited) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('visited_child_name_settings', visited);
  }

  // 名前設定画面に遷移したことがあるかを取得
  static Future<bool> hasVisitedChildNameSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('visited_child_name_settings') ?? false; // デフォルトはfalse
  }

  // 海のアイテムの装備情報を保存
  static Future<void> saveEquippedSeaItems(List<String> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('equipped_sea_items', items);
  }

  // 海のアイテムの装備情報を読み込み
  static Future<List<String>> loadEquippedSeaItems() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('equipped_sea_items') ?? [];
  }

  // 海の生き物の装備情報を保存
  static Future<void> saveEquippedLivings(List<String> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('equipped_livings', items);
  }

  // 海の生き物の装備情報を読み込み
  static Future<List<String>> loadEquippedLivings() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('equipped_livings') ?? [];
  }

  // ★ 連携中のバックアップサービスを保存
  static Future<void> saveBackupService(BackupServiceKbn service) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('backup_service', service.name);
  }

  // ★ 連携中のバックアップサービスを読み込み
  static Future<BackupServiceKbn> loadBackupService() async {
    final prefs = await SharedPreferences.getInstance();
    final serviceName = prefs.getString('backup_service');
    return BackupServiceKbn.values.firstWhere(
      (e) => e.name == serviceName,
      orElse: () => BackupServiceKbn.none, // デフォルトは「連携なし」
    );
  }

  // ★ 全てのデータをJSON文字列としてエクスポートする
  static Future<String> exportDataAsJson() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();

    final Map<String, dynamic> allData = {};
    for (String key in allKeys) {
      allData[key] = prefs.get(key);
    }

    return jsonEncode(allData);
  }

  // ★ JSON文字列からデータをインポート（復元）する
  static Future<void> importDataFromJson(String jsonString) async {
    final prefs = await SharedPreferences.getInstance();

    // まず現在のデータをすべてクリアする（任意）
    // await prefs.clear();
    // ※ clear() を使うと連携サービスの設定も消えてしまうので、
    // キーをループして削除する方が安全かもしれません。
    // ここでは、読み書きの競合を防ぐため、キーごとに上書きします。

    Map<String, dynamic> allData = jsonDecode(jsonString);

    for (String key in allData.keys) {
      final value = allData[key];
      // 型に合わせてデータを書き戻す
      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      } else if (value is List) {
        // List<String> のみを想定
        await prefs.setStringList(key, value.cast<String>());
      }
    }
  }

  // 空のアイテムの装備情報を保存
  static Future<void> saveEquippedSkyItems(List<String> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('equipped_sky_items', items);
  }

  // 空のアイテムの装備情報を読み込み
  static Future<List<String>> loadEquippedSkyItems() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('equipped_sky_items') ?? [];
  }

  // 空の生き物の装備情報を保存
  static Future<void> saveEquippedSkyLivings(List<String> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('equipped_sky_livings', items);
  }

  // 空の生き物の装備情報を読み込み
  static Future<List<String>> loadEquippedSkyLivings() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('equipped_sky_livings') ?? [];
  }

  // 宇宙のアイテムの装備情報を保存
  static Future<void> saveEquippedSpaceItems(List<String> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('equipped_space_items', items);
  }

  // 宇宙のアイテムの装備情報を読み込み
  static Future<List<String>> loadEquippedSpaceItems() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('equipped_space_items') ?? [];
  }

  // 宇宙の生き物の装備情報を保存
  static Future<void> saveEquippedSpaceLivings(List<String> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('equipped_space_livings', items);
  }

  // 宇宙の生き物の装備情報を読み込み
  static Future<List<String>> loadEquippedSpaceLivings() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('equipped_space_livings') ?? [];
  }
}
