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
            // 1. Dartを実行中かチェック
            if (!engine.dartExecutor.isExecutingDart) return false

            // 2. リフレクションを使用して内部のFlutterJNIがアタッチされているかチェック
            // これが "FlutterJNI is not attached to native" を防ぐ最も確実な方法です
            val flutterJniField = engine.javaClass.getDeclaredField("flutterJNI")
            flutterJniField.isAccessible = true
            val flutterJni = flutterJniField.get(engine)
            val isAttachedMethod = flutterJni.javaClass.getDeclaredMethod("isAttached")
            val isAttached = isAttachedMethod.invoke(flutterJni) as Boolean
            
            isAttached
        } catch (e: Exception) {
            Log.e("MainActivity", "Engine health check failed: ${e.message}")
            // 判定に失敗した場合は、安全のため不健全とみなす
            false
        }
    }

    override fun shouldDestroyEngineWithHost(): Boolean {
        // 共有エンジンを使用している場合のみ、破棄をスキップする
        // それ以外（Activity独自に作成されたエンジン）はメモリリーク防止のため破棄する
        return !isUsingSharedEngine
    }
}
