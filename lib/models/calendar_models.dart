/// 多民族日历核心数据模型

/// 统一的日历日期表示
class CalendarDate {
  final String id;

  /// 公历日期
  final DateTime solarDate;

  /// 农历日期（可选）
  final LunarDate? lunarDate;

  /// 藏历日期（可选）
  final TibetanDate? tibetanDate;

  /// 节日列表
  final List<Festival> festivals;

  /// 每日宜忌信息
  final DailyInfo? dailyInfo;

  CalendarDate({
    required this.solarDate,
    this.lunarDate,
    this.tibetanDate,
    this.festivals = const [],
    this.dailyInfo,
  }) : id = '${solarDate.year}-${solarDate.month}-${solarDate.day}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarDate && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// 农历日期
class LunarDate {
  final int year;           // 农历年
  final int month;          // 农历月
  final int day;            // 农历日
  final bool isLeapMonth;   // 是否闰月

  /// 年份名称（如：甲子年）
  final String? yearName;

  /// 月份名称（如：正月）
  final String? monthName;

  /// 日期名称（如：初一）
  final String? dayName;

  /// 生肖（如：鼠）
  final String? zodiac;

  /// 天干地支
  final String? ganZhi;

  const LunarDate({
    required this.year,
    required this.month,
    required this.day,
    this.isLeapMonth = false,
    this.yearName,
    this.monthName,
    this.dayName,
    this.zodiac,
    this.ganZhi,
  });

  @override
  String toString() {
    return '$yearName($zodiac) $monthName$dayName';
  }
}

/// 藏历日期
class TibetanDate {
  final int year;           // 藏历年
  final int month;          // 藏历月
  final int day;            // 藏历日

  /// 五行+生肖纪年（如：火马年）
  final String? yearElement;

  /// 月份名称（藏文）
  final String? monthNameTibetan;

  /// 月份名称（中文）
  final String? monthNameChinese;

  /// 日期名称（藏文）
  final String? dayNameTibetan;

  /// 日期名称（中文）
  final String? dayNameChinese;

  /// 是否缺日
  final bool isMissingDay;

  /// 是否重日
  final bool isDoubleday;

  const TibetanDate({
    required this.year,
    required this.month,
    required this.day,
    this.yearElement,
    this.monthNameTibetan,
    this.monthNameChinese,
    this.dayNameTibetan,
    this.dayNameChinese,
    this.isMissingDay = false,
    this.isDoubleday = false,
  });

  @override
  String toString() {
    return '$yearElement $monthNameChinese${dayNameTibetan ?? day}';
  }
}

/// 节日
class Festival {
  final String id;
  final String name;                // 节日名称
  final String? nameTibetan;        // 藏文名称
  final FestivalDate date;          // 日期
  final CalendarType calendarType;  // 所属历法

  /// 节日类型
  final FestivalType type;

  /// 节日描述
  final String? description;

  /// 相关图片
  final String? imageUrl;

  const Festival({
    required this.id,
    required this.name,
    this.nameTibetan,
    required this.date,
    required this.calendarType,
    this.type = FestivalType.traditional,
    this.description,
    this.imageUrl,
  });
}

/// 节日日期
abstract class FestivalDate {
  const FestivalDate();
}

/// 固定日期
class FixedDate extends FestivalDate {
  final int month;
  final int day;

  const FixedDate(this.month, this.day);
}

/// 相对日期（如：五月第二个星期日）
class RelativeDate extends FestivalDate {
  final int month;
  final int week;
  final int weekday;

  const RelativeDate(this.month, this.week, this.weekday);
}

/// 农历日期
class LunarFestivalDate extends FestivalDate {
  final int month;
  final int day;

  const LunarFestivalDate(this.month, this.day);
}

/// 藏历日期
class TibetanFestivalDate extends FestivalDate {
  final int month;
  final int day;

  const TibetanFestivalDate(this.month, this.day);
}

/// 节日类型
enum FestivalType {
  traditional('传统节日'),
  buddhist('佛教节日'),
  national('国家节日'),
  solar('节气'),
  custom('自定义');

  final String label;
  const FestivalType(this.label);
}

/// 历法类型
enum CalendarType {
  solar('公历'),
  lunar('农历'),
  tibetan('藏历'),
  islamic('伊斯兰历'),
  dai('傣历'),
  yi('彝历');

  final String label;
  const CalendarType(this.label);
}

/// 每日详细信息
class DailyInfo {
  final DateTime date;

  /// 宜
  final List<String> suitable;

  /// 忌
  final List<String> unsuitable;

  /// 吉神方位
  final List<String> luckyDirections;

  /// 凶神方位
  final List<String> unluckyDirections;

  /// 胎神方位
  final String? fetusGodDirection;

  /// 彭祖百忌
  final String? pengzuTaboo;

  /// 五行
  final String? fiveElements;

  /// 冲煞
  final String? chongSha;

  /// 备注
  final String? note;

  const DailyInfo({
    required this.date,
    this.suitable = const [],
    this.unsuitable = const [],
    this.luckyDirections = const [],
    this.unluckyDirections = const [],
    this.fetusGodDirection,
    this.pengzuTaboo,
    this.fiveElements,
    this.chongSha,
    this.note,
  });
}

/// 提醒规则
class ReminderRule {
  final String id;

  /// 提醒名称
  final String name;

  /// 提醒类型
  final ReminderType type;

  /// 是否启用
  final bool isEnabled;

  /// 提前天数
  final int advanceDays;

  /// 提醒时间（小时:分钟）
  final String reminderTime;

  const ReminderRule({
    required this.id,
    required this.name,
    required this.type,
    this.isEnabled = true,
    this.advanceDays = 0,
    this.reminderTime = '09:00',
  });
}

/// 提醒类型
enum ReminderType {
  newMoon('初一提醒'),
  fullMoon('十五提醒'),
  buddhistFestival('佛教节日'),
  traditionalFestival('传统节日'),
  solarTerm('节气'),
  tibetanFestival('藏历节日'),
  custom('自定义');

  final String label;
  const ReminderType(this.label);
}

/// 日历插件元数据
class CalendarPluginMetadata {
  final String identifier;       // 插件标识
  final String name;             // 插件名称
  final String? nameEn;          // 英文名称
  final String version;          // 版本号
  final String? author;          // 作者
  final String? description;     // 描述
  final CalendarType calendarType;  // 历法类型

  /// 支持的年份范围
  final int minYear;
  final int maxYear;

  /// 支持的语言
  final List<String> supportedLanguages;

  /// 资源下载地址（可选）
  final String? downloadUrl;

  /// 资源版本
  final String? resourceVersion;

  /// 资源大小（字节）
  final int? resourceSize;

  const CalendarPluginMetadata({
    required this.identifier,
    required this.name,
    this.nameEn,
    required this.version,
    this.author,
    this.description,
    required this.calendarType,
    required this.minYear,
    required this.maxYear,
    this.supportedLanguages = const ['zh-Hans'],
    this.downloadUrl,
    this.resourceVersion,
    this.resourceSize,
  });

  ClosedRange<int> get supportedYearRange => ClosedRange(minYear, maxYear);
}

/// 简单的范围类
class ClosedRange<T extends num> {
  final T start;
  final T end;

  const ClosedRange(this.start, this.end);

  bool contains(T value) => value >= start && value <= end;

  @override
  String toString() => '$start...$end';
}

/// 插件状态
enum PluginState {
  notInstalled('未安装'),
  installed('已安装'),
  needsUpdate('需要更新'),
  error('错误');

  final String label;
  const PluginState(this.label);
}
