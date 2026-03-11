import 'package:flutter/material.dart';
import '../../models/calendar_models.dart';

/// 日历主题系统
///
/// 基于调研结果设计的现代配色方案
/// 灵感来源：Fantastical, Timepage, Google Calendar
class CalendarTheme {
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Gradient primaryGradient;
  final Color backgroundColor;
  final Color cardColor;
  final Color surfaceColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color accent;
  final Color festival;
  final Color specialDay;

  const CalendarTheme({
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.primaryGradient,
    required this.backgroundColor,
    required this.cardColor,
    required this.surfaceColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.accent,
    required this.festival,
    required this.specialDay,
  });

  /// 公历主题 - 晨曦橙（日出）
  static CalendarTheme get solar => CalendarTheme(
    name: '晨曦',
    primaryColor: const Color(0xFFFF9500),
    secondaryColor: const Color(0xFFFF6B00),
    primaryGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFF9500), Color(0xFFFF6B00)],
    ),
    backgroundColor: const Color(0xFFFAFBFC),
    cardColor: Colors.white,
    surfaceColor: const Color(0xFFFFF7ED),
    textPrimary: const Color(0xFF1F2937),
    textSecondary: const Color(0xFF6B7280),
    textHint: const Color(0xFF9CA3AF),
    accent: const Color(0xFFFF9500),
    festival: const Color(0xFFEF5350),
    specialDay: const Color(0xFFFF8F00),
  );

  /// 农历主题 - 月光蓝（夜晚）
  static CalendarTheme get lunar => CalendarTheme(
    name: '月光',
    primaryColor: const Color(0xFF6366F1),
    secondaryColor: const Color(0xFF4F46E5),
    primaryGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
    ),
    backgroundColor: const Color(0xFFFAFBFC),
    cardColor: Colors.white,
    surfaceColor: const Color(0xFFEEF2FF),
    textPrimary: const Color(0xFF1F2937),
    textSecondary: const Color(0xFF6B7280),
    textHint: const Color(0xFF9CA3AF),
    accent: const Color(0xFF6366F1),
    festival: const Color(0xFF10B981),
    specialDay: const Color(0xFFFF8F00),
  );

  /// 藏历主题 - 雪域青（天空）
  static CalendarTheme get tibetan => CalendarTheme(
    name: '雪域',
    primaryColor: const Color(0xFF0891B2),
    secondaryColor: const Color(0xFF0E7490),
    primaryGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0891B2), Color(0xFF0E7490)],
    ),
    backgroundColor: const Color(0xFFFAFBFC),
    cardColor: Colors.white,
    surfaceColor: const Color(0xFFECFEFF),
    textPrimary: const Color(0xFF1F2937),
    textSecondary: const Color(0xFF6B7280),
    textHint: const Color(0xFF9CA3AF),
    accent: const Color(0xFF0891B2),
    festival: const Color(0xFFEF5350),
    specialDay: const Color(0xFFFF8F00),
  );

  /// 根据历法类型获取主题
  static CalendarTheme fromType(CalendarType type) {
    switch (type) {
      case CalendarType.solar:
        return solar;
      case CalendarType.lunar:
        return lunar;
      case CalendarType.tibetan:
        return tibetan;
      default:
        return lunar;
    }
  }
}
