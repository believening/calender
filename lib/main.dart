import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/calendar_settings_provider.dart';
import 'ui/views/calendar_view.dart';

void main() {
  runApp(const MultiCalendarApp());
}

class MultiCalendarApp extends StatelessWidget {
  const MultiCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => CalendarSettingsProvider()),
      ],
      child: Consumer2<LocaleProvider, CalendarSettingsProvider>(
        builder: (context, localeProvider, settingsProvider, _) {
          return MaterialApp(
            title: '多民族日历',
            debugShowCheckedModeBanner: false,
            
            // 国际化配置
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: LocaleProvider.supportedLocales,
            locale: localeProvider.locale,
        
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF8B5CF6),
                brightness: Brightness.light,
              ).copyWith(
                primary: const Color(0xFF8B5CF6),
                onPrimary: Colors.white,
                primaryContainer: const Color(0xFFEDE9FE),
                onPrimaryContainer: const Color(0xFF4C1D95),
                secondary: const Color(0xFFC4B5FD),
                onSecondary: const Color(0xFF4C1D95),
                secondaryContainer: const Color(0xFFEDE9FE),
                surface: const Color(0xFFFAF5FF),
                onSurface: const Color(0xFF4C1D95),
                onSurfaceVariant: const Color(0xFF6B7280),
              ),
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFFFAF5FF),
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
                scrolledUnderElevation: 0.5,
                backgroundColor: Color(0xFFFAF5FF),
                foregroundColor: Color(0xFF4C1D95),
              ),
              cardTheme: CardTheme(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              textTheme: const TextTheme(
                headlineLarge: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4C1D95),
                  letterSpacing: -0.5,
                ),
                headlineMedium: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4C1D95),
                  letterSpacing: -0.25,
                ),
                bodyLarge: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF4C1D95),
                  height: 1.5,
                ),
                bodyMedium: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              switchTheme: SwitchThemeData(
                thumbColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFF8B5CF6);
                  }
                  return const Color(0xFFC4B5FD);
                }),
                trackColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFFEDE9FE);
                  }
                  return const Color(0xFFE5E7EB);
                }),
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF8B5CF6),
                brightness: Brightness.dark,
              ).copyWith(
                primary: const Color(0xFFA78BFA),
                onPrimary: const Color(0xFF4C1D95),
                primaryContainer: const Color(0xFF4F378B),
                onPrimaryContainer: const Color(0xFFEDE9FE),
                secondary: const Color(0xFFDDD6FE),
                onSecondary: const Color(0xFF4C1D95),
                secondaryContainer: const Color(0xFF4F378B),
                surface: const Color(0xFF1F1B24),
                onSurface: const Color(0xFFEDE9FE),
                onSurfaceVariant: const Color(0xFF9CA3AF),
              ),
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFF1F1B24),
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
                scrolledUnderElevation: 0.5,
                backgroundColor: Color(0xFF1F1B24),
                foregroundColor: Color(0xFFEDE9FE),
              ),
              cardTheme: CardTheme(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: const Color(0xFF2D2831),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              textTheme: const TextTheme(
                headlineLarge: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEDE9FE),
                  letterSpacing: -0.5,
                ),
                headlineMedium: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEDE9FE),
                  letterSpacing: -0.25,
                ),
                bodyLarge: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFEDE9FE),
                  height: 1.5,
                ),
                bodyMedium: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF9CA3AF),
                  height: 1.5,
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              switchTheme: SwitchThemeData(
                thumbColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFFA78BFA);
                  }
                  return const Color(0xFF6B7280);
                }),
                trackColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFF4F378B);
                  }
                  return const Color(0xFF374151);
                }),
              ),
            ),
            themeMode: ThemeMode.system,
            home: const CalendarView(),
          );
        },
      ),
    );
  }
}
