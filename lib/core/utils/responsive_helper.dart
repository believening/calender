import 'package:flutter/material.dart';

/// 响应式设计助手
///
/// 根据屏幕宽度自动调整尺寸，适配移动端、平板、桌面端
class ResponsiveHelper {
  /// 屏幕断点定义
  static const double mobileBreakpoint = 600;   // 移动端
  static const double tabletBreakpoint = 900;   // 平板
  static const double desktopBreakpoint = 1200; // 桌面端

  /// 获取设备类型
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return DeviceType.mobile;
    if (width < tabletBreakpoint) return DeviceType.tablet;
    if (width < desktopBreakpoint) return DeviceType.desktop;
    return DeviceType.largeDesktop;
  }

  /// 缩放因子 - 基于设备类型返回合适的缩放比例
  static double scaleFactor(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return 1.0;
      case DeviceType.tablet:
        return 1.3;
      case DeviceType.desktop:
        return 1.6;
      case DeviceType.largeDesktop:
        return 2.0;
    }
  }

  /// 响应式尺寸 - 根据基础尺寸和当前设备计算实际尺寸
  static double responsiveValue(BuildContext context, double baseValue) {
    return baseValue * scaleFactor(context);
  }

  /// 响应式字体大小
  static double responsiveFontSize(BuildContext context, double baseSize) {
    return responsiveValue(context, baseSize);
  }

  /// 响应式间距
  static double responsiveSpacing(BuildContext context, double baseSpacing) {
    return responsiveValue(context, baseSpacing);
  }

  /// 响应式圆角
  static double responsiveRadius(BuildContext context, double baseRadius) {
    return responsiveValue(context, baseRadius);
  }

  /// 响应式内边距
  static EdgeInsets responsivePadding(BuildContext context, {
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? right,
    double? top,
    double? bottom,
  }) {
    final scale = scaleFactor(context);
    return EdgeInsets.only(
      left: (left ?? horizontal ?? all ?? 0) * scale,
      right: (right ?? horizontal ?? all ?? 0) * scale,
      top: (top ?? vertical ?? all ?? 0) * scale,
      bottom: (bottom ?? vertical ?? all ?? 0) * scale,
    );
  }

  /// 是否为桌面端（用于条件渲染）
  static bool isDesktop(BuildContext context) {
    final type = getDeviceType(context);
    return type == DeviceType.desktop || type == DeviceType.largeDesktop;
  }

  /// 是否为移动端
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// 最大内容宽度 - 桌面端限制内容宽度以保持可读性
  static double maxContentWidth(BuildContext context) {
    if (isDesktop(context)) {
      return 600; // 移动端的最大宽度作为桌面端内容宽度
    }
    return double.infinity;
  }
}

/// 设备类型枚举
enum DeviceType {
  mobile,        // < 600px
  tablet,        // 600px - 900px
  desktop,       // 900px - 1200px
  largeDesktop,  // > 1200px
}

/// 扩展方法 - 简化调用
extension ResponsiveExtension on BuildContext {
  DeviceType get deviceType => ResponsiveHelper.getDeviceType(this);
  double get scale => ResponsiveHelper.scaleFactor(this);

  double responsive(double value) => ResponsiveHelper.responsiveValue(this, value);
  double responsiveFontSize(double size) => ResponsiveHelper.responsiveFontSize(this, size);
  double responsiveSpacing(double spacing) => ResponsiveHelper.responsiveSpacing(this, spacing);
  double responsiveRadius(double radius) => ResponsiveHelper.responsiveRadius(this, radius);

  /// 响应式内边距（扩展方法）
  EdgeInsets responsivePadding({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? right,
    double? top,
    double? bottom,
  }) => ResponsiveHelper.responsivePadding(
    this,
    all: all,
    horizontal: horizontal,
    vertical: vertical,
    left: left,
    right: right,
    top: top,
    bottom: bottom,
  );

  bool get isDesktop => ResponsiveHelper.isDesktop(this);
  bool get isMobile => ResponsiveHelper.isMobile(this);
  double get maxContentWidth => ResponsiveHelper.maxContentWidth(this);
}
