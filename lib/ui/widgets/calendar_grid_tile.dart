import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/calendar_models.dart';
import '../../core/utils/responsive_helper.dart';
import '../viewmodels/calendar_view_model.dart';
import 'metro_tile.dart';

/// 日历视图模式
enum CalendarViewMode {
  month,  // 月视图
  week,   // 周视图
  day,    // 日视图
}

/// 日历视图模式扩展
extension CalendarViewModeExtension on CalendarViewMode {
  String get displayName {
    switch (this) {
      case CalendarViewMode.month:
        return '月';
      case CalendarViewMode.week:
        return '周';
      case CalendarViewMode.day:
        return '日';
    }
  }

  IconData get icon {
    switch (this) {
      case CalendarViewMode.month:
        return Icons.calendar_view_month;
      case CalendarViewMode.week:
        return Icons.view_week;
      case CalendarViewMode.day:
        return Icons.today;
    }
  }
}

/// 日历网格磁贴（支持月/周/日视图切换）
class CalendarGridTile extends StatefulWidget {
  final CalendarViewModel viewModel;
  final CalendarViewMode initialMode;
  final VoidCallback? onDateSelected;
  final void Function(CalendarViewMode)? onViewModeChanged;

  const CalendarGridTile({
    super.key,
    required this.viewModel,
    this.initialMode = CalendarViewMode.month,
    this.onDateSelected,
    this.onViewModeChanged,
  });

  @override
  State<CalendarGridTile> createState() => _CalendarGridTileState();
}

class _CalendarGridTileState extends State<CalendarGridTile>
    with SingleTickerProviderStateMixin {
  late CalendarViewMode _viewMode;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _viewMode = widget.initialMode;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setViewMode(CalendarViewMode mode) {
    if (_viewMode == mode) return;

    HapticFeedback.lightImpact();
    _animationController.reverse().then((_) {
      setState(() {
        _viewMode = mode;
      });
      _animationController.forward();
      widget.onViewModeChanged?.call(mode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MetroColors.calendar,
        borderRadius: BorderRadius.circular(4),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildCalendarContent(context),
            ),
          ),
          _buildViewModeSwitcher(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final vm = widget.viewModel;
    final isMobile = context.isMobile;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 12,
        vertical: isMobile ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 月份导航
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white70, size: 20),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  vm.previousMonth();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              Text(
                '${vm.currentMonth.year}年${vm.currentMonth.month}月',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white70, size: 20),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  vm.nextMonth();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),

          // 今天按钮
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              vm.goToToday();
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
            ),
            child: Text(
              '今天',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: isMobile ? 11 : 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarContent(BuildContext context) {
    switch (_viewMode) {
      case CalendarViewMode.month:
        return _buildMonthView(context);
      case CalendarViewMode.week:
        return _buildWeekView(context);
      case CalendarViewMode.day:
        return _buildDayView(context);
    }
  }

  /// 月视图
  Widget _buildMonthView(BuildContext context) {
    final vm = widget.viewModel;
    final dates = vm.monthDates;
    final now = DateTime.now();
    final isMobile = context.isMobile;

    // 星期标题
    final weekdays = ['一', '二', '三', '四', '五', '六', '日'];

    return Padding(
      padding: EdgeInsets.all(isMobile ? 4 : 8),
      child: Column(
        children: [
          // 星期标题行
          _buildWeekdayHeader(weekdays, isMobile),

          // 日期网格
          Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
              ),
              itemCount: dates.length > 35 ? 42 : 35,
              itemBuilder: (context, index) {
                if (index >= dates.length) {
                  return const SizedBox();
                }

                final date = dates[index];
                final isToday = _isSameDay(date.solarDate, now);
                final isSelected = _isSameDay(date.solarDate, vm.selectedDate);
                final isCurrentMonth = date.solarDate.month == vm.currentMonth.month;

                return _buildDateCell(
                  context,
                  date,
                  isToday,
                  isSelected,
                  isCurrentMonth,
                  isMobile,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader(List<String> weekdays, bool isMobile) {
    return Row(
      children: weekdays.map((d) {
        final isWeekend = d == '六' || d == '日';
        return Expanded(
          child: Center(
            child: Text(
              d,
              style: TextStyle(
                color: isWeekend
                    ? Colors.white.withOpacity(0.4)
                    : Colors.white.withOpacity(0.6),
                fontSize: isMobile ? 10 : 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateCell(
    BuildContext context,
    CalendarDate date,
    bool isToday,
    bool isSelected,
    bool isCurrentMonth,
    bool isMobile,
  ) {
    final hasFestival = date.festivals.isNotEmpty;
    final hasSolarTerm = date.dailyInfo?.note != null;
    final lunarDay = date.lunarDate?.dayName ?? '';

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.viewModel.selectDate(date.solarDate);
        widget.onDateSelected?.call();
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.3)
              : isToday
                  ? Colors.white.withOpacity(0.15)
                  : null,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(
          children: [
            // 日期数字
            Center(
              child: Text(
                '${date.solarDate.day}',
                style: TextStyle(
                  color: isCurrentMonth
                      ? Colors.white
                      : Colors.white.withOpacity(0.3),
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),

            // 农历日期（初一显示月份）
            if (lunarDay.isNotEmpty)
              Positioned(
                bottom: 1,
                left: 0,
                right: 0,
                child: Text(
                  date.lunarDate!.day == 1
                      ? (date.lunarDate!.monthName ?? '初一')
                      : lunarDay,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: hasFestival || hasSolarTerm
                        ? Colors.orange.withOpacity(0.9)
                        : Colors.white.withOpacity(0.5),
                    fontSize: isMobile ? 7 : 8,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // 节日/节气标记点
            if (hasFestival || hasSolarTerm)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: isMobile ? 3 : 4,
                  height: isMobile ? 3 : 4,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 周视图
  Widget _buildWeekView(BuildContext context) {
    final vm = widget.viewModel;
    final selectedDate = vm.selectedDate;
    final now = DateTime.now();
    final isMobile = context.isMobile;

    // 计算当前周的日期
    final weekDates = <CalendarDate>[];
    final startOfWeek = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));

    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final calendarDate = vm.pluginManager.convertWithAllPlugins(date);
      weekDates.add(calendarDate);
    }

    final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

    return Padding(
      padding: EdgeInsets.all(isMobile ? 6 : 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final date = weekDates[index];
          final isToday = _isSameDay(date.solarDate, now);
          final isSelected = _isSameDay(date.solarDate, selectedDate);

          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                vm.selectDate(date.solarDate);
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: isMobile ? 1 : 2),
                padding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.3)
                      : isToday
                          ? Colors.white.withOpacity(0.15)
                          : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      weekdays[index],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: isMobile ? 9 : 10,
                      ),
                    ),
                    SizedBox(height: isMobile ? 4 : 6),
                    Text(
                      '${date.solarDate.day}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 18 : 22,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: isMobile ? 2 : 4),
                    Text(
                      date.lunarDate?.dayName ?? '',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: isMobile ? 8 : 9,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// 日视图
  Widget _buildDayView(BuildContext context) {
    final vm = widget.viewModel;
    final selectedDate = vm.selectedCalendarDate;
    final now = DateTime.now();
    final isMobile = context.isMobile;

    if (selectedDate == null) {
      return const Center(
        child: Text(
          '请选择日期',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    final isToday = _isSameDay(selectedDate.solarDate, now);
    final weekday = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final weekdayName = weekday[selectedDate.solarDate.weekday - 1];

    return Padding(
      padding: EdgeInsets.all(isMobile ? 8 : 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 星期
          Text(
            weekdayName,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: isMobile ? 12 : 14,
            ),
          ),
          SizedBox(height: isMobile ? 6 : 8),

          // 日期大数字
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${selectedDate.solarDate.day}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 48 : 64,
                  fontWeight: FontWeight.w300,
                ),
              ),
              SizedBox(width: isMobile ? 6 : 8),
              Text(
                '${selectedDate.solarDate.month}月',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: isMobile ? 16 : 20,
                ),
              ),
            ],
          ),

          // 今天标记
          if (isToday)
            Container(
              margin: EdgeInsets.only(top: isMobile ? 4 : 6),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 8 : 12,
                vertical: isMobile ? 2 : 4,
              ),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '今天',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 10 : 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          SizedBox(height: isMobile ? 8 : 12),

          // 农历信息
          if (selectedDate.lunarDate != null)
            Text(
              '农历 ${selectedDate.lunarDate!.monthName ?? '${selectedDate.lunarDate!.month}月'}${selectedDate.lunarDate!.dayName ?? '${selectedDate.lunarDate!.day}日'}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: isMobile ? 11 : 13,
              ),
            ),

          // 节气/节日
          if (selectedDate.dailyInfo?.note != null)
            Padding(
              padding: EdgeInsets.only(top: isMobile ? 4 : 6),
              child: Text(
                selectedDate.dailyInfo!.note!,
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: isMobile ? 11 : 13,
                ),
              ),
            ),

          if (selectedDate.festivals.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: isMobile ? 4 : 6),
              child: Text(
                selectedDate.festivals.map((f) => f.name).join(' · '),
                style: TextStyle(
                  color: Colors.orange.withOpacity(0.8),
                  fontSize: isMobile ? 10 : 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildViewModeSwitcher(BuildContext context) {
    final isMobile = context.isMobile;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 6 : 8,
        vertical: isMobile ? 4 : 6,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: CalendarViewMode.values.map((mode) {
          final isSelected = _viewMode == mode;

          return GestureDetector(
            onTap: () => _setViewMode(mode),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: isMobile ? 2 : 4),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 8 : 12,
                vertical: isMobile ? 4 : 6,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.25)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    mode.icon,
                    color: isSelected ? Colors.white : Colors.white70,
                    size: isMobile ? 12 : 14,
                  ),
                  SizedBox(width: isMobile ? 2 : 4),
                  Text(
                    mode.displayName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: isMobile ? 10 : 12,
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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
