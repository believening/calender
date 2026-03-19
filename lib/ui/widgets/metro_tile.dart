import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Metro 磁贴尺寸
enum MetroTileSize {
  /// 小磁贴 (1x1)
  small,
  /// 中磁贴 (2x1 宽)
  wide,
  /// 大磁贴 (2x2)
  large,
  /// 超大磁贴 (4x2)
  extraLarge,
}

/// Metro 磁贴扩展方法
extension MetroTileSizeExtension on MetroTileSize {
  int get crossAxisCellCount {
    switch (this) {
      case MetroTileSize.small:
        return 1;
      case MetroTileSize.wide:
        return 2;
      case MetroTileSize.large:
        return 2;
      case MetroTileSize.extraLarge:
        return 4;
    }
  }

  int get mainAxisCellCount {
    switch (this) {
      case MetroTileSize.small:
        return 1;
      case MetroTileSize.wide:
        return 1;
      case MetroTileSize.large:
        return 2;
      case MetroTileSize.extraLarge:
        return 2;
    }
  }

  String get displayName {
    switch (this) {
      case MetroTileSize.small:
        return '小';
      case MetroTileSize.wide:
        return '宽';
      case MetroTileSize.large:
        return '大';
      case MetroTileSize.extraLarge:
        return '超大';
    }
  }
}

/// Windows 8 Metro 风格磁贴
class MetroTile extends StatefulWidget {
  /// 磁贴尺寸
  final MetroTileSize size;

  /// 背景颜色
  final Color backgroundColor;

  /// 前景颜色（文字、图标）
  final Color foregroundColor;

  /// 标题
  final String? title;

  /// 副标题
  final String? subtitle;

  /// 主内容（大数字或图标）
  final String? mainContent;

  /// 释义（翻转后显示）
  final String? explanation;

  /// 图标
  final IconData? icon;

  /// 自定义内容
  final Widget? child;

  /// 是否启用翻转
  final bool enableFlip;

  /// 点击回调
  final VoidCallback? onTap;

  const MetroTile({
    super.key,
    this.size = MetroTileSize.small,
    required this.backgroundColor,
    this.foregroundColor = Colors.white,
    this.title,
    this.subtitle,
    this.mainContent,
    this.explanation,
    this.icon,
    this.child,
    this.enableFlip = true,
    this.onTap,
  });

  @override
  State<MetroTile> createState() => _MetroTileState();
}

class _MetroTileState extends State<MetroTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showFront = true;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (!widget.enableFlip || widget.explanation == null) return;

    HapticFeedback.lightImpact();
    setState(() {
      _showFront = !_showFront;
    });

    if (_showFront) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap ?? _flip,
        onLongPress: widget.enableFlip && widget.explanation != null
            ? _flip
            : null,
        child: AnimatedScale(
          scale: _isHovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final angle = _animation.value * math.pi;
              final transform = Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle);

              return Transform(
                transform: transform,
                alignment: Alignment.center,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: _isHovered
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _animation.value < 0.5
                      ? _buildFront()
                      : Transform(
                          transform: Matrix4.identity()..rotateY(math.pi),
                          alignment: Alignment.center,
                          child: _buildBack(),
                        ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFront() {
    if (widget.child != null) {
      return widget.child!;
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部标题
          if (widget.title != null)
            Text(
              widget.title!,
              style: TextStyle(
                color: widget.foregroundColor.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),

          const Spacer(),

          // 主内容
          if (widget.mainContent != null)
            Text(
              widget.mainContent!,
              style: TextStyle(
                color: widget.foregroundColor,
                fontSize: widget.size == MetroTileSize.small ? 28 : 42,
                fontWeight: FontWeight.w300,
              ),
            ),

          // 图标
          if (widget.icon != null)
            Icon(
              widget.icon,
              color: widget.foregroundColor,
              size: widget.size == MetroTileSize.small ? 32 : 48,
            ),

          // 底部副标题
          if (widget.subtitle != null)
            Text(
              widget.subtitle!,
              style: TextStyle(
                color: widget.foregroundColor.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 释义标题
          Text(
            widget.title ?? '释义',
            style: TextStyle(
              color: widget.foregroundColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          // 释义内容
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                widget.explanation ?? '',
                style: TextStyle(
                  color: widget.foregroundColor.withOpacity(0.9),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
          ),

          // 提示
          Text(
            '点击返回',
            style: TextStyle(
              color: widget.foregroundColor.withOpacity(0.5),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

/// Metro 磁贴网格布局
class MetroTileGrid extends StatelessWidget {
  /// 磁贴列表
  final List<MetroTile> tiles;

  /// 每行磁贴数量（小磁贴为单位）
  final int tilesPerRow;

  /// 磁贴间距
  final double spacing;

  /// 磁贴高度（小磁贴）
  final double tileHeight;

  const MetroTileGrid({
    super.key,
    required this.tiles,
    this.tilesPerRow = 4,
    this.spacing = 4,
    this.tileHeight = 100,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth - spacing * (tilesPerRow - 1)) / tilesPerRow;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: tiles.map((tile) {
            final width = tileWidth * tile.size.crossAxisCellCount + spacing * (tile.size.crossAxisCellCount - 1);
            final height = tileHeight * tile.size.mainAxisCellCount + spacing * (tile.size.mainAxisCellCount - 1);

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
}

/// Metro 配色方案 - 阳光温暖的 Windows 8 Metro 风格
class MetroColors {
  // 日历网格 - 阳光橙色
  static const Color calendar = Color(0xFFFF8C00); // 橙色

  // 农历 - 珊瑚红
  static const Color lunar = Color(0xFFE74C3C); // 珊瑚红

  // 藏历 - 天空蓝
  static const Color tibetan = Color(0xFF3498DB); // 天蓝色

  // 节日 - 金黄色
  static const Color festival = Color(0xFFF1C40F); // 金黄色

  // 节气 - 翠绿色
  static const Color solarTerm = Color(0xFF27AE60); // 翠绿

  // 殊胜日 - 暖橙色
  static const Color specialDay = Color(0xFFE67E22); // 暖橙

  // 冲煞 - 玫瑰红
  static const Color chongSha = Color(0xFFE74C3C); // 玫瑰红

  // 五行 - 青绿色
  static const Color fiveElements = Color(0xFF1ABC9C); // 青绿

  // 宜忌 - 青柠绿
  static const Color yiJi = Color(0xFF2ECC71); // 青柠绿

  // 默认 - 暖灰色
  static const Color defaultTile = Color(0xFF95A5A6); // 暖灰
}
