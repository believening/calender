import 'package:flutter/material.dart';
import '../../core/theme/calendar_theme.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/providers/calendar_settings_provider.dart';
import '../../models/calendar_models.dart';

/// 选中日期详情卡片 - 支持多历法滑动切换
///
/// 设计原则：
/// - 每种历法独立渲染自己的详情卡片
/// - 多历法时，滑动切换查看不同历法信息
/// - 单历法时，直接显示
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

  // 历法类型列表
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
    
    // 根据设置添加历法（不包含公历）
    if (widget.settings.showLunarCalendar) {
      _calendarTypes.add(CalendarType.lunar);
    }
    if (widget.settings.showTibetanCalendar) {
      _calendarTypes.add(CalendarType.tibetan);
    }

    // 确保当前页在范围内
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

    // 没有启用的历法：不显示
    if (_calendarTypes.isEmpty) {
      return const SizedBox.shrink();
    }

    // 单历法：直接显示
    if (_calendarTypes.length == 1) {
      return _buildSingleCalendarView(context, _calendarTypes.first, scale);
    }

    // 多历法：滑动切换
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
          // 历法切换指示器
          _buildCalendarTabs(context, scale),

          // 历法详情内容（滑动切换）- 使用 Expanded 填充剩余空间
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemCount: _calendarTypes.length,
              itemBuilder: (context, index) {
                return SingleChildScrollView(
                  child: _buildCalendarContent(context, _calendarTypes[index], scale),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 单历法视图
  Widget _buildSingleCalendarView(BuildContext context, CalendarType type, double scale) {
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
      child: SingleChildScrollView(
        child: _buildCalendarContent(context, type, scale),
      ),
    );
  }

  /// 历法切换标签
  Widget _buildCalendarTabs(BuildContext context, double scale) {
    return Container(
      padding: EdgeInsets.all(context.responsiveSpacing(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _calendarTypes.asMap().entries.map((entry) {
          final index = entry.key;
          final type = entry.value;
          final isSelected = index == _currentPage;

          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.symmetric(horizontal: 6 * scale),
              padding: EdgeInsets.symmetric(
                horizontal: 16 * scale,
                vertical: 8 * scale,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? widget.theme.primaryColor
                    : widget.theme.surfaceColor,
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(
                  color: isSelected
                      ? widget.theme.primaryColor
                      : widget.theme.textHint.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getCalendarIcon(type),
                    style: TextStyle(fontSize: 14 * scale),
                  ),
                  SizedBox(width: 6 * scale),
                  Text(
                    _getCalendarName(type),
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(13),
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : widget.theme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 历法内容
  Widget _buildCalendarContent(BuildContext context, CalendarType type, double scale) {
    switch (type) {
      case CalendarType.lunar:
        return _buildLunarContent(context, scale);
      case CalendarType.tibetan:
        return _buildTibetanContent(context, scale);
      case CalendarType.solar:
      case CalendarType.islamic:
      case CalendarType.dai:
      case CalendarType.yi:
        return _buildEmptyState(context, '暂未支持该历法', scale);
    }
  }

  /// 农历内容
  Widget _buildLunarContent(BuildContext context, double scale) {
    final solarDate = widget.date.solarDate;
    final lunarDate = widget.date.lunarDate;
    final dailyInfo = widget.date.dailyInfo;
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];

    if (lunarDate == null) {
      return _buildEmptyState(context, '暂无农历数据', scale);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(context.responsiveSpacing(16)),
      child: Column(
        children: [
          // 日期头部
          _buildDateHeader(context, solarDate, scale, weekdays),

          // 农历信息
          _buildLunarInfoSection(context, lunarDate, scale),

          // 五行纳音（新增）
          if (dailyInfo?.fiveElements != null)
            _buildFiveElementsSection(context, dailyInfo!.fiveElements!, scale),

          // 冲煞（新增）
          if (dailyInfo?.chongSha != null)
            _buildChongShaSection(context, dailyInfo!.chongSha!, scale),

          // 节气（农历独有）
          if (dailyInfo?.note != null)
            _buildSolarTermSection(context, dailyInfo!.note!, scale),

          // 节日
          if (widget.settings.showFestivals && widget.date.festivals.isNotEmpty)
            _buildFestivalsSection(context, scale),

          // 宜忌（农历独有）
          if (widget.settings.showDailyInfo && dailyInfo != null)
            _buildDailyInfoSection(context, dailyInfo, scale),

          // 彭祖百忌（新增）
          if (widget.settings.showDailyInfo && dailyInfo?.pengzuTaboo != null)
            _buildPengzuSection(context, dailyInfo!.pengzuTaboo!, scale),

          // 胎神方位（新增）
          if (widget.settings.showDailyInfo && dailyInfo?.fetusGodDirection != null)
            _buildFetusGodSection(context, dailyInfo!.fetusGodDirection!, scale),
        ],
      ),
    );
  }

  /// 藏历内容
  Widget _buildTibetanContent(BuildContext context, double scale) {
    final solarDate = widget.date.solarDate;
    final tibetanDate = widget.date.tibetanDate;
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];

    if (tibetanDate == null) {
      return _buildEmptyState(context, '暂无藏历数据', scale);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(context.responsiveSpacing(16)),
      child: Column(
        children: [
          // 日期头部
          _buildDateHeader(context, solarDate, scale, weekdays),

          // 藏历信息
          _buildTibetanInfoSection(context, tibetanDate, scale),

          // 殊胜日（藏历独有）
          if (_isSpecialDay(tibetanDate))
            _buildSpecialDaySection(context, tibetanDate, scale),

          // 节日
          if (widget.settings.showFestivals && widget.date.festivals.isNotEmpty)
            _buildFestivalsSection(context, scale),
        ],
      ),
    );
  }

  /// 空状态
  Widget _buildEmptyState(BuildContext context, String message, double scale) {
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
              message,
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

  /// 日期头部
  Widget _buildDateHeader(BuildContext context, DateTime solarDate, double scale, List<String> weekdays) {
    return Container(
      padding: EdgeInsets.all(context.responsiveSpacing(16)),
      decoration: BoxDecoration(
        color: widget.theme.primaryColor.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Row(
        children: [
          // 大日期数字
          Container(
            width: 56 * scale,
            height: 56 * scale,
            decoration: BoxDecoration(
              gradient: widget.theme.primaryGradient,
              borderRadius: BorderRadius.circular(16 * scale),
            ),
            child: Center(
              child: Text(
                '${solarDate.day}',
                style: TextStyle(
                  fontSize: context.responsiveFontSize(28),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 16 * scale),

          // 日期信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${solarDate.month}月',
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(20),
                    fontWeight: FontWeight.bold,
                    color: widget.theme.textPrimary,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  '星期${weekdays[solarDate.weekday - 1]}',
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(14),
                    color: widget.theme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 农历信息区域
  Widget _buildLunarInfoSection(BuildContext context, LunarDate lunarDate, double scale) {
    return Container(
      margin: EdgeInsets.only(top: context.responsiveSpacing(16)),
      padding: EdgeInsets.all(context.responsiveSpacing(16)),
      decoration: BoxDecoration(
        color: widget.theme.festival.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(color: widget.theme.festival.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          // 年份信息
          if (lunarDate.yearName != null || lunarDate.ganZhi != null)
            Padding(
              padding: EdgeInsets.only(bottom: 12 * scale),
              child: Row(
                children: [
                  Text(
                    '🗓️',
                    style: TextStyle(fontSize: 16 * scale),
                  ),
                  SizedBox(width: 8 * scale),
                  Text(
                    [lunarDate.ganZhi, lunarDate.yearName]
                        .where((s) => s != null)
                        .join(' · ') ?? '',
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(15),
                      fontWeight: FontWeight.bold,
                      color: widget.theme.festival,
                    ),
                  ),
                ],
              ),
            ),

          // 月日信息
          Row(
            children: [
              _buildLunarInfoChip(
                context,
                '🌸',
                lunarDate.monthName ?? '${lunarDate.month}月',
                scale,
              ),
              SizedBox(width: 12 * scale),
              _buildLunarInfoChip(
                context,
                '🌙',
                lunarDate.dayName ?? '${lunarDate.day}日',
                scale,
              ),
              if (lunarDate.isLeapMonth) ...[
                SizedBox(width: 8 * scale),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8 * scale,
                    vertical: 4 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(6 * scale),
                  ),
                  child: Text(
                    '闰月',
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(11),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLunarInfoChip(BuildContext context, String emoji, String text, double scale) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: TextStyle(fontSize: 14 * scale)),
        SizedBox(width: 6 * scale),
        Text(
          text,
          style: TextStyle(
            fontSize: context.responsiveFontSize(15),
            fontWeight: FontWeight.w500,
            color: widget.theme.textPrimary,
          ),
        ),
      ],
    );
  }

  /// 藏历信息区域
  Widget _buildTibetanInfoSection(BuildContext context, TibetanDate tibetanDate, double scale) {
    return Container(
      margin: EdgeInsets.only(top: context.responsiveSpacing(16)),
      padding: EdgeInsets.all(context.responsiveSpacing(16)),
      decoration: BoxDecoration(
        color: widget.theme.specialDay.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(color: widget.theme.specialDay.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 年份信息
          if (tibetanDate.yearElement != null)
            Padding(
              padding: EdgeInsets.only(bottom: 12 * scale),
              child: Row(
                children: [
                  Text(
                    '🏔️',
                    style: TextStyle(fontSize: 16 * scale),
                  ),
                  SizedBox(width: 8 * scale),
                  Text(
                    tibetanDate.yearElement!,
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(15),
                      fontWeight: FontWeight.bold,
                      color: widget.theme.specialDay,
                    ),
                  ),
                ],
              ),
            ),

          // 月日信息
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * scale,
                  vertical: 6 * scale,
                ),
                decoration: BoxDecoration(
                  color: widget.theme.cardColor,
                  borderRadius: BorderRadius.circular(10 * scale),
                ),
                child: Text(
                  '${tibetanDate.month}月${tibetanDate.day}日',
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(15),
                    fontWeight: FontWeight.w500,
                    color: widget.theme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 节气区域（农历独有）
  Widget _buildSolarTermSection(BuildContext context, String solarTerm, double scale) {
    return Container(
      margin: EdgeInsets.only(top: context.responsiveSpacing(16)),
      padding: EdgeInsets.all(context.responsiveSpacing(14)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981).withOpacity(0.1),
            const Color(0xFF059669).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8 * scale),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(8 * scale),
            ),
            child: Icon(
              Icons.wb_sunny,
              color: Colors.white,
              size: 18 * scale,
            ),
          ),
          SizedBox(width: 12 * scale),
          Text(
            solarTerm,
            style: TextStyle(
              fontSize: context.responsiveFontSize(16),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF059669),
            ),
          ),
          SizedBox(width: 8 * scale),
          Text(
            '节气',
            style: TextStyle(
              fontSize: context.responsiveFontSize(12),
              color: const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  /// 五行纳音区域（农历独有）
  Widget _buildFiveElementsSection(BuildContext context, String fiveElements, double scale) {
    return Container(
      margin: EdgeInsets.only(top: context.responsiveSpacing(16)),
      padding: EdgeInsets.all(context.responsiveSpacing(14)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B5CF6).withOpacity(0.1),
            const Color(0xFF7C3AED).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8 * scale),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6),
                  borderRadius: BorderRadius.circular(8 * scale),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 18 * scale,
                ),
              ),
              SizedBox(width: 12 * scale),
              Text(
                fiveElements,
                style: TextStyle(
                  fontSize: context.responsiveFontSize(15),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF7C3AED),
                ),
              ),
              SizedBox(width: 8 * scale),
              Text(
                '五行',
                style: TextStyle(
                  fontSize: context.responsiveFontSize(12),
                  color: const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),
          Text(
            '纳音五行：干支对应的五行属性，用于命理推算',
            style: TextStyle(
              fontSize: context.responsiveFontSize(11),
              color: const Color(0xFF7C3AED).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// 冲煞区域（农历独有）
  Widget _buildChongShaSection(BuildContext context, String chongSha, double scale) {
    return Container(
      margin: EdgeInsets.only(top: context.responsiveSpacing(16)),
      padding: EdgeInsets.all(context.responsiveSpacing(14)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFEF4444).withOpacity(0.1),
            const Color(0xFFDC2626).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8 * scale),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(8 * scale),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 18 * scale,
                ),
              ),
              SizedBox(width: 12 * scale),
              Text(
                chongSha,
                style: TextStyle(
                  fontSize: context.responsiveFontSize(15),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),
          Text(
            '冲：与当日地支相冲的生肖；煞：不宜的方位',
            style: TextStyle(
              fontSize: context.responsiveFontSize(11),
              color: const Color(0xFFDC2626).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// 彭祖百忌区域（农历独有）
  Widget _buildPengzuSection(BuildContext context, String pengzuTaboo, double scale) {
    return Container(
      margin: EdgeInsets.only(top: context.responsiveSpacing(16)),
      padding: EdgeInsets.all(context.responsiveSpacing(14)),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8 * scale),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(8 * scale),
                ),
                child: Icon(
                  Icons.menu_book,
                  color: Colors.white,
                  size: 18 * scale,
                ),
              ),
              SizedBox(width: 12 * scale),
              Text(
                '彭祖百忌',
                style: TextStyle(
                  fontSize: context.responsiveFontSize(14),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD97706),
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),
          Text(
            '彭祖传说活了八百岁，总结的每日宜忌经验',
            style: TextStyle(
              fontSize: context.responsiveFontSize(11),
              color: const Color(0xFFD97706).withOpacity(0.7),
            ),
          ),
          SizedBox(height: 10 * scale),
          Text(
            pengzuTaboo,
            style: TextStyle(
              fontSize: context.responsiveFontSize(13),
              color: const Color(0xFF92400E),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 胎神方位区域（农历独有）
  Widget _buildFetusGodSection(BuildContext context, String fetusGodDirection, double scale) {
    return Container(
      margin: EdgeInsets.only(top: context.responsiveSpacing(16)),
      padding: EdgeInsets.all(context.responsiveSpacing(14)),
      decoration: BoxDecoration(
        color: const Color(0xFFEC4899).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: const Color(0xFFEC4899).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8 * scale),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC4899),
                  borderRadius: BorderRadius.circular(8 * scale),
                ),
                child: Icon(
                  Icons.child_care,
                  color: Colors.white,
                  size: 18 * scale,
                ),
              ),
              SizedBox(width: 12 * scale),
              Text(
                '胎神',
                style: TextStyle(
                  fontSize: context.responsiveFontSize(14),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFDB2777),
                ),
              ),
              SizedBox(width: 8 * scale),
              Expanded(
                child: Text(
                  fetusGodDirection,
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(13),
                    color: const Color(0xFF9D174D),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),
          Text(
            '胎神所在方位，孕妇应避免在此方位动土或搬动',
            style: TextStyle(
              fontSize: context.responsiveFontSize(11),
              color: const Color(0xFFDB2777).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// 节日区域
  Widget _buildFestivalsSection(BuildContext context, double scale) {
    return Container(
      margin: EdgeInsets.only(top: context.responsiveSpacing(16)),
      child: Wrap(
        spacing: 8 * scale,
        runSpacing: 8 * scale,
        children: widget.date.festivals.map((festival) {
          final isBuddhist = festival.type == FestivalType.buddhist;
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: 14 * scale,
              vertical: 8 * scale,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isBuddhist
                    ? [const Color(0xFFFFB300), widget.theme.specialDay]
                    : [widget.theme.festival, const Color(0xFFDC2626)],
              ),
              borderRadius: BorderRadius.circular(12 * scale),
              boxShadow: [
                BoxShadow(
                  color: (isBuddhist ? widget.theme.specialDay : widget.theme.festival)
                      .withOpacity(0.3),
                  blurRadius: 6 * scale,
                  offset: Offset(0, 2 * scale),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (festival.nameTibetan != null) ...[
                  Text(
                    festival.nameTibetan!,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: context.responsiveFontSize(11),
                    ),
                  ),
                  SizedBox(width: 6 * scale),
                ],
                Text(
                  festival.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: context.responsiveFontSize(12),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 殊胜日区域（藏历独有）
  Widget _buildSpecialDaySection(BuildContext context, TibetanDate tibetanDate, double scale) {
    final specialDayName = _getSpecialDayName(tibetanDate.day);
    if (specialDayName == null) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(top: context.responsiveSpacing(16)),
      padding: EdgeInsets.all(context.responsiveSpacing(14)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.theme.specialDay.withOpacity(0.12),
            const Color(0xFFFFB300).withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: widget.theme.specialDay.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8 * scale),
            decoration: BoxDecoration(
              color: widget.theme.specialDay,
              borderRadius: BorderRadius.circular(8 * scale),
            ),
            child: Icon(
              Icons.star,
              color: Colors.white,
              size: 18 * scale,
            ),
          ),
          SizedBox(width: 12 * scale),
          Text(
            specialDayName,
            style: TextStyle(
              fontSize: context.responsiveFontSize(15),
              fontWeight: FontWeight.bold,
              color: widget.theme.specialDay,
            ),
          ),
          SizedBox(width: 8 * scale),
          Text(
            '殊胜日',
            style: TextStyle(
              fontSize: context.responsiveFontSize(12),
              color: const Color(0xFFFFB300),
            ),
          ),
        ],
      ),
    );
  }

  /// 宜忌区域（农历独有）
  Widget _buildDailyInfoSection(BuildContext context, DailyInfo info, double scale) {
    final hasYi = info.suitable.isNotEmpty;
    final hasJi = info.unsuitable.isNotEmpty;

    if (!hasYi && !hasJi) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(top: context.responsiveSpacing(16)),
      child: Column(
        children: [
          if (hasYi)
            _buildYiJiRow(
              context,
              '宜',
              info.suitable,
              const Color(0xFF10B981),
              scale,
            ),
          if (hasYi && hasJi) SizedBox(height: 10 * scale),
          if (hasJi)
            _buildYiJiRow(
              context,
              '忌',
              info.unsuitable,
              widget.theme.festival,
              scale,
            ),
        ],
      ),
    );
  }

  Widget _buildYiJiRow(
    BuildContext context,
    String label,
    List<String> items,
    Color color,
    double scale,
  ) {
    return Container(
      padding: EdgeInsets.all(context.responsiveSpacing(12)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10 * scale,
              vertical: 4 * scale,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6 * scale),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: context.responsiveFontSize(12),
              ),
            ),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Text(
              items.join(' · '),
              style: TextStyle(
                color: color.withOpacity(0.9),
                fontSize: context.responsiveFontSize(13),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 计算内容高度
  double _calculateContentHeight(BuildContext context, double scale) {
    // 基础高度：日期头部 + 内边距
    double height = 120 * scale;

    // 根据历法类型添加额外高度
    for (final type in _calendarTypes) {
      switch (type) {
        case CalendarType.lunar:
          height += 200 * scale; // 农历信息 + 节气 + 宜忌
          break;
        case CalendarType.tibetan:
          height += 150 * scale; // 藏历信息 + 殊胜日
          break;
        case CalendarType.solar:
        case CalendarType.islamic:
        case CalendarType.dai:
        case CalendarType.yi:
          height += 60 * scale; // 节日等
          break;
      }
    }

    // 节日高度
    if (widget.date.festivals.isNotEmpty) {
      height += 60 * scale;
    }

    // 最大高度限制
    return height.clamp(200.0, 400.0);
  }

  /// 检查是否是殊胜日
  bool _isSpecialDay(TibetanDate? tibetanDate) {
    if (tibetanDate == null) return false;
    return tibetanDate.day == 1 ||
           tibetanDate.day == 8 ||
           tibetanDate.day == 10 ||
           tibetanDate.day == 15 ||
           tibetanDate.day == 25 ||
           tibetanDate.day == 30;
  }

  /// 获取殊胜日名称
  String? _getSpecialDayName(int day) {
    switch (day) {
      case 1: return '吉祥日';
      case 8: return '药师佛节日';
      case 10: return '莲师荟供日';
      case 15: return '佛陀节日';
      case 25: return '空行母荟供日';
      case 30: return '释迦牟尼佛节日';
      default: return null;
    }
  }

  String _getCalendarIcon(CalendarType type) {
    switch (type) {
      case CalendarType.solar:
        return '📅';
      case CalendarType.lunar:
        return '🌸';
      case CalendarType.tibetan:
        return '🏔️';
      case CalendarType.islamic:
        return '🌙';
      case CalendarType.dai:
        return '🌴';
      case CalendarType.yi:
        return '🔥';
    }
  }

  String _getCalendarName(CalendarType type) {
    switch (type) {
      case CalendarType.solar:
        return '公历';
      case CalendarType.lunar:
        return '农历';
      case CalendarType.tibetan:
        return '藏历';
      case CalendarType.islamic:
        return '伊斯兰历';
      case CalendarType.dai:
        return '傣历';
      case CalendarType.yi:
        return '彝历';
    }
  }
}
