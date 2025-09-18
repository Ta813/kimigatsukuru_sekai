import 'package:flutter/material.dart';
import '../../managers/bgm_manager.dart';
import '../../helpers/shared_prefs_helper.dart';
import '../../l10n/app_localizations.dart';

class BgmSelectionScreen extends StatefulWidget {
  const BgmSelectionScreen({super.key});

  @override
  State<BgmSelectionScreen> createState() => _BgmSelectionScreenState();
}

class _BgmSelectionScreenState extends State<BgmSelectionScreen> {
  BgmTrack? _selectedTrack;

  @override
  void initState() {
    super.initState();
    _loadSelectedBgm();
  }

  Future<void> _loadSelectedBgm() async {
    final trackName = await SharedPrefsHelper.loadSelectedBgm();
    setState(() {
      // 保存された文字列からBgmTrack enumに変換
      _selectedTrack = BgmTrack.values.firstWhere(
        (e) => e.name == trackName,
        orElse: () => BgmTrack.main, // 保存されていなければデフォルト
      );
    });
  }

  // BGMの表示名を取得するヘルパーメソッド
  String _getBgmDisplayName(BuildContext context, BgmTrack track) {
    final l10n = AppLocalizations.of(context)!; // l10nを呼び出す

    switch (track) {
      case BgmTrack.main: // 'いつものBGM'
        return l10n.bgmMain;
      case BgmTrack.fun: // 'たのしいBGM'
        return l10n.bgmFun;
      case BgmTrack.cute: // 'かわいいBGM'
        return l10n.bgmCute;
      case BgmTrack.relaxing: // 'ゆったりなBGM'
        return l10n.bgmRelaxing;
      case BgmTrack.energetic: // 'げんきなBGM'
        return l10n.bgmEnergetic;
      case BgmTrack.sparkly: // 'キラキラなBGM'
        return l10n.bgmSparkly;
      case BgmTrack.none: // 'BGMなし'
        return l10n.bgmNone;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    // 表示対象のBGMリスト (集中BGMは除外)
    final availableTracks = [
      BgmTrack.main,
      BgmTrack.fun,
      BgmTrack.cute,
      BgmTrack.relaxing,
      BgmTrack.energetic,
      BgmTrack.sparkly,
      BgmTrack.none,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.selectBgmTitle)),
      body: ListView.builder(
        itemCount: availableTracks.length,
        itemBuilder: (context, index) {
          final track = availableTracks[index];
          final isSelected = _selectedTrack == track;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(_getBgmDisplayName(context, track)),
              // ★ 試聴ボタン
              trailing: IconButton(
                icon: const Icon(Icons.play_circle_outline),
                onPressed: () {
                  // 一時的に試聴する
                  BgmManager.instance.play(track);
                },
              ),
              onTap: () async {
                setState(() {
                  _selectedTrack = track;
                });
                // 選択したBGMをBgmManagerで再生
                BgmManager.instance.play(track);
                // 選択したBGMをSharedPrefsに保存
                await SharedPrefsHelper.saveSelectedBgm(track.name);
              },
            ),
          );
        },
      ),
    );
  }
}
