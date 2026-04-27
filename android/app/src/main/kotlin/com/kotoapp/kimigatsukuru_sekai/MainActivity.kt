package com.kotoapp.kimigatsukuru_sekai

import android.content.Context
import android.util.Log
import com.ryanheise.audioservice.AudioServicePlugin
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterFragmentActivity() {
    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        Log.d("MainActivity", "provideFlutterEngine called")
        val engine = AudioServicePlugin.getFlutterEngine(context)
        
        if (engine != null) {
            // Defensive check: if the engine is not executing dart, it might be in a broken/detached state
            // that causes "FlutterJNI is not attached to native" errors during activity recreation.
            if (!engine.dartExecutor.isExecutingDart) {
                Log.w("MainActivity", "Shared engine is not executing Dart. Returning null to force fresh engine creation.")
                return null
            }
            
            // ★ 追加: レンダラーへのアクセスを試みることで、JNIがアタッチされているか簡易チェック
            try {
                engine.renderer
            } catch (e: Exception) {
                Log.e("MainActivity", "Shared engine renderer is inaccessible: ${e.message}. Returning null.")
                return null
            }

            Log.d("MainActivity", "Returning shared engine from AudioServicePlugin")
        } else {
            Log.d("MainActivity", "AudioServicePlugin.getFlutterEngine returned null. A new engine will be created.")
        }
        
        return engine
    }

    // ★ 追加: Activityが破棄される際に、共有されているFlutterエンジンまで破棄しないようにする
    // これにより、オーディオサービス等と共有しているエンジンが不健全な状態になるのを防ぎます
    override fun shouldDestroyEngineWithHost(): Boolean {
        return false
    }
}
