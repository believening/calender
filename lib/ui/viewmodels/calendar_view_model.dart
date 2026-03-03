import 'package:flutter/foundation.dart';
import '../../core/plugin_manager/plugin_manager.dart';
import '../../core/providers/calendar_settings_provider.dart';
import '../../plugins/lunar_calendar/lunar_calendar_plugin.dart';
import '../../plugins/tibetan_calendar/tibetan_calendar_plugin.dart';
import '../../models/calendar_models.dart';

/// 日历视图模型
class CalendarViewModel extends ChangeNotifier {
  final PluginManager _pluginManager = PluginManager();
  final CalendarSettingsProvider _settings;

  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  List<CalendarDate> _monthDates = [];
  CalendarDate? _selectedCalendarDate;
  List<Festival> _monthFestivals = [];

  CalendarViewModel({CalendarSettingsProvider? settings}) 
      : _settings = settings ?? CalendarSettingsProvider() {
    _initPlugins();
    _loadMonthData();
  }

  // Getters
  DateTime get selectedDate => _selectedDate;
  DateTime get currentMonth => _currentMonth;
  List<CalendarDate> get monthDates => _monthDates;
  CalendarDate? get selectedCalendarDate => _selectedCalendarDate;
  List<Festival> get monthFestivals => _monthFestivals;
  PluginManager get pluginManager => _pluginManager;
  CalendarSettingsProvider get settings => _settings;

  void _initPlugins() {
    _pluginManager.registerPlugin(LunarCalendarPlugin());
    _pluginManager.registerPlugin(TibetanCalendarPlugin());
  }

  void _loadMonthData() {
    _monthDates.clear();
    _monthFestivals.clear();

    // 获取当月第一天
    DateTime firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);

    // 计算日历开始日期（包含上月日期填充）
    int weekday = firstDay.weekday;
    DateTime calendarStart = firstDay.subtract(Duration(days: weekday - 1));

    // 生成6周42天的日历数据
    for (int i = 0; i < 42; i++) {
      DateTime date = calendarStart.add(Duration(days: i));
      var calendarDate = _pluginManager.convertWithAllPlugins(date);
      _monthDates.add(calendarDate);
    }

    // 获取当月节日
    _monthFestivals = _pluginManager.getAllFestivals(_currentMonth.year, _currentMonth.month);

    notifyListeners();
  }

  /// 选择日期
  void selectDate(DateTime date) {
    _selectedDate = date;
    _selectedCalendarDate = _pluginManager.convertWithAllPlugins(date);
    notifyListeners();
  }

  /// 切换到上个月
  void previousMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    _loadMonthData();
  }

  /// 切换到下个月
  void nextMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    _loadMonthData();
  }

  /// 切换到指定月份
  void goToMonth(int year, int month) {
    _currentMonth = DateTime(year, month);
    _loadMonthData();
  }

  /// 回到今天
  void goToToday() {
    _currentMonth = DateTime.now();
    _selectedDate = DateTime.now();
    _loadMonthData();
    selectDate(_selectedDate);
  }

  /// 获取指定年份的所有节气
  List<Festival> getSolarTerms(int year) {
    return _pluginManager.getAllSolarTerms(year);
  }

  /// 获取指定年份的所有节日
  List<Festival> getFestivalsForYear(int year) {
    return _pluginManager.getAllFestivalsForYear(year);
  }

  /// 获取月份标题
  String get monthTitle {
    return '${_currentMonth.year}年${_currentMonth.month}月';
  }

  /// 检查日期是否是今天
  bool isToday(DateTime date) {
    DateTime now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// 检查日期是否是选中日期
  bool isSelected(DateTime date) {
    return date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;
  }

  /// 检查日期是否在当前月份
  bool isCurrentMonth(DateTime date) {
    return date.month == _currentMonth.month;
  }

  /// 获取星期的名称
  static const List<String> weekdays = ['一', '二', '三', '四', '五', '六', '日'];

  /// 获取日期单元格的显示文本（根据主历法）
  String getDateCellText(CalendarDate calendarDate) {
    switch (_settings.primaryCalendar) {
      case CalendarType.lunar:
        if (calendarDate.lunarDate != null) {
          return _getLunarDayText(calendarDate.lunarDate!);
        }
        break;
      case CalendarType.tibetan:
        if (calendarDate.tibetanDate != null) {
          return _getTibetanDayText(calendarDate.tibetanDate!);
        }
        break;
      case CalendarType.solar:
      case CalendarType.islamic:
      case CalendarType.dai:
      case CalendarType.yi:
        // 暂时不支持，回退到农历
        if (calendarDate.lunarDate != null) {
          return _getLunarDayText(calendarDate.lunarDate!);
        }
        break;
    }
    return '';
  }

  /// 获取农历日期显示文本
  String _getLunarDayText(LunarDate lunarDate) {
    if (lunarDate.day == 1) {
      return lunarDate.monthName ?? '初一';
    }
    return lunarDate.dayName ?? '${lunarDate.day}';
  }

  /// 获取藏历日期显示文本
  String _getTibetanDayText(TibetanDate tibetanDate) {
    if (tibetanDate.day == 1) {
      return tibetanDate.monthNameChinese ?? '初一';
    }
    return tibetanDate.dayNameChinese ?? '${tibetanDate.day}';
  }

  /// 获取年份信息卡片显示文本（根据主历法）
  String getYearInfoText(CalendarDate calendarDate) {
    switch (_settings.primaryCalendar) {
      case CalendarType.lunar:
        return calendarDate.lunarDate?.yearName ?? '';
      case CalendarType.tibetan:
        return calendarDate.tibetanDate?.yearElement ?? '';
      case CalendarType.solar:
      case CalendarType.islamic:
      case CalendarType.dai:
      case CalendarType.yi:
        return calendarDate.lunarDate?.yearName ?? '';
    }
  }
}
