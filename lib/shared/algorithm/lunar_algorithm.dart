import '../data/lunar_data.dart';
import '../../models/calendar_models.dart' show LunarDate;

/// 农历算法引擎
class LunarAlgorithm {
  /// 公历转农历
  static LunarDate? solarToLunar(DateTime date) {
    int year = date.year;
    int month = date.month;
    int day = date.day;

    // 年份范围检查
    if (year < 1900 || year > 2100) return null;

    // 计算与1900年1月31日(农历正月初一)的天数差
    DateTime baseDate = DateTime(1900, 1, 31);
    int offset = date.difference(baseDate).inDays;

    if (offset < 0) return null;

    // 计算农历年
    int lunarYear = 1900;
    int yearDays = 0;
    while (lunarYear < 2101 && offset > 0) {
      yearDays = LunarData.getYearDays(lunarYear);
      if (offset < yearDays) break;
      offset -= yearDays;
      lunarYear++;
    }

    // 计算农历月和日
    int leapMonth = LunarData.getLeapMonth(lunarYear);
    bool isLeap = false;
    int lunarMonth = 1;
    int monthDays = 0;

    for (int i = 1; i <= 12 && offset > 0; i++) {
      // 闰月
      if (leapMonth > 0 && i == leapMonth + 1 && !isLeap) {
        i--;
        isLeap = true;
        monthDays = LunarData.getLeapDays(lunarYear);
      } else {
        monthDays = LunarData.getMonthDays(lunarYear, i);
      }

      if (offset < monthDays) {
        lunarMonth = i;
        break;
      }

      offset -= monthDays;
      isLeap = false;
    }

    int lunarDay = offset + 1;

    // 获取年份名称
    int ganIndex = (lunarYear - 4) % 10;
    int zhiIndex = (lunarYear - 4) % 12;
    String yearName = '${LunarData.tianGan[ganIndex]}${LunarData.diZhi[zhiIndex]}年';
    
    // 获取生肖
    int zodiacIndex = (lunarYear - 4) % 12;
    String zodiac = LunarData.zodiacs[zodiacIndex];
    
    // 获取月份名称
    String monthName = LunarData.months[lunarMonth - 1];
    if (isLeap && lunarMonth == leapMonth) {
      monthName = '闰$monthName';
    }
    
    // 获取日期名称
    String dayName = LunarData.days[lunarDay - 1];

    return LunarDate(
      year: lunarYear,
      month: lunarMonth,
      day: lunarDay,
      isLeapMonth: isLeap && lunarMonth == leapMonth,
      yearName: yearName,
      monthName: monthName,
      dayName: dayName,
      zodiac: zodiac,
      ganZhi: yearName,
    );
  }

  /// 农历转公历
  static DateTime? lunarToSolar(int year, int month, int day, {bool isLeapMonth = false}) {
    // 参数校验
    if (year < 1900 || year > 2100) return null;
    if (month < 1 || month > 12) return null;
    if (day < 1 || day > 30) return null;

    // 计算从1900年1月31日到目标日期的天数
    int offset = 0;

    // 累加年份天数
    for (int y = 1900; y < year; y++) {
      offset += LunarData.getYearDays(y);
    }

    // 获取闰月信息
    int leapMonth = LunarData.getLeapMonth(year);

    // 累加月份天数
    if (isLeapMonth) {
      for (int m = 1; m <= month; m++) {
        offset += LunarData.getMonthDays(year, m);
      }
      offset += LunarData.getLeapDays(year);
    } else {
      for (int m = 1; m < month; m++) {
        offset += LunarData.getMonthDays(year, m);
        if (leapMonth == m) {
          offset += LunarData.getLeapDays(year);
        }
      }
    }

    // 累加日期天数
    offset += day - 1;

    // 计算公历日期
    DateTime baseDate = DateTime(1900, 1, 31);
    return baseDate.add(Duration(days: offset));
  }

  /// 获取节气
  static String? getSolarTerm(DateTime date) {
    int year = date.year;
    
    for (int i = 0; i < 24; i++) {
      // 计算该年该节气的日期
      int termOffset = _getSolarTermOffset(year, i);
      DateTime termDate = DateTime(1900, 1, 6).add(Duration(days: termOffset));
      
      if (termDate.year == date.year && 
          termDate.month == date.month && 
          termDate.day == date.day) {
        return LunarData.solarTerms[i];
      }
    }
    return null;
  }

  /// 获取指定年份的所有节气
  static List<(String name, DateTime date)> getSolarTermsOfYear(int year) {
    List<(String, DateTime)> result = [];
    
    for (int i = 0; i < 24; i++) {
      int termOffset = _getSolarTermOffset(year, i);
      DateTime termDate = DateTime(1900, 1, 6).add(Duration(days: termOffset));
      
      if (termDate.year == year) {
        result.add((LunarData.solarTerms[i], termDate));
      }
    }
    
    return result;
  }

  /// 计算节气偏移量
  static int _getSolarTermOffset(int year, int index) {
    // 节气计算公式
    int termIndex = (year - 1900) * 24 + index;
    int baseOffset = LunarData.solarTermInfo[index % 24];
    double avgDaysPerYear = 365.2422;
    int offset = ((termIndex ~/ 24) * avgDaysPerYear).round() + baseOffset ~/ (24 * 60);
    return offset;
  }

  /// 三伏天数据
  static List<({String name, DateTime date})> getSanfu(int year) {
    // 夏至后第三个庚日为初伏
    // 夏至后第四个庚日为中伏
    // 立秋后第一个庚日为末伏
    
    DateTime xiazhi = _findSolarTermDate(year, '夏至');
    DateTime liqiu = _findSolarTermDate(year, '立秋');
    
    // 找夏至后第三个庚日
    DateTime chufu = _findNextGengDay(xiazhi, 3);
    // 找夏至后第四个庚日
    DateTime zhongfu = chufu.add(const Duration(days: 10));
    // 找立秋后第一个庚日
    DateTime mofu = _findNextGengDay(liqiu, 1);
    
    return [
      (name: '初伏', date: chufu),
      (name: '中伏', date: zhongfu),
      (name: '末伏', date: mofu),
    ];
  }

  /// 数九数据
  static List<({String name, DateTime date})> getShujiu(int year) {
    // 冬至为一九第一天
    DateTime dongzhi = _findSolarTermDate(year, '冬至');
    
    const List<String> jiuNames = [
      '一九', '二九', '三九', '四九', '五九',
      '六九', '七九', '八九', '九九'
    ];
    
    return List.generate(9, (i) => (
      name: jiuNames[i],
      date: dongzhi.add(Duration(days: i * 9)),
    ));
  }

  /// 查找节气日期
  static DateTime _findSolarTermDate(int year, String termName) {
    int index = LunarData.solarTerms.indexOf(termName);
    if (index == -1) return DateTime(year, 1, 1);
    
    int termOffset = _getSolarTermOffset(year, index);
    return DateTime(1900, 1, 6).add(Duration(days: termOffset));
  }

  /// 找下一个庚日
  static DateTime _findNextGengDay(DateTime date, int count) {
    // 庚日的天干索引是6 (甲乙丙丁戊己庚)
    DateTime result = date;
    int found = 0;
    
    while (found < count) {
      result = result.add(const Duration(days: 1));
      int dayGan = (result.difference(DateTime(1900, 1, 1)).inDays + 6) % 10;
      if (dayGan == 6) {
        found++;
      }
    }
    
    return result;
  }
}
