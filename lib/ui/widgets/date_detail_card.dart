import 'package:flutter/material.dart';
import '../../core/theme/calendar_theme.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/providers/calendar_settings_provider.dart';
import '../../models/calendar_models.dart';

/// 选中日期详情卡片 - 次级卡片
///
/// 职责：
/// - 展示选中日期的详细信息（日级别）
/// - 根据历法类型显示不同的特殊内容：
///   - 节日（共有）
///   - 节气（农历独有）
///   - 殊胜日（藏历独有）
///   - 宜忌（农历独有）
class DateDetailCard extends StatelessWidget {
  final CalendarDate date;
  final CalendarSettingsProvider settings;
  final CalendarTheme theme;

  const DateDetailCard({
    super.key,
    required this.date,
    required this.settings,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.scale;
    final solarDate = date.solarDate;
    final lunarDate = date.lunarDate;
    final tibetanDate = date.tibetanDate;
    final dailyInfo = date.dailyInfo;

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
          // === 日期头部 ===
          _buildDateHeader(context, solarDate, scale),

          // === 历法信息 ===
          if (lunarDate != null || tibetanDate != null)
            _buildCalendarSection(context, lunarDate, tibetanDate, scale),

          // === 节气（农历独有）===
          if (settings.showLunarCalendar && lunarDate?.solarTerm != null)
            _buildSolarTermSection(context, lunarDate!.solarTerm!, scale),

          // === 节日（共有）===
          if (settings.showFestivals && date.festivals.isNotEmpty)
            _buildFestivalsSection(context, scale),

          // === 殊胜日（藏历独有）===
          if (settings.showTibetanCalendar && _isSpecialDay(tibetanDate))
            _buildSpecialDaySection(context, tibetanDate!, scale),

          // === 宜忌（农历独有）===
          if (settings.showLunarCalendar && settings.showDailyInfo && dailyInfo != null)
            _buildDailyInfoSection(context, dailyInfo, scale),
        ],
      ),
    );
  }

  /// 日期头部
  Widget _buildDateHeader(BuildContext context, DateTime solarDate, double scale) {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];

    return Container(
      padding: EdgeInsets.all(context.responsiveSpacing(20)),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.04),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20 * scale)),
      ),
      child: Row(
        children: [
          // 大日期数字
          Container(
            width: 56 * scale,
            height: 56 * scale,
            decoration: BoxDecoration(
              gradient: theme.primaryGradient,
              borderRadius: BorderRadius.circular(16 * scale),
            ),
            child: Center(
              child: Text(
                '${solarDate.day}',
                style: TextStyle(
                  fontSize: context.responsiveFontSize(28),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 16 * scale),

          // 日期信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${solarDate.month}月',
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(20),
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  '星期${weekdays[solarDate.weekday - 1]}',
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(14),
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 历法信息区域
  Widget _buildCalendarSection(
    BuildContext context,
    LunarDate? lunarDate,
    TibetanDate? tibetanDate,
    double scale,
  ) {
    return Container(
      padding: EdgeInsets.all(context.responsiveSpacing(16)),
      child: Column(
        children: [
          // 农历
          if (settings.showLunarCalendar && lunarDate != null)
            _buildCalendarRow(
              context,
              '农历',
              '${lunarDate.monthName}${lunarDate.dayName}',
              theme.festival,
              scale,
              isLeapMonth: lunarDate.isLeapMonth,
            ),

          // 藏历
          if (settings.showTibetanCalendar && tibetanDate != null)
            _buildCalendarRow(
              context,
              '藏历',
              '${tibetanDate.month}月${tibetanDate.day}日',
              theme.specialDay,
              scale,
            ),
        ],
      ),
    );
  }

  Widget _buildCalendarRow(
    BuildContext context,
    String label,
    String dateText,
    Color color,
    double scale, {
    bool isLeapMonth = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8 * scale),
      padding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
        vertical: 10 * scale,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: context.responsiveFontSize(13),
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Text(
              dateText,
              style: TextStyle(
                fontSize: context.responsiveFontSize(15),
                fontWeight: FontWeight.w500,
                color: theme.textPrimary,
              ),
            ),
          ),
          if (isLeapMonth)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8 * scale,
                vertical: 2 * scale,
              ),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(6 * scale),
              ),
              child: Text(
                '闰',
                style: TextStyle(
                  fontSize: context.responsiveFontSize(11),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 节气区域（农历独有）
  Widget _buildSolarTermSection(BuildContext context, String solarTerm, double scale) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        context.responsiveSpacing(16),
        0,
        context.responsiveSpacing(16),
        context.responsiveSpacing(16),
      ),
      padding: EdgeInsets.all(context.responsiveSpacing(14)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981).withOpacity(0.1),
            const Color(0xFF059669).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8 * scale),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(8 * scale),
            ),
            child: Icon(
              Icons.wb_sunny,
              color: Colors.white,
              size: 18 * scale,
            ),
          ),
          SizedBox(width: 12 * scale),
          Text(
            solarTerm,
            style: TextStyle(
              fontSize: context.responsiveFontSize(16),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF059669),
            ),
          ),
          SizedBox(width: 8 * scale),
          Text(
            '节气',
            style: TextStyle(
              fontSize: context.responsiveFontSize(12),
              color: const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  /// 节日区域（共有）
  Widget _buildFestivalsSection(BuildContext context, double scale) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        context.responsiveSpacing(16),
        0,
        context.responsiveSpacing(16),
        context.responsiveSpacing(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8 * scale,
            runSpacing: 8 * scale,
            children: date.festivals.map((festival) {
              final isBuddhist = festival.type == FestivalType.buddhist;
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14 * scale,
                  vertical: 8 * scale,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isBuddhist
                        ? [const Color(0xFFFFB300), theme.specialDay]
                        : [theme.festival, const Color(0xFFDC2626)],
                  ),
                  borderRadius: BorderRadius.circular(12 * scale),
                  boxShadow: [
                    BoxShadow(
                      color: (isBuddhist ? theme.specialDay : theme.festival)
                          .withOpacity(0.3),
                      blurRadius: 6 * scale,
                      offset: Offset(0, 2 * scale),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (festival.nameTibetan != null) ...[
                      Text(
                        festival.nameTibetan!,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: context.responsiveFontSize(11),
                        ),
                      ),
                      SizedBox(width: 6 * scale),
                    ],
                    Text(
                      festival.name,
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

  /// 殊胜日区域（藏历独有）
  Widget _buildSpecialDaySection(BuildContext context, TibetanDate tibetanDate, double scale) {
    final specialDayName = _getSpecialDayName(tibetanDate.day);
    if (specialDayName == null) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.fromLTRB(
        context.responsiveSpacing(16),
        0,
        context.responsiveSpacing(16),
        context.responsiveSpacing(16),
      ),
      padding: EdgeInsets.all(context.responsiveSpacing(14)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.specialDay.withOpacity(0.12),
            const Color(0xFFFFB300).withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: theme.specialDay.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8 * scale),
            decoration: BoxDecoration(
              color: theme.specialDay,
              borderRadius: BorderRadius.circular(8 * scale),
            ),
            child: Icon(
              Icons.star,
              color: Colors.white,
              size: 18 * scale,
            ),
          ),
          SizedBox(width: 12 * scale),
          Text(
            specialDayName,
            style: TextStyle(
              fontSize: context.responsiveFontSize(15),
              fontWeight: FontWeight.bold,
              color: theme.specialDay,
            ),
          ),
          SizedBox(width: 8 * scale),
          Text(
            '殊胜日',
            style: TextStyle(
              fontSize: context.responsiveFontSize(12),
              color: const Color(0xFFFFB300),
            ),
          ),
        ],
      ),
    );
  }

  /// 宜忌区域（农历独有）
  Widget _buildDailyInfoSection(BuildContext context, DailyInfo info, double scale) {
    final hasYi = info.suitable.isNotEmpty;
    final hasJi = info.unsuitable.isNotEmpty;

    if (!hasYi && !hasJi) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.fromLTRB(
        context.responsiveSpacing(16),
        0,
        context.responsiveSpacing(16),
        context.responsiveSpacing(16),
      ),
      child: Column(
        children: [
          // 宜
          if (hasYi)
            _buildYiJiRow(
              context,
              '宜',
              info.suitable,
              const Color(0xFF10B981),
              scale,
            ),

          if (hasYi && hasJi) SizedBox(height: 10 * scale),

          // 忌
          if (hasJi)
            _buildYiJiRow(
              context,
              '忌',
              info.unsuitable,
              theme.festival,
              scale,
            ),
        ],
      ),
    );
  }

  Widget _buildYiJiRow(
    BuildContext context,
    String label,
    List<String> items,
    Color color,
    double scale,
  ) {
    return Container(
      padding: EdgeInsets.all(context.responsiveSpacing(12)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: color.withOpacity(0.15)),
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
              color: color,
              borderRadius: BorderRadius.circular(6 * scale),
            ),
            child: Text(
              label,
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
              items.join(' · '),
              style: TextStyle(
                color: color.withOpacity(0.9),
                fontSize: context.responsiveFontSize(13),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 检查是否是殊胜日
  bool _isSpecialDay(TibetanDate? tibetanDate) {
    if (tibetanDate == null) return false;
    return tibetanDate.day == 1 ||
           tibetanDate.day == 8 ||
           tibetanDate.day == 10 ||
           tibetanDate.day == 15 ||
           tibetanDate.day == 25 ||
           tibetanDate.day == 30;
  }

  /// 获取殊胜日名称
  String? _getSpecialDayName(int day) {
    switch (day) {
      case 1: return '吉祥日';
      case 8: return '药师佛节日';
      case 10: return '莲师荟供日';
      case 15: return '佛陀节日';
      case 25: return '空行母荟供日';
      case 30: return '释迦牟尼佛节日';
      default: return null;
    }
  }
}
