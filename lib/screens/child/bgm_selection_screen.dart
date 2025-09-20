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
  BgmTrack? _selectedMainTrack;
  BgmTrack? _selectedFocusTrack;

  @override
  void initState() {
    super.initState();
    _loadSelectedBgms();
  }

  @override
  void dispose() {
    // この画面を抜ける時に、ホーム画面用のBGMを再生し直す
    _playSavedMainBgm();
    super.dispose(); // 必ず最後にsuper.dispose()を呼ぶ
  }

  // ホーム画面用のBGMを読み込んで再生するメソッド
  Future<void> _playSavedMainBgm() async {
    final trackName = await SharedPrefsHelper.loadSelectedBgm();
    final track = BgmTrack.values.firstWhere(
      (e) => e.name == trackName,
      orElse: () => BgmTrack.main, // 保存されていなければデフォルト
    );
    BgmManager.instance.play(track);
  }

  Future<void> _loadSelectedBgms() async {
    // ふだんのBGMを読み込む
    final mainTrackName = await SharedPrefsHelper.loadSelectedBgm();
    // しゅうちゅうBGMを読み込む
    final focusTrackName = await SharedPrefsHelper.loadSelectedFocusBgm();

    setState(() {
      _selectedMainTrack = BgmTrack.values.firstWhere(
        (e) => e.name == mainTrackName,
        orElse: () => BgmTrack.main,
      );
      _selectedFocusTrack = BgmTrack.values.firstWhere(
        (e) => e.name == focusTrackName,
        orElse: () => BgmTrack.focus_original,
      );
    });
  }

  String _getBgmDisplayName(BgmTrack track) {
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
      case BgmTrack.focus_original:
        return l10n.focusBgmDefault;
      case BgmTrack.focus_cute:
        return l10n.focusBgmCute;
      case BgmTrack.focus_cool:
        return l10n.focusBgmCool;
      case BgmTrack.focus_hurry:
        return l10n.focusBgmHurry;
      case BgmTrack.focus_nature:
        return l10n.focusBgmNature;
      case BgmTrack.focus_relaxing:
        return l10n.focusBgmRelaxing;
      case BgmTrack.focus_none:
        return l10n.bgmNone; // 不明な場合はデフォルトを返す
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- BGMのリストを定義 ---
    final mainTracks = [
      BgmTrack.main,
      BgmTrack.fun,
      BgmTrack.cute,
      BgmTrack.relaxing,
      BgmTrack.energetic,
      BgmTrack.sparkly,
      BgmTrack.none,
    ];
    final focusTracks = [
      BgmTrack.focus_original,
      BgmTrack.focus_cute,
      BgmTrack.focus_cool,
      BgmTrack.focus_hurry,
      BgmTrack.focus_nature,
      BgmTrack.focus_relaxing,
      BgmTrack.focus_none,
    ];

    return DefaultTabController(
      length: 2, // ★ タブの数を2に設定
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.selectBgmTitle),
          // ★ AppBarの下にTabBarを設置
          bottom: TabBar(
            tabs: [
              Tab(
                text: AppLocalizations.of(context)!.normalBgm,
                icon: Icon(Icons.music_note),
              ),
              Tab(
                text: AppLocalizations.of(context)!.focusBgm,
                icon: Icon(Icons.timer),
              ),
            ],
          ),
        ),
        // ★ TabBarViewでタブの中身を作成
        body: TabBarView(
          children: [
            // --- 1. ふだんのBGM選択リスト ---
            _buildBgmList(
              tracks: mainTracks,
              selectedTrack: _selectedMainTrack,
              onTrackSelected: (track) async {
                setState(() => _selectedMainTrack = track);
                BgmManager.instance.play(track);
                await SharedPrefsHelper.saveSelectedBgm(track.name);
              },
            ),
            // --- 2. しゅうちゅうBGM選択リスト ---
            _buildBgmList(
              tracks: focusTracks,
              selectedTrack: _selectedFocusTrack,
              onTrackSelected: (track) async {
                setState(() => _selectedFocusTrack = track);
                BgmManager.instance.play(track); // 試聴
                await SharedPrefsHelper.saveSelectedFocusBgm(track.name);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ★ リスト表示部分を共通のメソッドに切り出し
  Widget _buildBgmList({
    required List<BgmTrack> tracks,
    required BgmTrack? selectedTrack,
    required Future<void> Function(BgmTrack) onTrackSelected,
  }) {
    return ListView.builder(
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final track = tracks[index];
        final isSelected = selectedTrack == track;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
            ),
            title: Text(_getBgmDisplayName(track)), // ★ 表示名を返すメソッドを呼び出す
            trailing: IconButton(
              icon: const Icon(Icons.play_circle_outline),
              onPressed: () => BgmManager.instance.play(track), // 試聴
            ),
            onTap: () => onTrackSelected(track),
          ),
        );
      },
    );
  }
}
