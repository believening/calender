# Changelog

All notable changes to this project will be documented in this file.

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
