import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/calendar_theme.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/providers/calendar_settings_provider.dart';
import '../../models/calendar_models.dart';
import 'tiles/tile_size.dart';

/// 日历网格卡片 - 主卡片 (Modern UI)
///
/// 职责：
/// - 展示日历网格（支持月/周/日三种视图）
/// - 展示年/月级别的历法信息（纪年、生肖）
/// - 支持磁贴尺寸切换
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
  
  /// 磁贴尺寸
  final TileSize tileSize;
  
  /// 尺寸变化回调
  final Function(TileSize)? onTileSizeChanged;

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
    this.tileSize = TileSize.large,
    this.onTileSizeChanged,
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

          // === 月份导航 + 尺寸切换 ===
          _buildMonthNavigation(context, scale),

          // === 星期头部（非日视图显示）===
          if (!tileSize.isDayView) _buildWeekdayHeader(context, scale),

          // === 日历网格 ===
          _buildCalendarGrid(context, scale),
        ],
      ),
    );
  }

  /// 年份信息栏 - 展示年级别的历法信息
  Widget _buildYearInfoBar(BuildContext context, double scale) {
    final displayDate = selectedDate ?? DateTime.now();
    CalendarDate? calendarDate;
    
    try {
      calendarDate = monthDates.firstWhere(
        (d) => d.solarDate.year == displayDate.year &&
               d.solarDate.month == displayDate.month &&
               d.solarDate.day == displayDate.day,
      );
    } catch (_) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${currentMonth.year}年',
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(18),
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Wrap(
                  spacing: 8 * scale,
                  runSpacing: 4 * scale,
                  children: [
                    if (settings.showLunarCalendar && lunarDate != null)
                      _buildYearChip(
                        context,
                        '${lunarDate.ganZhi ?? ''} ${lunarDate.zodiac ?? ''}年',
                        theme.festival,
                        scale,
                      ),
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
      padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 4 * scale),
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

  /// 月份导航 + 尺寸切换控件
  Widget _buildMonthNavigation(BuildContext context, double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveSpacing(16),
        vertical: context.responsiveSpacing(12),
      ),
      child: Row(
        children: [
          // 左侧：上一月按钮
          _buildNavButton(context, Icons.chevron_left_rounded, onPreviousMonth, theme, scale),
          
          // 中间：月份标题
          Expanded(
            child: Center(
              child: Text(
                tileSize.isDayView 
                    ? '${selectedDate?.month ?? currentMonth.month}月'
                    : '${currentMonth.month}月',
                style: TextStyle(
                  fontSize: context.responsiveFontSize(20),
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimary,
                ),
              ),
            ),
          ),
          
          // 右侧：下一月按钮
          _buildNavButton(context, Icons.chevron_right_rounded, onNextMonth, theme, scale),
          
          SizedBox(width: 12 * scale),
          
          // 尺寸切换控件
          _buildTileSizeSwitcher(context, scale),
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

  /// 磁贴尺寸切换器
  Widget _buildTileSizeSwitcher(BuildContext context, double scale) {
    return Container(
      padding: EdgeInsets.all(4 * scale),
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: TileSize.values.map((size) {
          final isSelected = size == tileSize;
          return GestureDetector(
            onTap: () => onTileSizeChanged?.call(size),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 6 * scale),
              decoration: BoxDecoration(
                color: isSelected ? theme.primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(8 * scale),
              ),
              child: Text(
                size.displayName,
                style: TextStyle(
                  fontSize: context.responsiveFontSize(12),
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : theme.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
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

  /// 日历网格 - 根据尺寸显示不同视图
  Widget _buildCalendarGrid(BuildContext context, double scale) {
    final displayDates = _getFilteredDates();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey('grid_${tileSize.name}'),
        child: tileSize.isDayView
            ? _buildDayView(context, scale)
            : _buildMonthOrWeekGrid(context, displayDates, scale),
      ),
    );
  }

  /// 月/周视图网格
  Widget _buildMonthOrWeekGrid(BuildContext context, List<CalendarDate> displayDates, double scale) {
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
        itemCount: displayDates.length,
        itemBuilder: (context, index) {
          return _buildDateCell(context, displayDates[index], scale);
        },
      ),
    );
  }
  
  /// 获取过滤后的日期列表
  List<CalendarDate> _getFilteredDates() {
    if (tileSize.isMonthView) {
      return monthDates;
    }
    
    if (tileSize.isWeekView && selectedDate != null) {
      // 获取选中日期所在周的所有日期
      final selected = selectedDate!;
      final weekday = selected.weekday % 7; // 转换为周日=0
      final startOfWeek = selected.subtract(Duration(days: weekday));
      
      return monthDates.where((date) {
        final d = date.solarDate;
        for (var i = 0; i < 7; i++) {
          final weekDay = startOfWeek.add(Duration(days: i));
          if (d.year == weekDay.year && d.month == weekDay.month && d.day == weekDay.day) {
            return true;
          }
        }
        return false;
      }).toList();
    }
    
    if (tileSize.isDayView && selectedDate != null) {
      return monthDates.where((date) {
        final d = date.solarDate;
        final s = selectedDate!;
        return d.year == s.year && d.month == s.month && d.day == s.day;
      }).toList();
    }
    
    return monthDates;
  }
  
  /// 日视图 - 单独渲染选中日期
  Widget _buildDayView(BuildContext context, double scale) {
    final selected = selectedDate ?? DateTime.now();
    CalendarDate? selectedCalendarDate;
    
    try {
      selectedCalendarDate = monthDates.firstWhere(
        (d) => d.solarDate.year == selected.year &&
               d.solarDate.month == selected.month &&
               d.solarDate.day == selected.day,
      );
    } catch (_) {}
    
    final lunarDate = selectedCalendarDate?.lunarDate;
    final tibetanDate = selectedCalendarDate?.tibetanDate;
    
    return Padding(
      padding: EdgeInsets.all(context.responsiveSpacing(16)),
      child: Container(
        padding: EdgeInsets.all(context.responsiveSpacing(20)),
        decoration: BoxDecoration(
          gradient: theme.primaryGradient,
          borderRadius: BorderRadius.circular(20 * scale),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.3),
              blurRadius: 20 * scale,
              offset: Offset(0, 8 * scale),
            ),
          ],
        ),
        child: Column(
          children: [
            // 大日期数字
            Text(
              '${selected.day}',
              style: TextStyle(
                fontSize: 64 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1,
              ),
            ),
            SizedBox(height: 8 * scale),
            
            // 星期
            Text(
              '星期${_getWeekdayName(selected.weekday)}',
              style: TextStyle(
                fontSize: context.responsiveFontSize(18),
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12 * scale),
            
            // 历法信息
            Wrap(
              spacing: 12 * scale,
              runSpacing: 8 * scale,
              alignment: WrapAlignment.center,
              children: [
                if (lunarDate != null)
                  _buildDayViewChip(
                    '🌸 ${lunarDate.monthName ?? ''}${lunarDate.dayName ?? ''}',
                    scale,
                  ),
                if (tibetanDate != null)
                  _buildDayViewChip(
                    '🏔️ ${tibetanDate.monthNameChinese ?? ''}${tibetanDate.dayNameChinese ?? ''}',
                    scale,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDayViewChip(String text, double scale) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8 * scale),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14 * scale,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  String _getWeekdayName(int weekday) {
    const names = ['一', '二', '三', '四', '五', '六', '日'];
    return names[weekday - 1];
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
