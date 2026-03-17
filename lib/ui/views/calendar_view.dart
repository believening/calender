import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/calendar_view_model.dart';
import '../../models/calendar_models.dart';
import '../../core/providers/calendar_settings_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/theme/calendar_theme.dart';
import '../widgets/calendar_grid_card.dart';
import '../widgets/date_detail_card.dart';

/// 日历主视图
///
/// 设计原则：
/// - 两个主要卡片：日历网格卡片（主）+ 选中日期详情卡片（次）
/// - 主次分明，信息层级清晰
/// - 日历网格展示年/月级别信息（纪年、生肖）
/// - 详情卡片展示日级别信息（节日、节气、宜忌等）
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
                      _buildAppBar(context, theme),
                      SliverToBoxAdapter(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          transform: Matrix4.translationValues(_dragOffset * 0.3, 0, 0),
                          child: FadeTransition(
                            opacity: _animationController,
                            child: Column(
                              children: [
                                // === 主卡片：日历网格 ===
                                CalendarGridCard(
                                  currentMonth: vm.currentMonth,
                                  monthDates: vm.monthDates,
                                  selectedDate: vm.selectedDate,
                                  settings: settings,
                                  theme: theme,
                                  onPreviousMonth: vm.previousMonth,
                                  onNextMonth: vm.nextMonth,
                                  onDateSelected: vm.selectDate,
                                  getDateCellText: vm.getDateCellText,
                                  isToday: vm.isToday,
                                  isSelected: vm.isSelected,
                                  isCurrentMonth: vm.isCurrentMonth,
                                ),

                                SizedBox(height: context.responsiveSpacing(16)),

                                // === 次级卡片：选中日期详情 ===
                                if (vm.selectedCalendarDate != null)
                                  DateDetailCard(
                                    date: vm.selectedCalendarDate!,
                                    settings: settings,
                                    theme: theme,
                                  ),

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

  Widget _buildAppBar(BuildContext context, CalendarTheme theme) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: const SizedBox.shrink(),
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

  Widget _buildTodayFab(CalendarTheme theme) {
    return Consumer<CalendarViewModel>(
      builder: (context, vm, _) => FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.mediumImpact();
          vm.goToToday();
        },
        backgroundColor: theme.primaryColor,
        elevation: 6,
        highlightElevation: 10,
        icon: const Icon(Icons.today_rounded, color: Colors.white),
        label: const Text(
          '今天',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
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
