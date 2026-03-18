import 'package:flutter/material.dart';
import '../../core/theme/calendar_theme.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/providers/calendar_settings_provider.dart';
import '../../models/calendar_models.dart';
import 'tiles/info_tile.dart';

/// 日期详情卡片 - Modern UI 磁贴风格
///
/// 设计原则：
/// - 每种历法的每种详情类型 = 一个磁贴
/// - 所有磁贴平铺展示，不需要 tab
/// - 支持左右滑动切换历法（整组磁贴切换）
/// - 每个磁贴可翻转显示释义
class DateDetailCard extends StatefulWidget {
  final CalendarDate date;
  final CalendarSettingsProvider settings;
  final CalendarTheme theme;

  const DateDetailCard({
    super.key,
    required this.date,
    required this.settings,
    required this.theme,
  });

  @override
  State<DateDetailCard> createState() => _DateDetailCardState();
}

class _DateDetailCardState extends State<DateDetailCard> {
  late PageController _pageController;
  int _currentPage = 0;
  late List<CalendarType> _calendarTypes;

  @override
  void initState() {
    super.initState();
    _updateCalendarTypes();
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void didUpdateWidget(DateDetailCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateCalendarTypes();
  }

  void _updateCalendarTypes() {
    _calendarTypes = [];
    
    if (widget.settings.showLunarCalendar) {
      _calendarTypes.add(CalendarType.lunar);
    }
    if (widget.settings.showTibetanCalendar) {
      _calendarTypes.add(CalendarType.tibetan);
    }

    if (_currentPage >= _calendarTypes.length) {
      _currentPage = 0;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.scale;

    if (_calendarTypes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: context.responsiveSpacing(16)),
      decoration: BoxDecoration(
        color: widget.theme.cardColor,
        borderRadius: BorderRadius.circular(20 * scale),
        boxShadow: [
          BoxShadow(
            color: widget.theme.primaryColor.withOpacity(0.08),
            blurRadius: 24 * scale,
            offset: Offset(0, 8 * scale),
          ),
        ],
      ),
      child: Column(
        children: [
          // 历法指示器
          if (_calendarTypes.length > 1)
            _buildCalendarIndicator(context, scale),
          
          // 磁贴内容（PageView 整体切换）
          SizedBox(
            height: _calculateContentHeight(context, scale),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemCount: _calendarTypes.length,
              itemBuilder: (context, index) {
                return SingleChildScrollView(
                  padding: EdgeInsets.all(context.responsiveSpacing(16)),
                  child: _buildTileGrid(context, _calendarTypes[index], scale),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 历法指示器（小圆点）
  Widget _buildCalendarIndicator(BuildContext context, double scale) {
    return Padding(
      padding: EdgeInsets.only(top: 12 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _calendarTypes.asMap().entries.map((entry) {
          final isSelected = entry.key == _currentPage;
          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                entry.key,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.symmetric(horizontal: 4 * scale),
              width: isSelected ? 24 * scale : 8 * scale,
              height: 8 * scale,
              decoration: BoxDecoration(
                color: isSelected
                    ? widget.theme.primaryColor
                    : widget.theme.textHint.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4 * scale),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 磁贴网格布局
  Widget _buildTileGrid(BuildContext context, CalendarType type, double scale) {
    final tiles = _buildTilesForCalendar(type, scale);
    
    if (tiles.isEmpty) {
      return _buildEmptyState(context, type, scale);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 历法标题
        Padding(
          padding: EdgeInsets.only(bottom: 12 * scale),
          child: Row(
            children: [
              Text(
                _getCalendarIcon(type),
                style: TextStyle(fontSize: 18 * scale),
              ),
              SizedBox(width: 8 * scale),
              Text(
                _getCalendarName(type),
                style: TextStyle(
                  fontSize: context.responsiveFontSize(16),
                  fontWeight: FontWeight.bold,
                  color: widget.theme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        
        // 磁贴网格
        InfoTileGrid(
          tiles: tiles,
          crossAxisCountMobile: 1,
          crossAxisCountTablet: 2,
          spacing: 12,
        ),
      ],
    );
  }

  /// 根据历法类型构建磁贴列表
  List<Widget> _buildTilesForCalendar(CalendarType type, double scale) {
    switch (type) {
      case CalendarType.lunar:
        return _buildLunarTiles(context, scale);
      case CalendarType.tibetan:
        return _buildTibetanTiles(context, scale);
      default:
        return [];
    }
  }

  /// 农历磁贴
  List<Widget> _buildLunarTiles(BuildContext context, double scale) {
    final tiles = <Widget>[];
    final lunarDate = widget.date.lunarDate;
    final dailyInfo = widget.date.dailyInfo;

    if (lunarDate == null) return tiles;

    // 农历月日信息
    tiles.add(InfoTile(
      type: InfoTileType.lunarInfo,
      content: '${lunarDate.monthName ?? ''}${lunarDate.dayName ?? ''}',
      explanation: '农历是中国传统历法，结合月相变化与太阳年长度。${lunarDate.ganZhi ?? ''}年，生肖${lunarDate.zodiac ?? ''}。',
      theme: widget.theme,
      compact: true,
    ));

    // 节气
    if (widget.settings.showDailyInfo && dailyInfo?.note != null) {
      tiles.add(InfoTile(
        type: InfoTileType.solarTerm,
        content: dailyInfo!.note!,
        explanation: '节气是根据太阳在黄道上的位置划分的24个时间点，每个节气约15天，用于指导农事和日常生活。',
        theme: widget.theme,
      ));
    }

    // 五行纳音
    if (widget.settings.showDailyInfo && dailyInfo?.fiveElements != null) {
      tiles.add(InfoTile(
        type: InfoTileType.fiveElements,
        content: dailyInfo!.fiveElements!,
        explanation: '纳音五行是干支对应的五行属性。今日干支五行属${_extractFiveElement(dailyInfo!.fiveElements!)}，可用于命理推算和择日参考。',
        theme: widget.theme,
      ));
    }

    // 冲煞
    if (widget.settings.showDailyInfo && dailyInfo?.chongSha != null) {
      tiles.add(InfoTile(
        type: InfoTileType.chongSha,
        content: dailyInfo!.chongSha!,
        explanation: _getChongShaExplanation(dailyInfo!.chongSha!),
        theme: widget.theme,
      ));
    }

    // 宜忌
    if (widget.settings.showDailyInfo && dailyInfo != null) {
      final yiText = dailyInfo.suitable.isNotEmpty
          ? '宜：${dailyInfo.suitable.take(5).join('、')}'
          : '';
      final jiText = dailyInfo.unsuitable.isNotEmpty
          ? '忌：${dailyInfo.unsuitable.take(5).join('、')}'
          : '';
      
      if (yiText.isNotEmpty || jiText.isNotEmpty) {
        tiles.add(InfoTile(
          type: InfoTileType.yiJi,
          content: [yiText, jiText].where((s) => s.isNotEmpty).join('\n'),
          explanation: '宜忌是根据当日干支五行推算的行事参考。「宜」表示适合进行的事项，「忌」表示应避免的事项，源自传统黄历智慧。',
          theme: widget.theme,
        ));
      }
    }

    // 彭祖百忌
    if (widget.settings.showDailyInfo && dailyInfo?.pengzuTaboo != null) {
      tiles.add(InfoTile(
        type: InfoTileType.pengzu,
        content: dailyInfo!.pengzuTaboo!,
        explanation: '彭祖百忌是传说中的长寿仙人彭祖总结的每日禁忌经验。此口诀提示今日应避免的具体行为，以趋吉避凶。',
        theme: widget.theme,
      ));
    }

    // 胎神方位
    if (widget.settings.showDailyInfo && dailyInfo?.fetusGodDirection != null) {
      tiles.add(InfoTile(
        type: InfoTileType.fetusGod,
        content: dailyInfo!.fetusGodDirection!,
        explanation: '胎神是守护胎儿的神灵，每日所在方位不同。孕妇及家人应避免在胎神方位动土、搬动物品或进行装修，以免惊扰胎神。',
        theme: widget.theme,
      ));
    }

    // 节日
    if (widget.settings.showFestivals && widget.date.festivals.isNotEmpty) {
      final festivalNames = widget.date.festivals
          .where((f) => f.type != FestivalType.buddhist)
          .map((f) => f.name)
          .toList();
      
      if (festivalNames.isNotEmpty) {
        tiles.add(InfoTile(
          type: InfoTileType.festival,
          content: festivalNames.first,
          additionalContent: festivalNames.length > 1 ? festivalNames.skip(1).toList() : null,
          explanation: '${festivalNames.first}是中华民族传统节日，承载着丰富的历史文化内涵和民俗传统。',
          theme: widget.theme,
        ));
      }
    }

    return tiles;
  }

  /// 藏历磁贴
  List<Widget> _buildTibetanTiles(BuildContext context, double scale) {
    final tiles = <Widget>[];
    final tibetanDate = widget.date.tibetanDate;

    if (tibetanDate == null) return tiles;

    // 藏历月日信息（双语文）
    final tibetanInfo = tibetanDate.monthNameTibetan != null || tibetanDate.dayNameTibetan != null
        ? '${tibetanDate.monthNameTibetan ?? ''}${tibetanDate.dayNameTibetan ?? ''}'
        : '';
    
    tiles.add(InfoTile(
      type: InfoTileType.tibetanInfo,
      content: '${tibetanDate.monthNameChinese ?? ''}${tibetanDate.dayNameChinese ?? ''}',
      explanation: tibetanInfo.isNotEmpty
          ? '藏文：$tibetanInfo\n藏历是藏族传统历法，融合了印度时轮历和汉历元素。${tibetanDate.yearElement ?? ''}。'
          : '藏历是藏族传统历法，融合了印度时轮历和汉历元素。${tibetanDate.yearElement ?? ''}',
      theme: widget.theme,
      compact: true,
    ));

    // 缺日/重日标记
    if (tibetanDate.isMissingDay || tibetanDate.isDoubleday) {
      final marks = <String>[];
      if (tibetanDate.isMissingDay) marks.add('缺日');
      if (tibetanDate.isDoubleday) marks.add('重日');
      
      tiles.add(InfoTile(
        type: InfoTileType.dateMark,
        content: marks.join(' · '),
        explanation: '藏历特有的日期调整机制。「缺日」表示此日被跳过、不在日历中显示；「重日」表示此日出现两次。这是藏历为保持与月相一致而采用的调整方式。',
        theme: widget.theme,
      ));
    }

    // 殊胜日
    if (_isSpecialDay(tibetanDate)) {
      final specialDayName = _getSpecialDayName(tibetanDate.day);
      final specialDayDesc = _getSpecialDayDescription(tibetanDate.day);
      
      if (specialDayName != null) {
        tiles.add(InfoTile(
          type: InfoTileType.specialDay,
          content: specialDayName,
          explanation: specialDayDesc ?? '藏传佛教殊胜日，修法功德倍增。',
          theme: widget.theme,
        ));
      }
    }

    // 佛教节日
    if (widget.settings.showFestivals && widget.date.festivals.isNotEmpty) {
      final buddhistFestivals = widget.date.festivals
          .where((f) => f.type == FestivalType.buddhist)
          .toList();
      
      if (buddhistFestivals.isNotEmpty) {
        tiles.add(InfoTile(
          type: InfoTileType.festival,
          content: buddhistFestivals.first.name,
          additionalContent: buddhistFestivals.length > 1 
              ? buddhistFestivals.skip(1).map((f) => f.name).toList() 
              : null,
          explanation: '佛教节日是纪念佛陀及诸菩萨的重要日子。',
          theme: widget.theme,
        ));
      }
    }

    return tiles;
  }

  /// 空状态
  Widget _buildEmptyState(BuildContext context, CalendarType type, double scale) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.responsiveSpacing(32)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 48 * scale,
              color: widget.theme.textHint,
            ),
            SizedBox(height: 16 * scale),
            Text(
              '暂无${_getCalendarName(type)}数据',
              style: TextStyle(
                fontSize: context.responsiveFontSize(14),
                color: widget.theme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 计算内容高度
  double _calculateContentHeight(BuildContext context, double scale) {
    // 根据磁贴数量动态计算高度
    int tileCount = 0;
    
    for (final type in _calendarTypes) {
      final tiles = _buildTilesForCalendar(type, scale);
      tileCount = tileCount > tiles.length ? tileCount : tiles.length;
    }
    
    // 基础高度 + 每个磁贴的高度
    final baseHeight = 80.0; // 标题 + padding
    final tileHeight = 100.0; // 每个磁贴大约高度
    final spacing = 12.0;
    
    final totalHeight = baseHeight + (tileCount * (tileHeight + spacing)) * scale;
    
    // 限制最大高度
    return totalHeight.clamp(200.0, 600.0);
  }

  bool _isSpecialDay(TibetanDate? tibetanDate) {
    if (tibetanDate == null) return false;
    return tibetanDate.day == 1 ||
           tibetanDate.day == 8 ||
           tibetanDate.day == 10 ||
           tibetanDate.day == 15 ||
           tibetanDate.day == 18 ||
           tibetanDate.day == 25 ||
           tibetanDate.day == 30;
  }

  String? _getSpecialDayName(int day) {
    switch (day) {
      case 1: return '吉祥日';
      case 8: return '药师佛节日';
      case 10: return '莲师荟供日';
      case 15: return '佛陀节日';
      case 18: return '观音菩萨节日';
      case 25: return '空行母荟供日';
      case 30: return '释迦牟尼佛节日';
      default: return null;
    }
  }

  String? _getSpecialDayDescription(int day) {
    switch (day) {
      case 1: return '初一为吉祥日，宜祈福修法';
      case 8: return '药师佛节日，药师法门修行殊胜日';
      case 10: return '莲花生大士荟供日，修持莲师法门功德倍增';
      case 15: return '满月日，佛陀节日，功德增长十万倍';
      case 18: return '观音菩萨节日，慈悲法门修行殊胜';
      case 25: return '空行母荟供日，女性本尊修行殊胜';
      case 30: return '新月日，释迦牟尼佛节日，功德增长百万倍';
      default: return null;
    }
  }

  String _getCalendarIcon(CalendarType type) {
    switch (type) {
      case CalendarType.solar: return '📅';
      case CalendarType.lunar: return '🌸';
      case CalendarType.tibetan: return '🏔️';
      case CalendarType.islamic: return '🌙';
      case CalendarType.dai: return '🌴';
      case CalendarType.yi: return '🔥';
    }
  }

  String _getCalendarName(CalendarType type) {
    switch (type) {
      case CalendarType.solar: return '公历';
      case CalendarType.lunar: return '农历';
      case CalendarType.tibetan: return '藏历';
      case CalendarType.islamic: return '伊斯兰历';
      case CalendarType.dai: return '傣历';
      case CalendarType.yi: return '彝历';
    }
  }

  /// 生成冲煞的详细释义
  String _getChongShaExplanation(String chongSha) {
    // 解析冲煞内容，如 "冲马煞南"
    String explanation = '冲煞是传统择日学的重要参考。';

    // 解析冲的生肖
    final chongMatch = RegExp(r'冲(\w)').firstMatch(chongSha);
    if (chongMatch != null) {
      final animal = chongMatch.group(1);
      explanation += '「冲$animal」表示今日与属$animal的人相冲，属$animal者今日宜谨慎行事。';
    }

    // 解析煞的方位
    final shaMatch = RegExp(r'煞(\w)').firstMatch(chongSha);
    if (shaMatch != null) {
      final direction = shaMatch.group(1);
      final fullDirection = _getFullDirection(direction ?? '');
      explanation += '「煞$direction」表示今日$fullDirection方位有凶神，不宜向此方位出行或动土。';
    }

    return explanation;
  }

  /// 获取完整方位名称
  String _getFullDirection(String direction) {
    switch (direction) {
      case '东': return '东方';
      case '南': return '南方';
      case '西': return '西方';
      case '北': return '北方';
      default: return direction;
    }
  }

  /// 从纳音五行中提取五行元素
  String _extractFiveElement(String fiveElements) {
    if (fiveElements.contains('金')) return '金';
    if (fiveElements.contains('木')) return '木';
    if (fiveElements.contains('水')) return '水';
    if (fiveElements.contains('火')) return '火';
    if (fiveElements.contains('土')) return '土';
    return fiveElements;
  }
}
