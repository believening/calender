import '../../models/calendar_models.dart';

/// 日历插件协议
abstract class CalendarPlugin {
  // MARK: - 插件信息

  /// 插件标识符（唯一）
  String get identifier;

  /// 插件名称
  String get name;

  /// 插件版本
  String get version;

  /// 历法类型
  CalendarType get calendarType;

  /// 支持的年份范围
  ClosedRange<int> get supportedYearRange;

  /// 插件元数据
  CalendarPluginMetadata get metadata;

  // MARK: - 核心功能

  /// 将公历日期转换为该历法日期
  CalendarDate? convert(DateTime date);

  /// 将该历法日期转换为公历日期
  DateTime? convertToSolar(int year, int month, int day, {bool isLeapMonth = false});

  /// 获取指定月份的所有节日
  List<Festival> getFestivals(int year, int month);

  /// 获取指定日期的详细信息（宜忌等）
  DailyInfo? getDailyInfo(DateTime date);

  // MARK: - 可选功能（有默认实现）

  /// 获取指定年份的所有节日
  List<Festival> getFestivalsForYear(int year) {
    List<Festival> allFestivals = [];
    for (int month = 1; month <= 12; month++) {
      allFestivals.addAll(getFestivals(year, month));
    }
    return allFestivals;
  }

  /// 获取节气（如果支持）
  List<Festival>? getSolarTerms(int year) => null;

  /// 检查是否为特殊日期（如：佛教殊胜日）
  (bool, String?)? isSpecialDate(DateTime date) => null;
}

/// 日历插件基类
class BaseCalendarPlugin implements CalendarPlugin {
  @override
  final String identifier;

  @override
  final String name;

  @override
  final String version;

  @override
  final CalendarType calendarType;

  @override
  final ClosedRange<int> supportedYearRange;

  BaseCalendarPlugin({
    required this.identifier,
    required this.name,
    required this.version,
    required this.calendarType,
    required this.supportedYearRange,
  });

  @override
  CalendarPluginMetadata get metadata => CalendarPluginMetadata(
        identifier: identifier,
        name: name,
        version: version,
        calendarType: calendarType,
        minYear: supportedYearRange.start,
        maxYear: supportedYearRange.end,
      );

  @override
  CalendarDate? convert(DateTime date) {
    throw UnimplementedError('Must override convert()');
  }

  @override
  DateTime? convertToSolar(int year, int month, int day, {bool isLeapMonth = false}) {
    throw UnimplementedError('Must override convertToSolar()');
  }

  @override
  List<Festival> getFestivals(int year, int month) => [];

  @override
  DailyInfo? getDailyInfo(DateTime date) => null;

  @override
  List<Festival> getFestivalsForYear(int year) {
    List<Festival> allFestivals = [];
    for (int month = 1; month <= 12; month++) {
      allFestivals.addAll(getFestivals(year, month));
    }
    return allFestivals;
  }

  @override
  List<Festival>? getSolarTerms(int year) => null;

  @override
  (bool, String?)? isSpecialDate(DateTime date) => null;
}
