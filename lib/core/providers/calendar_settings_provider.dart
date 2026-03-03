import 'package:flutter/foundation.dart';
import '../../models/calendar_models.dart';

/// 历法设置管理器
/// 
/// 管理用户选择的主历法和其他历法显示设置
class CalendarSettingsProvider extends ChangeNotifier {
  /// 当前选中的主历法（用于日历网格显示）
  CalendarType _primaryCalendar = CalendarType.lunar;

  /// 是否显示农历（即使不是主历法）
  bool _showLunarCalendar = true;

  /// 是否显示藏历（即使不是主历法）
  bool _showTibetanCalendar = true;

  /// 是否显示节日
  bool _showFestivals = true;

  /// 是否显示宜忌
  bool _showDailyInfo = true;

  // Getters
  CalendarType get primaryCalendar => _primaryCalendar;
  bool get showLunarCalendar => _showLunarCalendar;
  bool get showTibetanCalendar => _showTibetanCalendar;
  bool get showFestivals => _showFestivals;
  bool get showDailyInfo => _showDailyInfo;

  /// 设置主历法
  void setPrimaryCalendar(CalendarType type) {
    if (_primaryCalendar != type) {
      _primaryCalendar = type;
      notifyListeners();
    }
  }

  /// 切换农历显示
  void toggleLunarCalendar(bool value) {
    _showLunarCalendar = value;
    notifyListeners();
  }

  /// 切换藏历显示
  void toggleTibetanCalendar(bool value) {
    _showTibetanCalendar = value;
    notifyListeners();
  }

  /// 切换节日显示
  void toggleFestivals(bool value) {
    _showFestivals = value;
    notifyListeners();
  }

  /// 切换宜忌显示
  void toggleDailyInfo(bool value) {
    _showDailyInfo = value;
    notifyListeners();
  }

  /// 获取所有支持的历法类型（用于设置页面）
  static List<CalendarType> get supportedCalendars => [
    CalendarType.lunar,
    CalendarType.tibetan,
    // 未来可以添加更多历法
    // CalendarType.islamic,
    // CalendarType.dai,
    // CalendarType.yi,
  ];

  /// 获取历法类型的显示名称
  static String getCalendarTypeName(CalendarType type) {
    switch (type) {
      case CalendarType.solar:
        return '公历';
      case CalendarType.lunar:
        return '农历';
      case CalendarType.tibetan:
        return '藏历';
      case CalendarType.islamic:
        return '伊斯兰历';
      case CalendarType.dai:
        return '傣历';
      case CalendarType.yi:
        return '彝历';
    }
  }

  /// 获取历法类型的图标
  static String getCalendarTypeIcon(CalendarType type) {
    switch (type) {
      case CalendarType.solar:
        return '📅';
      case CalendarType.lunar:
        return '🌙';
      case CalendarType.tibetan:
        return '🏔️';
      case CalendarType.islamic:
        return '☪️';
      case CalendarType.dai:
        return '🏯';
      case CalendarType.yi:
        return '🔥';
    }
  }
}
