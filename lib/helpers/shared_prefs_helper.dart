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

  static List<Map<String, dynamic>> _getDefaultPromises(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      {
        'title': l10n.promiseDefault1Title,
        'icon': '🍳',
        'time': '07:00',
        'duration': 30,
        'points': 20,
      },
      {
        'title': l10n.promiseDefault2Title,
        'icon': '🪥',
        'time': '07:30',
        'duration': 10,
        'points': 10,
      },
      {
        'title': l10n.promiseDefault3Title,
        'icon': '👕',
        'time': '07:45',
        'duration': 10,
        'points': 10,
      },
      {
        'title': l10n.promiseDefault4Title,
        'icon': '🛀',
        'time': '18:00',
        'duration': 30,
        'points': 20,
      },
      {
        'title': l10n.promiseDefault5Title,
        'icon': '🍛',
        'time': '19:00',
        'duration': 30,
        'points': 20,
      },
      {
        'title': l10n.promiseDefault6Title,
        'icon': '🪥',
        'time': '19:30',
        'duration': 10,
        'points': 10,
      },
      {
        'title': l10n.promiseDefault7Title,
        'icon': '💤',
        'time': '20:00',
        'duration': 10,
        'points': 10,
      },
    ];
  }

  static Future<List<Map<String, dynamic>>> checkAndSaveDefaultPromises(
    BuildContext context,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? stringList = prefs.getStringList(_regularPromisesKey);

    // もし何も保存されていなかったら（初回起動時など）
    if (stringList == null || stringList.isEmpty) {
      final defaultPromises = _getDefaultPromises(context);
      // デフォルトのサンプルやくそくをSharedPreferencesに保存
      await saveRegularPromises(defaultPromises);
      return defaultPromises;
    }

    // すでにデータがあれば、それを読み込んで返す
    return stringList
        .map((string) => json.decode(string) as Map<String, dynamic>)
        .toList();
  }

  static Future<void> resetToDefaultRegularPromises(
    BuildContext context,
  ) async {
    final defaultPromises = _getDefaultPromises(context);
    await saveRegularPromises(defaultPromises);
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

  // デバッグ用：仮想の現在日付をセットする
  static Future<void> setDebugSimulatedDate(DateTime? date) async {
    final prefs = await SharedPreferences.getInstance();
    if (date == null) {
      await prefs.remove('debug_simulated_date');
    } else {
      await prefs.setString('debug_simulated_date', date.toIso8601String());
    }
  }

  // デバッグ用：仮想の現在日付を取得する
  static Future<DateTime> getSimulatedDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString('debug_simulated_date');
    if (dateStr != null) {
      try {
        return DateTime.parse(dateStr);
      } catch (_) {}
    }
    return DateTime.now();
  }

  // ここから達成記録関連 ---
  static const String _completedPromisesKey = 'completed_promises';

  // 新しい達成記録を追加する
  static Future<void> addCompletionRecord(String promiseTitle) async {
    final prefs = await SharedPreferences.getInstance();
    final today = await getSimulatedDate();
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
    final today = await getSimulatedDate();
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

  // --- ここからスキップ記録関連 ---
  static const String _skippedPromisesKey = 'skipped_promises';

  static Future<void> addSkippedRecord(String promiseTitle) async {
    final prefs = await SharedPreferences.getInstance();
    final today = await getSimulatedDate();
    final todayString = "${today.year}-${today.month}-${today.day}";

    final newRecord = {'title': promiseTitle, 'date': todayString};

    final List<String> recordsString =
        prefs.getStringList(_skippedPromisesKey) ?? [];
    recordsString.add(json.encode(newRecord));

    await prefs.setStringList(_skippedPromisesKey, recordsString);
  }

  static Future<List<String>> loadTodaysSkippedPromiseTitles() async {
    final prefs = await SharedPreferences.getInstance();
    final today = await getSimulatedDate();
    final todayString = "${today.year}-${today.month}-${today.day}";

    final List<String> recordsString =
        prefs.getStringList(_skippedPromisesKey) ?? [];
    if (recordsString.isEmpty) return [];

    return recordsString
        .map((record) => json.decode(record) as Map<String, dynamic>)
        .where((record) => record['date'] == todayString)
        .map((record) => record['title'] as String)
        .toList();
  }

  // 過去すべての達成記録を日ごとに集計し、Heatmap用のMapを返す
  static Future<Map<DateTime, int>> loadCompletionHeatmapData() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> recordsString =
        prefs.getStringList(_completedPromisesKey) ?? [];

    Map<DateTime, int> heatmapData = {};
    for (String recordStr in recordsString) {
      try {
        final record = json.decode(recordStr) as Map<String, dynamic>;
        final dateStr = record['date'] as String;
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final day = int.parse(parts[2]);
          // 時間を除いた日付のみにする
          final date = DateTime(year, month, day);
          heatmapData[date] = (heatmapData[date] ?? 0) + 1;
        }
      } catch (e) {
        // フォーマットエラーなどは無視して次へ
        print('Error parsing completion record: $e');
      }
    }
    return heatmapData;
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

  // こどものチュートリアル開始 フラグのキー
  static const String _childTutorialStartKey = 'child_tutorial_start';
  // おやのチュートリアル開始フラグのキー
  static const String _parentTutorialStartKey = 'parent_tutorial_start';
  // チュートリアルのステータス
  static const String tutorialPhaseRegular = 'regular';
  static const String tutorialPhaseStart = 'start';
  static const String tutorialPhaseFinish = 'finish';

  // こどものチュートリアルがすでに開始されたかチェックする
  static Future<String> getChildTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_childTutorialStartKey) ?? tutorialPhaseRegular;
  }

  // こどものチュートリアルを開始済みにセットする
  static Future<void> setChildTutorial(String step) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_childTutorialStartKey, step);
  }

  // おやのチュートリアルがすでに開始されたかチェックする
  static Future<String> getParentTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_parentTutorialStartKey) ?? tutorialPhaseRegular;
  }

  // おやのチュートリアルを開始済みにセットする
  static Future<void> setParentTutorial(String step) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_parentTutorialStartKey, step);
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
    // 保存された文字列からenumに変換。保存されていなければデフォルトでnoneを返す
    return LockMode.values.firstWhere(
      (e) => e.name == modeName,
      orElse: () => LockMode.none,
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

  // 特定の機能のガイドを表示したかどうかを確認する
  static Future<bool> isFeatureGuideShown(String featureKey) async {
    final prefs = await SharedPreferences.getInstance();
    // デフォルトは false（まだ見ていない）
    return prefs.getBool('guide_$featureKey') ?? false;
  }

  // 特定の機能のガイドを表示済みにする
  static Future<void> setFeatureGuideShown(String featureKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('guide_$featureKey', true);
  }

  // --- おやの設定ボタンの点滅フラグ（ホーム画面用） ---
  static Future<bool> isFirstHomeAdvice() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_first_home_advice') ?? true;
  }

  static Future<bool> isFirstHomeRegular() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_first_home_regular') ?? true;
  }

  // --- チュートリアル各ステップの表示済みフラグ ---
  static const String tutorialStepPromiseKey = 'tutorial_step_promise_shown';
  static const String tutorialStepShopKey = 'tutorial_step_shop_shown';
  static const String tutorialStepCustomizeKey =
      'tutorial_step_customize_shown';
  static const String tutorialStepMoveKey = 'tutorial_step_move_shown';
  static const String tutorialStepParentSetupShownKey =
      'tutorial_step_parent_setup_shown';

  static const String tutorialPurchasedItemKey = 'tutorial_purchased_item';
  static const String tutorialPurchasedTypeKey = 'tutorial_purchased_type';

  static Future<void> setTutorialPurchasedItem(
    String itemPath,
    String type,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tutorialPurchasedItemKey, itemPath);
    await prefs.setString(tutorialPurchasedTypeKey, type);
  }

  static Future<String?> getTutorialPurchasedItem() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tutorialPurchasedItemKey);
  }

  static Future<String?> getTutorialPurchasedType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tutorialPurchasedTypeKey);
  }

  static Future<bool> isTutorialStepShown(String stepKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(stepKey) ?? false;
  }

  static Future<void> setTutorialStepShown(String stepKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(stepKey, true);
  }

  // --- チュートリアルとガイドのリセット（デバッグ用） ---
  static Future<void> resetTutorialStatus() async {
    final prefs = await SharedPreferences.getInstance();

    // チュートリアルステップのフラグを削除
    await prefs.remove(tutorialStepPromiseKey);
    await prefs.remove(tutorialStepShopKey);
    await prefs.remove(tutorialStepCustomizeKey);
    await prefs.remove(tutorialStepMoveKey);
    await prefs.remove(tutorialStepParentSetupShownKey);
    await prefs.remove(tutorialPurchasedItemKey);
    await prefs.remove(tutorialPurchasedTypeKey);
    await prefs.remove(_childTutorialStartKey);
    await prefs.remove(_parentTutorialStartKey);
    await prefs.remove(_keyHasVisitedMissionScreen);

    // ホーム画面のアドバイスフラグをリセット（trueに戻す）
    await prefs.remove('is_first_home_advice');
    await prefs.remove('is_first_home_regular');

    // 'guide_' で始まる全てのキーを削除
    final allKeys = prefs.getKeys();
    for (String key in allKeys) {
      if (key.startsWith('guide_')) {
        await prefs.remove(key);
      }
    }
  }

  // --- ミッション用キー ---
  static const String _keyCumulativeShopCount =
      'cumulative_shop_count'; // 買い物回数
  static const String _keyHasChangedBgm = 'has_changed_bgm'; // BGM変更フラグ
  static const String _keyHasOpenedWorldMap =
      'has_opened_world_map'; // マップ閲覧フラグ
  static const String _keyClaimedMissionIds =
      'claimed_mission_ids'; // 報酬受け取り済みミッションIDリスト
  static const String _keyCumulativePoints = 'cumulative_points'; // 累計獲得ポイント
  static const String _keyHasVisitedBigIsland =
      'has_visited_big_island'; // 大きな島
  static const String _keyHasVisitedSea = 'has_visited_sea'; // 海
  static const String _keyHasVisitedSky = 'has_visited_sky'; // 空
  static const String _keyHasVisitedSpace = 'has_visited_space'; // 宇宙
  static const String _keyHasVisitedPromiseBoard =
      'has_visited_promise_board'; // やくそくボード訪問フラグ
  static const String _keyCumulativePromiseCount =
      'cumulative_promise_count'; // 累計やくそく達成回数
  // --- 累計系ミッション（ログイン日数） ---
  static const String _keyCumulativeLoginDays = 'cumulative_login_days';
  static const String _keyLastLoginDateForCount = 'last_login_date_for_count';
  // --- 累計系ミッション（ログイン日数） ---
  static const List<int> loginTargets = [
    1, // はじめてのログイン！
    2, // 2日連続の壁を越えさせる
    3,
    5, // 3日坊主を乗り越えたご褒美
    7, // 1週間！
    10,
    14, // 2週間！
    21, // 🌟変更：14日〜28日の「魔の2週間」を埋めるため21日を追加
    30, // 1ヶ月！
    40,
    50,
    60,
    80,
    100,
    150,
    200,
    250,
    300,
    365, // 1周年！
  ];

  // --- 累計系ミッション（買い物） ---
  static const List<int> shopTargets = [
    1, // はじめてのお買い物体験をすぐ褒める
    3,
    5,
    10,
    15,
    20,
    30,
    50,
    75,
    100,
  ];

  // --- 累計系ミッション（レベル） ---
  static const List<int> levelTargets = [
    2, // レベルアップの仕組みを理解させるための最速ご褒美
    3,
    5,
    7, // 🌟変更：5〜10の間に「7」を挟んで中だるみ防止
    10,
    12, // 🌟変更：10以降も少し刻む
    15,
    20,
    25,
    30,
    40,
    50,
  ];

  // --- 累計系ミッション（ポイント） ---
  // 最初は「もらえるポイント」の嬉しさを知ってもらうために細かく設定
  static const List<int> pointTargets = [
    100, // チュートリアルクリアですぐもらえる！
    300,
    500,
    800,
    1000,
    1500,
    2000,
    2500,
    3000,
    4000, // ここから少しずつ間隔を広げる
    5000,
    6000,
    7000,
    8500,
    10000,
  ];

  // --- 買い物回数の管理 ---
  static Future<int> loadCumulativeShopCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCumulativeShopCount) ?? 0;
  }

  static Future<void> incrementShopCount() async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_keyCumulativeShopCount) ?? 0;
    await prefs.setInt(_keyCumulativeShopCount, current + 1);
  }

  // --- BGM変更フラグの管理 ---
  static Future<bool> getHasChangedBgm() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasChangedBgm) ?? false;
  }

  static Future<void> setHasChangedBgm(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasChangedBgm, value);
  }

  // --- 世界マップ閲覧フラグの管理 ---
  static Future<bool> getHasOpenedWorldMap() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasOpenedWorldMap) ?? false;
  }

  static Future<void> setHasOpenedWorldMap(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasOpenedWorldMap, value);
  }

  // --- 報酬受け取り済みミッションIDの管理 ---
  // ID例: 'mission_level_5', 'mission_shop_10' など
  static Future<List<String>> loadClaimedMissionIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyClaimedMissionIds) ?? [];
  }

  static Future<void> claimMission(String missionId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> claimed = prefs.getStringList(_keyClaimedMissionIds) ?? [];
    if (!claimed.contains(missionId)) {
      claimed.add(missionId);
      await prefs.setStringList(_keyClaimedMissionIds, claimed);
    }
  }

  static Future<bool> isMissionClaimed(String missionId) async {
    final claimed = await loadClaimedMissionIds();
    return claimed.contains(missionId);
  }

  // --- 累計獲得ポイントの管理 ---
  static Future<int> loadCumulativePoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCumulativePoints) ?? 0;
  }

  // ポイントを獲得した時に、現在のポイントと一緒にこれも呼ぶ
  static Future<void> addCumulativePoints(int points) async {
    if (points <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    int currentTotal = prefs.getInt(_keyCumulativePoints) ?? 0;
    await prefs.setInt(_keyCumulativePoints, currentTotal + points);
  }

  // --- マップ訪問フラグの管理（大きな島） ---
  static Future<bool> getHasVisitedBigIsland() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasVisitedBigIsland) ?? false;
  }

  static Future<void> setHasVisitedBigIsland(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasVisitedBigIsland, value);
  }

  // --- マップ訪問フラグの管理（海） ---
  static Future<bool> getHasVisitedSea() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasVisitedSea) ?? false;
  }

  static Future<void> setHasVisitedSea(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasVisitedSea, value);
  }

  // --- マップ訪問フラグの管理（空） ---
  static Future<bool> getHasVisitedSky() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasVisitedSky) ?? false;
  }

  static Future<void> setHasVisitedSky(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasVisitedSky, value);
  }

  // --- マップ訪問フラグの管理（宇宙） ---
  static Future<bool> getHasVisitedSpace() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasVisitedSpace) ?? false;
  }

  static Future<void> setHasVisitedSpace(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasVisitedSpace, value);
  }

  // --- やくそくボード訪問フラグの管理 ---
  static Future<bool> getHasVisitedPromiseBoard() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasVisitedPromiseBoard) ?? false;
  }

  static Future<void> setHasVisitedPromiseBoard(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasVisitedPromiseBoard, value);
  }

  // --- 累計やくそく達成回数の管理 ---
  static Future<int> loadCumulativePromiseCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCumulativePromiseCount) ?? 0;
  }

  // やくそくを完了（おわった！ボタン押下）した時に呼び出す
  static Future<void> incrementPromiseCount() async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_keyCumulativePromiseCount) ?? 0;
    await prefs.setInt(_keyCumulativePromiseCount, current + 1);
  }

  // --- ログイン累計日数の管理 ---
  // 累計ログイン日数を取得する
  static Future<int> loadCumulativeLoginDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCumulativeLoginDays) ?? 0;
  }

  // 今日初めてのログインなら累計日数を +1 する（1日1回しかカウントしない）
  static Future<void> recordLoginDay() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month}-${now.day}';
    final lastStr = prefs.getString(_keyLastLoginDateForCount);
    if (lastStr != todayStr) {
      final current = prefs.getInt(_keyCumulativeLoginDays) ?? 0;
      await prefs.setInt(_keyCumulativeLoginDays, current + 1);
      await prefs.setString(_keyLastLoginDateForCount, todayStr);
    }
  }

  // --- ミッション画面遷移履歴の管理 ---
  static const String _keyHasVisitedMissionScreen =
      'has_visited_mission_screen';

  static Future<void> setHasVisitedMissionScreen(bool visited) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasVisitedMissionScreen, visited);
  }

  static Future<bool> hasVisitedMissionScreen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasVisitedMissionScreen) ?? false;
  }

  static Future<void> saveEquippedFace(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('equipped_face', path);
  }

  static Future<String?> loadEquippedFace() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('equipped_face');
  }

  static Future<void> saveEquippedHairstyle(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('equipped_hairstyle', path);
  }

  static Future<String?> loadEquippedHairstyle() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('equipped_hairstyle');
  }

  static Future<void> saveEquippedClothes(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_equippedClothesKey, path);
  }

  static Future<String?> loadEquippedClothes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_equippedClothesKey);
  }

  static Future<void> saveEquippedHeadgear(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('equipped_headgear', path);
  }

  static Future<String?> loadEquippedHeadgear() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('equipped_headgear');
  }

  static Future<void> saveEquippedAccessory(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('equipped_accessory', path);
  }

  static Future<String?> loadEquippedAccessory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('equipped_accessory');
  }
}
