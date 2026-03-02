import 'package:flutter/material.dart';

/// 语言设置 Provider
/// 
/// 支持的语言：
/// - zh_CN: 中文（简体）
/// - bo_CN: 藏文
/// - en_US: English
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('zh', 'CN');

  Locale get locale => _locale;

  /// 可用的语言列表
  static const List<Locale> supportedLocales = [
    Locale('zh', 'CN'),
    Locale('bo', 'CN'),
    Locale('en', 'US'),
  ];

  /// 语言名称映射
  static const Map<String, String> languageNames = {
    'zh_CN': '中文',
    'bo_CN': 'བོད་ཡིག',
    'en_US': 'English',
  };

  /// 设置语言
  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }

  /// 设置语言（通过语言代码）
  void setLocaleByCode(String code) {
    switch (code) {
      case 'zh_CN':
        setLocale(const Locale('zh', 'CN'));
        break;
      case 'bo_CN':
        setLocale(const Locale('bo', 'CN'));
        break;
      case 'en_US':
        setLocale(const Locale('en', 'US'));
        break;
    }
  }

  /// 获取当前语言代码
  String get currentLocaleCode {
    return '${_locale.languageCode}_${_locale.countryCode}';
  }

  /// 获取当前语言名称
  String get currentLanguageName {
    return languageNames[currentLocaleCode] ?? '中文';
  }
}
