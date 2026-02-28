import '../data/tibetan_data.dart';
import '../../models/calendar_models.dart';

/// 藏历算法引擎
class TibetanAlgorithm {
  /// 公历转藏历
  static TibetanDate? solarToTibetan(DateTime date) {
    int year = date.year;
    int month = date.month;
    int day = date.day;

    return solarToTibetanYMD(year: year, month: month, day: day);
  }

  /// 公历转藏历 (年月日)
  static TibetanDate solarToTibetanYMD({required int year, required int month, required int day}) {
    // 藏历与公历的差异大约在1-2个月
    // 藏历新年通常在农历新年前后

    int tibetanYear = year;
    int tibetanMonth = month - 1;
    int tibetanDay = day;

    // 调整月份
    if (tibetanMonth <= 0) {
      tibetanMonth = 12;
      tibetanYear -= 1;
    }

    // 获取五行和生肖
    var (elementChinese, elementTibetan) = TibetanData.getElement(tibetanYear);
    var (zodiacChinese, zodiacTibetan) = TibetanData.getZodiac(tibetanYear);

    // 年份名称
    String yearElement = '$elementChinese$zodiacChinese年';

    // 检查缺日和重日
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
      dayNameChinese: null,
      isMissingDay: isMissing,
      isDoubleday: isDouble,
    );
  }

  /// 藏历转公历
  static DateTime? tibetanToSolar({required int year, required int month, required int day}) {
    // 参数校验
    if (year < 1950 || year > 2050) return null;
    if (month < 1 || month > 12) return null;
    if (day < 1 || day > 30) return null;

    // 藏历大约比公历早1个月
    int solarYear = year;
    int solarMonth = month + 1;
    int solarDay = day;

    // 调整月份
    if (solarMonth > 12) {
      solarMonth = 1;
      solarYear += 1;
    }

    try {
      return DateTime(solarYear, solarMonth, solarDay);
    } catch (_) {
      return null;
    }
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
