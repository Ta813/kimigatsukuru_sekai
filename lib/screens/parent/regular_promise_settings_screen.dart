// lib/screens/parent_mode/regular_promise_settings_screen.dart

import 'package:flutter/material.dart';
import '../../helpers/shared_prefs_helper.dart';
import 'add_edit_promise_screen.dart';
import '../../managers/sfx_manager.dart';
import '../../widgets/ad_banner.dart';
import '../../l10n/app_localizations.dart';

class RegularPromiseSettingsScreen extends StatefulWidget {
  const RegularPromiseSettingsScreen({super.key});

  @override
  State<RegularPromiseSettingsScreen> createState() =>
      _RegularPromiseSettingsScreenState();
}

class _RegularPromiseSettingsScreenState
    extends State<RegularPromiseSettingsScreen> {
  // 定例のやくそくリストを管理するためのデータ
  List<Map<String, dynamic>> _regularPromises = [];

  // 画面が最初に表示された時に、保存されているデータを読み込む
  @override
  void initState() {
    super.initState();
    _loadPromises();
  }

  Future<void> _loadPromises() async {
    final loadedPromises = await SharedPrefsHelper.loadRegularPromises(context);
    loadedPromises.sort((a, b) {
      final timeA = a['time'] ?? '00:00';
      final timeB = b['time'] ?? '00:00';
      return timeA.compareTo(timeB);
    });
    setState(() {
      _regularPromises = loadedPromises;
    });
  }

  // やくそくを削除する処理
  void _deletePromise(int index) {
    // 削除する前に対象のやくそく名を取得しておきます
    final String deletedPromiseTitle = _regularPromises[index]['title'];

    setState(() {
      _regularPromises.removeAt(index);
    });

    // 変更後のリストを保存
    SharedPrefsHelper.saveRegularPromises(_regularPromises);

    // 古いSnackBarが残っている可能性があれば消去します
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    // 画面下部に新しいメッセージ（SnackBar）を表示します
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // 表示するメッセージ
        content: Text(
          AppLocalizations.of(context)!.promiseDeleted(deletedPromiseTitle),
        ),
        // メッセージの表示時間
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // 「＋」ボタンが押された時の処理
  void _navigateToAddScreen() async {
    SfxManager.instance.playTapSound();
    // まず、追加画面のファイルをインポートするのを忘れないようにしましょう
    // import 'add_edit_promise_screen.dart';

    final newPromise = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const AddEditPromiseScreen()),
    );

    // もし、新しいやくそくのデータを持って戻ってきたら
    if (newPromise != null) {
      setState(() {
        _regularPromises.add(newPromise);

        _regularPromises.sort((a, b) {
          final timeA = a['time'] ?? '00:00';
          final timeB = b['time'] ?? '00:00';
          return timeA.compareTo(timeB);
        });
      });
      // 変更後のリストを保存
      SharedPrefsHelper.saveRegularPromises(_regularPromises);
      // 追加したことをユーザーに知らせるメッセージ
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.promiseAdded(newPromise['title']),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToEditScreen(int index) async {
    final promiseToEdit = _regularPromises[index];

    final updatedPromise = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        // ★編集対象のデータを渡して画面を開く
        builder: (context) =>
            AddEditPromiseScreen(initialPromise: promiseToEdit),
      ),
    );

    // もし、更新されたデータを持って戻ってきたら
    if (updatedPromise != null) {
      setState(() {
        // リストの該当箇所を、新しいデータに置き換える
        _regularPromises[index] = updatedPromise;
      });
      // SharedPreferencesに保存
      SharedPrefsHelper.saveRegularPromises(_regularPromises);

      // ユーザーに知らせるメッセージ
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            )!.promiseUpdated(updatedPromise['title']),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.regularPromiseSettingsTitle),
      ),
      body: ListView.builder(
        itemCount: _regularPromises.length,
        itemBuilder: (context, index) {
          final promise = _regularPromises[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(promise['title']),
              subtitle: Text(
                '${AppLocalizations.of(context)!.timeLabel}: ${promise['time']} / ${promise['duration']}分 / ${promise['points']}${AppLocalizations.of(context)!.points}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min, // Rowが必要な分だけ幅をとるようにする
                children: [
                  // 編集ボタン（機能は後で追加）
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      SfxManager.instance.playTapSound();
                      _navigateToEditScreen(index);
                    },
                  ),
                  // 削除ボタン
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red[400]),
                    onPressed: () {
                      SfxManager.instance.playTapSound();
                      _deletePromise(index);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      // 新しいやくそくを追加するための「＋」ボタン
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddScreen,
        child: const Icon(Icons.add),
      ),
      // 画面下部にバナーを設置
      bottomNavigationBar: const AdBanner(),
    );
  }
}
