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
            builder: (context, vm, _) => Text(vm.monthTitle),
          ),
          centerTitle: true,
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
        body: Column(
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
    );
  }

  Widget _buildMonthNavigation() {
    return Consumer<CalendarViewModel>(
      builder: (context, vm, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: vm.previousMonth,
            ),
            Text(
              vm.monthTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: vm.nextMonth,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: CalendarViewModel.weekdays.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: day == '六' || day == '日' ? Colors.red : null,
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

    return GestureDetector(
      onTap: () => vm.selectDate(date),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : null,
          borderRadius: BorderRadius.circular(8),
          border: isToday ? Border.all(color: Theme.of(context).primaryColor, width: 2) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Colors.white
                    : isCurrentMonth
                        ? Colors.black
                        : Colors.grey,
              ),
            ),
            if (calendarDate.lunarDate != null)
              Text(
                _getLunarDayText(calendarDate.lunarDate!),
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected
                      ? Colors.white70
                      : hasFestival
                          ? Colors.red
                          : Colors.grey,
                ),
              ),
            if (hasFestival)
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getLunarDayText(LunarDate lunarDate) {
    // 初一显示月份，其他显示日期
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(
              top: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDateHeader(selectedDate),
              const SizedBox(height: 8),
              _buildDateDetails(selectedDate),
              if (selectedDate.festivals.isNotEmpty) ...[
                const Divider(),
                _buildFestivals(selectedDate.festivals),
              ],
              if (selectedDate.dailyInfo != null) ...[
                const Divider(),
                _buildDailyInfo(selectedDate.dailyInfo!),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateHeader(CalendarDate date) {
    final solarDate = date.solarDate;
    return Row(
      children: [
        Text(
          '${solarDate.year}年${solarDate.month}月${solarDate.day}日',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Text(
          '星期${CalendarViewModel.weekdays[solarDate.weekday - 1]}',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
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
      runSpacing: 4,
      children: details,
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  Widget _buildFestivals(List<Festival> festivals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '节日',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: festivals.map((f) => Chip(
            label: Text(f.name),
            backgroundColor: f.type == FestivalType.buddhist
                ? Colors.orange[100]
                : Colors.red[100],
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildDailyInfo(DailyInfo info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (info.suitable.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('宜：', style: TextStyle(color: Colors.green)),
                Expanded(
                  child: Text(
                    info.suitable.join(' '),
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        if (info.unsuitable.isNotEmpty)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('忌：', style: TextStyle(color: Colors.red)),
              Expanded(
                child: Text(
                  info.unsuitable.join(' '),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        if (info.note != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              info.note!,
              style: TextStyle(color: Colors.orange[700], fontSize: 12),
            ),
          ),
      ],
    );
  }
}
