import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/calendar_view_model.dart';
import '../../models/calendar_models.dart';
import '../../core/providers/calendar_settings_provider.dart';
import '../../core/providers/locale_provider.dart';

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

class _CalendarViewState extends State<CalendarView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
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

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarSettingsProvider>(
      builder: (context, settings, _) => ChangeNotifierProvider(
        create: (_) => CalendarViewModel(settings: settings)..selectDate(DateTime.now()),
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F7FC),
          body: Consumer<CalendarViewModel>(
            builder: (context, vm, _) => CustomScrollView(
              slivers: [
                _buildAppBar(context, vm),
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _animationController,
                    child: Column(
                      children: [
                        _buildYearInfoCard(vm, settings),
                        _buildCalendarSection(vm, settings),
                        _buildSelectedDateSection(vm, settings),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: _buildTodayFab(),
        ),
      ),
    );
  }

  /// 现代化 AppBar
  Widget _buildAppBar(BuildContext context, CalendarViewModel vm) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6B5B95).withOpacity(0.95),
              const Color(0xFF8B7BC8).withOpacity(0.9),
            ],
          ),
        ),
        child: FlexibleSpaceBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_month, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      vm.monthTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          centerTitle: true,
        ),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
          ),
          onPressed: () => _showSettingsSheet(context),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// 年份信息卡片（根据主历法显示）
  Widget _buildYearInfoCard(CalendarViewModel vm, CalendarSettingsProvider settings) {
    final selectedDate = vm.selectedCalendarDate;
    if (selectedDate == null) return const SizedBox.shrink();

    final primaryCalendar = settings.primaryCalendar;
    String yearInfo = '';
    String monthDayInfo = '';
    String? extraInfo;
    bool isSpecial = false;

    // 根据主历法显示对应信息
    switch (primaryCalendar) {
      case CalendarType.lunar:
        if (selectedDate.lunarDate != null) {
          final lunar = selectedDate.lunarDate!;
          yearInfo = lunar.yearName ?? '';
          monthDayInfo = '农历 ${lunar.monthName}${lunar.dayName}';
          extraInfo = lunar.zodiac != null ? '${lunar.zodiac}年' : null;
        }
        break;
      case CalendarType.tibetan:
        if (selectedDate.tibetanDate != null) {
          final tibetan = selectedDate.tibetanDate!;
          yearInfo = tibetan.yearElement ?? '';
          monthDayInfo = '藏历 ${tibetan.month}月${tibetan.day}日';
          extraInfo = tibetan.monthNameTibetan;
          
          // 检查殊胜日
          if (tibetan.day == 1 || tibetan.day == 8 || 
              tibetan.day == 10 || tibetan.day == 15 ||
              tibetan.day == 25 || tibetan.day == 30) {
            isSpecial = true;
          }
        }
        break;
      case CalendarType.solar:
      case CalendarType.islamic:
      case CalendarType.dai:
      case CalendarType.yi:
        // 暂不支持，回退到农历
        if (selectedDate.lunarDate != null) {
          final lunar = selectedDate.lunarDate!;
          yearInfo = lunar.yearName ?? '';
          monthDayInfo = '农历 ${lunar.monthName}${lunar.dayName}';
        }
        break;
    }

    if (yearInfo.isEmpty && monthDayInfo.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: primaryCalendar == CalendarType.tibetan
              ? [
                  const Color(0xFFFFF8E1),
                  const Color(0xFFFFECB3),
                ]
              : [
                  const Color(0xFFE8F5E9),
                  const Color(0xFFC8E6C9),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (primaryCalendar == CalendarType.tibetan
                    ? const Color(0xFFFFB300)
                    : const Color(0xFF4CAF50))
                .withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (primaryCalendar == CalendarType.tibetan
                          ? const Color(0xFFFFB300)
                          : const Color(0xFF4CAF50))
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  primaryCalendar == CalendarType.tibetan
                      ? Icons.auto_awesome
                      : Icons.nights_stay,
                  color: primaryCalendar == CalendarType.tibetan
                      ? const Color(0xFFFF8F00)
                      : const Color(0xFF2E7D32),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      yearInfo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      monthDayInfo,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.brown[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (extraInfo != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (primaryCalendar == CalendarType.tibetan
                            ? const Color(0xFFFFB300)
                            : const Color(0xFF4CAF50))
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    extraInfo,
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF5D4037),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          
          // 藏历特殊标记（缺日/重日）
          if (primaryCalendar == CalendarType.tibetan && 
              selectedDate.tibetanDate != null &&
              (selectedDate.tibetanDate!.isMissingDay || 
               selectedDate.tibetanDate!.isDoubleday))
            Container(
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: selectedDate.tibetanDate!.isMissingDay 
                    ? const Color(0xFFEF5350).withOpacity(0.1)
                    : const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    selectedDate.tibetanDate!.isMissingDay 
                        ? Icons.remove_circle_outline 
                        : Icons.add_circle_outline,
                    size: 16,
                    color: selectedDate.tibetanDate!.isMissingDay 
                        ? const Color(0xFFEF5350)
                        : const Color(0xFF4CAF50),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    selectedDate.tibetanDate!.isMissingDay ? '缺日' : '重日',
                    style: TextStyle(
                      fontSize: 12,
                      color: selectedDate.tibetanDate!.isMissingDay 
                          ? const Color(0xFFEF5350)
                          : const Color(0xFF4CAF50),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 日历主体区域
  Widget _buildCalendarSection(CalendarViewModel vm, CalendarSettingsProvider settings) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B5B95).withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMonthNavigation(vm, settings),
          _buildWeekdayHeader(),
          _buildCalendarGrid(vm, settings),
        ],
      ),
    );
  }

  /// 月份导航
  Widget _buildMonthNavigation(CalendarViewModel vm, CalendarSettingsProvider settings) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavButton(Icons.chevron_left_rounded, vm.previousMonth),
          Row(
            children: [
              Text(
                vm.monthTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2438),
                ),
              ),
              // 显示主历法的年份信息
              if (vm.selectedCalendarDate != null) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B5B95).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    vm.getYearInfoText(vm.selectedCalendarDate!),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B5B95),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          _buildNavButton(Icons.chevron_right_rounded, vm.nextMonth),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: const Color(0xFFF5F3FF),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            color: const Color(0xFF6B5B95),
            size: 24,
          ),
        ),
      ),
    );
  }

  /// 星期头部
  Widget _buildWeekdayHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
                  fontSize: 13,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 日历网格
  Widget _buildCalendarGrid(CalendarViewModel vm, CalendarSettingsProvider settings) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
        ),
        itemCount: vm.monthDates.length,
        itemBuilder: (context, index) {
          return _buildDateCell(context, vm, vm.monthDates[index], settings);
        },
      ),
    );
  }

  /// 日期单元格
  Widget _buildDateCell(
    BuildContext context,
    CalendarViewModel vm,
    CalendarDate calendarDate,
    CalendarSettingsProvider settings,
  ) {
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
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6B5B95), Color(0xFF8B7BC8)],
                )
              : isToday
                  ? LinearGradient(
                      colors: [
                        const Color(0xFF6B5B95).withOpacity(0.15),
                        const Color(0xFF8B7BC8).withOpacity(0.1),
                      ],
                    )
                  : null,
          borderRadius: BorderRadius.circular(16),
          border: isToday && !isSelected
              ? Border.all(color: const Color(0xFF6B5B95), width: 2)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6B5B95).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
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
                      fontSize: 15,
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
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        dateText,
                        style: TextStyle(
                          fontSize: 9,
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
                top: 4,
                right: 4,
                child: Container(
                  width: 6,
                  height: 6,
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
                        blurRadius: 4,
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

  /// 选中日期详情区域
  Widget _buildSelectedDateSection(CalendarViewModel vm, CalendarSettingsProvider settings) {
    final selectedDate = vm.selectedCalendarDate;
    if (selectedDate == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B5B95).withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDateHeader(selectedDate, settings),
          if (settings.showFestivals && selectedDate.festivals.isNotEmpty)
            _buildFestivalsSection(selectedDate.festivals),
          if (settings.showDailyInfo && selectedDate.dailyInfo != null)
            _buildDailyInfoSection(selectedDate.dailyInfo!),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDateHeader(CalendarDate date, CalendarSettingsProvider settings) {
    final solarDate = date.solarDate;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // 大日期数字
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6B5B95), Color(0xFF8B7BC8)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6B5B95).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${solarDate.day}',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          // 日期详情
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${solarDate.year}年${solarDate.month}月',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '星期${CalendarViewModel.weekdays[solarDate.weekday - 1]}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                // 根据设置显示历法信息
                ..._buildCalendarInfo(date, settings),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 根据设置构建历法信息显示
  List<Widget> _buildCalendarInfo(CalendarDate date, CalendarSettingsProvider settings) {
    List<Widget> widgets = [];

    // 显示主历法信息
    if (settings.primaryCalendar == CalendarType.lunar && 
        date.lunarDate != null &&
        settings.showLunarCalendar) {
      widgets.add(
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '农历 ${date.lunarDate!.monthName}${date.lunarDate!.dayName}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF059669),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    } else if (settings.primaryCalendar == CalendarType.tibetan && 
               date.tibetanDate != null &&
               settings.showTibetanCalendar) {
      widgets.add(
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFF8F00).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '藏历 ${date.tibetanDate!.month}月${date.tibetanDate!.day}日',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFE65100),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    // 如果显示农历但不是主历法，额外显示农历
    if (settings.primaryCalendar != CalendarType.lunar && 
        date.lunarDate != null &&
        settings.showLunarCalendar) {
      widgets.add(
        Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '农历 ${date.lunarDate!.monthName}${date.lunarDate!.dayName}',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF059669),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    // 如果显示藏历但不是主历法，额外显示藏历
    if (settings.primaryCalendar != CalendarType.tibetan && 
        date.tibetanDate != null &&
        settings.showTibetanCalendar) {
      widgets.add(
        Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFF8F00).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '藏历 ${date.tibetanDate!.month}月${date.tibetanDate!.day}日',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFFE65100),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildFestivalsSection(List<Festival> festivals) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF5350).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.celebration_rounded,
                  size: 16,
                  color: Color(0xFFEF5350),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                '节日',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: festivals.map((f) {
              final isBuddhist = f.type == FestivalType.buddhist;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isBuddhist
                        ? [const Color(0xFFFFB300), const Color(0xFFFF8F00)]
                        : [const Color(0xFFEF5350), const Color(0xFFDC2626)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: (isBuddhist 
                          ? const Color(0xFFFF8F00)
                          : const Color(0xFFEF5350)).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (f.nameTibetan != null) ...[
                      Text(
                        f.nameTibetan!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 1,
                        height: 12,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      f.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
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

  Widget _buildDailyInfoSection(DailyInfo info) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B5B95).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: Color(0xFF6B5B95),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                '每日宜忌',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // 宜
          if (info.suitable.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '宜',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      info.suitable.join(' · '),
                      style: const TextStyle(
                        color: Color(0xFF059669),
                        fontSize: 13,
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
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEF5350).withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFEF5350).withOpacity(0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF5350),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '忌',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      info.unsuitable.join(' · '),
                      style: const TextStyle(
                        color: Color(0xFFDC2626),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 备注
          if (info.note != null)
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB300).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFFB300).withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: Colors.orange[700],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      info.note!,
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontSize: 12,
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
        backgroundColor: const Color(0xFF6B5B95),
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
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
                child: _buildSettingsContent(context, scrollController),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context, ScrollController scrollController) {
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
          _buildCalendarSection(settingsProvider),
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
            color: const Color(0xFF6B5B95).withOpacity(0.06),
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
                    ? const Color(0xFF6B5B95).withOpacity(0.1)
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
                      color: Color(0xFF6B5B95),
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

  Widget _buildCalendarSection(CalendarSettingsProvider settings) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B5B95).withOpacity(0.06),
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
          color: const Color(0xFF6B5B95).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.calendar_today, color: Color(0xFF6B5B95), size: 20),
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
          activeColor: const Color(0xFF6B5B95),
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
        child: Icon(icon, color: const Color(0xFF6B5B95), size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF6B5B95),
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
            color: const Color(0xFF6B5B95).withOpacity(0.06),
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
