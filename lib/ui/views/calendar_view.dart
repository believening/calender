import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/calendar_view_model.dart';
import '../../models/calendar_models.dart';

/// 日历主视图
class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalendarViewModel()..selectDate(DateTime.now()),
      child: Scaffold(
        appBar: AppBar(
          title: Consumer<CalendarViewModel>(
            builder: (context, vm, _) => Text(
              vm.monthTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          centerTitle: true,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.today),
              onPressed: () {
                context.read<CalendarViewModel>().goToToday();
              },
              tooltip: '回到今天',
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey[50]!, Colors.grey[100]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              _buildMonthNavigation(),
              _buildWeekdayHeader(),
              Expanded(
                child: _buildCalendarGrid(),
              ),
              _buildSelectedDateInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthNavigation() {
    return Consumer<CalendarViewModel>(
      builder: (context, vm, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavButton(Icons.chevron_left, vm.previousMonth),
            Row(
              children: [
                Text(
                  vm.monthTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(width: 8),
                if (vm.selectedCalendarDate?.lunarDate != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      vm.selectedCalendarDate!.lunarDate!.yearName ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.deepPurple.shade700,
                      ),
                    ),
                  ),
              ],
            ),
            _buildNavButton(Icons.chevron_right, vm.nextMonth),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.deepPurple.shade50,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.deepPurple),
        ),
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
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
                  color: isWeekend ? Colors.red.shade400 : Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    return Consumer<CalendarViewModel>(
      builder: (context, vm, _) => GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: vm.monthDates.length,
        itemBuilder: (context, index) {
          var calendarDate = vm.monthDates[index];
          return _buildDateCell(context, vm, calendarDate);
        },
      ),
    );
  }

  Widget _buildDateCell(
    BuildContext context,
    CalendarViewModel vm,
    CalendarDate calendarDate,
  ) {
    final date = calendarDate.solarDate;
    final isToday = vm.isToday(date);
    final isSelected = vm.isSelected(date);
    final isCurrentMonth = vm.isCurrentMonth(date);
    final hasFestival = calendarDate.festivals.isNotEmpty;
    final isWeekend = date.weekday == 6 || date.weekday == 7;

    return GestureDetector(
      onTap: () => vm.selectDate(date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.deepPurple
              : isToday
                  ? Colors.deepPurple.shade50
                  : null,
          borderRadius: BorderRadius.circular(12),
          border: isToday && !isSelected
              ? Border.all(color: Colors.deepPurple, width: 2)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
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
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isToday || isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
                          : isCurrentMonth
                              ? isWeekend
                                  ? Colors.red.shade400
                                  : Colors.grey[800]
                              : Colors.grey[400],
                    ),
                  ),
                  if (calendarDate.lunarDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        _getLunarDayText(calendarDate.lunarDate!),
                        style: TextStyle(
                          fontSize: 9,
                          color: isSelected
                              ? Colors.white70
                              : hasFestival
                                  ? Colors.red
                                  : Colors.grey[500],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            if (hasFestival)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getLunarDayText(LunarDate lunarDate) {
    if (lunarDate.day == 1) {
      return lunarDate.monthName ?? '初一';
    }
    return lunarDate.dayName ?? '${lunarDate.day}';
  }

  Widget _buildSelectedDateInfo() {
    return Consumer<CalendarViewModel>(
      builder: (context, vm, _) {
        final selectedDate = vm.selectedCalendarDate;
        if (selectedDate == null) return const SizedBox.shrink();

        return Container(
          constraints: const BoxConstraints(maxHeight: 280),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDateHeader(selectedDate),
                const SizedBox(height: 12),
                _buildDateDetails(selectedDate),
                if (selectedDate.festivals.isNotEmpty) ...[
                  const Divider(height: 24),
                  _buildFestivals(selectedDate.festivals),
                ],
                if (selectedDate.dailyInfo != null) ...[
                  const Divider(height: 24),
                  _buildDailyInfo(selectedDate.dailyInfo!),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateHeader(CalendarDate date) {
    final solarDate = date.solarDate;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // 日期数字（大号）
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${solarDate.day}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 日期详情
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${solarDate.year}年${solarDate.month}月',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '星期${CalendarViewModel.weekdays[solarDate.weekday - 1]}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateDetails(CalendarDate date) {
    List<Widget> details = [];

    if (date.lunarDate != null) {
      details.add(_buildInfoChip(
        Icons.calendar_today,
        '农历 ${date.lunarDate}',
        Colors.green,
      ));
    }

    if (date.tibetanDate != null) {
      details.add(_buildInfoChip(
        Icons.star,
        '藏历 ${date.tibetanDate}',
        Colors.orange,
      ));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: details,
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFestivals(List<Festival> festivals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.celebration_rounded,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '节日',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: festivals.map((f) {
            final isBuddhist = f.type == FestivalType.buddhist;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isBuddhist
                      ? [const Color(0xFFFFB74D), const Color(0xFFFF9800)]
                      : [const Color(0xFFEF5350), const Color(0xFFE53935)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (isBuddhist ? Colors.orange : Colors.red)
                        .withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                f.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDailyInfo(DailyInfo info) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Row(
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '每日宜忌',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 宜
        if (info.suitable.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4CAF50).withOpacity(0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
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
                      color: Color(0xFF2E7D32),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEF5350).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFEF5350).withOpacity(0.3),
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
                      color: Color(0xFFC62828),
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFFF9800).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: Colors.orange[700],
                ),
                const SizedBox(width: 8),
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
    );
  }
}
