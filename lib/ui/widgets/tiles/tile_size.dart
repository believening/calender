/// 磁贴尺寸枚举
///
/// Modern UI 风格的三种磁贴尺寸
enum TileSize {
  /// 大磁贴 - 月视图（7x6 网格）
  large,
  
  /// 中磁贴 - 周视图（7x1 行）
  medium,
  
  /// 小磁贴 - 日视图（单日）
  small,
}

/// 磁贴尺寸扩展方法
extension TileSizeExtension on TileSize {
  /// 获取显示名称
  String get displayName {
    switch (this) {
      case TileSize.large:
        return '大';
      case TileSize.medium:
        return '中';
      case TileSize.small:
        return '小';
    }
  }
  
  /// 获取图标
  String get icon {
    switch (this) {
      case TileSize.large:
        return '⊞';
      case TileSize.medium:
        return '⊟';
      case TileSize.small:
        return '⊡';
    }
  }
  
  /// 获取网格列数
  int get gridColumns {
    switch (this) {
      case TileSize.large:
        return 7; // 完整周
      case TileSize.medium:
        return 7; // 完整周
      case TileSize.small:
        return 1; // 单日
    }
  }
  
  /// 获取网格行数
  int get gridRows {
    switch (this) {
      case TileSize.large:
        return 6; // 完整月
      case TileSize.medium:
        return 1; // 单周
      case TileSize.small:
        return 1; // 单日
    }
  }
  
  /// 是否显示完整月历
  bool get isMonthView => this == TileSize.large;
  
  /// 是否是周视图
  bool get isWeekView => this == TileSize.medium;
  
  /// 是否是日视图
  bool get isDayView => this == TileSize.small;
}
