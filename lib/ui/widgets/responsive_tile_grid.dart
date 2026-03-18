import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/responsive_helper.dart';
import 'metro_tile.dart';
import 'calendar_grid_tile.dart';

/// 响应式磁贴网格配置
class ResponsiveTileConfig {
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final int largeDesktopColumns;
  final double spacing;
  final double tileHeight;

  const ResponsiveTileConfig({
    this.mobileColumns = 2,
    this.tabletColumns = 3,
    this.desktopColumns = 4,
    this.largeDesktopColumns = 5,
    this.spacing = 4,
    this.tileHeight = 100,
  });

  int getColumns(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return mobileColumns;
      case DeviceType.tablet:
        return tabletColumns;
      case DeviceType.desktop:
        return desktopColumns;
      case DeviceType.largeDesktop:
        return largeDesktopColumns;
    }
  }
}

/// 响应式磁贴网格
class ResponsiveTileGrid extends StatelessWidget {
  final List<MetroTile> tiles;
  final ResponsiveTileConfig config;

  const ResponsiveTileGrid({
    super.key,
    required this.tiles,
    this.config = const ResponsiveTileConfig(),
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = context.deviceType;
    final columns = config.getColumns(deviceType);
    final spacing = context.responsiveSpacing(config.spacing);
    final tileHeight = context.responsive(config.tileHeight);

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: tiles.map((tile) {
            final width = tileWidth * tile.size.crossAxisCellCount +
                spacing * (tile.size.crossAxisCellCount - 1);
            final height = tileHeight * tile.size.mainAxisCellCount +
                spacing * (tile.size.mainAxisCellCount - 1);

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

/// 带捏合缩放手势的磁贴网格
class GestureTileGrid extends StatefulWidget {
  final List<MetroTile> tiles;
  final MetroTile? calendarTile;
  final ResponsiveTileConfig config;
  final void Function(CalendarViewMode)? onViewModeChanged;

  const GestureTileGrid({
    super.key,
    required this.tiles,
    this.calendarTile,
    this.config = const ResponsiveTileConfig(),
    this.onViewModeChanged,
  });

  @override
  State<GestureTileGrid> createState() => _GestureTileGridState();
}

class _GestureTileGridState extends State<GestureTileGrid> {
  CalendarViewMode _viewMode = CalendarViewMode.month;
  double _scale = 1.0;
  double _lastScale = 1.0;

  void _handleScaleStart(ScaleStartDetails details) {
    _lastScale = _scale;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    final newScale = _lastScale * details.scale;

    // 限制缩放范围
    if (newScale >= 0.5 && newScale <= 2.0) {
      setState(() {
        _scale = newScale;
      });
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    // 根据缩放比例切换视图模式
    if (_scale < 0.7 && _viewMode != CalendarViewMode.week) {
      _setViewMode(CalendarViewMode.week);
    } else if (_scale > 1.3 && _viewMode != CalendarViewMode.day) {
      _setViewMode(CalendarViewMode.day);
    } else if (_scale >= 0.9 && _scale <= 1.1 && _viewMode != CalendarViewMode.month) {
      _setViewMode(CalendarViewMode.month);
    }

    // 重置缩放
    setState(() {
      _scale = 1.0;
    });
  }

  void _setViewMode(CalendarViewMode mode) {
    HapticFeedback.lightImpact();
    setState(() {
      _viewMode = mode;
    });
    widget.onViewModeChanged?.call(mode);
  }

  @override
  Widget build(BuildContext context) {
    final deviceType = context.deviceType;
    final columns = widget.config.getColumns(deviceType);
    final spacing = context.responsiveSpacing(widget.config.spacing);
    final tileHeight = context.responsive(widget.config.tileHeight);

    return GestureDetector(
      onScaleStart: _handleScaleStart,
      onScaleUpdate: _handleScaleUpdate,
      onScaleEnd: _handleScaleEnd,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tileWidth =
                (constraints.maxWidth - spacing * (columns - 1)) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: widget.tiles.map((tile) {
                final width = tileWidth * tile.size.crossAxisCellCount +
                    spacing * (tile.size.crossAxisCellCount - 1);
                final height = tileHeight * tile.size.mainAxisCellCount +
                    spacing * (tile.size.mainAxisCellCount - 1);

                return SizedBox(
                  width: width,
                  height: height,
                  child: tile,
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

/// 流式磁贴布局 - 自动换行
class FlowTileLayout extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  const FlowTileLayout({
    super.key,
    required this.children,
    this.spacing = 4,
    this.runSpacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: context.responsiveSpacing(spacing),
      runSpacing: context.responsiveSpacing(runSpacing),
      children: children,
    );
  }
}

/// 瀑布流磁贴布局
class MasonryTileLayout extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  const MasonryTileLayout({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 4,
    this.crossAxisSpacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    // 简化版瀑布流 - 使用 GridView
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: context.responsiveSpacing(mainAxisSpacing),
      crossAxisSpacing: context.responsiveSpacing(crossAxisSpacing),
      childAspectRatio: 1.0,
      children: children,
    );
  }
}
