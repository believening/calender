# MultiCalendarApp - 多民族日历整合应用

一款支持多种民族历法的日历应用，采用插件化架构设计，已完成核心算法和基础架构。

## ✅ 当前进度

### 已完成功能

| 模块 | 状态 | 说明 |
|------|------|------|
| 农历完整算法 | ✅ | 1900-2100年，公历⇄农历双向转换 |
| 藏历完整算法 | ✅ | 五行、生肖、绕迥纪年、殊胜日、九宫飞星 |
| 节气计算 | ✅ | 24节气精确计算 |
| 三伏天/数九 | ✅ | 完整三伏天、数九计算 |
| 农历宜忌 | ✅ | 每日宜忌信息 |
| 插件架构 | ✅ | CalendarPlugin 协议 + PluginManager |
| SwiftUI 界面 | ✅ | 完整日历视图、日期详情、节日列表、设置页 |
| Xcode 配置 | ✅ | 完整项目配置，可直接打开编译 |
| 测试用例 | ✅ | 26项测试，100%通过 |

### 测试覆盖

```
总测试数: 26项
通过率: 100%
性能: 1000次转换 < 0.2秒
```

## 项目结构

```
MultiCalendarApp/
├── MultiCalendarApp.swift      # 应用入口
├── MultiCalendarApp.xcodeproj/ # Xcode 项目
├── Package.swift               # SPM 配置
├── Info.plist                  # 应用配置
│
├── Core/                       # 核心引擎
│   ├── CalendarCore/           # CalendarPlugin 协议定义
│   ├── PluginManager/          # 插件管理器
│   └── NotificationManager/    # 提醒管理器
│
├── Plugins/                    # 日历插件
│   ├── LunarCalendar/          # 农历插件
│   │   └── Sources/LunarCalendarPlugin.swift
│   └── TibetanCalendar/        # 藏历插件
│       └── Sources/TibetanCalendarPlugin.swift
│
├── Shared/                     # 共享模块
│   ├── Algorithm/              # 算法引擎
│   │   ├── LunarAlgorithm.swift    # 农历算法
│   │   └── TibetanAlgorithm.swift  # 藏历算法
│   ├── Data/                   # 数据表
│   │   ├── LunarData.swift         # 农历数据 (1900-2100)
│   │   └── TibetanData.swift       # 藏历数据
│   └── Models/                 # 数据模型
│       └── CalendarModels.swift
│
├── UI/                         # 用户界面
│   ├── Views/
│   │   ├── ContentView.swift       # 主视图
│   │   ├── SettingsView.swift      # 设置页
│   │   └── YearPickerView.swift    # 年份选择器
│   └── ViewModels/
│       └── CalendarViewModel.swift
│
├── Resources/                  # 资源文件
│   ├── AppIcon.svg
│   ├── LaunchScreen.svg
│   └── Assets.xcassets/
│
└── Tests/                      # 测试
    ├── run_tests.py            # Python 测试 (15项)
    ├── run_tests_v2.py         # 完整测试 (11项)
    ├── CalendarPluginTests.swift
    └── IntegrationTests.swift
```

## 核心算法

### 农历算法 (LunarAlgorithm)

```swift
// 公历 → 农历
let lunar = LunarAlgorithm.solarToLunar(date: Date())
// LunarDate(year: 2026, month: 1, day: 15, isLeapMonth: false)

// 农历 → 公历
let solar = LunarAlgorithm.lunarToSolar(year: 2026, month: 1, day: 15)

// 获取节气
let term = LunarAlgorithm.getSolarTerm(year: 2026, index: 0) // 小寒

// 三伏天
let sanfu = LunarAlgorithm.getSanfu(year: 2026)

// 数九
let shujiu = LunarAlgorithm.getShujiu(year: 2026, date: Date())
```

### 藏历算法 (TibetanAlgorithm)

```swift
// 公历 → 藏历
let tibetan = TibetanAlgorithm.solarToTibetan(date: Date())
// TibetanDate(year: 2053, month: 1, day: 15, element: "火", animal: "狗")

// 获取殊胜日
let special = TibetanAlgorithm.getSpecialDays(year: 2053, month: 1)

// 九宫飞星
let feixing = TibetanAlgorithm.getFeixing(year: 2053)
```

## 插件系统

### 日历插件协议

```swift
protocol CalendarPlugin {
    var identifier: String { get }
    var name: String { get }
    var version: String { get }
    
    func convert(from date: Date) -> CalendarDate?
    func getFestivals(year: Int, month: Int) -> [Festival]
    func getDailyInfo(date: Date) -> DailyInfo?
    var supportedYearRange: ClosedRange<Int> { get }
}
```

### 实现插件

```swift
class LunarCalendarPlugin: CalendarPlugin {
    let identifier = "com.app.lunar"
    let name = "农历"
    let version = "1.0.0"
    
    func convert(from date: Date) -> CalendarDate? {
        return LunarAlgorithm.solarToLunar(date: date)
    }
    // ...
}
```

## 快速开始

```bash
# 克隆仓库
git clone https://github.com/believening/calender.git
cd calender

# 打开 Xcode
open MultiCalendarApp.xcodeproj

# 运行测试
cd Tests
python3 run_tests_v2.py
```

## 技术栈

| 类别 | 技术 |
|------|------|
| 平台 | iOS 15.0+ |
| 语言 | Swift 5.7 |
| UI | SwiftUI |
| 架构 | MVVM + Plugin |
| 依赖管理 | Swift Package Manager |

## 开发路线

### Phase 1: 核心算法 ✅
- [x] 农历完整算法
- [x] 藏历完整算法
- [x] 节气、三伏、数九
- [x] 插件协议设计

### Phase 2: UI 开发 ✅
- [x] 基础界面框架
- [x] 完整日历视图
- [x] 节日显示（搜索、筛选、分组）
- [x] 日期详情页（公历/农历/藏历/节日/宜忌）
- [x] 设置页面完善

### Phase 3: 功能完善 🚧
- [ ] 智能提醒系统
- [ ] Widget 小组件
- [ ] Apple Watch 支持

### Phase 4: 发布
- [ ] App Store 上架
- [ ] 用户反馈收集

## 参考资料

- [中国农历算法](https://github.com/isee15/Lunar-Solar-Calendar-Converter)
- [藏历算法](https://github.com/tibetan-calendar)
- [SwiftUI 教程](https://developer.apple.com/tutorials/swiftui)

## License

MIT License
