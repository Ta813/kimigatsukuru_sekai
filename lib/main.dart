import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/locale_provider.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // 🌟 1. 画面の描画（UI）に絶対必要なもの「だけ」を先に待つ
  final localeProvider = LocaleProvider();
  await localeProvider.init();

  // 🌟 2. UIに最低限必要な準備が終わったら、まず爆速でアプリを起動(描画)します！
  runApp(
    ChangeNotifierProvider.value(value: localeProvider, child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
      locale: localeProvider.locale,
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        // 端末の言語設定が日本語だったら、日本語を選択
        if (deviceLocale != null) {
          if (deviceLocale.languageCode == 'ja') {
            return const Locale('ja');
          }
          if (deviceLocale.languageCode == 'hi') {
            return const Locale('hi');
          }
          if (deviceLocale.languageCode == 'ur') {
            return const Locale('ur');
          }
          if (deviceLocale.languageCode == 'bn') {
            return const Locale('bn');
          }
          if (deviceLocale.languageCode == 'ar') {
            return const Locale('ar');
          }
        }
        // それ以外の場合は、すべて英語をデフォルトにする
        return const Locale('en');
      },
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // 英語
        Locale('ja', ''), // 日本語
        Locale('hi', ''), // ヒンディー語
        Locale('ur', ''), // ウルドゥー語
        Locale('bn', ''), // ベンガル語
        Locale('ar', ''), // アラビア語
      ],

      // アプリのテーマカラーなどを後で設定できます
      theme: ThemeData(
        fontFamily: 'MochiyPopOne',
        // 2. メインカラー（温かいオレンジ）
        primaryColor: const Color(0xFFFF7043),

        // 3. アクセントカラー（ハニーイエロー）
        // colorSchemeを使い、secondary（2番目の色）に設定します
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF7043), // メインカラーを元に配色を自動生成
          secondary: const Color(0xFFFFCA28), // アクセントカラーを上書き
        ),

        // 4. アプリ全体の背景色（ピーチクリーム）
        scaffoldBackgroundColor: const Color(0xFFFFF3E0),

        // 5. AppBarのデフォルトデザイン
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFF7043), // 背景をメインカラーに
          foregroundColor: Colors.white, // 文字やアイコンの色を白に
        ),

        // 6. フローティングアクションボタンのデフォルトデザイン
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFFCA28), // 背景をアクセントカラーに
          foregroundColor: Colors.white,
        ),

        // その他のウィジェットのデフォルト色もここで設定できます
        useMaterial3: true,
      ),
      // このアプリの「玄関」となる画面を指定します
      home: const SplashScreen(),
    );
  }
}
