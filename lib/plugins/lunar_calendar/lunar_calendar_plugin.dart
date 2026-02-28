import '../../core/calendar_core/calendar_plugin.dart';
import '../../models/calendar_models.dart';
import '../../shared/algorithm/lunar_algorithm.dart';

/// 农历插件
class LunarCalendarPlugin extends BaseCalendarPlugin {
  final List<Festival> _festivals = [];

  LunarCalendarPlugin()
      : super(
          identifier: 'com.multicalendar.lunar',
          name: '农历',
          version: '2.0.0',
          calendarType: CalendarType.lunar,
          supportedYearRange: const ClosedRange(1900, 2100),
        ) {
    _loadFestivals();
  }

  void _loadFestivals() {
    _festivals.addAll([
      // 农历传统节日
      Festival(
        id: 'lunar-spring-festival',
        name: '春节',
        date: const LunarFestivalDate(1, 1),
        calendarType: CalendarType.lunar,
        type: FestivalType.traditional,
        description: '农历新年，最重要的传统节日',
      ),
      Festival(
        id: 'lunar-lantern-festival',
        name: '元宵节',
        date: const LunarFestivalDate(1, 15),
        calendarType: CalendarType.lunar,
        type: FestivalType.traditional,
        description: '正月十五，又称上元节',
      ),
      Festival(
        id: 'lunar-dragon-head',
        name: '龙抬头',
        date: const LunarFestivalDate(2, 2),
        calendarType: CalendarType.lunar,
        type: FestivalType.traditional,
        description: '二月二，青龙节',
      ),
      Festival(
        id: 'lunar-shangsi',
        name: '上巳节',
        date: const LunarFestivalDate(3, 3),
        calendarType: CalendarType.lunar,
        type: FestivalType.traditional,
        description: '三月三',
      ),
      Festival(
        id: 'lunar-buddha-birthday',
        name: '佛诞日',
        date: const LunarFestivalDate(4, 8),
        calendarType: CalendarType.lunar,
        type: FestivalType.buddhist,
        description: '四月初八，释迦牟尼佛诞辰',
      ),
      Festival(
        id: 'lunar-dragon-boat-festival',
        name: '端午节',
        date: const LunarFestivalDate(5, 5),
        calendarType: CalendarType.lunar,
        type: FestivalType.traditional,
        description: '五月初五',
      ),
      Festival(
        id: 'lunar-qixi',
        name: '七夕节',
        date: const LunarFestivalDate(7, 7),
        calendarType: CalendarType.lunar,
        type: FestivalType.traditional,
        description: '七月初七，中国情人节',
      ),
      Festival(
        id: 'lunar-ghost-festival',
        name: '中元节',
        date: const LunarFestivalDate(7, 15),
        calendarType: CalendarType.lunar,
        type: FestivalType.traditional,
        description: '七月十五，鬼节',
      ),
      Festival(
        id: 'lunar-mid-autumn-festival',
        name: '中秋节',
        date: const LunarFestivalDate(8, 15),
        calendarType: CalendarType.lunar,
        type: FestivalType.traditional,
        description: '八月十五',
      ),
      Festival(
        id: 'lunar-double-ninth-festival',
        name: '重阳节',
        date: const LunarFestivalDate(9, 9),
        calendarType: CalendarType.lunar,
        type: FestivalType.traditional,
        description: '九月初九',
      ),
      Festival(
        id: 'lunar-xiayuan',
        name: '下元节',
        date: const LunarFestivalDate(10, 15),
        calendarType: CalendarType.lunar,
        type: FestivalType.traditional,
        description: '十月十五',
      ),
      Festival(
        id: 'lunar-laba-festival',
        name: '腊八节',
        date: const LunarFestivalDate(12, 8),
        calendarType: CalendarType.lunar,
        type: FestivalType.traditional,
        description: '腊月初八',
      ),
      Festival(
        id: 'lunar-new-year-eve',
        name: '除夕',
        date: const LunarFestivalDate(12, 30),
        calendarType: CalendarType.lunar,
        type: FestivalType.traditional,
        description: '腊月最后一天',
      ),
    ]);
  }

  @override
  CalendarDate? convert(DateTime date) {
    var lunarDate = LunarAlgorithm.solarToLunar(date);
    if (lunarDate == null) return null;

    // 获取当日节日
    List<Festival> dateFestivals = [];
    for (var festival in _festivals) {
      if (festival.date is LunarFestivalDate) {
        var lunarFestivalDate = festival.date as LunarFestivalDate;
        if (lunarFestivalDate.month == lunarDate.month &&
            lunarFestivalDate.day == lunarDate.day) {
          dateFestivals.add(festival);
        }
      }
    }

    // 获取节气
    String? solarTerm = LunarAlgorithm.getSolarTerm(date);

    return CalendarDate(
      solarDate: date,
      lunarDate: lunarDate,
      festivals: dateFestivals,
      dailyInfo: _getDailyInfo(date, lunarDate, solarTerm),
    );
  }

  @override
  DateTime? convertToSolar(int year, int month, int day, {bool isLeapMonth = false}) {
    return LunarAlgorithm.lunarToSolar(year, month, day, isLeapMonth: isLeapMonth);
  }

  @override
  List<Festival> getFestivals(int year, int month) {
    return _festivals.where((festival) {
      if (festival.date is LunarFestivalDate) {
        var lunarDate = festival.date as LunarFestivalDate;
        return lunarDate.month == month;
      }
      return false;
    }).toList();
  }

  @override
  DailyInfo? getDailyInfo(DateTime date) {
    var lunarDate = LunarAlgorithm.solarToLunar(date);
    if (lunarDate == null) return null;

    String? solarTerm = LunarAlgorithm.getSolarTerm(date);
    return _getDailyInfo(date, lunarDate, solarTerm);
  }

  DailyInfo _getDailyInfo(DateTime date, LunarDate lunarDate, String? solarTerm) {
    // 简化的宜忌数据
    List<String> yi = [];
    List<String> ji = [];

    // 根据日期生成宜忌（简化版）
    int daySum = lunarDate.year + lunarDate.month + lunarDate.day;

    const List<String> yiItems = ['祭祀', '祈福', '求嗣', '开光', '出行', '解除', '纳采', '冠笄', '嫁娶', '纳婿'];
    const List<String> jiItems = ['动土', '破土', '安葬', '开仓', '纳畜', '伐木', '作梁', '造桥'];

    for (int i = 0; i < 3; i++) {
      yi.add(yiItems[(daySum + i) % yiItems.length]);
      ji.add(jiItems[(daySum + i + 3) % jiItems.length]);
    }

    // 检查三伏天和数九
    String? note = solarTerm;
    int year = date.year;

    // 三伏天检查
    var sanfu = LunarAlgorithm.getSanfu(year);
    for (var item in sanfu) {
      if (date.year == item.date.year &&
          date.month == item.date.month &&
          date.day == item.date.day) {
        note = item.name;
        break;
      }
    }

    // 数九检查
    var shujiu = LunarAlgorithm.getShujiu(year);
    for (var item in shujiu) {
      var startDate = item.date;
      var endDate = startDate.add(const Duration(days: 8));
      if (date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          date.isBefore(endDate.add(const Duration(days: 1)))) {
        note = item.name;
        break;
      }
    }

    return DailyInfo(
      date: date,
      suitable: yi,
      unsuitable: ji,
      note: note,
    );
  }

  @override
  List<Festival>? getSolarTerms(int year) {
    var terms = LunarAlgorithm.getSolarTermsOfYear(year);

    return terms.map((item) {
      var (name, termDate) = item;
      return Festival(
        id: 'solar-term-$name-$year',
        name: name,
        date: FixedDate(termDate.month, termDate.day),
        calendarType: CalendarType.solar,
        type: FestivalType.solar,
        description: '二十四节气',
      );
    }).toList();
  }
}
