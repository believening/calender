/// 藏历数据表 (1950-2050年)
///
/// 藏历基础知识：
/// - 基于11世纪传入的印度时轮历 (Kalachakra)
/// - 使用绕迥 (Rabjung) 60年周期纪年，始于1027年
/// - 五行顺序：木→火→土→铁→水（与中国历法相同）
/// - 生肖顺序：兔→龙→蛇→马→羊→猴→鸡→狗→猪→鼠→牛→虎（与中国历法不同！）
/// - 每个五行对应连续两年（先阳年后阴年）
class TibetanData {
  // 五行（按藏历顺序）
  static const List<String> elements = ['木', '火', '土', '铁', '水'];
  static const List<String> elementsTibetan = ['ཤིང་', 'མེ་', 'ས་', 'ལྕགས་', 'ཆུ་'];
  static const List<String> elementsEnglish = ['Wood', 'Fire', 'Earth', 'Iron', 'Water'];

  // 生肖（按藏历顺序：兔为首，虎为尾）
  // 注意：这与中国历法的鼠→牛→虎...顺序不同！
  static const List<String> zodiacs = ['兔', '龙', '蛇', '马', '羊', '猴', '鸡', '狗', '猪', '鼠', '牛', '虎'];
  static const List<String> zodiacsTibetan = ['ཡོས', 'འབྲུག', 'སྦྲུལ', 'རྟ', 'ལུག', 'སྤྲེལ', 'བྱ', 'ཁྱི', 'ཕག', 'བྱི་བ', 'གླང་', 'སྟག'];
  static const List<String> zodiacsEnglish = ['Rabbit', 'Dragon', 'Snake', 'Horse', 'Sheep', 'Monkey', 'Bird', 'Dog', 'Pig', 'Rat', 'Ox', 'Tiger'];

  // 阴阳性
  static const List<String> genders = ['阳', '阴'];
  static const List<String> gendersTibetan = ['ཕོ', 'མོ'];

  // 月份名称
  static const List<String> monthsChinese = [
    '一月', '二月', '三月', '四月', '五月', '六月',
    '七月', '八月', '九月', '十月', '十一月', '十二月'
  ];
  static const List<String> monthsTibetan = [
    'ཧོར་ཟླ་དང་པོ', 'ཧོར་ཟླ་གཉིས་པ', 'ཧོར་ཟླ་གསུམ་པ', 'ཧོར་ཟླ་བཞི་པ',
    'ཧོར་ཟླ་ལྔ་པ', 'ཧོར་ཟླ་དྲུག་པ', 'ཧོར་ཟླ་བདུན་པ', 'ཧོར་ཟླ་བརྒྱད་པ',
    'ཧོར་ཟླ་དགུ་པ', 'ཧོར་ཟླ་བཅུ་པ', 'ཧོར་ཟླ་བཅུ་གཅིག་པ', 'ཧོར་ཟླ་བཅུ་གཉིས་པ'
  ];

  // 日期名称
  static const List<String> daysTibetan = [
    'གཅིག', 'གཉིས', 'གསུམ', 'བཞི', 'ལྔ', 'དྲུག', 'བདུན', 'བརྒྱད', 'དགུ', 'བཅུ',
    'བཅུ་གཅིག', 'བཅུ་གཉིས', 'བཅུ་གསུམ', 'བཅུ་བཞི', 'བཅོ་ལྔ',
    'བཅུ་དྲུག', 'བཅུ་བདུན', 'བཅུ་བརྒྱད', 'བཅུ་དགུ', 'ཉི་ཤུ',
    'ཉེར་གཅིག', 'ཉེར་གཉིས', 'ཉེར་གསུམ', 'ཉེར་བཞི', 'ཉེར་ལྔ',
    'ཉེར་དྲུག', 'ཉེར་བདུན', 'ཉེར་བརྒྱད', 'ཉེར་དགུ', 'སུམ་ཅུ'
  ];

  // 殊胜日
  static const Set<int> specialDays = {1, 8, 10, 15, 18, 25, 30};

  // 殊胜日描述
  static const Map<int, String> specialDayDescriptions = {
    1: '初一 - 吉祥日',
    8: '初八 - 药师佛节日',
    10: '初十 - 莲师荟供日',
    15: '十五 - 佛陀节日 (满月)',
    18: '十八 - 观音菩萨节日',
    25: '廿五 - 空行母荟供日',
    30: '三十 - 释迦牟尼佛节日 (新月)',
  };

  // 重大节日
  static const List<({int month, int day, String name, String nameTibetan, String description})> majorFestivals = [
    // 藏历新年及正月节日
    (month: 1, day: 1, name: '藏历新年', nameTibetan: 'ལོ་གསར', description: '藏族最重要的传统节日，庆祝新的一年开始'),
    (month: 1, day: 3, name: '麦朵切', nameTibetan: 'སྨོན་ལམ་ཆེན་པོ', description: '拉萨大昭寺传召大法会开始'),
    (month: 1, day: 8, name: '神变节', nameTibetan: 'ཆོ་འཕྲུལ་དུས་ཆེན', description: '佛陀示现神变的日子'),
    (month: 1, day: 15, name: '酥油花灯节', nameTibetan: 'ཆོས་འཁོར་དུས་ཆེན', description: '正月十五，纪念佛陀示现神变，展出酥油花'),
    (month: 1, day: 25, name: '正月末', nameTibetan: 'དང་པོའི་མཇུག', description: '正月最后一个殊胜日'),

    // 二月节日
    (month: 2, day: 15, name: '二月十五', nameTibetan: 'ཟླ་གཉིས་པའི་བཅོ་ལྔ', description: '春季重要的佛教节日'),

    // 三月节日
    (month: 3, day: 15, name: '三月十五', nameTibetan: 'ཟླ་གསུམ་པའི་བཅོ་ལྔ', description: '时轮金刚灌顶纪念日'),

    // 四月节日 (萨迦达瓦 - 最重要)
    (month: 4, day: 7, name: '佛陀诞辰', nameTibetan: 'སྐུ་བལྟམས་པའི་དུས་ཆེན', description: '佛陀诞生'),
    (month: 4, day: 15, name: '萨迦达瓦', nameTibetan: 'ས་ག་ཟླ་བ', description: '佛诞、成道、涅槃三节合一，藏历最殊胜日'),
    (month: 4, day: 25, name: '四月末', nameTibetan: 'ས་གའི་མཇུག', description: '萨迦达瓦月最后一个殊胜日'),

    // 六月节日
    (month: 6, day: 4, name: '佛陀初转法轮', nameTibetan: 'ཆོས་འཁོར་དང་པོ', description: '佛陀在鹿野苑初转法轮'),
    (month: 6, day: 15, name: '六月十五', nameTibetan: 'ཟླ་དྲུག་པའི་བཅོ་ལྔ', description: '夏季重要节日'),
    (month: 6, day: 30, name: '雪顿节', nameTibetan: 'ཞོ་སྟོན', description: '吃酸奶的节日，藏戏表演'),

    // 七月节日
    (month: 7, day: 15, name: '七月十五', nameTibetan: 'ཟླ་བདུན་པའི་བཅོ་ལྔ', description: '秋季开始'),

    // 八月节日
    (month: 8, day: 3, name: '八月节', nameTibetan: 'ཟླ་བརྒྱད་པ', description: '丰收季节'),
    (month: 8, day: 15, name: '八月十五', nameTibetan: 'ཟླ་བརྒྱད་པའི་བཅོ་ལྔ', description: '中秋节 (与农历相同)'),

    // 九月节日
    (month: 9, day: 15, name: '九月十五', nameTibetan: 'ཟླ་དགུ་པའི་བཅོ་ལྔ', description: '秋季重要节日'),
    (month: 9, day: 22, name: '佛陀天降日', nameTibetan: 'ལྷ་བབས་དུས་ཆེན', description: '佛陀从三十三天返回人间'),

    // 十月节日
    (month: 10, day: 15, name: '十月十五', nameTibetan: 'ཟླ་བཅུ་པའི་བཅོ་ལྔ', description: '宗喀巴大师圆寂纪念日前夕'),
    (month: 10, day: 25, name: '燃灯节', nameTibetan: 'དགའ་ལྡན་ལྔ་མཆོད', description: '宗喀巴大师圆寂纪念日，点灯供养'),

    // 十一月节日
    (month: 11, day: 15, name: '十一月十五', nameTibetan: 'ཟླ་བཅུ་གཅིག་པའི་བཅོ་ལྔ', description: '冬季重要节日'),
    (month: 11, day: 29, name: '驱鬼节', nameTibetan: 'གླིང་རས་ཆེན་པོ', description: '年终驱鬼仪式'),

    // 十二月节日
    (month: 12, day: 15, name: '十二月十五', nameTibetan: 'ཟླ་བཅུ་གཉིས་པའི་བཅོ་ལྔ', description: '年终准备'),
    (month: 12, day: 29, name: '除夕', nameTibetan: 'ལོ་མཇུག', description: '藏历年前夜，驱鬼除旧'),
    (month: 12, day: 30, name: '除夕夜', nameTibetan: 'ལོ་རྙིང་མཇུག་རྫོགས', description: '旧年最后一天'),
  ];

  /// 获取年份的五行
  /// 
  /// 藏历五行纪年规则：
  /// - 每60年周期中，每个五行出现12次
  /// - 每个五行对应连续2年（先阳后阴）
  /// - 2024年 = 木龙年（阳木）
  /// - 2025年 = 木蛇年（阴木）
  /// - 2026年 = 火马年（阳火）
  static (String chinese, String tibetan) getElement(int year) {
    // 2024年是木年（阳木龙年），作为参考点
    // 60年周期中，五行每2年轮换一次
    int yearsSince1984 = year - 1984;
    int elementIndex = ((yearsSince1984 % 60) ~/ 2) % 5;
    if (elementIndex < 0) elementIndex += 5;
    return (elements[elementIndex], elementsTibetan[elementIndex]);
  }

  /// 获取年份的五行（英文）
  static (String english, String tibetan) getElementEnglish(int year) {
    var (chinese, tibetan) = getElement(year);
    int index = elements.indexOf(chinese);
    return (elementsEnglish[index], tibetan);
  }

  /// 获取年份的生肖
  /// 
  /// 藏历生肖顺序（兔为首）：
  /// 兔→龙→蛇→马→羊→猴→鸡→狗→猪→鼠→牛→虎
  /// 
  /// 2024年 = 龙年
  /// 2025年 = 蛇年
  /// 2026年 = 马年
  static (String chinese, String tibetan) getZodiac(int year) {
    // 1984年是鼠年（在藏历顺序中是第10个，索引9）
    // 藏历顺序：兔(0), 龙(1), 蛇(2), 马(3), 羊(4), 猴(5), 鸡(6), 狗(7), 猪(8), 鼠(9), 牛(10), 虎(11)
    // 1984年对应鼠(9)，所以偏移是9
    int baseIndex = 9; // 1984年鼠年在藏历顺序中的位置
    int zodiacIndex = (baseIndex + (year - 1984)) % 12;
    if (zodiacIndex < 0) zodiacIndex += 12;
    return (zodiacs[zodiacIndex], zodiacsTibetan[zodiacIndex]);
  }

  /// 获取年份的生肖（英文）
  static (String english, String tibetan) getZodiacEnglish(int year) {
    var (chinese, tibetan) = getZodiac(year);
    int index = zodiacs.indexOf(chinese);
    return (zodiacsEnglish[index], tibetan);
  }

  /// 获取年份的阴阳属性
  /// 
  /// 奇数年为阳，偶数年为阴
  static (String chinese, String tibetan) getGender(int year) {
    int genderIndex = year % 2; // 奇数=阳(0), 偶数=阴(1)
    return (genders[genderIndex], gendersTibetan[genderIndex]);
  }

  // 获取绕迥纪年
  static (int cycle, int yearInCycle) getRabjungYear(int year) {
    const int rabjungStart = 1027;
    int yearsSinceStart = year - rabjungStart;

    if (yearsSinceStart < 0) {
      return (0, 0);
    }

    int cycle = yearsSinceStart ~/ 60 + 1;
    int yearInCycle = yearsSinceStart % 60 + 1;

    return (cycle, yearInCycle);
  }

  /// 获取完整的年份名称
  /// 
  /// 格式：第N绕迥 阴/阳 五行生肖年
  /// 例如：第17绕迥 阳火马年
  static String getFullYearName(int year) {
    var (cycle, _) = getRabjungYear(year);
    var (gender, _) = getGender(year);
    var (element, _) = getElement(year);
    var (zodiac, _) = getZodiac(year);

    return '第$cycle绕迥 $gender$element$zodiac年';
  }

  /// 获取完整的年份名称（藏文）
  static String getFullYearNameTibetan(int year) {
    var (cycle, yearInCycle) = getRabjungYear(year);
    var (_, genderTibetan) = getGender(year);
    var (_, elementTibetan) = getElement(year);
    var (_, zodiacTibetan) = getZodiac(year);

    return 'རབ་བྱུང་$cycle ལོ་$yearInCycle $genderTibetan$elementTibetan$zodiacTibetan';
  }

  /// 获取完整的年份名称（英文）
  static String getFullYearNameEnglish(int year) {
    var (cycle, yearInCycle) = getRabjungYear(year);
    var (gender, _) = getGender(year);
    var (element, _) = getElementEnglish(year);
    var (zodiac, _) = getZodiacEnglish(year);

    String genderEn = year % 2 == 1 ? 'Male' : 'Female';
    return 'Rabjung $cycle Year $yearInCycle - $genderEn $element $zodiac';
  }

  /// 获取年份的完整信息（用于UI显示）
  static Map<String, dynamic> getYearFullInfo(int year) {
    var (cycle, yearInCycle) = getRabjungYear(year);
    var (genderCn, genderTb) = getGender(year);
    var (elementCn, elementTb) = getElement(year);
    var (zodiacCn, zodiacTb) = getZodiac(year);
    var (_, elementEn) = getElementEnglish(year);
    var (_, zodiacEn) = getZodiacEnglish(year);

    return {
      'year': year,
      'cycle': cycle,
      'yearInCycle': yearInCycle,
      'gender': {'chinese': genderCn, 'tibetan': genderTb},
      'element': {'chinese': elementCn, 'tibetan': elementTb, 'english': elementEn},
      'zodiac': {'chinese': zodiacCn, 'tibetan': zodiacTb, 'english': zodiacEn},
      'fullNameChinese': getFullYearName(year),
      'fullNameTibetan': getFullYearNameTibetan(year),
      'fullNameEnglish': getFullYearNameEnglish(year),
    };
  }

  // 获取月份天数
  static int getMonthDays(int year, int month) {
    int baseDays = 30;
    int adjustment = (year + month) % 3;

    switch (adjustment) {
      case 0:
        return baseDays - 1;
      case 1:
      case 2:
      default:
        return baseDays;
    }
  }

  // 检查是否为缺日
  static bool isMissingDay(int year, int month, int day) {
    return (year + month + day) % 64 == 0;
  }

  // 检查是否为重日
  static bool isDoubleday(int year, int month, int day) {
    return (year + month + day) % 128 == 0;
  }

  /// 旧的命名参数兼容方法
  static bool isMissingDayOld({required int year, required int month, required int day}) {
    return isMissingDay(year, month, day);
  }

  static bool isDoubledayOld({required int year, required int month, required int day}) {
    return isDoubleday(year, month, day);
  }

  // 检查是否为殊胜日
  static bool isSpecialDay(int day) {
    return specialDays.contains(day);
  }

  // 获取殊胜日描述
  static String? getSpecialDayDescription(int day) {
    return specialDayDescriptions[day];
  }

  // 获取指定月份的节日
  static List<({int day, String name, String nameTibetan, String description})> getFestivals(int month) {
    return majorFestivals
        .where((f) => f.month == month)
        .map((f) => (day: f.day, name: f.name, nameTibetan: f.nameTibetan, description: f.description))
        .toList();
  }

  // 获取指定日期的节日
  static ({String name, String nameTibetan, String description})? getFestival(int month, int day) {
    try {
      var festival = majorFestivals.firstWhere((f) => f.month == month && f.day == day);
      return (name: festival.name, nameTibetan: festival.nameTibetan, description: festival.description);
    } catch (_) {
      return null;
    }
  }
}
