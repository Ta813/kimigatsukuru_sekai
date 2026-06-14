//ios/KimigatsukuruWidget/KimigatsukuruWidget.swift

import WidgetKit
import SwiftUI

// 🌟 App Group ID (Dart側、Xcodeの設定と完全に一致させること)
private let appGroupID = "group.com.kotoapp.kimigatsukurusekai"

struct Provider: TimelineProvider {
    // プレビュー（ウィジェット追加画面）での表示
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), imagePath: nil)
    }

    // 一瞬表示されるスナップショット
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), imagePath: nil)
        completion(entry)
    }

    // 実際の表示データ（タイムライン）を作成
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // App Groupの共有スペースからパスを取得
        let sharedDefaults = UserDefaults(suiteName: appGroupID)
        let path = sharedDefaults?.string(forKey: "widget_background_path")

        // 現在の時刻でエントリを作成
        let entries = [SimpleEntry(date: Date(), imagePath: path)]

        // タイムラインを更新しない（Flutterアプリからの通知でのみ更新する）設定
        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
}

// ウィジェットに渡すデータ構造
struct SimpleEntry: TimelineEntry {
    let date: Date
    let imagePath: String? // Dart側から送られてきたPNGへのパス
}

// 🌟 ウィジェットの見た目 (SwiftUI)
struct KimigatsukuruWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        GeometryReader { geometry in
            if let imagePath = entry.imagePath,
               let uiImage = UIImage(contentsOfFile: imagePath) {
                // 🌟 生成されたPNG画像を表示
                // Dart側で背景色、角丸、テキスト、画面写真を全部入れた正方形画像を作っているので、
                // scaledToFillで枠いっぱいに表示するだけでOKです。
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            } else {
                // 🌟 画像がない場合（初期状態）のフォールバック
                // Androidで作った widget_preview.png を iOSの Assets.xcassets にも追加しておき、
                // それを表示するようにします。
                Image("widget_preview")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            }
        }
        // 🌟 【ここに追加！】ウィジェット全体をタップした時に送るURLを設定
        .widgetURL(URL(string: "kimiapp://open_action_dialog"))
        // iOS 17以降で必須のコンテナ背景設定
        .containerBackground(.clear, for: .widget)
    }
}

@main
struct KimigatsukuruWidget: Widget {
    // 🌟 ヘルパーの iOSName と一致させる
    let kind: String = "KimigatsukuruWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            KimigatsukuruWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Kimigatsukuru Widget")
        .description("Widget showing your created world.")
        // 🌟 サイズを Small (Androidの2x2相当) のみに限定
        .supportedFamilies([.systemSmall])
    }
}