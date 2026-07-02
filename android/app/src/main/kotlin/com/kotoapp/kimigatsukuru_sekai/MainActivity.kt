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
        
        // 🌟 修正: 暗黙的エンジン(null返し)は、Activity再生成時等に 
        // "attached to by another activity" の AssertionError を引き起こすため、
        // 明示的に FlutterEngine を作成・キャッシュして使い回す
        isUsingSharedEngine = true 
        val cache = io.flutter.embedding.engine.FlutterEngineCache.getInstance()
        var cachedEngine = cache.get("my_cached_engine")
        
        if (cachedEngine != null && !isEngineHealthy(cachedEngine)) {
            Log.w("MainActivity", "Cached engine is unhealthy. Destroying it.")
            cachedEngine.destroy()
            cache.remove("my_cached_engine")
            cachedEngine = null
        }
        
        if (cachedEngine == null) {
            Log.d("MainActivity", "Creating new explicit engine for cache")
            cachedEngine = FlutterEngine(context.applicationContext)
            cache.put("my_cached_engine", cachedEngine)
        }
        
        return cachedEngine
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

    override fun getRenderMode(): io.flutter.embedding.android.RenderMode {
        // Android 9 (API 28) の Google デバイスでの SurfaceControl 関連のクラッシュを防ぐための対応
        if (android.os.Build.VERSION.SDK_INT == android.os.Build.VERSION_CODES.P &&
            android.os.Build.MANUFACTURER.equals("Google", ignoreCase = true)) {
            return io.flutter.embedding.android.RenderMode.texture
        }
        return super.getRenderMode()
    }
}
