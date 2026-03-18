import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/calendar_theme.dart';
import '../../../core/utils/responsive_helper.dart';
import 'tile_flip_animation.dart';

/// 信息磁贴类型
enum InfoTileType {
  /// 节气
  solarTerm,
  
  /// 宜忌
  yiJi,
  
  /// 冲煞
  chongSha,
  
  /// 五行纳音
  fiveElements,
  
  /// 彭祖百忌
  pengzu,
  
  /// 胎神方位
  fetusGod,
  
  /// 节日
  festival,
  
  /// 殊胜日
  specialDay,
  
  /// 缺日/重日标记
  dateMark,
  
  /// 藏历信息
  tibetanInfo,
  
  /// 农历信息
  lunarInfo,
}

/// 信息磁贴配置
class InfoTileConfig {
  final String title;
  final String icon;
  final Color color;
  final Color backgroundColor;
  
  const InfoTileConfig({
    required this.title,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });
  
  /// 根据类型获取配置
  factory InfoTileConfig.fromType(InfoTileType type, CalendarTheme theme) {
    switch (type) {
      case InfoTileType.solarTerm:
        return InfoTileConfig(
          title: '节气',
          icon: '☀️',
          color: const Color(0xFF059669),
          backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
        );
      case InfoTileType.yiJi:
        return InfoTileConfig(
          title: '宜忌',
          icon: '📋',
          color: const Color(0xFF10B981),
          backgroundColor: const Color(0xFF10B981).withOpacity(0.08),
        );
      case InfoTileType.chongSha:
        return InfoTileConfig(
          title: '冲煞',
          icon: '⚠️',
          color: const Color(0xFFDC2626),
          backgroundColor: const Color(0xFFEF4444).withOpacity(0.1),
        );
      case InfoTileType.fiveElements:
        return InfoTileConfig(
          title: '五行',
          icon: '✨',
          color: const Color(0xFF7C3AED),
          backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.1),
        );
      case InfoTileType.pengzu:
        return InfoTileConfig(
          title: '彭祖百忌',
          icon: '📖',
          color: const Color(0xFFD97706),
          backgroundColor: const Color(0xFFF59E0B).withOpacity(0.08),
        );
      case InfoTileType.fetusGod:
        return InfoTileConfig(
          title: '胎神',
          icon: '👶',
          color: const Color(0xFFDB2777),
          backgroundColor: const Color(0xFFEC4899).withOpacity(0.08),
        );
      case InfoTileType.festival:
        return InfoTileConfig(
          title: '节日',
          icon: '🎉',
          color: theme.festival,
          backgroundColor: theme.festival.withOpacity(0.1),
        );
      case InfoTileType.specialDay:
        return InfoTileConfig(
          title: '殊胜日',
          icon: '⭐',
          color: theme.specialDay,
          backgroundColor: theme.specialDay.withOpacity(0.12),
        );
      case InfoTileType.dateMark:
        return InfoTileConfig(
          title: '日期标记',
          icon: '📌',
          color: const Color(0xFFEF4444),
          backgroundColor: const Color(0xFFEF4444).withOpacity(0.08),
        );
      case InfoTileType.tibetanInfo:
        return InfoTileConfig(
          title: '藏历',
          icon: '🏔️',
          color: theme.specialDay,
          backgroundColor: theme.specialDay.withOpacity(0.06),
        );
      case InfoTileType.lunarInfo:
        return InfoTileConfig(
          title: '农历',
          icon: '🌸',
          color: theme.festival,
          backgroundColor: theme.festival.withOpacity(0.06),
        );
    }
  }
}

/// 信息磁贴 - 可翻转的磁贴组件
///
/// 正面显示原始内容，背面显示释义说明
class InfoTile extends StatefulWidget {
  /// 磁贴类型
  final InfoTileType type;
  
  /// 主要内容（正面）
  final String content;
  
  /// 释义说明（背面）
  final String? explanation;
  
  /// 主题
  final CalendarTheme theme;
  
  /// 是否启用翻转
  final bool enableFlip;
  
  /// 自定义背景色
  final Color? backgroundColor;
  
  /// 自定义前景色
  final Color? foregroundColor;
  
  /// 附加内容（如节日名称列表）
  final List<String>? additionalContent;
  
  /// 是否紧凑模式
  final bool compact;
  
  const InfoTile({
    super.key,
    required this.type,
    required this.content,
    this.explanation,
    required this.theme,
    this.enableFlip = true,
    this.backgroundColor,
    this.foregroundColor,
    this.additionalContent,
    this.compact = false,
  });
  
  @override
  State<InfoTile> createState() => _InfoTileState();
}

class _InfoTileState extends State<InfoTile> {
  bool _showFront = true;

  void _toggle() {
    if (!widget.enableFlip || widget.explanation == null) return;
    HapticFeedback.lightImpact();
    setState(() {
      _showFront = !_showFront;
    });
  }

  void _handleLongPress() {
    if (!widget.enableFlip || widget.explanation == null) return;
    HapticFeedback.heavyImpact();
    setState(() {
      _showFront = !_showFront;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final scale = context.scale;
    final config = InfoTileConfig.fromType(widget.type, widget.theme);
    final bgColor = widget.backgroundColor ?? config.backgroundColor;
    final fgColor = widget.foregroundColor ?? config.color;
    
    return GestureDetector(
      onTap: _toggle,
      onLongPress: _handleLongPress,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey(_showFront),
          padding: EdgeInsets.all(widget.compact ? 10 * scale : 14 * scale),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(widget.compact ? 10 * scale : 12 * scale),
            border: Border.all(color: fgColor.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: fgColor.withOpacity(0.08),
                blurRadius: 8 * scale,
                offset: Offset(0, 2 * scale),
              ),
            ],
          ),
          child: _showFront ? _buildFront(config, fgColor, scale) : _buildBack(config, fgColor, scale),
        ),
      ),
    );
  }
  
  /// 构建正面（原始内容）
  Widget _buildFront(InfoTileConfig config, Color fgColor, double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 标题行
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(widget.compact ? 4 * scale : 6 * scale),
              decoration: BoxDecoration(
                color: fgColor,
                borderRadius: BorderRadius.circular(widget.compact ? 6 * scale : 8 * scale),
              ),
              child: Text(
                config.icon,
                style: TextStyle(fontSize: widget.compact ? 12 * scale : 14 * scale),
              ),
            ),
            SizedBox(width: 8 * scale),
            Text(
              config.title,
              style: TextStyle(
                fontSize: context.responsiveFontSize(widget.compact ? 11 : 12),
                fontWeight: FontWeight.w600,
                color: fgColor,
              ),
            ),
            if (widget.enableFlip && widget.explanation != null) ...[
              const Spacer(),
              Icon(
                Icons.flip,
                size: widget.compact ? 12 * scale : 14 * scale,
                color: fgColor.withOpacity(0.5),
              ),
            ],
          ],
        ),
        
        SizedBox(height: widget.compact ? 6 * scale : 10 * scale),
        
        // 主要内容
        Text(
          widget.content,
          style: TextStyle(
            fontSize: context.responsiveFontSize(widget.compact ? 12 : 14),
            fontWeight: FontWeight.w500,
            color: widget.theme.textPrimary,
            height: 1.4,
          ),
        ),
        
        // 附加内容
        if (widget.additionalContent != null && widget.additionalContent!.isNotEmpty) ...[
          SizedBox(height: 6 * scale),
          Wrap(
            spacing: 4 * scale,
            runSpacing: 4 * scale,
            children: widget.additionalContent!.map((item) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 6 * scale,
                  vertical: 2 * scale,
                ),
                decoration: BoxDecoration(
                  color: fgColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4 * scale),
                ),
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(10),
                    color: fgColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
  
  /// 构建背面（释义说明）
  Widget _buildBack(InfoTileConfig config, Color fgColor, double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 标题行
        Row(
          children: [
            Icon(
              Icons.info_outline,
              size: widget.compact ? 12 * scale : 14 * scale,
              color: fgColor,
            ),
            SizedBox(width: 6 * scale),
            Text(
              '释义',
              style: TextStyle(
                fontSize: context.responsiveFontSize(widget.compact ? 11 : 12),
                fontWeight: FontWeight.w600,
                color: fgColor,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.flip,
              size: widget.compact ? 12 * scale : 14 * scale,
              color: fgColor.withOpacity(0.5),
            ),
          ],
        ),
        
        SizedBox(height: widget.compact ? 6 * scale : 10 * scale),
        
        // 释义内容
        Text(
          widget.explanation ?? '',
          style: TextStyle(
            fontSize: context.responsiveFontSize(widget.compact ? 11 : 12),
            color: widget.theme.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

/// 磁贴网格布局
class InfoTileGrid extends StatelessWidget {
  /// 磁贴列表
  final List<Widget> tiles;
  
  /// 每行磁贴数量（移动端）
  final int crossAxisCountMobile;
  
  /// 每行磁贴数量（平板）
  final int crossAxisCountTablet;
  
  /// 间距
  final double spacing;
  
  const InfoTileGrid({
    super.key,
    required this.tiles,
    this.crossAxisCountMobile = 1,
    this.crossAxisCountTablet = 2,
    this.spacing = 12,
  });
  
  @override
  Widget build(BuildContext context) {
    final scale = context.scale;
    final deviceType = ResponsiveHelper.getDeviceType(context);
    final crossAxisCount = deviceType == DeviceType.mobile
        ? crossAxisCountMobile
        : crossAxisCountTablet;
    
    if (tiles.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      children: _buildRows(context, crossAxisCount, scale),
    );
  }
  
  List<Widget> _buildRows(BuildContext context, int crossAxisCount, double scale) {
    final rows = <Widget>[];
    
    for (var i = 0; i < tiles.length; i += crossAxisCount) {
      final rowTiles = <Widget>[];
      
      for (var j = 0; j < crossAxisCount && i + j < tiles.length; j++) {
        rowTiles.add(
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: j < crossAxisCount - 1 ? spacing * scale : 0,
              ),
              child: tiles[i + j],
            ),
          ),
        );
      }
      
      rows.add(
        Padding(
          padding: EdgeInsets.only(
            bottom: i + crossAxisCount < tiles.length ? spacing * scale : 0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rowTiles,
          ),
        ),
      );
    }
    
    return rows;
  }
}
