//
//  SettingsView.swift
//  MultiCalendarApp
//
//  设置视图 - 完整版
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var pluginManager = PluginManager.shared
    
    @State private var showReminderSettings = false
    @State private var showAboutPage = false
    @State private var showExportData = false
    
    // 显示设置
    @AppStorage("showLunarByDefault") private var showLunarByDefault = true
    @AppStorage("showTibetanByDefault") private var showTibetanByDefault = false
    @AppStorage("showWeekNumbers") private var showWeekNumbers = false
    @AppStorage("firstDayOfWeek") private var firstDayOfWeek = 1 // 1=周日, 2=周一
    @AppStorage("showFestivalDots") private var showFestivalDots = true
    @AppStorage("highlightToday") private var highlightToday = true
    
    // 外观设置
    @AppStorage("colorScheme") private var colorScheme = 0 // 0=自动, 1=浅色, 2=深色
    @AppStorage("calendarTheme") private var calendarTheme = "blue"
    
    var body: some View {
        NavigationView {
            List {
                // 显示设置
                Section(header: Text("显示设置")) {
                    Toggle("默认显示农历", isOn: $showLunarByDefault)
                    Toggle("默认显示藏历", isOn: $showTibetanByDefault)
                    Toggle("显示周数", isOn: $showWeekNumbers)
                    Toggle("显示节日标记", isOn: $showFestivalDots)
                    Toggle("高亮今天", isOn: $highlightToday)
                    
                    Picker("每周第一天", selection: $firstDayOfWeek) {
                        Text("周日").tag(1)
                        Text("周一").tag(2)
                    }
                }
                
                // 外观设置
                Section(header: Text("外观")) {
                    Picker("颜色模式", selection: $colorScheme) {
                        Text("跟随系统").tag(0)
                        Text("浅色模式").tag(1)
                        Text("深色模式").tag(2)
                    }
                    
                    Picker("日历主题色", selection: $calendarTheme) {
                        Text("蓝色").tag("blue")
                        Text("绿色").tag("green")
                        Text("橙色").tag("orange")
                        Text("紫色").tag("purple")
                        Text("红色").tag("red")
                    }
                }
                
                // 提醒设置
                Section(header: Text("提醒设置")) {
                    ForEach(notificationManager.reminderRules) { rule in
                        ReminderRuleRow(rule: rule) { updatedRule in
                            notificationManager.updateReminderRule(updatedRule)
                        }
                    }
                    
                    Button(action: { showReminderSettings = true }) {
                        Label("高级提醒设置", systemImage: "bell.badge")
                    }
                }
                
                // 插件管理
                Section(header: Text("历法插件")) {
                    ForEach(CalendarType.allCases, id: \.self) { calendarType in
                        PluginRow(
                            calendarType: calendarType,
                            isInstalled: pluginManager.isPluginInstalled(identifier: calendarType.rawValue)
                        )
                    }
                    
                    NavigationLink(destination: PluginStoreView()) {
                        Label("插件商店", systemImage: "app.badge")
                    }
                }
                
                // 数据管理
                Section(header: Text("数据管理")) {
                    Button(action: { exportData() }) {
                        Label("导出数据", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(action: { importData() }) {
                        Label("导入数据", systemImage: "square.and.arrow.down")
                    }
                    
                    Button(action: { clearCache() }) {
                        Label("清除缓存", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                }
                
                // 关于
                Section(header: Text("关于")) {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("构建版本")
                        Spacer()
                        Text("2026.02.27")
                            .foregroundColor(.gray)
                    }
                    
                    NavigationLink(destination: AboutView()) {
                        Label("关于应用", systemImage: "info.circle")
                    }
                    
                    Link(destination: URL(string: "https://github.com/believening/calender")!) {
                        HStack {
                            Label("GitHub", systemImage: "link")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Link(destination: URL(string: "mailto:feedback@multicalendar.app")!) {
                        HStack {
                            Label("反馈问题", systemImage: "envelope")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    NavigationLink(destination: AcknowledgmentsView()) {
                        Label("致谢", systemImage: "heart.fill")
                    }
                }
            }
            .navigationTitle("设置")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func exportData() {
        // TODO: 实现数据导出
    }
    
    private func importData() {
        // TODO: 实现数据导入
    }
    
    private func clearCache() {
        // TODO: 实现缓存清除
    }
}

// MARK: - 插件商店视图

struct PluginStoreView: View {
    @State private var availablePlugins: [CalendarPluginMetadata] = []
    
    var body: some View {
        List {
            ForEach(availablePlugins, id: \.identifier) { plugin in
                PluginStoreRow(plugin: plugin)
            }
        }
        .navigationTitle("插件商店")
        .onAppear {
            loadAvailablePlugins()
        }
    }
    
    private func loadAvailablePlugins() {
        // TODO: 从服务器加载可用插件列表
        availablePlugins = []
    }
}

struct PluginStoreRow: View {
    let plugin: CalendarPluginMetadata
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(plugin.name)
                        .font(.headline)
                    
                    if let nameEn = plugin.nameEn {
                        Text(nameEn)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("v\(plugin.version)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if let size = plugin.resourceSize {
                        Text(ByteCountFormatter.string(fromByteCount: size, countStyle: .file))
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            if let desc = plugin.description {
                Text(desc)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            HStack {
                Label(plugin.calendarType.rawValue, systemImage: "calendar")
                    .font(.caption2)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Button("安装") {
                    // TODO: 下载并安装插件
                }
                .font(.caption)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 关于视图

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // App 图标
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                    .padding(.top, 40)
                
                // 名称和版本
                VStack(spacing: 8) {
                    Text("MultiCalendarApp")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("多民族日历整合应用")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("版本 1.0.0")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Divider()
                    .padding(.horizontal, 40)
                
                // 特性介绍
                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(icon: "moon.fill", title: "农历支持", desc: "1900-2100年完整农历算法")
                    FeatureRow(icon: "flame.fill", title: "藏历支持", desc: "五行生肖、殊胜日、九宫飞星")
                    FeatureRow(icon: "leaf.fill", title: "节气计算", desc: "24节气、三伏天、数九")
                    FeatureRow(icon: "bell.fill", title: "智能提醒", desc: "节日、初一十五自动提醒")
                    FeatureRow(icon: "puzzlepiece.fill", title: "插件架构", desc: "可扩展多种历法支持")
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // 版权信息
                VStack(spacing: 8) {
                    Text("© 2026 MultiCalendar Team")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("Made with ❤️")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let desc: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(desc)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - 致谢视图

struct AcknowledgmentsView: View {
    var body: some View {
        List {
            Section(header: Text("开源项目")) {
                AcknowledgmentRow(
                    name: "Lunar-Solar-Calendar-Converter",
                    license: "MIT",
                    url: "https://github.com/isee15/Lunar-Solar-Calendar-Converter"
                )
                
                AcknowledgmentRow(
                    name: "SwiftUI",
                    license: "Apache 2.0",
                    url: "https://developer.apple.com/xcode/swiftui/"
                )
            }
            
            Section(header: Text("数据来源")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("农历数据")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("基于中国科学院紫金山天文台发布的数据")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("藏历数据")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("参考西藏藏医院天文历算研究所资料")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
            }
            
            Section(header: Text("特别感谢")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("感谢所有为传统历法传承做出贡献的学者和开发者")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("致谢")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AcknowledgmentRow: View {
    let name: String
    let license: String
    let url: String
    
    var body: some View {
        Link(destination: URL(string: url)!) {
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.subheadline)
                
                HStack {
                    Text(license)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right.square")
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 2)
        }
    }
}

// MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
