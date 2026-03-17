import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/calendar_theme.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/providers/calendar_settings_provider.dart';
import '../../models/calendar_models.dart';

/// 日历网格卡片 - 主卡片
///
/// 职责：
/// - 展示传统日历网格（核心功能）
/// - 展示年/月级别的历法信息（纪年、生肖）
/// - 这些信息在日历网格区域直接体现
class CalendarGridCard extends StatelessWidget {
  final DateTime currentMonth;
  final List<CalendarDate> monthDates;
  final DateTime? selectedDate;
  final CalendarSettingsProvider settings;
  final CalendarTheme theme;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final Function(DateTime) onDateSelected;
  final String Function(CalendarDate) getDateCellText;
  final bool Function(DateTime) isToday;
  final bool Function(DateTime) isSelected;
  final bool Function(DateTime) isCurrentMonth;

  const CalendarGridCard({
    super.key,
    required this.currentMonth,
    required this.monthDates,
    required this.selectedDate,
    required this.settings,
    required this.theme,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onDateSelected,
    required this.getDateCellText,
    required this.isToday,
    required this.isSelected,
    required this.isCurrentMonth,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.scale;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: context.responsiveSpacing(16)),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20 * scale),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.08),
            blurRadius: 24 * scale,
            offset: Offset(0, 8 * scale),
          ),
        ],
      ),
      child: Column(
        children: [
          // === 年份信息栏 ===
          _buildYearInfoBar(context, scale),

          // === 月份导航 ===
          _buildMonthNavigation(context, scale),

          // === 星期头部 ===
          _buildWeekdayHeader(context, scale),

          // === 日历网格 ===
          _buildCalendarGrid(context, scale),
        ],
      ),
    );
  }

  /// 年份信息栏 - 展示年级别的历法信息
  Widget _buildYearInfoBar(BuildContext context, double scale) {
    // 获取当前选中日期或今天的历法信息
    final displayDate = selectedDate ?? DateTime.now();

    // 找到对应的 CalendarDate
    CalendarDate? calendarDate;
    try {
      calendarDate = monthDates.firstWhere(
        (d) => d.solarDate.year == displayDate.year &&
               d.solarDate.month == displayDate.month &&
               d.solarDate.day == displayDate.day,
      );
    } catch (_) {
      // 如果找不到，使用第一个日期的年份信息
      if (monthDates.isNotEmpty) {
        calendarDate = monthDates.first;
      }
    }

    final lunarDate = calendarDate?.lunarDate;
    final tibetanDate = calendarDate?.tibetanDate;

    return Container(
      padding: EdgeInsets.all(context.responsiveSpacing(16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor.withOpacity(0.08),
            theme.secondaryColor.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20 * scale)),
      ),
      child: Row(
        children: [
          // 生肖图标
          if (lunarDate?.zodiac != null)
            Container(
              width: 44 * scale,
              height: 44 * scale,
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12 * scale),
              ),
              child: Center(
                child: Text(
                  _getZodiacEmoji(lunarDate!.zodiac),
                  style: TextStyle(fontSize: 22 * scale),
                ),
              ),
            ),
          SizedBox(width: 12 * scale),

          // 年份信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 公历年份
                Text(
                  '${currentMonth.year}年',
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(18),
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                ),
                SizedBox(height: 4 * scale),

                // 历法年份信息
                Wrap(
                  spacing: 8 * scale,
                  runSpacing: 4 * scale,
                  children: [
                    // 农历年份（干支 + 生肖）
                    if (settings.showLunarCalendar && lunarDate != null)
                      _buildYearChip(
                        context,
                        '${lunarDate.ganZhi ?? ''} ${lunarDate.zodiac ?? ''}年',
                        theme.festival,
                        scale,
                      ),

                    // 藏历年份
                    if (settings.showTibetanCalendar && tibetanDate != null)
                      _buildYearChip(
                        context,
                        tibetanDate.yearElement ?? '',
                        theme.specialDay,
                        scale,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearChip(BuildContext context, String text, Color color, double scale) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10 * scale,
        vertical: 4 * scale,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8 * scale),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: context.responsiveFontSize(12),
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  /// 月份导航
  Widget _buildMonthNavigation(BuildContext context, double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveSpacing(16),
        vertical: context.responsiveSpacing(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavButton(
            context,
            Icons.chevron_left_rounded,
            onPreviousMonth,
            theme,
            scale,
          ),
          Text(
            '${currentMonth.month}月',
            style: TextStyle(
              fontSize: context.responsiveFontSize(20),
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          _buildNavButton(
            context,
            Icons.chevron_right_rounded,
            onNextMonth,
            theme,
            scale,
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(
    BuildContext context,
    IconData icon,
    VoidCallback onPressed,
    CalendarTheme theme,
    double scale,
  ) {
    return Material(
      color: theme.surfaceColor,
      borderRadius: BorderRadius.circular(12 * scale),
      child: InkWell(
        borderRadius: BorderRadius.circular(12 * scale),
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        splashColor: theme.primaryColor.withOpacity(0.2),
        highlightColor: theme.primaryColor.withOpacity(0.1),
        child: Container(
          padding: EdgeInsets.all(10 * scale),
          child: Icon(icon, color: theme.primaryColor, size: 24 * scale),
        ),
      ),
    );
  }

  /// 星期头部
  Widget _buildWeekdayHeader(BuildContext context, double scale) {
    const weekdays = ['日', '一', '二', '三', '四', '五', '六'];

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: context.responsiveSpacing(12),
        horizontal: context.responsiveSpacing(8),
      ),
      child: Row(
        children: weekdays.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          final isWeekend = index == 0 || index == 6;

          return Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isWeekend
                      ? theme.festival.withOpacity(0.7)
                      : theme.textSecondary,
                  fontSize: context.responsiveFontSize(13),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 日历网格
  Widget _buildCalendarGrid(BuildContext context, double scale) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.responsiveSpacing(12),
        0,
        context.responsiveSpacing(12),
        context.responsiveSpacing(16),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1,
          mainAxisSpacing: 6 * scale,
          crossAxisSpacing: 6 * scale,
        ),
        itemCount: monthDates.length,
        itemBuilder: (context, index) {
          return _buildDateCell(context, monthDates[index], scale);
        },
      ),
    );
  }

  /// 日期单元格
  Widget _buildDateCell(BuildContext context, CalendarDate calendarDate, double scale) {
    final date = calendarDate.solarDate;
    final isTodayDate = isToday(date);
    final isSelectedDate = isSelected(date);
    final isCurrentMonthDate = isCurrentMonth(date);
    final hasFestival = calendarDate.festivals.isNotEmpty && settings.showFestivals;
    final isWeekend = date.weekday == 7 || date.weekday == 6;

    final dateText = getDateCellText(calendarDate);

    // 检查殊胜日（仅藏历）
    final tibetanDate = calendarDate.tibetanDate;
    final isSpecialDay = settings.primaryCalendar == CalendarType.tibetan &&
        tibetanDate != null &&
        (tibetanDate.day == 1 || tibetanDate.day == 8 ||
         tibetanDate.day == 10 || tibetanDate.day == 15 ||
         tibetanDate.day == 25 || tibetanDate.day == 30);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onDateSelected(date);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..scale(isSelectedDate ? 1.05 : 1.0),
        decoration: BoxDecoration(
          gradient: isSelectedDate
              ? theme.primaryGradient
              : isTodayDate
                  ? LinearGradient(
                      colors: [
                        theme.primaryColor.withOpacity(0.15),
                        theme.secondaryColor.withOpacity(0.1),
                      ],
                    )
                  : null,
          borderRadius: BorderRadius.circular(14 * scale),
          border: isTodayDate && !isSelectedDate
              ? Border.all(color: theme.primaryColor, width: 2)
              : null,
          boxShadow: isSelectedDate
              ? [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.4),
                    blurRadius: 12 * scale,
                    offset: Offset(0, 4 * scale),
                  ),
                ]
              : isTodayDate
                  ? [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.1),
                        blurRadius: 6 * scale,
                        offset: Offset(0, 2 * scale),
                      ),
                    ]
                  : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 公历日期
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(15),
                      fontWeight: isTodayDate || isSelectedDate
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelectedDate
                          ? Colors.white
                          : isCurrentMonthDate
                              ? isWeekend
                                  ? theme.festival.withOpacity(0.8)
                                  : theme.textPrimary
                              : theme.textHint,
                    ),
                  ),
                  // 历法日期
                  if (dateText.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 2 * scale),
                      child: Text(
                        dateText,
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(9),
                          color: isSelectedDate
                              ? Colors.white.withOpacity(0.8)
                              : isSpecialDay
                                  ? theme.specialDay
                                  : hasFestival
                                      ? theme.festival
                                      : theme.textHint,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            // 节日/殊胜日标记
            if (hasFestival || isSpecialDay)
              Positioned(
                top: 4 * scale,
                right: 4 * scale,
                child: Container(
                  width: 5 * scale,
                  height: 5 * scale,
                  decoration: BoxDecoration(
                    color: isSelectedDate
                        ? Colors.white
                        : isSpecialDay
                            ? theme.specialDay
                            : theme.festival,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isSpecialDay
                            ? theme.specialDay
                            : theme.festival).withOpacity(0.4),
                        blurRadius: 3 * scale,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getZodiacEmoji(String? zodiac) {
    switch (zodiac) {
      case '鼠': return '🐭';
      case '牛': return '🐮';
      case '虎': return '🐯';
      case '兔': return '🐰';
      case '龙': return '🐲';
      case '蛇': return '🐍';
      case '马': return '🐴';
      case '羊': return '🐑';
      case '猴': return '🐵';
      case '鸡': return '🐔';
      case '狗': return '🐶';
      case '猪': return '🐷';
      default: return '📅';
    }
  }
}
