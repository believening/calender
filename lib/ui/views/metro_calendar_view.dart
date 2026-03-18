import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/calendar_view_model.dart';
import '../../models/calendar_models.dart';
import '../../core/providers/calendar_settings_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../widgets/metro_tile.dart';

/// Windows 8 Metro 风格日历视图
class MetroCalendarView extends StatefulWidget {
  const MetroCalendarView({super.key});

  @override
  State<MetroCalendarView> createState() => _MetroCalendarViewState();
}

class _MetroCalendarViewState extends State<MetroCalendarView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Consumer<CalendarViewModel>(
        builder: (context, vm, _) {
          final settings = context.watch<CalendarSettingsProvider>();
          final locale = context.watch<LocaleProvider>();

          return CustomScrollView(
            slivers: [
              // 顶部应用栏
              SliverAppBar(
                expandedHeight: 80,
                floating: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  title: _buildHeader(vm),
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 12),
                ),
                actions: [
                  // 磁贴尺寸切换器
                  _buildTileSizeSwitcher(),
                  const SizedBox(width: 16),
                  // 设置按钮
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white70),
                    onPressed: () => _showSettings(context),
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              // 磁贴内容
              SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildMetroTiles(context, vm, settings, locale),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(CalendarViewModel vm) {
    final month = vm.currentMonth;
    final weekdays = ['一', '二', '三', '四', '五', '六', '日'];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${month.year}年${month.month}月',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(width: 24),
        ...weekdays.map((d) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            d,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildTileSizeSwitcher() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: MetroTileSize.values.map((size) {
          final isSelected = false; // TODO: 绑定状态
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              // TODO: 切换磁贴尺寸
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                size.displayName,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetroTiles(
    BuildContext context,
    CalendarViewModel vm,
    CalendarSettingsProvider settings,
    LocaleProvider locale,
  ) {
    final tiles = <MetroTile>[];

    // 1. 日历网格磁贴（大磁贴 2x2）
    tiles.add(MetroTile(
      size: MetroTileSize.large,
      backgroundColor: MetroColors.calendar,
      title: '${vm.currentMonth.year}年${vm.currentMonth.month}月',
      child: _buildCalendarGrid(vm, settings),
    ));

    // 2. 选中日期磁贴（宽磁贴 2x1）
    final selectedDate = vm.selectedCalendarDate;
    if (selectedDate != null) {
      tiles.add(MetroTile(
        size: MetroTileSize.wide,
        backgroundColor: MetroColors.calendar.withOpacity(0.8),
        title: '选中日期',
        mainContent: '${selectedDate.solarDate.day}',
        subtitle: _getSelectedDateSubtitle(selectedDate, settings),
      ));
    }

    // 3. 农历磁贴组
    if (settings.showLunarCalendar && selectedDate?.lunarDate != null) {
      final lunar = selectedDate!.lunarDate!;

      // 农历月日磁贴
      tiles.add(MetroTile(
        size: MetroTileSize.small,
        backgroundColor: MetroColors.lunar,
        title: '农历',
        mainContent: '${lunar.month}月${lunar.day}',
        subtitle: lunar.ganZhi ?? lunar.zodiac ?? '',
        explanation: '农历${lunar.ganZhi ?? ''}年，${lunar.month}月${lunar.day}日。干支纪年是中国传统历法的重要组成部分。',
      ));

      // 节气磁贴
      if (selectedDate.dailyInfo?.note != null) {
        tiles.add(MetroTile(
          size: MetroTileSize.small,
          backgroundColor: MetroColors.solarTerm,
          title: '节气',
          mainContent: selectedDate.dailyInfo!.note,
          explanation: '${selectedDate.dailyInfo!.note}是二十四节气之一，标志着季节变化的重要时刻。',
        ));
      }

      // 宜忌磁贴
      if (selectedDate.dailyInfo != null) {
        final yiText = selectedDate.dailyInfo!.suitable?.take(3).join(' ') ?? '';
        final jiText = selectedDate.dailyInfo!.unsuitable?.take(3).join(' ') ?? '';
        if (yiText.isNotEmpty || jiText.isNotEmpty) {
          tiles.add(MetroTile(
            size: MetroTileSize.wide,
            backgroundColor: MetroColors.yiJi,
            title: '宜忌',
            subtitle: '宜: $yiText\n忌: $jiText',
            explanation: '宜：今日适合进行的事项。忌：今日应避免的事项。源自传统黄历推算。',
          ));
        }
      }

      // 冲煞磁贴
      if (selectedDate.dailyInfo?.chongSha != null) {
        tiles.add(MetroTile(
          size: MetroTileSize.small,
          backgroundColor: MetroColors.chongSha,
          title: '冲煞',
          mainContent: selectedDate.dailyInfo!.chongSha!.split(' ').first,
          explanation: _getChongShaExplanation(selectedDate.dailyInfo!.chongSha!),
        ));
      }
    }

    // 4. 藏历磁贴组
    if (settings.showTibetanCalendar && selectedDate?.tibetanDate != null) {
      final tibetan = selectedDate!.tibetanDate!;

      // 藏历月日磁贴
      tiles.add(MetroTile(
        size: MetroTileSize.small,
        backgroundColor: MetroColors.tibetan,
        title: '藏历',
        mainContent: '${tibetan.month}月${tibetan.day}',
        subtitle: tibetan.yearElement ?? '',
        explanation: '藏历${tibetan.yearElement ?? ''}，${tibetan.month}月${tibetan.day}日。藏历是基于印度时轮历的阴阳合历。',
      ));

      // 殊胜日磁贴 - 从 dailyInfo 获取
      // TODO: 需要从 TibetanAlgorithm 获取殊胜日信息
    }

    // 5. 节日磁贴
    if (settings.showFestivals) {
      final festivals = <String>[];
      if (selectedDate?.festivals.isNotEmpty == true) {
        festivals.addAll(selectedDate!.festivals.map((f) => f.name));
      }

      if (festivals.isNotEmpty) {
        tiles.add(MetroTile(
          size: MetroTileSize.wide,
          backgroundColor: MetroColors.festival,
          title: '节日',
          subtitle: festivals.take(3).join(' · '),
          explanation: '今日是${festivals.join('、')}。',
        ));
      }
    }

    // 使用 Wrap 布局
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth - 12) / 4;
        final tileHeight = tileWidth;

        return Wrap(
          spacing: 4,
          runSpacing: 4,
          children: tiles.map((tile) {
            final width = tileWidth * tile.size.crossAxisCellCount + 4 * (tile.size.crossAxisCellCount - 1);
            final height = tileHeight * tile.size.mainAxisCellCount + 4 * (tile.size.mainAxisCellCount - 1);

            return SizedBox(
              width: width,
              height: height,
              child: tile,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCalendarGrid(CalendarViewModel vm, CalendarSettingsProvider settings) {
    final dates = vm.monthDates;
    final now = DateTime.now();

    return Padding(
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              vm.selectDate(date.solarDate);
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
              child: Center(
                child: Text(
                  '${date.solarDate.day}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getSelectedDateSubtitle(CalendarDate date, CalendarSettingsProvider settings) {
    final parts = <String>[];
    parts.add('${date.solarDate.month}月${date.solarDate.day}日');

    if (settings.showLunarCalendar && date.lunarDate != null) {
      parts.add('农历${date.lunarDate!.month}月${date.lunarDate!.day}');
    }

    return parts.join(' · ');
  }

  String _getChongShaExplanation(String chongSha) {
    final parts = chongSha.split(' ');
    if (parts.isEmpty) return '';

    String explanation = '';

    if (parts.isNotEmpty) {
      final chong = parts[0];
      if (chong.startsWith('冲')) {
        final animal = chong.substring(1);
        explanation += '今日与属$animal的人相冲，不宜合作或重要决定。';
      }
    }

    if (parts.length > 1) {
      final sha = parts[1];
      if (sha.startsWith('煞')) {
        final direction = sha.substring(1);
        explanation += '煞$direction方位，避免向该方向行事。';
      }
    }

    return explanation;
  }

  void _showSettings(BuildContext context) {
    // TODO: 显示设置面板
  }
}
