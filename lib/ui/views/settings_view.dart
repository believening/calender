import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/providers/calendar_settings_provider.dart';
import '../../models/calendar_models.dart';

/// 设置页面
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1F2937),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('语言设置'),
            _buildLanguageSection(context),
            const SizedBox(height: 24),
            _buildSectionTitle('历法设置'),
            _buildCalendarSection(context),
            const SizedBox(height: 24),
            _buildSectionTitle('插件管理'),
            _buildPluginsSection(context),
            const SizedBox(height: 24),
            _buildSectionTitle('关于'),
            _buildAboutSection(context),
          ],
        ),
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

  Widget _buildLanguageSection(BuildContext context) {
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
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) => Column(
          children: LocaleProvider.supportedLocales.map((locale) {
            final code = '${locale.languageCode}_${locale.countryCode}';
            final name = LocaleProvider.languageNames[code] ?? '';
            final isSelected = localeProvider.locale == locale;
            
            return _buildLanguageItem(
              context,
              name,
              locale.languageCode,
              isSelected,
              () => localeProvider.setLocale(locale),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLanguageItem(
    BuildContext context,
    String name,
    String code,
    bool isSelected,
    VoidCallback onTap,
  ) {
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
            _getLanguageFlag(code),
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
      onTap: onTap,
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

  Widget _buildCalendarSection(BuildContext context) {
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
      child: Consumer<CalendarSettingsProvider>(
        builder: (context, settings, _) => Column(
          children: [
            // 主历法选择
            _buildPrimaryCalendarSelector(context, settings),
            _buildDivider(),
            _buildSettingTile(
              Icons.water_drop,
              '显示农历',
              settings.showLunarCalendar,
              settings.toggleLunarCalendar,
            ),
            _buildDivider(),
            _buildSettingTile(
              Icons.star,
              '显示藏历',
              settings.showTibetanCalendar,
              settings.toggleTibetanCalendar,
            ),
            _buildDivider(),
            _buildSettingTile(
              Icons.celebration,
              '显示节日',
              settings.showFestivals,
              settings.toggleFestivals,
            ),
            _buildDivider(),
            _buildSettingTile(
              Icons.auto_awesome,
              '显示宜忌',
              settings.showDailyInfo,
              settings.toggleDailyInfo,
            ),
          ],
        ),
      ),
    );
  }

  /// 主历法选择器
  Widget _buildPrimaryCalendarSelector(BuildContext context, CalendarSettingsProvider settings) {
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

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 68, endIndent: 16);
  }

  Widget _buildPluginsSection(BuildContext context) {
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
            'LunarCalendarPlugin',
            '2.0.0',
            true,
            Icons.water_drop,
            const Color(0xFF10B981),
          ),
          _buildDivider(),
          _buildPluginTile(
            '藏历插件',
            'TibetanCalendarPlugin',
            '2.0.0',
            true,
            Icons.star,
            const Color(0xFFFF8F00),
          ),
        ],
      ),
    );
  }

  Widget _buildPluginTile(
    String name,
    String id,
    String version,
    bool isEnabled,
    IconData icon,
    Color color,
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
        'v$version',
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
    );
  }

  Widget _buildAboutSection(BuildContext context) {
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
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.info_outline, color: Color(0xFF6B5B95)),
            ),
            title: const Text('版本', style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: const Text('1.0.0'),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {},
          ),
          _buildDivider(),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.code, color: Color(0xFF6B5B95)),
            ),
            title: const Text('开源许可', style: TextStyle(fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {},
          ),
          _buildDivider(),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.favorite, color: Color(0xFFEF5350)),
            ),
            title: const Text('关于项目', style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: const Text('民族文化传承'),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.calendar_month, color: Color(0xFF6B5B95)),
            SizedBox(width: 10),
            Text('多民族日历'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '一款支持多种民族历法的跨平台日历应用，致力于服务关心自己民族历法的群体，助力民族文化传承。',
              style: TextStyle(height: 1.6),
            ),
            SizedBox(height: 16),
            Text('功能特点：', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('• 支持公历、农历、藏历'),
            Text('• 插件化架构，按需加载历法'),
            Text('• 多语言支持（中文、藏文、英文）'),
            Text('• 跨平台（Android、iOS、Web、Desktop）'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
