# MultiCalendarApp - 多民族日历应用

一款支持多种民族历法的跨平台日历应用，支持 **Android、iOS、Linux、macOS、Windows、Web** 全平台。

## ✅ 功能特性

| 模块 | 状态 | 说明 |
|------|------|------|
| 农历完整算法 | ✅ | 1900-2100年，公历⇄农历双向转换 |
| 藏历完整算法 | ✅ | 五行、生肖、绕迥纪年、殊胜日、九宫飞星 |
| 节气计算 | ✅ | 24节气精确计算 |
| 三伏天/数九 | ✅ | 完整三伏天、数九计算 |
| 插件架构 | ✅ | CalendarPlugin 协议 + PluginManager |
| Flutter UI | ✅ | 日历视图、日期详情、节日显示、宜忌信息 |
| Web 构建 | ✅ | 已验证通过 |

## 快速开始

```bash
# 安装依赖
flutter pub get

# 代码分析
flutter analyze

# 运行
flutter run -d chrome    # Web
flutter run -d linux     # Linux (需要 cmake)

# 构建
flutter build web        # Web
flutter build apk        # Android
flutter build ios        # iOS
```

## 项目结构

```
lib/
├── main.dart                    # 应用入口
├── models/
│   └── calendar_models.dart     # 数据模型
├── core/
│   ├── calendar_core/
│   │   └── calendar_plugin.dart # 插件协议
│   └── plugin_manager/
│       └── plugin_manager.dart  # 插件管理器
├── shared/
│   ├── algorithm/
│   │   ├── lunar_algorithm.dart    # 农历算法
│   │   └── tibetan_algorithm.dart  # 藏历算法
│   └── data/
│       ├── lunar_data.dart         # 农历数据
│       └── tibetan_data.dart       # 藏历数据
├── plugins/
│   ├── lunar_calendar/
│   │   └── lunar_calendar_plugin.dart   # 农历插件
│   └── tibetan_calendar/
│       └── tibetan_calendar_plugin.dart # 藏历插件
└── ui/
    ├── views/
    │   └── calendar_view.dart     # 日历视图
    └── viewmodels/
        └── calendar_view_model.dart # 视图模型
```

## 核心功能

### 农历算法 (LunarAlgorithm)

```dart
// 公历 → 农历
var lunarDate = LunarAlgorithm.solarToLunar(DateTime.now());

// 农历 → 公历
var solar = LunarAlgorithm.lunarToSolar(2026, 1, 15);

// 获取节气
var term = LunarAlgorithm.getSolarTerm(DateTime.now());

// 三伏天
var sanfu = LunarAlgorithm.getSanfu(2026);

// 数九
var shujiu = LunarAlgorithm.getShujiu(2026);
```

### 藏历算法 (TibetanAlgorithm)

```dart
// 公历 → 藏历
var tibetan = TibetanAlgorithm.solarToTibetan(DateTime.now());

// 殊胜日检查
var (isSpecial, desc) = TibetanAlgorithm.isSpecialDate(DateTime.now());

// 九宫飞星
var (star, direction, meaning) = TibetanAlgorithm.getFlyingStar(2026, 2, 28);

// 绕迥纪年
var info = TibetanAlgorithm.getYearInfo(2026);
```

## 技术栈

| 类别 | 技术 |
|------|------|
| 框架 | Flutter 3.x |
| 语言 | Dart 3.x |
| 状态管理 | Provider |
| 平台 | Android, iOS, Linux, macOS, Windows, Web |

## License

MIT License
