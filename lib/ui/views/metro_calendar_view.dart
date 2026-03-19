import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/calendar_view_model.dart';
import '../../models/calendar_models.dart';
import '../../core/providers/calendar_settings_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/utils/responsive_helper.dart';
import '../widgets/metro_tile.dart';
import '../widgets/calendar_grid_tile.dart';
import '../widgets/responsive_tile_grid.dart';

/// 历法系统磁贴组
class CalendarSystemGroup {
  final CalendarType type;
  final String name;
  final List<MetroTile> tiles;

  CalendarSystemGroup({
    required this.type,
    required this.name,
    required this.tiles,
  });
}

/// Windows 8 Metro 风格日历视图
class MetroCalendarView extends StatefulWidget {
  const MetroCalendarView({super.key});

  @override
  State<MetroCalendarView> createState() => _MetroCalendarViewState();
}

class _MetroCalendarViewState extends State<MetroCalendarView> {
  late CalendarViewModel _viewModel;
  CalendarViewMode _currentViewMode = CalendarViewMode.month;
  final PageController _calendarPageController = PageController();
  int _currentCalendarPage = 0;

  @override
  void initState() {
    super.initState();
    _viewModel = CalendarViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _calendarPageController.dispose();
    super.dispose();
  }

  void _handleViewModeChanged(CalendarViewMode mode) {
    setState(() {
      _currentViewMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8), // 温暖的米白色背景
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final settings = context.watch<CalendarSettingsProvider>();
          final locale = context.watch<LocaleProvider>();
          final deviceType = context.deviceType;
          final isMobile = context.isMobile;

          return CustomScrollView(
            slivers: [
              // 顶部应用栏
              SliverAppBar(
                expandedHeight: isMobile ? 60 : 80,
                floating: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  title: _buildHeader(_viewModel, isMobile),
                  titlePadding: EdgeInsets.only(
                    left: isMobile ? 12 : 20,
                    bottom: isMobile ? 8 : 12,
                  ),
                ),
                actions: [
                  // 视图模式切换器
                  _buildViewModeSwitcher(isMobile),
                  const SizedBox(width: 8),
                  // 设置按钮
                  IconButton(
                    icon: const Icon(Icons.settings, color: Color(0xFF5D4E37)),
                    onPressed: () => _showSettings(context),
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              // 磁贴内容
              SliverPadding(
                padding: EdgeInsets.all(isMobile ? 8 : 12),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildGestureTileGrid(context, _viewModel, settings, locale, deviceType),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(CalendarViewModel _viewModel, bool isMobile) {
    final month = _viewModel.currentMonth;
    final weekdays = ['一', '二', '三', '四', '五', '六', '日'];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${month.year}年${month.month}月',
          style: TextStyle(
            color: const Color(0xFF5D4E37),
            fontSize: isMobile ? 18 : 24,
            fontWeight: FontWeight.w300,
          ),
        ),
        if (!isMobile) ...[
          const SizedBox(width: 24),
          ...weekdays.map((d) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              d,
              style: TextStyle(
                color: const Color(0xFF5D4E37).withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildViewModeSwitcher(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 8),
      decoration: BoxDecoration(
        color: const Color(0xFF5D4E37).withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: CalendarViewMode.values.map((mode) {
          final isSelected = _currentViewMode == mode;
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _handleViewModeChanged(mode);
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 8 : 12,
                vertical: isMobile ? 4 : 6,
              ),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF5D4E37).withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    mode.icon,
                    color: isSelected ? const Color(0xFF5D4E37) : const Color(0xFF5D4E37).withOpacity(0.7),
                    size: isMobile ? 12 : 14,
                  ),
                  if (!isMobile) ...[
                    SizedBox(width: 4),
                    Text(
                      mode.displayName,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF5D4E37) : const Color(0xFF5D4E37).withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGestureTileGrid(
    BuildContext context,
    CalendarViewModel _viewModel,
    CalendarSettingsProvider settings,
    LocaleProvider locale,
    DeviceType deviceType,
  ) {
    final isMobile = context.isMobile;
    final config = _getTileConfig(deviceType);

    // 获取日历网格磁贴
    final calendarGridTile = _buildCalendarGridTile(_viewModel, settings, isMobile);

    // 获取所有启用的历法系统
    final calendarSystems = _getEnabledCalendarSystems(settings, _viewModel, locale, isMobile);

    // 选中日期磁贴（始终显示在日历网格下方）
    final selectedDateTile = _buildSelectedDateTile(_viewModel, settings, isMobile);

    // 获取当前历法系统的磁贴
    List<MetroTile> currentTiles = [];
    if (calendarSystems.isNotEmpty && _currentCalendarPage < calendarSystems.length) {
      currentTiles = calendarSystems[_currentCalendarPage].tiles;
    }

    return GestureDetector(
      onScaleUpdate: (details) {
        final newScale = details.scale;
        // 根据缩放方向切换视图
        if (newScale < 0.7 && _currentViewMode != CalendarViewMode.week) {
          HapticFeedback.lightImpact();
          _handleViewModeChanged(CalendarViewMode.week);
        } else if (newScale > 1.3 && _currentViewMode != CalendarViewMode.day) {
          HapticFeedback.lightImpact();
          _handleViewModeChanged(CalendarViewMode.day);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 日历网格磁贴
          _buildSingleTileWidget(calendarGridTile, config, deviceType),

          // 选中日期磁贴
          if (selectedDateTile != null)
            _buildSingleTileWidget(selectedDateTile, config, deviceType),

          // 历法系统指示器
          if (calendarSystems.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(calendarSystems.length, (index) {
                  final isActive = index == _currentCalendarPage;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _currentCalendarPage = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF5D4E37).withOpacity(0.15)
                            : const Color(0xFF5D4E37).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        calendarSystems[index].name,
                        style: TextStyle(
                          color: isActive ? const Color(0xFF5D4E37) : const Color(0xFF5D4E37).withOpacity(0.7),
                          fontSize: isMobile ? 11 : 12,
                          fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

          // 当前历法系统的磁贴
          if (currentTiles.isNotEmpty)
            _buildTileGroup(currentTiles, config, deviceType),
        ],
      ),
    );
  }

  /// 构建选中日期磁贴
  MetroTile? _buildSelectedDateTile(
    CalendarViewModel _viewModel,
    CalendarSettingsProvider settings,
    bool isMobile,
  ) {
    final selectedDate = _viewModel.selectedCalendarDate;
    if (selectedDate == null) return null;

    return MetroTile(
      size: MetroTileSize.wide,
      backgroundColor: MetroColors.festival, // 使用金黄色
      title: '选中日期',
      mainContent: '${selectedDate.solarDate.day}',
      subtitle: _getSelectedDateSubtitle(selectedDate, settings),
      explanation: '${selectedDate.solarDate.year}年${selectedDate.solarDate.month}月${selectedDate.solarDate.day}日，'
          '${_getWeekdayName(selectedDate.solarDate.weekday)}。'
          '${selectedDate.lunarDate != null ? '农历${selectedDate.lunarDate!.yearName ?? ""}年，${selectedDate.lunarDate!.monthName ?? "${selectedDate.lunarDate!.month}月"}${selectedDate.lunarDate!.dayName ?? "${selectedDate.lunarDate!.day}日"}。' : ''}',
    );
  }

  /// 构建单个磁贴组件
  Widget _buildSingleTileWidget(
    MetroTile tile,
    ResponsiveTileConfig config,
    DeviceType deviceType,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = config.getColumns(deviceType);
        final spacing = context.responsiveSpacing(config.spacing);
        final tileHeight = context.responsive(config.tileHeight);
        final tileWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;

        final int crossCount = tile.size.crossAxisCellCount;
        final int mainCount = tile.size.mainAxisCellCount;

        final actualCrossCount = crossCount > columns ? columns : crossCount;
        final width = tileWidth * actualCrossCount + spacing * (actualCrossCount - 1);
        final height = tileHeight * mainCount + spacing * (mainCount - 1);

        return Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: SizedBox(
            width: width,
            height: height,
            child: tile,
          ),
        );
      },
    );
  }

  /// 构建 PageView 用于历法系统磁贴组
  Widget _buildCalendarSystemPageView(
    List<CalendarSystemGroup> calendarSystems,
    ResponsiveTileConfig config,
    DeviceType deviceType,
    bool isMobile,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 历法系统指示器
            if (calendarSystems.length > 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(calendarSystems.length, (index) {
                    final isActive = index == _currentCalendarPage;
                    return GestureDetector(
                      onTap: () {
                        _calendarPageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.white.withOpacity(0.2)
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          calendarSystems[index].name,
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.white70,
                            fontSize: isMobile ? 11 : 12,
                            fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

            // PageView
            SizedBox(
              height: _calculatePageViewHeight(calendarSystems, config, deviceType, constraints),
              child: PageView.builder(
                controller: _calendarPageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentCalendarPage = index;
                  });
                },
                itemCount: calendarSystems.length,
                itemBuilder: (context, index) {
                  final system = calendarSystems[index];
                  return _buildTileGroup(system.tiles, config, deviceType);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// 计算 PageView 高度
  double _calculatePageViewHeight(
    List<CalendarSystemGroup> calendarSystems,
    ResponsiveTileConfig config,
    DeviceType deviceType,
    BoxConstraints constraints,
  ) {
    if (calendarSystems.isEmpty) return 0;

    // 找出所有系统中最大的高度
    double maxHeight = 0;
    for (final system in calendarSystems) {
      final height = _calculateTilesHeight(system.tiles, config, deviceType, constraints);
      if (height > maxHeight) maxHeight = height;
    }

    return maxHeight;
  }

  /// 计算磁贴组高度
  double _calculateTilesHeight(
    List<MetroTile> tiles,
    ResponsiveTileConfig config,
    DeviceType deviceType,
    BoxConstraints constraints,
  ) {
    final columns = config.getColumns(deviceType);
    final spacing = 4.0;
    final tileHeight = config.tileHeight.toDouble();

    double currentRowHeight = 0;
    double totalHeight = 0;
    int currentRowCrossCount = 0;

    for (final tile in tiles) {
      final crossCount = tile.size.crossAxisCellCount;
      final mainCount = tile.size.mainAxisCellCount;

      if (currentRowCrossCount + crossCount > columns) {
        // 换行
        totalHeight += currentRowHeight + spacing;
        currentRowHeight = tileHeight * mainCount;
        currentRowCrossCount = crossCount;
      } else {
        currentRowCrossCount += crossCount;
        final tileRowHeight = tileHeight * mainCount + spacing * (mainCount - 1);
        if (tileRowHeight > currentRowHeight) {
          currentRowHeight = tileRowHeight;
        }
      }
    }

    totalHeight += currentRowHeight;
    return totalHeight + spacing;
  }

  /// 构建磁贴组
  Widget _buildTileGroup(
    List<MetroTile> tiles,
    ResponsiveTileConfig config,
    DeviceType deviceType,
  ) {
    final columns = config.getColumns(deviceType);

    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = context.responsiveSpacing(config.spacing);
        final tileHeight = context.responsive(config.tileHeight);
        final tileWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: tiles.map((tile) {
            final int crossCount = tile.size.crossAxisCellCount;
            final int mainCount = tile.size.mainAxisCellCount;

            final actualCrossCount = crossCount > columns ? columns : crossCount;

            final width = tileWidth * actualCrossCount + spacing * (actualCrossCount - 1);
            final height = tileHeight * mainCount + spacing * (mainCount - 1);

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

  ResponsiveTileConfig _getTileConfig(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return const ResponsiveTileConfig(
          mobileColumns: 2,
          tabletColumns: 2,
          desktopColumns: 2,
          largeDesktopColumns: 2,
          spacing: 4,
          tileHeight: 90,
        );
      case DeviceType.tablet:
        return const ResponsiveTileConfig(
          mobileColumns: 3,
          tabletColumns: 3,
          desktopColumns: 3,
          largeDesktopColumns: 3,
          spacing: 4,
          tileHeight: 100,
        );
      case DeviceType.desktop:
        return const ResponsiveTileConfig(
          mobileColumns: 4,
          tabletColumns: 4,
          desktopColumns: 4,
          largeDesktopColumns: 4,
          spacing: 6,
          tileHeight: 100,
        );
      case DeviceType.largeDesktop:
        return const ResponsiveTileConfig(
          mobileColumns: 5,
          tabletColumns: 5,
          desktopColumns: 5,
          largeDesktopColumns: 5,
          spacing: 6,
          tileHeight: 110,
        );
    }
  }

  /// 构建日历网格磁贴（始终显示）
  MetroTile _buildCalendarGridTile(
    CalendarViewModel _viewModel,
    CalendarSettingsProvider settings,
    bool isMobile,
  ) {
    return MetroTile(
      size: MetroTileSize.large,
      backgroundColor: Colors.white, // 白色背景
      foregroundColor: const Color(0xFF5D4E37), // 深棕色文字
      title: '${_viewModel.currentMonth.year}年${_viewModel.currentMonth.month}月',
      enableFlip: false,
      child: _buildEnhancedCalendarGrid(_viewModel, settings, isMobile),
    );
  }

  /// 获取所有启用的历法系统
  List<CalendarSystemGroup> _getEnabledCalendarSystems(
    CalendarSettingsProvider settings,
    CalendarViewModel _viewModel,
    LocaleProvider locale,
    bool isMobile,
  ) {
    final systems = <CalendarSystemGroup>[];
    final selectedDate = _viewModel.selectedCalendarDate;

    // 农历系统
    if (settings.showLunarCalendar && selectedDate?.lunarDate != null) {
      systems.add(CalendarSystemGroup(
        type: CalendarType.lunar,
        name: '农历',
        tiles: _buildLunarTiles(selectedDate!, isMobile),
      ));
    }

    // 藏历系统
    if (settings.showTibetanCalendar && selectedDate?.tibetanDate != null) {
      systems.add(CalendarSystemGroup(
        type: CalendarType.tibetan,
        name: '藏历',
        tiles: _buildTibetanTiles(selectedDate!, isMobile),
      ));
    }

    // 节日磁贴（单独一组或合并到当前历法）
    if (settings.showFestivals && selectedDate?.festivals.isNotEmpty == true) {
      systems.add(CalendarSystemGroup(
        type: CalendarType.solar,
        name: '节日',
        tiles: _buildFestivalTiles(selectedDate!, isMobile),
      ));
    }

    return systems;
  }

  /// 构建农历系统磁贴
  List<MetroTile> _buildLunarTiles(CalendarDate selectedDate, bool isMobile) {
    final tiles = <MetroTile>[];
    final lunar = selectedDate.lunarDate!;

    // 农历月日磁贴
    tiles.add(MetroTile(
      size: MetroTileSize.small,
      backgroundColor: MetroColors.lunar,
      title: '农历',
      mainContent: '${lunar.month}月${lunar.day}',
      subtitle: lunar.ganZhi ?? lunar.zodiac ?? '',
      explanation: '农历${lunar.ganZhi ?? ""}年${lunar.isLeapMonth ? "闰" : ""}${lunar.monthName ?? "${lunar.month}月"}${lunar.dayName ?? "${lunar.day}日"}。'
          '${lunar.zodiac != null ? "生肖属${lunar.zodiac}。" : ""}'
          '干支纪年是中国传统历法的重要组成部分，以天干地支循环纪年。',
    ));

    // 节气磁贴
    if (selectedDate.dailyInfo?.note != null) {
      tiles.add(MetroTile(
        size: MetroTileSize.small,
        backgroundColor: MetroColors.solarTerm,
        title: '节气',
        mainContent: selectedDate.dailyInfo!.note,
        explanation: '${selectedDate.dailyInfo!.note}是二十四节气之一，'
            '标志着季节变化的重要时刻。二十四节气是中国古人根据太阳运行规律制定的补充历法，'
            '对农业生产和日常生活具有重要指导意义。',
      ));
    }

    // 宜忌磁贴
    if (selectedDate.dailyInfo != null) {
      final yiList = selectedDate.dailyInfo!.suitable;
      final jiList = selectedDate.dailyInfo!.unsuitable;
      if (yiList.isNotEmpty || jiList.isNotEmpty) {
        final yiText = yiList.take(3).join(' ');
        final jiText = jiList.take(3).join(' ');
        tiles.add(MetroTile(
          size: MetroTileSize.wide,
          backgroundColor: MetroColors.yiJi,
          title: '宜忌',
          subtitle: '宜: $yiText\n忌: $jiText',
          explanation: '宜：今日适合进行的事项，包括${yiList.join("、")}等。'
              '忌：今日应避免的事项，包括${jiList.join("、")}等。'
              '宜忌源自传统黄历推算，根据天干地支、五行生克等理论计算得出。',
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

    // 五行磁贴
    if (selectedDate.dailyInfo?.fiveElements != null) {
      tiles.add(MetroTile(
        size: MetroTileSize.small,
        backgroundColor: MetroColors.fiveElements,
        title: '五行',
        mainContent: selectedDate.dailyInfo!.fiveElements,
        explanation: '今日五行属${selectedDate.dailyInfo!.fiveElements}。'
            '五行学说是中国古代哲学的重要组成部分，认为万物由金、木、水、火、土五种基本元素构成。'
            '五行相生相克，影响着人的运势和活动。',
      ));
    }

    return tiles;
  }

  /// 构建藏历系统磁贴
  List<MetroTile> _buildTibetanTiles(CalendarDate selectedDate, bool isMobile) {
    final tiles = <MetroTile>[];
    final tibetan = selectedDate.tibetanDate!;

    // 藏历月日磁贴
    tiles.add(MetroTile(
      size: MetroTileSize.small,
      backgroundColor: MetroColors.tibetan,
      title: '藏历',
      mainContent: '${tibetan.month}月${tibetan.day}',
      subtitle: tibetan.yearElement ?? '',
      explanation: '藏历${tibetan.yearElement ?? ""}，'
          '${tibetan.monthNameChinese ?? "${tibetan.month}月"}${tibetan.dayNameChinese ?? "${tibetan.day}日"}。'
          '${tibetan.isMissingDay ? "今日为缺日。" : ""}'
          '${tibetan.isDoubleday ? "今日为重日。" : ""}'
          '藏历是基于印度时轮历的阴阳合历，融合了汉族农历和印度历法的特点。',
    ));

    return tiles;
  }

  /// 构建节日磁贴
  List<MetroTile> _buildFestivalTiles(CalendarDate selectedDate, bool isMobile) {
    final tiles = <MetroTile>[];
    final festivals = selectedDate.festivals;
    final festivalNames = festivals.take(3).map((f) => f.name).join(' · ');

    tiles.add(MetroTile(
      size: MetroTileSize.wide,
      backgroundColor: MetroColors.festival,
      title: '节日',
      subtitle: festivalNames,
      explanation: '今日是${festivals.map((f) => f.name).join("、")}。'
          '${festivals.first.description ?? "这是重要的传统节日，具有丰富的文化内涵和历史意义。"}',
    ));

    return tiles;
  }

  Widget _buildEnhancedCalendarGrid(
    CalendarViewModel _viewModel,
    CalendarSettingsProvider settings,
    bool isMobile,
  ) {
    final dates = _viewModel.monthDates;
    final now = DateTime.now();

    // 根据视图模式构建不同的内容
    switch (_currentViewMode) {
      case CalendarViewMode.month:
        return _buildMonthGrid(_viewModel, dates, now, isMobile);
      case CalendarViewMode.week:
        return _buildWeekGrid(_viewModel, isMobile);
      case CalendarViewMode.day:
        return _buildDayView(_viewModel, isMobile);
    }
  }

  Widget _buildMonthGrid(
    CalendarViewModel _viewModel,
    List<CalendarDate> dates,
    DateTime now,
    bool isMobile,
  ) {
    final weekdays = ['一', '二', '三', '四', '五', '六', '日'];

    // 计算需要的行数
    final totalCells = dates.length > 35 ? 42 : 35;
    final rows = (totalCells / 7).ceil();

    return LayoutBuilder(
      builder: (context, constraints) {
        // 计算可用高度
        final availableHeight = constraints.maxHeight;
        // 星期标题高度
        final headerHeight = isMobile ? 14.0 : 18.0;
        // 间距
        final spacing = isMobile ? 2.0 : 4.0;
        // 计算每个日期格子的高度
        final cellHeight = (availableHeight - headerHeight - spacing) / rows;
        final cellWidth = (constraints.maxWidth - 12) / 7; // 12 = padding

        return Padding(
          padding: EdgeInsets.all(isMobile ? 4 : 8),
          child: Column(
            children: [
              // 星期标题行
              SizedBox(
                height: headerHeight,
                child: Row(
                  children: weekdays.map((d) {
                    final isWeekend = d == '六' || d == '日';
                    return Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: TextStyle(
                            color: isWeekend
                                ? const Color(0xFFE74C3C).withOpacity(0.7)
                                : const Color(0xFF5D4E37).withOpacity(0.6),
                            fontSize: isMobile ? 9 : 11,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: spacing),

              // 日期网格 - 使用 Wrap 代替 GridView
              Expanded(
                child: Wrap(
                  spacing: 2,
                  runSpacing: 2,
                  children: List.generate(totalCells, (index) {
                    if (index >= dates.length) {
                      return SizedBox(
                        width: cellWidth - 2,
                        height: cellHeight - 2,
                      );
                    }

                    final date = dates[index];
                    final isToday = _isSameDay(date.solarDate, now);
                    final isSelected = _isSameDay(date.solarDate, _viewModel.selectedDate);
                    final isCurrentMonth = date.solarDate.month == _viewModel.currentMonth.month;

                    return SizedBox(
                      width: cellWidth - 2,
                      height: cellHeight - 2,
                      child: _buildDateCell(
                        date,
                        isToday,
                        isSelected,
                        isCurrentMonth,
                        isMobile,
                        _viewModel,
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateCell(
    CalendarDate date,
    bool isToday,
    bool isSelected,
    bool isCurrentMonth,
    bool isMobile,
    CalendarViewModel _viewModel,
  ) {
    final hasFestival = date.festivals.isNotEmpty;
    final hasSolarTerm = date.dailyInfo?.note != null;
    final lunarDay = date.lunarDate?.dayName ?? '';

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _viewModel.selectDate(date.solarDate);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? MetroColors.calendar.withOpacity(0.2)
              : isToday
                  ? MetroColors.calendar.withOpacity(0.1)
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
                      ? const Color(0xFF5D4E37)
                      : const Color(0xFF5D4E37).withOpacity(0.3),
                  fontSize: isMobile ? 11 : 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),

            // 农历日期
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
                        ? MetroColors.calendar
                        : const Color(0xFF5D4E37).withOpacity(0.5),
                    fontSize: isMobile ? 6 : 7,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // 节日/节气标记
            if (hasFestival || hasSolarTerm)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: isMobile ? 3 : 4,
                  height: isMobile ? 3 : 4,
                  decoration: BoxDecoration(
                    color: MetroColors.calendar,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekGrid(CalendarViewModel _viewModel, bool isMobile) {
    final selectedDate = _viewModel.selectedDate;
    final now = DateTime.now();

    // 计算当前周的日期
    final weekDates = <CalendarDate>[];
    final startOfWeek = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));

    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final calendarDate = _viewModel.pluginManager.convertWithAllPlugins(date);
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
                _viewModel.selectDate(date.solarDate);
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: isMobile ? 1 : 2),
                padding: EdgeInsets.symmetric(vertical: isMobile ? 4 : 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? MetroColors.calendar.withOpacity(0.2)
                      : isToday
                          ? MetroColors.calendar.withOpacity(0.1)
                          : const Color(0xFF5D4E37).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      weekdays[index],
                      style: TextStyle(
                        color: const Color(0xFF5D4E37).withOpacity(0.6),
                        fontSize: isMobile ? 8 : 9,
                      ),
                    ),
                    SizedBox(height: isMobile ? 2 : 4),
                    Text(
                      '${date.solarDate.day}',
                      style: TextStyle(
                        color: const Color(0xFF5D4E37),
                        fontSize: isMobile ? 16 : 20,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: isMobile ? 1 : 2),
                    Text(
                      date.lunarDate?.dayName ?? '',
                      style: TextStyle(
                        color: const Color(0xFF5D4E37).withOpacity(0.5),
                        fontSize: isMobile ? 7 : 8,
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

  Widget _buildDayView(CalendarViewModel _viewModel, bool isMobile) {
    final selectedDate = _viewModel.selectedCalendarDate;
    final now = DateTime.now();

    if (selectedDate == null) {
      return const Center(
        child: Text(
          '请选择日期',
          style: TextStyle(color: Color(0xFF5D4E37), fontWeight: FontWeight.w300),
        ),
      );
    }

    final isToday = _isSameDay(selectedDate.solarDate, now);
    final weekday = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final weekdayName = weekday[selectedDate.solarDate.weekday - 1];

    return Padding(
      padding: EdgeInsets.all(isMobile ? 6 : 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 星期
          Text(
            weekdayName,
            style: TextStyle(
              color: const Color(0xFF5D4E37).withOpacity(0.6),
              fontSize: isMobile ? 10 : 12,
            ),
          ),
          SizedBox(height: isMobile ? 4 : 6),

          // 日期大数字
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${selectedDate.solarDate.day}',
                style: TextStyle(
                  color: const Color(0xFF5D4E37),
                  fontSize: isMobile ? 36 : 48,
                  fontWeight: FontWeight.w300,
                ),
              ),
              SizedBox(width: isMobile ? 4 : 6),
              Text(
                '${selectedDate.solarDate.month}月',
                style: TextStyle(
                  color: const Color(0xFF5D4E37).withOpacity(0.7),
                  fontSize: isMobile ? 14 : 18,
                ),
              ),
            ],
          ),

          // 今天标记
          if (isToday)
            Container(
              margin: EdgeInsets.only(top: isMobile ? 2 : 4),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 6 : 10,
                vertical: isMobile ? 2 : 3,
              ),
              decoration: BoxDecoration(
                color: MetroColors.calendar,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '今天',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 9 : 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          SizedBox(height: isMobile ? 6 : 10),

          // 农历信息
          if (selectedDate.lunarDate != null)
            Text(
              '农历 ${selectedDate.lunarDate!.monthName ?? '${selectedDate.lunarDate!.month}月'}${selectedDate.lunarDate!.dayName ?? '${selectedDate.lunarDate!.day}日'}',
              style: TextStyle(
                color: const Color(0xFF5D4E37).withOpacity(0.6),
                fontSize: isMobile ? 10 : 12,
              ),
            ),

          // 节气/节日
          if (selectedDate.dailyInfo?.note != null)
            Padding(
              padding: EdgeInsets.only(top: isMobile ? 2 : 4),
              child: Text(
                selectedDate.dailyInfo!.note!,
                style: TextStyle(
                  color: MetroColors.calendar,
                  fontSize: isMobile ? 10 : 12,
                ),
              ),
            ),

          if (selectedDate.festivals.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: isMobile ? 2 : 4),
              child: Text(
                selectedDate.festivals.map((f) => f.name).join(' · '),
                style: TextStyle(
                  color: MetroColors.festival,
                  fontSize: isMobile ? 9 : 11,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  String _getWeekdayName(int weekday) {
    const names = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return names[weekday - 1];
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getSelectedDateSubtitle(CalendarDate date, CalendarSettingsProvider settings) {
    final parts = <String>[];
    parts.add('${date.solarDate.month}月${date.solarDate.day}日');

    if (settings.showLunarCalendar && date.lunarDate != null) {
      parts.add('农历${date.lunarDate!.monthName ?? '${date.lunarDate!.month}月'}${date.lunarDate!.dayName ?? '${date.lunarDate!.day}日'}');
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
