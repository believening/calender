import '../calendar_core/calendar_plugin.dart';
import '../../models/calendar_models.dart';

/// 插件管理器
class PluginManager {
  static final PluginManager _instance = PluginManager._internal();
  factory PluginManager() => _instance;
  PluginManager._internal();

  final Map<String, CalendarPlugin> _plugins = {};

  /// 注册插件
  void registerPlugin(CalendarPlugin plugin) {
    _plugins[plugin.identifier] = plugin;
  }

  /// 注销插件
  void unregisterPlugin(String identifier) {
    _plugins.remove(identifier);
  }

  /// 获取插件
  CalendarPlugin? getPlugin(String identifier) {
    return _plugins[identifier];
  }

  /// 获取所有插件
  List<CalendarPlugin> get allPlugins => _plugins.values.toList();

  /// 获取所有已启用的插件
  List<CalendarPlugin> get enabledPlugins => _plugins.values.toList();

  /// 检查插件是否存在
  bool hasPlugin(String identifier) {
    return _plugins.containsKey(identifier);
  }

  /// 获取插件数量
  int get pluginCount => _plugins.length;

  /// 清除所有插件
  void clearPlugins() {
    _plugins.clear();
  }

  /// 使用所有插件转换日期
  CalendarDate convertWithAllPlugins(DateTime date) {
    LunarDate? lunarDate;
    TibetanDate? tibetanDate;
    List<Festival> allFestivals = [];
    DailyInfo? dailyInfo;

    for (var plugin in _plugins.values) {
      var calendarDate = plugin.convert(date);
      if (calendarDate != null) {
        lunarDate ??= calendarDate.lunarDate;
        tibetanDate ??= calendarDate.tibetanDate;
        allFestivals.addAll(calendarDate.festivals);
        dailyInfo ??= calendarDate.dailyInfo;
      }
    }

    return CalendarDate(
      solarDate: date,
      lunarDate: lunarDate,
      tibetanDate: tibetanDate,
      festivals: allFestivals,
      dailyInfo: dailyInfo,
    );
  }

  /// 获取指定月份的所有节日（来自所有插件）
  List<Festival> getAllFestivals(int year, int month) {
    List<Festival> allFestivals = [];

    for (var plugin in _plugins.values) {
      allFestivals.addAll(plugin.getFestivals(year, month));
    }

    // 去重并排序
    var uniqueFestivals = <String, Festival>{};
    for (var festival in allFestivals) {
      uniqueFestivals[festival.id] = festival;
    }

    return uniqueFestivals.values.toList();
  }

  /// 获取指定年份的所有节日（来自所有插件）
  List<Festival> getAllFestivalsForYear(int year) {
    List<Festival> allFestivals = [];

    for (var plugin in _plugins.values) {
      allFestivals.addAll(plugin.getFestivalsForYear(year));
    }

    // 去重
    var uniqueFestivals = <String, Festival>{};
    for (var festival in allFestivals) {
      uniqueFestivals[festival.id] = festival;
    }

    return uniqueFestivals.values.toList();
  }

  /// 获取所有节气（来自支持的插件）
  List<Festival> getAllSolarTerms(int year) {
    List<Festival> allTerms = [];

    for (var plugin in _plugins.values) {
      var terms = plugin.getSolarTerms(year);
      if (terms != null) {
        allTerms.addAll(terms);
      }
    }

    return allTerms;
  }
}
