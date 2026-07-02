package com.kotoapp.kimigatsukuru_sekai

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.io.File

class HomeWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout)

            val backgroundPath = widgetData.getString("widget_background_path", null)
            // 🌟 画像が正常にセットされたかを記録するフラグ
            var isImageSet = false

            if (backgroundPath != null) {
                try {
                    val imgFile = File(backgroundPath)
                    if (imgFile.exists()) {
                        val options = BitmapFactory.Options()
                        options.inJustDecodeBounds = true
                        BitmapFactory.decodeFile(imgFile.absolutePath, options)

                        var scale = 1
                        val maxSize = 800
                        while (options.outWidth / scale > maxSize || options.outHeight / scale > maxSize) {
                            scale *= 2
                        }

                        options.inJustDecodeBounds = false
                        options.inSampleSize = scale

                        val bitmap = BitmapFactory.decodeFile(imgFile.absolutePath, options)
                        if (bitmap != null) {
                            views.setImageViewBitmap(R.id.widget_background, bitmap)
                            isImageSet = true // 🌟 成功したらフラグをtrueにする
                        }
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }

            // 🌟 【ここを追加】まだ一度も画像が作られていない場合の処理
            if (!isImageSet) {
                // res/drawable/widget_preview.png を初期画像として表示する
                views.setImageViewResource(R.id.widget_background, R.drawable.widget_preview)
            }

            // LaunchIntentを直接生成せず、Intentを明示的に作成してフラグを付与する
            val intent = android.content.Intent(context, MainActivity::class.java).apply {
                data = Uri.parse("kimiapp://open_action_dialog")
                action = HomeWidgetLaunchIntent.HOME_WIDGET_LAUNCH_ACTION
                flags = android.content.Intent.FLAG_ACTIVITY_NEW_TASK or android.content.Intent.FLAG_ACTIVITY_CLEAR_TASK
            }

            var pendingIntentFlags = android.app.PendingIntent.FLAG_UPDATE_CURRENT
            if (android.os.Build.VERSION.SDK_INT >= 23) {
                pendingIntentFlags = pendingIntentFlags or android.app.PendingIntent.FLAG_IMMUTABLE
            }

            val pendingIntent = if (android.os.Build.VERSION.SDK_INT < 34) {
                android.app.PendingIntent.getActivity(context, 0, intent, pendingIntentFlags)
            } else {
                val options = android.app.ActivityOptions.makeBasic()
                if (android.os.Build.VERSION.SDK_INT >= 35) {
                    options.setPendingIntentCreatorBackgroundActivityStartMode(
                        android.app.ActivityOptions.MODE_BACKGROUND_ACTIVITY_START_ALLOWED
                    )
                } else {
                    options.pendingIntentBackgroundActivityStartMode = 
                        android.app.ActivityOptions.MODE_BACKGROUND_ACTIVITY_START_ALLOWED
                }
                android.app.PendingIntent.getActivity(context, 0, intent, pendingIntentFlags, options.toBundle())
            }

            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}