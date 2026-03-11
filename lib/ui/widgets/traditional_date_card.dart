import 'package:flutter/material.dart';
import '../../models/calendar_models.dart';
import '../../core/theme/calendar_theme.dart';
import '../../core/utils/responsive_helper.dart';

/// 传统历法信息卡片
///
/// 展示农历/藏历的传统文化元素：
/// - 生肖图标
/// - 天干地支
/// - 传统装饰边框
class TraditionalDateCard extends StatelessWidget {
  final CalendarDate date;
  final CalendarTheme theme;

  const TraditionalDateCard({
    super.key,
    required this.date,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.scale;
    final lunarDate = date.lunarDate;

    if (lunarDate == null) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: context.responsiveSpacing(16)),
      padding: EdgeInsets.all(context.responsiveSpacing(16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor.withOpacity(0.05),
            theme.secondaryColor.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 生肖和天干地支
          Row(
            children: [
              _buildZodiacIcon(context, lunarDate.zodiac),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (lunarDate.yearName != null)
                      Text(
                        lunarDate.yearName!,
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(16),
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
                        ),
                      ),
                    if (lunarDate.ganZhi != null)
                      Padding(
                        padding: EdgeInsets.only(top: 4 * scale),
                        child: Text(
                          lunarDate.ganZhi!,
                          style: TextStyle(
                            fontSize: context.responsiveFontSize(12),
                            color: theme.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // 生肖文字
              if (lunarDate.zodiac != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12 * scale,
                    vertical: 6 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8 * scale),
                  ),
                  child: Text(
                    lunarDate.zodiac!,
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(14),
                      fontWeight: FontWeight.w600,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
            ],
          ),

          // 分隔线
          if (lunarDate.yearName != null)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12 * scale),
              child: Divider(
                color: theme.textHint.withOpacity(0.1),
                height: 1,
              ),
            ),

          // 农历日期详情
          Row(
            children: [
              _buildInfoChip(
                context,
                '🌸',
                lunarDate.monthName ?? '${lunarDate.month}月',
                theme,
              ),
              SizedBox(width: 8 * scale),
              _buildInfoChip(
                context,
                '🌙',
                lunarDate.dayName ?? '${lunarDate.day}日',
                theme,
              ),
              if (lunarDate.isLeapMonth) ...[
                SizedBox(width: 8 * scale),
                _buildInfoChip(
                  context,
                  '⚡',
                  '闰月',
                  theme,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildZodiacIcon(BuildContext context, String? zodiac) {
    final scale = context.scale;
    final zodiacEmoji = _getZodiacEmoji(zodiac);

    return Container(
      width: 48 * scale,
      height: 48 * scale,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor.withOpacity(0.15),
            theme.secondaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12 * scale),
      ),
      child: Center(
        child: Text(
          zodiacEmoji,
          style: TextStyle(fontSize: 24 * scale),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String emoji, String text, CalendarTheme theme) {
    final scale = context.scale;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10 * scale,
        vertical: 6 * scale,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8 * scale),
        border: Border.all(
          color: theme.textHint.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: 14 * scale)),
          SizedBox(width: 6 * scale),
          Text(
            text,
            style: TextStyle(
              fontSize: context.responsiveFontSize(13),
              fontWeight: FontWeight.w500,
              color: theme.textPrimary,
            ),
          ),
        ],
      ),
    );
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
