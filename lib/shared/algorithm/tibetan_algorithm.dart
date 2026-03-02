import '../data/tibetan_data.dart';
import '../../models/calendar_models.dart';

/// 藏历算法引擎
///
/// 藏历计算原理：
/// 1. 藏历是阴阳合历，以月相变化为基准
/// 2. 藏历新年（Losar）通常在公历1-3月之间
/// 3. 藏历月平均29.5天，有缺日和重日现象
/// 4. 每2-3年增加一个闰月
///
/// 注：本算法为简化版本，适用于POC演示
/// 精确转换需要使用专业天文算法或预计算数据表
class TibetanAlgorithm {
  /// 藏历新年偏移表（相对于公历年份）
  /// 格式：年份 -> (藏历新年公历月份, 公历日期)
  /// 数据来源：历史藏历数据
  static const Map<int, (int, int)> _losarDates = {
    2024: (2, 10),  // 2024年藏历新年：2月10日
    2025: (2, 28),  // 2025年藏历新年：2月28日
    2026: (2, 18),  // 2026年藏历新年：2月18日（预估）
    2027: (2, 7),   // 2027年藏历新年：2月7日（预估）
    2028: (2, 26),  // 2028年藏历新年：2月26日（预估）
    2029: (2, 14),  // 2029年藏历新年：2月14日（预估）
    2030: (3, 5),   // 2030年藏历新年：3月5日（预估）
  };

  /// 公历转藏历
  static TibetanDate? solarToTibetan(DateTime date) {
    int year = date.year;
    int month = date.month;
    int day = date.day;

    return solarToTibetanYMD(year: year, month: month, day: day);
  }

  /// 公历转藏历 (年月日)
  /// 
  /// 算法说明：
  /// 1. 根据藏历新年日期确定当前藏历年份
  /// 2. 计算从藏历新年开始的天数
  /// 3. 转换为藏历月日
  static TibetanDate solarToTibetanYMD({required int year, required int month, required int day}) {
    // 获取当前年和下一年的藏历新年日期
    var losarThisYear = _losarDates[year] ?? (2, 15); // 默认2月15日
    var losarNextYear = _losarDates[year + 1] ?? (2, 15);

    DateTime losarThis = DateTime(year, losarThisYear.$1, losarThisYear.$2);
    DateTime losarNext = DateTime(year + 1, losarNextYear.$1, losarNextYear.$2);
    DateTime current = DateTime(year, month, day);

    int tibetanYear;
    int daysSinceLosar;

    if (current.isBefore(losarThis)) {
      // 当前日期在藏历新年之前，属于上一个藏历年
      var losarPrevYear = _losarDates[year - 1] ?? (2, 15);
      DateTime losarPrev = DateTime(year - 1, losarPrevYear.$1, losarPrevYear.$2);
      tibetanYear = year - 1;
      daysSinceLosar = current.difference(losarPrev).inDays;
    } else {
      // 当前日期在藏历新年之后，属于当前藏历年
      tibetanYear = year;
      daysSinceLosar = current.difference(losarThis).inDays;
    }

    // 计算藏历月日
    // 藏历月平均29.5天，简化为30天计算
    int tibetanMonth = (daysSinceLosar ~/ 30) + 1;
    int tibetanDay = (daysSinceLosar % 30) + 1;

    // 边界检查
    if (tibetanMonth > 12) {
      tibetanMonth = 12;
      tibetanDay = 30;
    }
    if (tibetanDay > 30) {
      tibetanDay = 30;
    }
    if (tibetanMonth < 1) tibetanMonth = 1;
    if (tibetanDay < 1) tibetanDay = 1;

    // 获取五行和生肖
    var (elementChinese, _) = TibetanData.getElement(tibetanYear);
    var (zodiacChinese, _) = TibetanData.getZodiac(tibetanYear);

    // 年份名称
    String yearElement = '$elementChinese$zodiacChinese年';

    // 检查缺日和重日（基于简化规则）
    bool isMissing = TibetanData.isMissingDay(tibetanYear, tibetanMonth, tibetanDay);
    bool isDouble = TibetanData.isDoubleday(tibetanYear, tibetanMonth, tibetanDay);

    return TibetanDate(
      year: tibetanYear,
      month: tibetanMonth,
      day: tibetanDay,
      yearElement: yearElement,
      monthNameTibetan: TibetanData.monthsTibetan[tibetanMonth - 1],
      monthNameChinese: TibetanData.monthsChinese[tibetanMonth - 1],
      dayNameTibetan: tibetanDay <= 30 ? TibetanData.daysTibetan[tibetanDay - 1] : null,
      dayNameChinese: _getDayNameChinese(tibetanDay),
      isMissingDay: isMissing,
      isDoubleday: isDouble,
    );
  }

  /// 获取中文日期名称
  static String _getDayNameChinese(int day) {
    if (day < 1 || day > 30) return '';
    const ones = ['', '一', '二', '三', '四', '五', '六', '七', '八', '九', '十'];
    if (day <= 10) return '初${ones[day]}';
    if (day == 11) return '十一';
    if (day == 12) return '十二';
    if (day == 13) return '十三';
    if (day == 14) return '十四';
    if (day == 15) return '十五';
    if (day == 16) return '十六';
    if (day == 17) return '十七';
    if (day == 18) return '十八';
    if (day == 19) return '十九';
    if (day == 20) return '二十';
    if (day == 21) return '廿一';
    if (day == 22) return '廿二';
    if (day == 23) return '廿三';
    if (day == 24) return '廿四';
    if (day == 25) return '廿五';
    if (day == 26) return '廿六';
    if (day == 27) return '廿七';
    if (day == 28) return '廿八';
    if (day == 29) return '廿九';
    return '三十';
  }

  /// 藏历转公历
  static DateTime? tibetanToSolar({required int year, required int month, required int day}) {
    // 参数校验
    if (year < 1950 || year > 2050) return null;
    if (month < 1 || month > 12) return null;
    if (day < 1 || day > 30) return null;

    // 获取该年藏历新年的公历日期
    var losar = _losarDates[year] ?? (2, 15);
    DateTime losarDate = DateTime(year, losar.$1, losar.$2);

    // 计算从藏历新年开始的天数
    int daysFromLosar = (month - 1) * 30 + (day - 1);

    // 返回公历日期
    return losarDate.add(Duration(days: daysFromLosar));
  }

  /// 检查是否为殊胜日
  static (bool isSpecial, String? description) isSpecialDate(DateTime date) {
    TibetanDate? tibetanDate = solarToTibetan(date);
    if (tibetanDate == null) {
      return (false, null);
    }

    if (TibetanData.isSpecialDay(tibetanDate.day)) {
      String? description = TibetanData.getSpecialDayDescription(tibetanDate.day);
      return (true, description ?? '殊胜日，作何善恶成倍增长');
    }

    return (false, null);
  }

  /// 获取下一个殊胜日
  static (DateTime date, String description)? getNextSpecialDay(DateTime fromDate) {
    DateTime currentDate = fromDate;

    for (int i = 0; i < 60; i++) {
      currentDate = currentDate.add(const Duration(days: 1));

      var (isSpecial, description) = isSpecialDate(currentDate);
      if (isSpecial && description != null) {
        return (currentDate, description);
      }
    }

    return null;
  }

  /// 获取指定月份的藏历节日
  static List<({int day, String name, String nameTibetan, String description, DateTime date})> getFestivals(int year, int month) {
    var festivals = TibetanData.getFestivals(month);

    return festivals.map((festival) {
      DateTime? solarDate = tibetanToSolar(year: year, month: month, day: festival.day);
      return (
        day: festival.day,
        name: festival.name,
        nameTibetan: festival.nameTibetan,
        description: festival.description,
        date: solarDate ?? DateTime(year, month, festival.day),
      );
    }).toList();
  }

  /// 获取全年所有节日
  static List<({int month, int day, String name, String nameTibetan, String description, DateTime date})> getAllFestivals(int year) {
    List<({int month, int day, String name, String nameTibetan, String description, DateTime date})> allFestivals = [];

    for (int month = 1; month <= 12; month++) {
      var monthFestivals = getFestivals(year, month);
      for (var festival in monthFestivals) {
        allFestivals.add((
          month: month,
          day: festival.day,
          name: festival.name,
          nameTibetan: festival.nameTibetan,
          description: festival.description,
          date: festival.date,
        ));
      }
    }

    // 按日期排序
    allFestivals.sort((a, b) => a.date.compareTo(b.date));

    return allFestivals;
  }

  /// 获取指定月份的缺日
  static List<int> getMissingDays(int year, int month) {
    List<int> missingDays = [];

    for (int day = 1; day <= 30; day++) {
      if (TibetanData.isMissingDay(year, month, day)) {
        missingDays.add(day);
      }
    }

    return missingDays;
  }

  /// 获取指定月份的重日
  static List<int> getDoubledays(int year, int month) {
    List<int> doubledays = [];

    for (int day = 1; day <= 30; day++) {
      if (TibetanData.isDoubleday(year, month, day)) {
        doubledays.add(day);
      }
    }

    return doubledays;
  }

  /// 获取完整的年份信息
  static ({int cycle, int yearInCycle, String element, String zodiac, String fullName}) getYearInfo(int year) {
    var (cycle, yearInCycle) = TibetanData.getRabjungYear(year);
    var (element, _) = TibetanData.getElement(year);
    var (zodiac, _) = TibetanData.getZodiac(year);
    String fullName = TibetanData.getFullYearName(year);

    return (cycle: cycle, yearInCycle: yearInCycle, element: element, zodiac: zodiac, fullName: fullName);
  }

  /// 藏历吉凶日计算
  static ({DayQuality quality, String description}) getDayQuality(int year, int month, int day) {
    int daySum = year + month + day;

    // 殊胜日为大吉
    if (TibetanData.isSpecialDay(day)) {
      return (quality: DayQuality.veryGood, description: '殊胜日，诸事皆宜');
    }

    // 节日为吉
    var festival = TibetanData.getFestival(month, day);
    if (festival != null) {
      return (quality: DayQuality.good, description: '${festival.name}，吉祥日');
    }

    // 缺日不吉
    if (TibetanData.isMissingDay(year, month, day)) {
      return (quality: DayQuality.bad, description: '缺日，不宜重大事项');
    }

    // 重日中性
    if (TibetanData.isDoubleday(year, month, day)) {
      return (quality: DayQuality.neutral, description: '重日');
    }

    // 根据日期简单判断
    switch (daySum % 5) {
      case 0:
        return (quality: DayQuality.veryGood, description: '大吉');
      case 1:
        return (quality: DayQuality.good, description: '吉');
      case 2:
        return (quality: DayQuality.neutral, description: '平');
      case 3:
        return (quality: DayQuality.slightlyBad, description: '小凶');
      case 4:
      default:
        return (quality: DayQuality.bad, description: '凶');
    }
  }

  /// 计算十神关系
  static String getTenGods(int year1, int year2) {
    int diff = (year2 - year1 + 12) % 12;

    const List<String> relations = [
      '比肩', '劫财', '食神', '伤官', '偏财', '正财',
      '七杀', '正官', '偏印', '正印', '比肩', '劫财'
    ];

    return relations[diff];
  }

  /// 计算九宫飞星
  static ({int star, String direction, String meaning}) getFlyingStar(int year, int month, int day) {
    // 简化的九宫飞星计算
    int sum = year + month + day;
    int star = (sum % 9) + 1;

    const Map<int, String> directions = {
      1: '北方', 2: '西南', 3: '东方', 4: '东南',
      5: '中央', 6: '西北', 7: '西方', 8: '东北', 9: '南方'
    };

    const Map<int, String> meanings = {
      1: '一白贪狼 - 喜庆、人缘',
      2: '二黑巨门 - 病符、健康',
      3: '三碧禄存 - 是非、官灾',
      4: '四绿文曲 - 文昌、学业',
      5: '五黄廉贞 - 煞气、灾祸',
      6: '六白武曲 - 偏财、贵人',
      7: '七赤破军 - 口舌、破财',
      8: '八白左辅 - 正财、置业',
      9: '九紫右弼 - 喜庆、姻缘'
    };

    return (star: star, direction: directions[star] ?? '中央', meaning: meanings[star] ?? '');
  }
}

/// 日质量枚举
enum DayQuality {
  veryGood,    // 大吉
  good,        // 吉
  neutral,     // 平
  slightlyBad, // 小凶
  bad;         // 凶

  String get symbol {
    switch (this) {
      case DayQuality.veryGood:
        return '✨';
      case DayQuality.good:
        return '✅';
      case DayQuality.neutral:
        return '➖';
      case DayQuality.slightlyBad:
        return '⚠️';
      case DayQuality.bad:
        return '❌';
    }
  }
}
