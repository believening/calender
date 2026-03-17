import 'package:flutter/material.dart';
import '../../models/calendar_models.dart';
import '../../core/theme/calendar_theme.dart';
import '../../core/utils/responsive_helper.dart';

/// 紧凑日期卡片 - 统一信息展示
///
/// 设计原则：
/// - 高信息密度，一屏看完
/// - 无冗余重复
/// - 清晰的视觉层次
class CompactDateCard extends StatelessWidget {
  final CalendarDate date;
  final CalendarTheme theme;
  final bool showLunar;
  final bool showTibetan;
  final bool showFestivals;
  final bool showDailyInfo;

  const CompactDateCard({
    super.key,
    required this.date,
    required this.theme,
    this.showLunar = true,
    this.showTibetan = true,
    this.showFestivals = true,
    this.showDailyInfo = true,
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
          // === 头部：公历 + 年份 ===
          _buildHeader(context, solarDate, lunarDate, scale),

          // === 历法信息行 ===
          if (showLunar || showTibetan)
            _buildCalendarRow(context, lunarDate, tibetanDate, scale),

          // === 节日区域 ===
          if (showFestivals && date.festivals.isNotEmpty)
            _buildFestivalsSection(context, scale),

          // === 宜忌区域 ===
          if (showDailyInfo && dailyInfo != null)
            _buildDailyInfoSection(context, dailyInfo, scale),
        ],
      ),
    );
  }

  /// 头部：公历日期 + 生肖 + 年份
  Widget _buildHeader(
    BuildContext context,
    DateTime solarDate,
    LunarDate? lunarDate,
    double scale,
  ) {
    final zodiac = lunarDate?.zodiac;
    final yearName = lunarDate?.yearName;
    final ganZhi = lunarDate?.ganZhi;

    return Container(
      padding: EdgeInsets.all(context.responsiveSpacing(20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor.withOpacity(0.06),
            theme.secondaryColor.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20 * scale)),
      ),
      child: Row(
        children: [
          // 生肖图标
          if (zodiac != null)
            Container(
              width: 56 * scale,
              height: 56 * scale,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.primaryColor.withOpacity(0.2),
                    theme.secondaryColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16 * scale),
              ),
              child: Center(
                child: Text(
                  _getZodiacEmoji(zodiac),
                  style: TextStyle(fontSize: 28 * scale),
                ),
              ),
            ),
          SizedBox(width: 16 * scale),

          // 日期和年份信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 公历日期 + 星期
                Text(
                  '${solarDate.month}月${solarDate.day}日  星期${_getWeekday(solarDate.weekday)}',
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(20),
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 6 * scale),

                // 年份信息（天干地支 + 生肖年）
                if (yearName != null || ganZhi != null)
                  Text(
                    [ganZhi, yearName].where((s) => s != null).join(' · '),
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(14),
                      color: theme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 历法信息行：农历 + 藏历
  Widget _buildCalendarRow(
    BuildContext context,
    LunarDate? lunarDate,
    TibetanDate? tibetanDate,
    double scale,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveSpacing(20),
        vertical: context.responsiveSpacing(14),
      ),
      child: Row(
        children: [
          // 农历
          if (showLunar && lunarDate != null) ...[
            _buildCalendarChip(
              context,
              '🌸',
              '${lunarDate.monthName}${lunarDate.dayName}',
              theme.festival,
              scale,
            ),
            if (lunarDate.isLeapMonth)
              Padding(
                padding: EdgeInsets.only(left: 6 * scale),
                child: _buildCalendarChip(
                  context,
                  '⚡',
                  '闰',
                  Colors.orange,
                  scale,
                  small: true,
                ),
              ),
          ],

          // 间隔
          if (showLunar && lunarDate != null && showTibetan && tibetanDate != null)
            SizedBox(width: 12 * scale),

          // 藏历
          if (showTibetan && tibetanDate != null)
            _buildCalendarChip(
              context,
              '🏔️',
              '藏历${tibetanDate.month}月${tibetanDate.day}日',
              theme.specialDay,
              scale,
            ),
        ],
      ),
    );
  }

  /// 历法信息小标签
  Widget _buildCalendarChip(
    BuildContext context,
    String emoji,
    String text,
    Color color,
    double scale, {
    bool small = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (small ? 8 : 12) * scale,
        vertical: (small ? 4 : 7) * scale,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: (small ? 12 : 14) * scale)),
          SizedBox(width: 6 * scale),
          Text(
            text,
            style: TextStyle(
              fontSize: context.responsiveFontSize(small ? 11 : 13),
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// 节日区域
  Widget _buildFestivalsSection(BuildContext context, double scale) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        context.responsiveSpacing(20),
        context.responsiveSpacing(8),
        context.responsiveSpacing(20),
        context.responsiveSpacing(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 节日标签（横向滚动）
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

  /// 宜忌区域
  Widget _buildDailyInfoSection(BuildContext context, DailyInfo info, double scale) {
    final hasYi = info.suitable.isNotEmpty;
    final hasJi = info.unsuitable.isNotEmpty;

    if (!hasYi && !hasJi) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.fromLTRB(
        context.responsiveSpacing(20),
        0,
        context.responsiveSpacing(20),
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

  /// 宜忌行
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
        border: Border.all(
          color: color.withOpacity(0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标签
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

          // 内容
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

  String _getWeekday(int weekday) {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return weekdays[weekday - 1];
  }

  String _getZodiacEmoji(String? zodiac) {
    switch (zodiac) {
      case '鼠': return '🐭';
      case '牛': return '🐮';
      case '虎': return '🐯';
      case '兔': return '🐰';
      case '龙': return '🐲';
      case '蛇': return '🐍';
      case '马': return '🐴';
      case '羊': return '🐑';
      case '猴': return '🐵';
      case '鸡': return '🐔';
      case '狗': return '🐶';
      case '猪': return '🐷';
      default: return '📅';
    }
  }
}
