package com.kotoapp.kimigatsukuru_sekai

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import com.ryanheise.audioservice.AudioServiceActivity // ★この行を追加

class MainActivity: AudioServiceActivity() { // ★「FlutterActivity」から変更
    // ★以下のメソッドを丸ごと追加
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }
}
