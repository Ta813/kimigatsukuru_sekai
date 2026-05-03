package com.kotoapp.kimigatsukuru_sekai

import android.content.Context
import android.util.Log
import com.ryanheise.audioservice.AudioServicePlugin
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterFragmentActivity() {
    private var isUsingSharedEngine = false

    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        Log.d("MainActivity", "provideFlutterEngine called")
        val engine = AudioServicePlugin.getFlutterEngine(context)
        
        if (engine != null) {
            // エンジンが健全（JNIがアタッチされており、Dartを実行中）かチェック
            if (isEngineHealthy(engine)) {
                Log.d("MainActivity", "Returning healthy shared engine")
                isUsingSharedEngine = true
                return engine
            } else {
                Log.w("MainActivity", "Shared engine is unhealthy. Forcing fresh engine creation.")
            }
        }
        
        isUsingSharedEngine = false
        return null // nullを返すとFlutterActivity/Fragmentが新しいエンジンを作成する
    }

    // エンジンが正常にネイティブと接続され、Dartを実行しているかを確認する
    private fun isEngineHealthy(engine: FlutterEngine): Boolean {
        return try {
            // 1. DartExecutorのチェック
            val dartExecutor = engine.dartExecutor
            if (!dartExecutor.isExecutingDart) {
                Log.w("MainActivity", "Engine Health: Dart is not executing")
                return false
            }

            // 2. Rendererのチェック（setViewportMetricsのクラッシュ箇所に関連）
            val renderer = engine.renderer
            if (renderer == null) {
                Log.w("MainActivity", "Engine Health: Renderer is null")
                return false
            }

            // 3. リフレクションを使用して内部のFlutterJNIがアタッチされているかチェック
            // io.flutter.embedding.engine.FlutterEngine の内部フィールド flutterJNI を取得
            val flutterJniField = try {
                engine.javaClass.getDeclaredField("flutterJNI")
            } catch (e: NoSuchFieldException) {
                // フィールド名が変更されている可能性（プロガード等）への予備チェック
                engine.javaClass.declaredFields.firstOrNull { it.type.name.contains("FlutterJNI") }
            }

            if (flutterJniField == null) {
                Log.w("MainActivity", "Engine Health: Could not find flutterJNI field")
                return false
            }

            flutterJniField.isAccessible = true
            val flutterJni = flutterJniField.get(engine)
            
            if (flutterJni == null) {
                Log.w("MainActivity", "Engine Health: flutterJNI is null")
                return false
            }

            // FlutterJNI.isAttached() メソッドを呼び出す
            val isAttachedMethod = flutterJni.javaClass.getDeclaredMethod("isAttached")
            val isAttached = isAttachedMethod.invoke(flutterJni) as Boolean
            
            if (!isAttached) {
                Log.w("MainActivity", "Engine Health: FlutterJNI is NOT attached")
            }
            
            isAttached
        } catch (e: Exception) {
            Log.e("MainActivity", "Engine health check failed: ${e.message}", e)
            // 判定に失敗した場合は、安全のため不健全とみなして新しいエンジンを作らせる
            false
        }
    }

    override fun shouldDestroyEngineWithHost(): Boolean {
        // 共有エンジンを使用している場合のみ、破棄をスキップする
        // それ以外（Activity独自に作成されたエンジン）はメモリリーク防止のため破棄する
        return !isUsingSharedEngine
    }
}
