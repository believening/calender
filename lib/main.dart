import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/providers/locale_provider.dart';
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
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) {
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
                seedColor: const Color(0xFF6750A4),
                brightness: Brightness.light,
              ).copyWith(
                primary: const Color(0xFF6750A4),
                primaryContainer: const Color(0xFFEADDFF),
                secondary: const Color(0xFF625B71),
                secondaryContainer: const Color(0xFFE8DEF8),
                surface: const Color(0xFFFFFBFE),
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
                scrolledUnderElevation: 1,
              ),
              cardTheme: CardThemeData(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6750A4),
                brightness: Brightness.dark,
              ).copyWith(
                primary: const Color(0xFFD0BCFF),
                primaryContainer: const Color(0xFF4F378B),
                secondary: const Color(0xFFCCC2DC),
                secondaryContainer: const Color(0xFF4A4458),
                surface: const Color(0xFF1C1B1F),
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
                scrolledUnderElevation: 1,
              ),
              cardTheme: CardThemeData(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
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
