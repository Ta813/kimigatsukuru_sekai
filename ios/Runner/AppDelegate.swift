import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {

  private let appGroupID = "group.com.kotoapp.kimigatsukurusekai"
  private let widgetUrlKey = "ios_widget_action_url"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // コールドスタート: ウィジェットタップで起動された場合の URL を App Group に保存
    if let url = launchOptions?[UIApplication.LaunchOptionsKey.url] as? URL,
       url.scheme == "kimiapp" {
      saveWidgetUrl(url.absoluteString)
    }

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // ウォームスタート: アプリがバックグラウンド/フォアグラウンドの状態でウィジェットがタップされた場合
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if url.scheme == "kimiapp" {
      saveWidgetUrl(url.absoluteString)
    }
    // home_widget プラグインにも転送
    return super.application(app, open: url, options: options)
  }

  // App Group UserDefaults に URL を保存（Dart 側から HomeWidget.getWidgetData で読み取る）
  private func saveWidgetUrl(_ urlString: String) {
    let defaults = UserDefaults(suiteName: appGroupID)
    defaults?.set(urlString, forKey: widgetUrlKey)
    defaults?.synchronize()
  }
}
