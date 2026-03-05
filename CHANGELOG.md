# Changelog

All notable changes to this project will be documented in this file.

## [1.3.0] - 2026-03-05

### Changed
- 🎨 **UI/UX 全面升级** - 采用 Soft UI Evolution 设计系统
  - 更新配色方案：薰衣草紫 (#8B5CF6) 替代旧紫色
  - 增强阴影效果：多层阴影提升视觉深度
  - 优化动画时长：250ms 平滑过渡
  - 改进卡片样式：统一圆角和阴影
  - 统一主题配色：日历视图和设置面板使用相同色系

### Fixed
- 🐛 **修复设置页面配色不一致问题**
  - 统一 BottomSheet 设置面板和独立设置页面的配色
  - 更新所有旧紫色引用 (#6B5B95) 为新设计色 (#8B5CF6)
  - 更新渐变色 (#8B7BC8 → #A78BFA)

### Improved
- ✨ **提升可访问性**
  - 文字对比度符合 WCAG AA+ 标准
  - 改进焦点状态和悬停反馈
  - 更好的暗色模式支持

- 📱 **优化组件样式**
  - FAB (悬浮按钮) 增强阴影和交互
  - 日历网格选中状态渐变优化
  - 导航按钮和开关颜色统一

## [1.2.3] - 2026-03-04

### Fixed
- 🐛 **修复重复的方法名导致的编译错误**
  - 错误：`_buildCalendarSection` is already declared in this scope
  - 将设置面板中的方法重命名为 `_buildCalendarSettingsSection`
  - 验证通过 ✅ GitHub Actions 构建成功

## [1.2.2] - 2026-03-04

### Fixed
- 🐛 **修复 BottomSheet 中无法访问 Provider 的问题** - 修复部署失败
  - BottomSheet 的 builder context 无法访问顶层的 Provider
  - 使用 MultiProvider + ChangeNotifierProvider.value 重新提供 Provider 实例
  - Consumer2 现在可以正常工作，UI 会响应设置变更

## [1.2.1] - 2026-03-03

### Fixed
- 🐛 **修复设置页面功能** - 所有设置现在都可以正常工作
  - 语言切换功能正常（中文、藏文、英文）
  - 历法显示开关正常（农历、藏历、节日、宜忌）
  - 主历法选择器正常（农历、藏历）
  - 插件管理可以启用/禁用插件

### Changed
- 🎨 **优化设置面板 UI**
  - 使用 `DraggableScrollableSheet` 替代固定高度
  - 支持拖动调整高度（50%-95%）
  - 添加滚动控制器，内容过长时可滚动
  - 将简化版设置面板替换为完整功能版

## [1.2.0] - 2026-03-03

### Added
- 🎯 **主历法切换功能** - 核心功能升级
  - 新增 `CalendarSettingsProvider` 管理历法设置
  - 设置页面添加"主历法选择器"（支持农历、藏历）
  - 日历网格根据主历法动态显示对应日期
  - 年份信息卡片根据主历法显示不同内容（农历：生肖年，藏历：绕迥纪年）
  - 日期详情区域智能显示主历法和其他历法信息

- 🎨 **UI 动态适配**
  - 不同历法使用不同配色（农历：绿色，藏历：黄色）
  - 卡片样式根据历法类型自动调整
  - 优化历法信息显示逻辑

### Changed
- 🔧 **架构优化**
  - 全局注入 `CalendarSettingsProvider` 状态管理
  - 所有组件自动响应历法设置变化
  - 设置页面的历法开关改为真实功能（之前是硬编码）

- 📝 **文档更新**
  - 添加 `IMPLEMENTATION_SUMMARY.md` 详细记录功能实现
  - 更新 README.md 说明主历法切换功能

### Technical Details
- 保持插件化架构不变，无需修改历法插件
- 扩展性强，易于添加新历法支持
- 状态管理清晰，使用 Provider 模式

## [1.1.0] - 2026-03-02

### Added
- 🌐 多语言支持
  - 添加中文翻译 (zh_CN)
  - 添加藏文翻译 (bo_CN)
  - 添加英文翻译 (en_US)
  - 创建 LocaleProvider 管理语言状态

- ⚙️ 设置页面
  - 语言切换功能
  - 历法显示开关
  - 插件管理列表
  - 关于信息弹窗

### Changed
- 🎨 UI 现代化设计
  - 应用 superdesign 设计原则
  - 使用柔和紫色系配色
  - 大圆角卡片设计（28px）
  - 添加入场动画
  - 优化日期单元格样式

- 🏔️ 藏历显示改进
  - 添加绕迥纪年信息卡片
  - 显示藏文月份名称
  - 标记殊胜日（橙色点）
  - 显示缺日/重日状态
  - 节日标签支持藏文显示

### Fixed
- 🐛 修正藏历生肖顺序（兔→龙→蛇...而非鼠→牛→虎...）
- 🐛 修正五行计算公式
- 🐛 改进公历⇔藏历转换算法

## [1.0.0] - 2026-02-XX

### Added
- ✅ 农历完整算法 (1900-2100)
- ✅ 藏历基础算法
- ✅ 二十四节气计算
- ✅ 三伏天/数九计算
- ✅ 插件架构 (CalendarPlugin + PluginManager)
- ✅ Flutter 基础 UI
- ✅ 跨平台支持 (Android/iOS/Web/Desktop)
