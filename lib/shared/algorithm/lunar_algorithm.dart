import '../data/lunar_data.dart';
import '../../models/calendar_models.dart' show LunarDate;

/// 农历算法引擎
class LunarAlgorithm {
  // 五行
  static const List<String> wuXing = ['金', '木', '水', '火', '土'];
  
  // 五行对应天干
  static const Map<String, String> ganWuXing = {
    '甲': '木', '乙': '木', '丙': '火', '丁': '火', '戊': '土',
    '己': '土', '庚': '金', '辛': '金', '壬': '水', '癸': '水'
  };
  
  // 五行对应地支
  static const Map<String, String> zhiWuXing = {
    '子': '水', '丑': '土', '寅': '木', '卯': '木', '辰': '土', '巳': '火',
    '午': '火', '未': '土', '申': '金', '酉': '金', '戌': '土', '亥': '水'
  };
  
  // 地支相冲
  static const Map<String, String> chongMap = {
    '子': '午', '丑': '未', '寅': '申', '卯': '酉', '辰': '戌', '巳': '亥',
    '午': '子', '未': '丑', '申': '寅', '酉': '卯', '戌': '辰', '亥': '巳'
  };
  
  // 地支对应煞方位
  static const Map<String, String> shaMap = {
    '子': '南', '丑': '东', '寅': '北', '卯': '西', '辰': '南', '巳': '东',
    '午': '北', '未': '西', '申': '南', '酉': '东', '戌': '北', '亥': '西'
  };
  
  // 地支对应生肖
  static const Map<String, String> zhiZodiac = {
    '子': '鼠', '丑': '牛', '寅': '虎', '卯': '兔', '辰': '龙', '巳': '蛇',
    '午': '马', '未': '羊', '申': '猴', '酉': '鸡', '戌': '狗', '亥': '猪'
  };
  
  // 彭祖百忌
  static const Map<String, String> pengzuGan = {
    '甲': '不开仓财物耗散',
    '乙': '不栽植千株不长',
    '丙': '不修灶必见灾殃',
    '丁': '不剃头头必生疮',
    '戊': '不受田田主不祥',
    '己': '不破券二比并亡',
    '庚': '不经络织机虚张',
    '辛': '不合酱主人不尝',
    '壬': '泱水难更堤防',
    '癸': '不词讼理弱敌强',
  };
  
  static const Map<String, String> pengzuZhi = {
    '子': '不问卜自惹祸殃',
    '丑': '不冠带主不还乡',
    '寅': '不祭祀神鬼不尝',
    '卯': '不穿井水泉不香',
    '辰': '不哭泣必主重丧',
    '巳': '不远行财物伏藏',
    '午': '不苫盖屋主更张',
    '未': '不服药毒气入肠',
    '申': '不安床鬼祟入房',
    '酉': '不宴客醉坐颠狂',
    '戌': '不吃犬作怪上床',
    '亥': '不嫁娶不利新郎',
  };
  
  // 日干支纳音（五行）
  static const List<String> naYin = [
    '海中金', '炉中火', '大林木', '路旁土', '剑锋金', '山头火',
    '涧下水', '城头土', '白蜡金', '杨柳木', '泉中水', '屋上土',
    '霹雳火', '松柏木', '长流水', '沙中金', '山下火', '平地木',
    '壁上土', '金箔金', '覆灯火', '天河水', '大驿土', '钗钏金',
    '桑柘木', '大溪水', '沙中土', '天上火', '石榴木', '大海水'
  ];
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

    for (int i = 1; i <= 12 && offset >= 0; i++) {
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

  /// 获取日干支
  static (String gan, String zhi) getDayGanZhi(DateTime date) {
    // 以1900年1月1日为基准（甲戌日）
    DateTime baseDate = DateTime(1900, 1, 1);
    int offset = date.difference(baseDate).inDays;
    
    // 1900年1月1日是甲戌日（天干索引0，地支索引10）
    int ganIndex = (offset + 0) % 10;
    int zhiIndex = (offset + 10) % 12;
    
    return (LunarData.tianGan[ganIndex], LunarData.diZhi[zhiIndex]);
  }

  /// 获取冲煞信息
  /// 返回: (冲生肖, 煞方位)
  static (String chong, String sha) getChongSha(DateTime date) {
    final (_, zhi) = getDayGanZhi(date);
    final chongZhi = chongMap[zhi] ?? '';
    final chongZodiac = zhiZodiac[chongZhi] ?? '';
    final sha = shaMap[zhi] ?? '';
    
    return ('冲$chongZodiac', '煞$sha');
  }

  /// 获取日纳音五行
  static String getNaYin(DateTime date) {
    final (gan, zhi) = getDayGanZhi(date);
    int ganIndex = LunarData.tianGan.indexOf(gan);
    int zhiIndex = LunarData.diZhi.indexOf(zhi);
    
    // 纳音索引 = (天干索引 * 2 + 地支索引 / 2) % 30
    // 简化算法：基于干支组合
    int offset = (ganIndex % 5) * 2 + (zhiIndex % 6) ~/ 2;
    offset = offset % 30;
    
    return naYin[offset];
  }

  /// 获取彭祖百忌
  /// 返回: (天干忌, 地支忌)
  static (String ganTaboo, String zhiTaboo) getPengzuTaboo(DateTime date) {
    final (gan, zhi) = getDayGanZhi(date);
    final ganTaboo = pengzuGan[gan] ?? '';
    final zhiTaboo = pengzuZhi[zhi] ?? '';
    
    return (ganTaboo, zhiTaboo);
  }

  /// 获取胎神方位
  static String getFetusGodDirection(DateTime date) {
    final (gan, zhi) = getDayGanZhi(date);
    
    // 天干对应的胎神方位
    const Map<String, String> ganFetus = {
      '甲': '门', '乙': '碓', '丙': '灶', '丁': '仓', '戊': '房',
      '己': '床', '庚': '碓', '辛': '厨', '壬': '仓', '癸': '房'
    };
    
    // 地支对应的胎神方位
    const Map<String, String> zhiFetus = {
      '子': '碓', '丑': '厕', '寅': '炉', '卯': '门', '辰': '栖', '巳': '床',
      '午': '窗', '未': '厕', '申': '碓', '酉': '门', '戌': '栖', '亥': '床'
    };
    
    final ganDir = ganFetus[gan] ?? '';
    final zhiDir = zhiFetus[zhi] ?? '';
    
    return '$ganDir$zhiDir外正${shaMap[zhi] ?? ''}';
  }

  /// 获取吉神方位
  static List<String> getLuckyDirections(DateTime date) {
    final (_, zhi) = getDayGanZhi(date);
    
    // 基于地支的吉神方位
    const Map<String, List<String>> luckyMap = {
      '子': ['东北', '西南'],
      '丑': ['东', '西'],
      '寅': ['北', '南'],
      '卯': ['西北', '东南'],
      '辰': ['北', '南'],
      '巳': ['东', '西'],
      '午': ['东北', '西南'],
      '未': ['西北', '东南'],
      '申': ['北', '南'],
      '酉': ['东', '西'],
      '戌': ['东北', '西南'],
      '亥': ['西北', '东南'],
    };
    
    return luckyMap[zhi] ?? [];
  }

  /// 获取凶神方位
  static List<String> getUnluckyDirections(DateTime date) {
    final (_, zhi) = getDayGanZhi(date);
    final sha = shaMap[zhi] ?? '';
    return ['正$sha'];
  }
}
