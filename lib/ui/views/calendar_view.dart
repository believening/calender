import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/calendar_view_model.dart';
import '../../models/calendar_models.dart';
import '../../core/providers/calendar_settings_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/theme/calendar_theme.dart';

/// 日历主视图 - 现代化设计
/// 
/// 设计原则：
/// - 使用柔和的紫色系配色（避免过于鲜艳）
/// - 大圆角卡片设计
/// - 微妙的阴影和动画
/// - 清晰的信息层次
class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> with TickerProviderStateMixin {
  late AnimationController _animationController;
  double _dragOffset = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 处理水平拖动 - 切换月份
  void _handleHorizontalDragEnd(double velocity) {
    const threshold = 100.0;

    if (velocity.abs() > threshold || _dragOffset.abs() > 50) {
      HapticFeedback.lightImpact();
      if (_dragOffset > 0) {
        context.read<CalendarViewModel>().previousMonth();
      } else {
        context.read<CalendarViewModel>().nextMonth();
      }
    }

    setState(() {
      _dragOffset = 0;
      _isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarSettingsProvider>(
      builder: (context, settings, _) {
        final theme = CalendarTheme.fromType(settings.primaryCalendar);
        return ChangeNotifierProvider(
          create: (_) => CalendarViewModel(settings: settings)..selectDate(DateTime.now()),
          child: Scaffold(
            backgroundColor: theme.backgroundColor,
            body: Consumer<CalendarViewModel>(
              builder: (context, vm, _) {
                return GestureDetector(
                  onHorizontalDragStart: (_) => setState(() => _isDragging = true),
                  onHorizontalDragUpdate: (details) {
                    setState(() => _dragOffset += details.delta.dx);
                  },
                  onHorizontalDragEnd: (details) {
                    _handleHorizontalDragEnd(details.primaryVelocity ?? 0);
                  },
                  onDoubleTap: () {
                    HapticFeedback.mediumImpact();
                    vm.goToToday();
                  },
                  child: CustomScrollView(
                    slivers: [
                      _buildAppBar(context, vm, theme),
                      SliverToBoxAdapter(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          transform: Matrix4.translationValues(_dragOffset * 0.3, 0, 0),
                          child: FadeTransition(
                            opacity: _animationController,
                            child: Column(
                              children: [
                                _buildCalendarSection(context, vm, settings, theme),
                                _buildSelectedDateSection(context, vm, settings, theme),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            floatingActionButton: _buildTodayFab(theme),
          ),
        );
      },
    );
  }

  /// 极简 AppBar - 只保留设置按钮
  Widget _buildAppBar(BuildContext context, CalendarViewModel vm, CalendarTheme theme) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: const SizedBox.shrink(), // 移除返回按钮
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.settings_outlined, color: theme.primaryColor, size: 20),
          ),
          onPressed: () => _showSettingsSheet(context),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  /// 日历主体区域（响应式）
  Widget _buildCalendarSection(BuildContext context, CalendarViewModel vm, CalendarSettingsProvider settings) {
    final scale = context.scale;
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: context.responsiveSpacing(16),
        vertical: context.responsiveSpacing(8),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28 * scale),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.12),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMonthNavigation(context, vm, settings),
          _buildWeekdayHeader(context),
          _buildCalendarGrid(context, vm, settings),
        ],
      ),
    );
  }

  /// 月份导航 - 极简设计，只显示月份和导航按钮（响应式）
  Widget _buildMonthNavigation(BuildContext context, CalendarViewModel vm, CalendarSettingsProvider settings) {
    final scale = context.scale;
    return Padding(
      padding: context.responsivePadding(
        horizontal: 20,
        top: 20,
        bottom: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavButton(context, Icons.chevron_left_rounded, vm.previousMonth),
          Text(
            vm.monthTitle,
            style: TextStyle(
              fontSize: context.responsiveFontSize(20),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          _buildNavButton(context, Icons.chevron_right_rounded, vm.nextMonth),
        ],
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, IconData icon, VoidCallback onPressed) {
    final scale = context.scale;
    return Material(
      color: const Color(0xFFEDE9FE),
      borderRadius: BorderRadius.circular(14 * scale),
      child: InkWell(
        borderRadius: BorderRadius.circular(14 * scale),
        onTap: onPressed,
        splashColor: const Color(0xFF8B5CF6).withOpacity(0.2),
        highlightColor: const Color(0xFF8B5CF6).withOpacity(0.1),
        child: Container(
          padding: EdgeInsets.all(10 * scale),
          child: Icon(
            icon,
            color: const Color(0xFF7C3AED),
            size: 24 * scale,
          ),
        ),
      ),
    );
  }

  /// 星期头部（响应式）
  Widget _buildWeekdayHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: context.responsiveSpacing(12),
        horizontal: context.responsiveSpacing(8),
      ),
      child: Row(
        children: CalendarViewModel.weekdays.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          final isWeekend = index >= 5;
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isWeekend
                      ? const Color(0xFFEF5350).withOpacity(0.7)
                      : const Color(0xFF6B7280),
                  fontSize: context.responsiveFontSize(13),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 日历网格（响应式）
  Widget _buildCalendarGrid(BuildContext context, CalendarViewModel vm, CalendarSettingsProvider settings) {
    final scale = context.scale;
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
        itemCount: vm.monthDates.length,
        itemBuilder: (context, index) {
          return _buildDateCell(context, vm, vm.monthDates[index], settings);
        },
      ),
    );
  }

  /// 日期单元格（响应式）
  Widget _buildDateCell(
    BuildContext context,
    CalendarViewModel vm,
    CalendarDate calendarDate,
    CalendarSettingsProvider settings,
  ) {
    final scale = context.scale;
    final date = calendarDate.solarDate;
    final isToday = vm.isToday(date);
    final isSelected = vm.isSelected(date);
    final isCurrentMonth = vm.isCurrentMonth(date);
    final hasFestival = calendarDate.festivals.isNotEmpty && settings.showFestivals;
    final isWeekend = date.weekday == 6 || date.weekday == 7;

    // 根据主历法获取日期文本
    final dateText = vm.getDateCellText(calendarDate);

    // 检查殊胜日（仅藏历）
    final tibetanDate = calendarDate.tibetanDate;
    final isSpecialDay = settings.primaryCalendar == CalendarType.tibetan &&
        tibetanDate != null &&
        (tibetanDate.day == 1 || tibetanDate.day == 8 ||
         tibetanDate.day == 10 || tibetanDate.day == 15 ||
         tibetanDate.day == 25 || tibetanDate.day == 30);

    return GestureDetector(
      onTap: () => vm.selectDate(date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                )
              : isToday
                  ? LinearGradient(
                      colors: [
                        const Color(0xFF8B5CF6).withOpacity(0.15),
                        const Color(0xFFA78BFA).withOpacity(0.1),
                      ],
                    )
                  : null,
          borderRadius: BorderRadius.circular(16 * scale),
          border: isToday && !isSelected
              ? Border.all(color: const Color(0xFF8B5CF6), width: 2)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.5),
                    blurRadius: 16 * scale,
                    offset: Offset(0, 6 * scale),
                  ),
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.2),
                    blurRadius: 8 * scale,
                    offset: Offset(0, 2 * scale),
                  ),
                ]
              : isToday
                  ? [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.15),
                        blurRadius: 8 * scale,
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
                      fontWeight: isToday || isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : isCurrentMonth
                              ? isWeekend
                                  ? const Color(0xFFEF5350).withOpacity(0.8)
                                  : const Color(0xFF1F2937)
                              : const Color(0xFFD1D5DB),
                    ),
                  ),
                  // 主历法日期
                  if (dateText.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 2 * scale),
                      child: Text(
                        dateText,
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(9),
                          color: isSelected
                              ? Colors.white.withOpacity(0.8)
                              : isSpecialDay
                                  ? const Color(0xFFFF8F00)
                                  : hasFestival
                                      ? const Color(0xFFEF5350)
                                      : const Color(0xFF9CA3AF),
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
                  width: 6 * scale,
                  height: 6 * scale,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white
                        : isSpecialDay
                            ? const Color(0xFFFF8F00)
                            : const Color(0xFFEF5350),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isSpecialDay
                            ? const Color(0xFFFF8F00)
                            : const Color(0xFFEF5350)).withOpacity(0.5),
                        blurRadius: 4 * scale,
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

  /// 选中日期详情区域 - 扁平化设计（响应式）
  Widget _buildSelectedDateSection(BuildContext context, CalendarViewModel vm, CalendarSettingsProvider settings) {
    final selectedDate = vm.selectedCalendarDate;
    if (selectedDate == null) return const SizedBox.shrink();

    final scale = context.scale;
    return Container(
      margin: EdgeInsets.fromLTRB(
        context.responsiveSpacing(16),
        context.responsiveSpacing(16),
        context.responsiveSpacing(16),
        0,
      ),
      padding: EdgeInsets.all(context.responsiveSpacing(20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28 * scale),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.12),
            blurRadius: 32 * scale,
            offset: Offset(0, 12 * scale),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateHeader(context, selectedDate, settings),
          SizedBox(height: context.responsiveSpacing(16)),
          if (settings.showFestivals && selectedDate.festivals.isNotEmpty)
            _buildFestivalsSection(context, selectedDate.festivals),
          if (settings.showDailyInfo && selectedDate.dailyInfo != null)
            _buildDailyInfoSection(context, selectedDate.dailyInfo!),
        ],
      ),
    );
  }

  /// 扁平化日期头部 - 紧凑的信息展示（响应式）
  Widget _buildDateHeader(BuildContext context, CalendarDate date, CalendarSettingsProvider settings) {
    final scale = context.scale;
    final solarDate = date.solarDate;
    final lunarDate = date.lunarDate;
    final tibetanDate = date.tibetanDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 公历日期和星期
        Text(
          '${solarDate.month}月${solarDate.day}日  星期${CalendarViewModel.weekdays[solarDate.weekday - 1]}',
          style: TextStyle(
            fontSize: context.responsiveFontSize(16),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        SizedBox(height: context.responsiveSpacing(12)),

        // 历法信息行
        Wrap(
          spacing: 12 * scale,
          runSpacing: 8 * scale,
          children: [
            // 主历法（带年份）
            if (settings.primaryCalendar == CalendarType.lunar && lunarDate != null && settings.showLunarCalendar)
              _buildCalendarChip(
                context,
                '🌸 ${lunarDate.yearName ?? ''} ${lunarDate.monthName}${lunarDate.dayName}',
                const Color(0xFF10B981),
              ),
            if (settings.primaryCalendar == CalendarType.tibetan && tibetanDate != null && settings.showTibetanCalendar)
              _buildCalendarChip(
                context,
                '🏔️ ${tibetanDate.yearElement ?? ''} ${tibetanDate.month}月${tibetanDate.day}日',
                const Color(0xFFFF8F00),
              ),

            // 辅助历法（不带年份，简洁显示）
            if (settings.primaryCalendar != CalendarType.lunar && lunarDate != null && settings.showLunarCalendar)
              _buildCalendarChip(
                context,
                '🌸 ${lunarDate.monthName}${lunarDate.dayName}',
                const Color(0xFF10B981),
              ),
            if (settings.primaryCalendar != CalendarType.tibetan && tibetanDate != null && settings.showTibetanCalendar)
              _buildCalendarChip(
                context,
                '🏔️ ${tibetanDate.month}月${tibetanDate.day}日',
                const Color(0xFFFF8F00),
              ),
          ],
        ),
      ],
    );
  }

  /// 历法信息小标签（响应式）
  Widget _buildCalendarChip(BuildContext context, String text, Color color) {
    final scale = context.scale;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12 * scale,
        vertical: 6 * scale,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12 * scale),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: context.responsiveFontSize(13),
          color: color.withOpacity(0.9),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFestivalsSection(BuildContext context, List<Festival> festivals) {
    final scale = context.scale;
    return Container(
      padding: EdgeInsets.fromLTRB(
        context.responsiveSpacing(20),
        0,
        context.responsiveSpacing(20),
        context.responsiveSpacing(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6 * scale),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF5350).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8 * scale),
                ),
                child: Icon(
                  Icons.celebration_rounded,
                  size: 16 * scale,
                  color: const Color(0xFFEF5350),
                ),
              ),
              SizedBox(width: 10 * scale),
              Text(
                '节日',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: context.responsiveFontSize(14),
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          SizedBox(height: context.responsiveSpacing(12)),
          Wrap(
            spacing: 8 * scale,
            runSpacing: 8 * scale,
            children: festivals.map((f) {
              final isBuddhist = f.type == FestivalType.buddhist;
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14 * scale,
                  vertical: 8 * scale,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isBuddhist
                        ? [const Color(0xFFFFB300), const Color(0xFFFF8F00)]
                        : [const Color(0xFFEF5350), const Color(0xFFDC2626)],
                  ),
                  borderRadius: BorderRadius.circular(14 * scale),
                  boxShadow: [
                    BoxShadow(
                      color: (isBuddhist
                          ? const Color(0xFFFF8F00)
                          : const Color(0xFFEF5350)).withOpacity(0.3),
                      blurRadius: 8 * scale,
                      offset: Offset(0, 3 * scale),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (f.nameTibetan != null) ...[
                      Text(
                        f.nameTibetan!,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: context.responsiveFontSize(11),
                        ),
                      ),
                      SizedBox(width: 6 * scale),
                    ],
                    Text(
                      f.name,
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
        ],
      ),
    );
  }

  Widget _buildDailyInfoSection(BuildContext context, DailyInfo info) {
    final scale = context.scale;
    return Container(
      padding: EdgeInsets.fromLTRB(
        context.responsiveSpacing(20),
        0,
        context.responsiveSpacing(20),
        context.responsiveSpacing(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6 * scale),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8 * scale),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  size: 16 * scale,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
              SizedBox(width: 10 * scale),
              Text(
                '每日宜忌',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: context.responsiveFontSize(14),
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          SizedBox(height: context.responsiveSpacing(12)),

          // 宜
          if (info.suitable.isNotEmpty)
            Container(
              margin: EdgeInsets.only(bottom: context.responsiveSpacing(10)),
              padding: EdgeInsets.all(context.responsiveSpacing(14)),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.08),
                borderRadius: BorderRadius.circular(16 * scale),
                border: Border.all(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                ),
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
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                    child: Text(
                      '宜',
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
                      info.suitable.join(' · '),
                      style: TextStyle(
                        color: const Color(0xFF059669),
                        fontSize: context.responsiveFontSize(13),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 忌
          if (info.unsuitable.isNotEmpty)
            Container(
              padding: EdgeInsets.all(context.responsiveSpacing(14)),
              decoration: BoxDecoration(
                color: const Color(0xFFEF5350).withOpacity(0.08),
                borderRadius: BorderRadius.circular(16 * scale),
                border: Border.all(
                  color: const Color(0xFFEF5350).withOpacity(0.2),
                ),
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
                      color: const Color(0xFFEF5350),
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                    child: Text(
                      '忌',
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
                      info.unsuitable.join(' · '),
                      style: TextStyle(
                        color: const Color(0xFFDC2626),
                        fontSize: context.responsiveFontSize(13),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 回到今天按钮
  Widget _buildTodayFab() {
    return Consumer<CalendarViewModel>(
      builder: (context, vm, _) => FloatingActionButton.extended(
        onPressed: vm.goToToday,
        backgroundColor: const Color(0xFF8B5CF6),
        elevation: 8,
        highlightElevation: 12,
        icon: const Icon(Icons.today_rounded, color: Colors.white),
        label: const Text(
          '今天',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// 显示设置面板
  void _showSettingsSheet(BuildContext context) {
    // 在打开 BottomSheet 之前获取 Provider 引用
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final settingsProvider = Provider.of<CalendarSettingsProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
          ChangeNotifierProvider<CalendarSettingsProvider>.value(value: settingsProvider),
        ],
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: _buildSettingsContent(scrollController),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsContent(ScrollController scrollController) {
    return Consumer2<LocaleProvider, CalendarSettingsProvider>(
      builder: (context, localeProvider, settingsProvider, _) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            '设置',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // 语言设置
          _buildSectionTitle('语言设置'),
          _buildLanguageSection(localeProvider),
          const SizedBox(height: 24),
          
          // 历法设置
          _buildSectionTitle('历法设置'),
          _buildCalendarSettingsSection(settingsProvider),
          const SizedBox(height: 24),
          
          // 插件管理
          _buildSectionTitle('插件管理'),
          _buildPluginsSection(settingsProvider),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }

  Widget _buildLanguageSection(LocaleProvider localeProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: LocaleProvider.supportedLocales.map((locale) {
          final code = '${locale.languageCode}_${locale.countryCode}';
          final name = LocaleProvider.languageNames[code] ?? '';
          final isSelected = localeProvider.locale == locale;
          
          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFFEDE9FE)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _getLanguageFlag(locale.languageCode),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: isSelected
                ? Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF8B5CF6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 16),
                  )
                : null,
            onTap: () => localeProvider.setLocale(locale),
          );
        }).toList(),
      ),
    );
  }

  String _getLanguageFlag(String code) {
    switch (code) {
      case 'zh':
        return '🇨🇳';
      case 'bo':
        return '🏔️';
      case 'en':
        return '🇺🇸';
      default:
        return '🌐';
    }
  }

  Widget _buildCalendarSettingsSection(CalendarSettingsProvider settings) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 主历法选择
          _buildPrimaryCalendarSelector(settings),
          const Divider(height: 1, indent: 68, endIndent: 16),
          _buildSettingTile(
            Icons.water_drop,
            '显示农历',
            settings.showLunarCalendar,
            settings.toggleLunarCalendar,
          ),
          const Divider(height: 1, indent: 68, endIndent: 16),
          _buildSettingTile(
            Icons.star,
            '显示藏历',
            settings.showTibetanCalendar,
            settings.toggleTibetanCalendar,
          ),
          const Divider(height: 1, indent: 68, endIndent: 16),
          _buildSettingTile(
            Icons.celebration,
            '显示节日',
            settings.showFestivals,
            settings.toggleFestivals,
          ),
          const Divider(height: 1, indent: 68, endIndent: 16),
          _buildSettingTile(
            Icons.auto_awesome,
            '显示宜忌',
            settings.showDailyInfo,
            settings.toggleDailyInfo,
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryCalendarSelector(CalendarSettingsProvider settings) {
    return ExpansionTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF8B5CF6).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.calendar_today, color: Color(0xFF8B5CF6), size: 20),
      ),
      title: const Text('主历法', style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        CalendarSettingsProvider.getCalendarTypeName(settings.primaryCalendar),
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      children: CalendarSettingsProvider.supportedCalendars.map((type) {
        final isSelected = settings.primaryCalendar == type;
        return RadioListTile<CalendarType>(
          title: Row(
            children: [
              Text(
                CalendarSettingsProvider.getCalendarTypeIcon(type),
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 10),
              Text(
                CalendarSettingsProvider.getCalendarTypeName(type),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          value: type,
          groupValue: settings.primaryCalendar,
          activeColor: const Color(0xFF8B5CF6),
          selected: isSelected,
          onChanged: (value) {
            if (value != null) {
              settings.setPrimaryCalendar(value);
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildSettingTile(
    IconData icon,
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F3FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF8B5CF6), size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF8B5CF6),
      ),
    );
  }

  Widget _buildPluginsSection(CalendarSettingsProvider settings) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPluginTile(
            '农历插件',
            'v2.0.0',
            settings.showLunarCalendar,
            Icons.water_drop,
            const Color(0xFF10B981),
            () => settings.toggleLunarCalendar(!settings.showLunarCalendar),
          ),
          const Divider(height: 1, indent: 68, endIndent: 16),
          _buildPluginTile(
            '藏历插件',
            'v2.0.0',
            settings.showTibetanCalendar,
            Icons.star,
            const Color(0xFFFF8F00),
            () => settings.toggleTibetanCalendar(!settings.showTibetanCalendar),
          ),
        ],
      ),
    );
  }

  Widget _buildPluginTile(
    String name,
    String version,
    bool isEnabled,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        version,
        style: TextStyle(color: Colors.grey[500], fontSize: 12),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isEnabled
              ? const Color(0xFF10B981).withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          isEnabled ? '已启用' : '已禁用',
          style: TextStyle(
            color: isEnabled ? const Color(0xFF10B981) : Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}
