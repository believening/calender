# MultiCalendarApp - 多民族日历应用

一款支持多种民族历法的跨平台日历应用，支持 **Android、iOS、Linux、macOS、Windows、Web** 全平台。

> 🏔️ 致力于服务关心自己民族历法的群体，助力民族文化传承

## ✅ 功能特性

| 模块 | 状态 | 说明 |
|------|------|------|
| 农历完整算法 | ✅ | 1900-2100年，公历⇄农历双向转换 |
| 藏历完整算法 | ✅ | 五行、生肖、绕迥纪年、殊胜日、九宫飞星 |
| 节气计算 | ✅ | 24节气精确计算 |
| 三伏天/数九 | ✅ | 完整三伏天、数九计算 |
| 插件架构 | ✅ | CalendarPlugin 协议 + PluginManager |
| Flutter UI | ✅ | 现代化设计、日历视图、日期详情 |
| 多语言支持 | ✅ | 中文、藏文、英文 |
| Web 构建 | ✅ | 已验证通过 |

## 🎨 设计特色

- **现代 UI 设计** - 柔和紫色系配色，大圆角卡片
- **藏历信息卡片** - 显示绕迥纪年、五行生肖
- **殊胜日标记** - 橙色标记藏历殊胜日
- **藏文支持** - 节日名称显示藏文
- **平滑动画** - 入场动画和交互反馈

## 🚀 快速开始

```bash
# 克隆仓库
git clone https://github.com/believening/calender.git
cd calender

# 安装依赖
flutter pub get

# 生成国际化代码
flutter gen-l10n

# 运行
flutter run -d chrome    # Web
flutter run -d linux     # Linux (需要 cmake)

# 构建
flutter build web        # Web
flutter build apk        # Android
flutter build ios        # iOS
```

## 📁 项目结构

```
lib/
├── main.dart                    # 应用入口
├── l10n/                        # 国际化文件
│   ├── app_zh.arb               # 中文翻译
│   ├── app_bo.arb               # 藏文翻译
│   └── app_en.arb               # 英文翻译
├── core/
│   ├── calendar_core/
│   │   └── calendar_plugin.dart # 插件协议
│   ├── plugin_manager/
│   │   └── plugin_manager.dart  # 插件管理器
│   └── providers/
│       └── locale_provider.dart # 语言设置
├── models/
│   └── calendar_models.dart     # 数据模型
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
    │   ├── calendar_view.dart     # 日历视图
    │   └── settings_view.dart     # 设置页面
    └── viewmodels/
        └── calendar_view_model.dart # 视图模型
```

## 🔧 核心功能

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
// 输出：第17绕迥 阳火马年
```

### 藏历数据 (TibetanData)

```dart
// 获取年份信息
var yearInfo = TibetanData.getYearFullInfo(2026);
// {
//   cycle: 17, yearInCycle: 40,
//   element: '火', zodiac: '马', gender: '阳',
//   fullNameChinese: '第17绕迥 阳火马年',
//   fullNameTibetan: 'རབ་བྱུང་༡༧ ལོ་༤༠ ཕོ་མེ་རྟ',
// }

// 获取五行生肖（支持中/藏/英三语）
var (element, tibetan) = TibetanData.getElement(2026);  // ('火', 'མེ་')
var (zodiac, tibetan) = TibetanData.getZodiac(2026);    // ('马', 'རྟ')
```

## 🌐 多语言支持

| 语言 | 代码 | 状态 |
|------|------|------|
| 中文 | zh_CN | ✅ 完成 |
| 藏文 | bo_CN | ✅ 完成 |
| 英文 | en_US | ✅ 完成 |

## 🔌 插件系统

### 创建自定义历法插件

```dart
class MyCalendarPlugin extends BaseCalendarPlugin {
  MyCalendarPlugin() : super(
    identifier: 'com.example.my_calendar',
    name: '我的历法',
    version: '1.0.0',
    calendarType: CalendarType.custom,
    supportedYearRange: const ClosedRange(1900, 2100),
  );

  @override
  CalendarDate? convert(DateTime date) {
    // 实现公历 → 自历法转换
  }

  @override
  DateTime? convertToSolar(int year, int month, int day) {
    // 实现自历法 → 公历转换
  }
}
```

## 📚 藏历知识

### 绕迥纪年
- 藏历使用60年周期（绕迥），始于1027年
- 2026年是第17绕迥第40年

### 五行生肖
- 五行顺序：木 → 火 → 土 → 铁 → 水
- 生肖顺序：兔 → 龙 → 蛇 → 马 → 羊 → 猴 → 鸡 → 狗 → 猪 → 鼠 → 牛 → 虎
- 2026年：阳火马年

### 殊胜日
藏历每月的以下日期为殊胜日：
- 初一 - 吉祥日
- 初八 - 药师佛节日
- 初十 - 莲师荟供日
- 十五 - 佛陀节日（满月）
- 十八 - 观音菩萨节日
- 廿五 - 空行母荟供日
- 三十 - 释迦牟尼佛节日（新月）

## 🛠️ 技术栈

| 类别 | 技术 |
|------|------|
| 框架 | Flutter 3.x |
| 语言 | Dart 3.x |
| 状态管理 | Provider |
| 国际化 | Flutter l10n |
| 平台 | Android, iOS, Linux, macOS, Windows, Web |

## 📝 更新日志

查看 [CHANGELOG.md](./CHANGELOG.md) 了解详细更新记录。

## 🤝 贡献

欢迎贡献代码、翻译或提出建议！

## 📄 License

MIT License
