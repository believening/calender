import '../../core/calendar_core/calendar_plugin.dart';
import '../../models/calendar_models.dart';
import '../../shared/algorithm/tibetan_algorithm.dart';
import '../../shared/data/tibetan_data.dart';

/// 藏历插件
class TibetanCalendarPlugin extends BaseCalendarPlugin {
  final List<Festival> _festivals = [];

  TibetanCalendarPlugin()
      : super(
          identifier: 'com.multicalendar.tibetan',
          name: '藏历',
          version: '2.0.0',
          calendarType: CalendarType.tibetan,
          supportedYearRange: const ClosedRange(1950, 2050),
        ) {
    _loadFestivals();
  }

  void _loadFestivals() {
    for (var festival in TibetanData.majorFestivals) {
      _festivals.add(Festival(
        id: 'tibetan-${festival.month}-${festival.day}',
        name: festival.name,
        nameTibetan: festival.nameTibetan,
        date: TibetanFestivalDate(festival.month, festival.day),
        calendarType: CalendarType.tibetan,
        type: festival.name.contains('佛') || festival.name.contains('萨迦')
            ? FestivalType.buddhist
            : FestivalType.traditional,
        description: festival.description,
      ));
    }
  }

  @override
  CalendarDate? convert(DateTime date) {
    var tibetanDate = TibetanAlgorithm.solarToTibetan(date);
    if (tibetanDate == null) return null;

    // 获取当日节日
    List<Festival> dateFestivals = [];
    for (var festival in _festivals) {
      if (festival.date is TibetanFestivalDate) {
        var tibetanFestivalDate = festival.date as TibetanFestivalDate;
        if (tibetanFestivalDate.month == tibetanDate.month &&
            tibetanFestivalDate.day == tibetanDate.day) {
          dateFestivals.add(festival);
        }
      }
    }

    return CalendarDate(
      solarDate: date,
      tibetanDate: tibetanDate,
      festivals: dateFestivals,
      dailyInfo: getDailyInfo(date),
    );
  }

  @override
  DateTime? convertToSolar(int year, int month, int day, {bool isLeapMonth = false}) {
    return TibetanAlgorithm.tibetanToSolar(year: year, month: month, day: day);
  }

  @override
  List<Festival> getFestivals(int year, int month) {
    return _festivals.where((festival) {
      if (festival.date is TibetanFestivalDate) {
        var tibetanDate = festival.date as TibetanFestivalDate;
        return tibetanDate.month == month;
      }
      return false;
    }).toList();
  }

  @override
  DailyInfo? getDailyInfo(DateTime date) {
    var tibetanDate = TibetanAlgorithm.solarToTibetan(date);
    if (tibetanDate == null) return null;

    // 获取吉凶
    var result = TibetanAlgorithm.getDayQuality(
      tibetanDate.year,
      tibetanDate.month,
      tibetanDate.day,
    );
    var quality = result.quality;
    var description = result.description;

    // 获取九宫飞星
    var flyingStar = TibetanAlgorithm.getFlyingStar(
      tibetanDate.year,
      tibetanDate.month,
      tibetanDate.day,
    );
    int star = flyingStar.star;
    String direction = flyingStar.direction;

    // 宜忌基于吉凶
    List<String> suitable = [];
    List<String> unsuitable = [];

    switch (quality) {
      case DayQuality.veryGood:
      case DayQuality.good:
        suitable = ['祈福', '供养', '修法', '放生', '布施', '诵经'];
        break;
      case DayQuality.neutral:
        suitable = ['日常事务'];
        unsuitable = ['重大决策'];
        break;
      case DayQuality.slightlyBad:
      case DayQuality.bad:
        unsuitable = ['开业', '婚嫁', '远行', '动土'];
        break;
    }

    // 如果是殊胜日，添加特殊宜
    var specialResult = TibetanAlgorithm.isSpecialDate(date);
    bool isSpecial = specialResult.$1;
    String? specialDesc = specialResult.$2;
    if (isSpecial) {
      suitable.add('殊胜日修行');
    }

    String? note = description;
    if (isSpecial && specialDesc != null) {
      note = '$specialDesc - $description';
    }

    return DailyInfo(
      date: date,
      suitable: suitable,
      unsuitable: unsuitable,
      luckyDirections: [direction],
      unluckyDirections: star == 5 ? ['中央'] : [],
      fiveElements: tibetanDate.yearElement,
      note: note,
    );
  }

  @override
  (bool, String?)? isSpecialDate(DateTime date) {
    var (isSpecial, description) = TibetanAlgorithm.isSpecialDate(date);
    return (isSpecial, description);
  }

  /// 获取下一个殊胜日
  Map<String, dynamic>? getNextSpecialDay(DateTime fromDate) {
    var result = TibetanAlgorithm.getNextSpecialDay(fromDate);
    if (result == null) return null;
    var (date, description) = result;
    return {'date': date, 'description': description};
  }

  /// 获取全年节日
  List<Map<String, dynamic>> getAllFestivals(int year) {
    var festivals = TibetanAlgorithm.getAllFestivals(year);
    return festivals.map((f) => {
      'month': f.month,
      'day': f.day,
      'name': f.name,
      'nameTibetan': f.nameTibetan,
      'description': f.description,
      'date': f.date,
    }).toList();
  }

  /// 获取年份信息（绕迥纪年）
  Map<String, dynamic> getYearInfo(int year) {
    var info = TibetanAlgorithm.getYearInfo(year);
    return {
      'cycle': info.cycle,
      'yearInCycle': info.yearInCycle,
      'element': info.element,
      'zodiac': info.zodiac,
      'fullName': info.fullName,
    };
  }

  /// 获取缺日
  List<int> getMissingDays(int year, int month) {
    return TibetanAlgorithm.getMissingDays(year, month);
  }

  /// 获取重日
  List<int> getDoubledays(int year, int month) {
    return TibetanAlgorithm.getDoubledays(year, month);
  }

  /// 获取九宫飞星
  Map<String, dynamic> getFlyingStarData(int year, int month, int day) {
    var result = TibetanAlgorithm.getFlyingStar(year, month, day);
    return {
      'star': result.star,
      'direction': result.direction,
      'meaning': result.meaning,
    };
  }
}
