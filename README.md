# MultiCalendarApp - 多民族日历整合应用

## 项目概述

一款支持多种民族历法的日历应用，采用插件化架构设计，支持动态资源分发。

### 核心特性

- ✅ 插件化架构 - 支持动态加载日历插件
- ✅ 农历内置 - 默认支持农历显示
- ✅ 藏历动态加载 - 通过资源包方式加载
- ✅ 三历并行显示 - 公历、农历、藏历同屏
- ✅ 智能提醒 - 初一十五、重要节日提醒
- ✅ 快速年份跳转 - 解决竞品痛点
- ✅ 汉藏双语 - 同时显示+切换

## 架构设计

```
MultiCalendarApp
├── App/                    # 应用主程序
│   ├── MultiCalendarApp.swift
│   ├── ContentView.swift
│   └── Info.plist
├── Core/                   # 核心引擎
│   ├── CalendarCore/       # 日历核心引擎
│   ├── PluginManager/      # 插件管理器
│   └── NotificationManager/ # 提醒管理器
├── Plugins/                # 日历插件
│   ├── LunarCalendar/      # 农历插件（内置）
│   │   ├── Sources/
│   │   └── Resources/
│   └── TibetanCalendar/    # 藏历插件（动态）
│       ├── Sources/
│       └── Resources/
├── UI/                     # 用户界面
│   ├── Views/
│   ├── ViewModels/
│   └── Components/
└── Shared/                 # 共享资源
    ├── Models/
    ├── Extensions/
    └── Utils/
```

## 插件系统设计

### 日历插件协议

```swift
protocol CalendarPlugin {
    // 插件信息
    var identifier: String { get }
    var name: String { get }
    var version: String { get }
    
    // 历法转换
    func convert(from date: Date) -> CalendarDate?
    
    // 获取节日
    func getFestivals(year: Int, month: Int) -> [Festival]
    
    // 获取吉凶宜忌（可选）
    func getDailyInfo(date: Date) -> DailyInfo?
    
    // 支持的年份范围
    var supportedYearRange: ClosedRange<Int> { get }
}
```

### 插件加载机制

1. **内置插件**：编译时打包到主程序
2. **动态插件**：从服务器下载 .bundle 资源包，运行时加载

### 资源包格式

```
TibetanCalendar.bundle/
├── Info.plist          # 插件信息
├── CalendarPlugin.json # 插件元数据
├── Data/
│   ├── calendar.db     # 历法数据
│   └── festivals.json  # 节日数据
└── Resources/
    ├── Strings/        # 多语言字符串
    │   ├── zh-Hans.json
    │   └── bo.json
    └── Images/         # 图片资源
```

## 技术栈

- **平台**：iOS 15.0+
- **语言**：Swift 5.7
- **UI框架**：SwiftUI
- **数据存储**：SQLite (GRDB.swift)
- **网络**：URLSession + Combine
- **通知**：UserNotifications

## 开发计划

### Phase 1: POC (当前)
- [x] 项目架构设计
- [ ] 核心引擎开发
- [ ] 农历插件实现
- [ ] 藏历插件实现
- [ ] 基础UI开发

### Phase 2: MVP
- [ ] 智能提醒系统
- [ ] 完整UI/UX
- [ ] 测试和优化

### Phase 3: 发布
- [ ] App Store 上架
- [ ] 用户反馈收集
- [ ] 迭代优化

## 开始开发

```bash
# 1. 打开项目
cd projects/MultiCalendarApp

# 2. 安装依赖（如果使用 SPM）
swift package resolve

# 3. 编译运行
# 在 Xcode 中打开 MultiCalendarApp.xcodeproj
```

## 参考资料

- [中国农历算法](https://github.com/isee15/Lunar-Solar-Calendar-Converter)
- [藏历算法](https://github.com/tibetan-calendar)
- [SwiftUI 教程](https://developer.apple.com/tutorials/swiftui)
