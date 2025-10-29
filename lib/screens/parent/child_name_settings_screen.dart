import 'package:flutter/material.dart';
import '../../helpers/shared_prefs_helper.dart'; // SharedPrefsHelperをインポート
import '../../l10n/app_localizations.dart'; // l10nを使う場合

class ChildNameSettingsScreen extends StatefulWidget {
  const ChildNameSettingsScreen({super.key});

  @override
  State<ChildNameSettingsScreen> createState() =>
      _ChildNameSettingsScreenState();
}

class _ChildNameSettingsScreenState extends State<ChildNameSettingsScreen> {
  List<Map<String, String>> _childNames = []; // 登録されている名前のリスト
  final _nameController = TextEditingController(); // 名前入力用
  String _selectedHonorific = 'ちゃん';

  // 敬称の選択肢
  final List<String> _honorifics = ['ちゃん', 'くん', 'さん', 'さま', 'どの', '（なし）'];

  @override
  void initState() {
    super.initState();
    _loadNames();
  }

  Future<void> _loadNames() async {
    final names = await SharedPrefsHelper.loadChildNames();
    if (mounted) {
      setState(() {
        _childNames = names;
      });
    }
  }

  void _addChildName() async {
    final name = _nameController.text.trim();

    final currentLocale = AppLocalizations.of(context)!.localeName;
    // ★ 「（なし）」の場合は空文字にする
    final honorific = (currentLocale != 'ja')
        ? ''
        : (_selectedHonorific == '（なし）')
        ? ''
        : _selectedHonorific;

    // 名前が空でないか、すでに同じ名前+敬称の組み合わせがないかチェック
    bool alreadyExists = _childNames.any(
      (child) => child['name'] == name && child['honorific'] == honorific,
    );

    if (name.isNotEmpty && !alreadyExists) {
      setState(() {
        // ★ Mapとして追加
        _childNames.add({'name': name, 'honorific': honorific});
      });
      await SharedPrefsHelper.saveChildNames(_childNames);
      _nameController.clear();
      FocusScope.of(context).unfocus();
    } else if (alreadyExists) {
      // 重複している場合はユーザーに通知（任意）
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.nameAlreadyExists),
        ),
      );
    }
  }

  void _removeChildName(int index) async {
    setState(() {
      _childNames.removeAt(index);
    });
    await SharedPrefsHelper.saveChildNames(_childNames);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = AppLocalizations.of(context)!.localeName;
    final isEnglish = currentLocale != 'ja';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.childNameSettingsTitle,
        ), // l10n.childNameSettingsTitle
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  kToolbarHeight -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  32, // Adjust padding (16*2)
            ),
            child: Column(
              // Columnで要素を縦に並べる
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 名前入力欄と追加ボタン ---
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(
                            context,
                          )!.enterNameHint, // l10n.enterNameHint
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!isEnglish)
                      DropdownButton<String>(
                        value: _selectedHonorific,
                        items: _honorifics.map<DropdownMenuItem<String>>((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedHonorific = newValue;
                            });
                          }
                        },
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: Text(
                        AppLocalizations.of(context)!.addAction,
                      ), // l10n.addAction
                      onPressed: _addChildName,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // --- 登録済み名前リスト ---
                Text(
                  AppLocalizations.of(
                    context,
                  )!.registeredNamesLabel, // l10n.registeredNamesLabel
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                // ★ 残りのスペースをListViewで埋める
                _childNames.isEmpty
                    ? Center(
                        child: Text(
                          AppLocalizations.of(
                            context,
                          )!.noNamesRegistered, // l10n.noNamesRegistered
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _childNames.length,
                        itemBuilder: (context, index) {
                          final child = _childNames[index];
                          final displayName =
                              '${child['name']}${child['honorific']}'; // ★ 表示用に結合
                          return Card(
                            // Cardで囲むと見やすい
                            child: ListTile(
                              leading: const Icon(Icons.face),
                              title: Text(displayName),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeChildName(index),
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
