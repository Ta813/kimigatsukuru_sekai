import 'package:flutter_tts/flutter_tts.dart';

class TtsManager {
  // 🌟 世界に1つだけのインスタンスを保持する（シングルトン）
  static final TtsManager _instance = TtsManager._internal();
  factory TtsManager() => _instance;
  TtsManager._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // 🌟 アプリ起動時、または事前に1度だけ初期化する
  Future<void> initialize(String localeName) async {
    if (_isInitialized) return; // すでに初期化済みならスキップ

    try {
      if (localeName == 'ja') {
        await _flutterTts.setLanguage("ja-JP");
        await _flutterTts.setSpeechRate(0.4);
        await _flutterTts.setPitch(1.6);
      } else if (localeName == 'ur') {
        await _flutterTts.setLanguage("ur-PK");
        await _flutterTts.setSpeechRate(0.5);
        await _flutterTts.setPitch(1.0);
      } else {
        await _flutterTts.setLanguage("en-US");
        await _flutterTts.setSpeechRate(0.6);
        await _flutterTts.setPitch(1.6);
      }
      await _flutterTts.setVolume(1.0);
      _isInitialized = true;
    } catch (e) {
      print("TTS Global Initialization Error: $e");
      _isInitialized = false;
    }
  }

  // 🌟 発話処理
  Future<void> speak(String text) async {
    if (!_isInitialized) return;
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      print("TTS Speak Error: $e");
    }
  }

  // 🌟 停止処理（タイマー画面を閉じる時などに呼ぶ）
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print("TTS Stop Error: $e");
    }
  }
}
