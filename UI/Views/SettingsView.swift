//
//  SettingsView.swift
//  MultiCalendarApp
//
//  设置视图
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var pluginManager = PluginManager.shared
    
    @State private var showReminderSettings = false
    
    var body: some View {
        NavigationView {
            List {
                // 提醒设置
                Section(header: Text("提醒设置")) {
                    ForEach(notificationManager.reminderRules) { rule in
                        ReminderRuleRow(rule: rule) { updatedRule in
                            notificationManager.updateReminderRule(updatedRule)
                        }
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
                        Text("开发者")
                        Spacer()
                        Text("MultiCalendar Team")
                            .foregroundColor(.gray)
                    }
                    
                    Link(destination: URL(string: "https://github.com/multicalendar")!) {
                        HStack {
                            Text("GitHub")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.gray)
                        }
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
}

// MARK: - 提醒规则行

struct ReminderRuleRow: View {
    let rule: ReminderRule
    let onUpdate: (ReminderRule) -> Void
    
    @State private var isEnabled: Bool
    @State private var advanceDays: Int
    @State private var showTimePicker = false
    
    init(rule: ReminderRule, onUpdate: @escaping (ReminderRule) -> Void) {
        self.rule = rule
        self.onUpdate = onUpdate
        _isEnabled = State(initialValue: rule.isEnabled)
        _advanceDays = State(initialValue: rule.advanceDays)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(rule.name)
                    .font(.subheadline)
                
                Spacer()
                
                Toggle("", isOn: $isEnabled)
                    .labelsHidden()
                    .onChange(of: isEnabled) { newValue in
                        var updatedRule = rule
                        updatedRule.isEnabled = newValue
                        onUpdate(updatedRule)
                    }
            }
            
            if isEnabled {
                HStack {
                    Text("提前")
                    
                    Picker("", selection: $advanceDays) {
                        Text("当天").tag(0)
                        Text("1天").tag(1)
                        Text("3天").tag(3)
                        Text("7天").tag(7)
                    }
                    .pickerStyle(.menu)
                    .onChange(of: advanceDays) { newValue in
                        var updatedRule = rule
                        updatedRule.advanceDays = newValue
                        onUpdate(updatedRule)
                    }
                    
                    Text("提醒")
                    
                    Spacer()
                    
                    Text(rule.reminderTime)
                        .foregroundColor(.blue)
                        .onTapGesture {
                            showTimePicker = true
                        }
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
        }
        .sheet(isPresented: $showTimePicker) {
            TimePickerView(time: rule.reminderTime) { selectedTime in
                var updatedRule = rule
                updatedRule.reminderTime = selectedTime
                onUpdate(updatedRule)
                showTimePicker = false
            }
        }
    }
}

// MARK: - 插件行

struct PluginRow: View {
    let calendarType: CalendarType
    let isInstalled: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(calendarType.rawValue)
                    .font(.subheadline)
                
                Text(statusText)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if isInstalled {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Button("下载") {
                    // TODO: 下载插件
                }
                .font(.caption)
                .buttonStyle(.bordered)
            }
        }
    }
    
    private var statusText: String {
        if isInstalled {
            return "已安装"
        } else {
            return "未安装"
        }
    }
}

// MARK: - 时间选择器

struct TimePickerView: View {
    let time: String
    let onSelect: (String) -> Void
    
    @State private var hour: Int
    @State private var minute: Int
    
    init(time: String, onSelect: @escaping (String) -> Void) {
        self.time = time
        self.onSelect = onSelect
        
        let components = time.split(separator: ":")
        _hour = State(initialValue: Int(components[0]) ?? 9)
        _minute = State(initialValue: Int(components[1]) ?? 0)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack(spacing: 0) {
                    Picker("小时", selection: $hour) {
                        ForEach(0..<24, id: \.self) { h in
                            Text(String(format: "%02d", h))
                                .tag(h)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100)
                    
                    Text(":")
                        .font(.title)
                    
                    Picker("分钟", selection: $minute) {
                        ForEach([0, 15, 30, 45], id: \.self) { m in
                            Text(String(format: "%02d", m))
                                .tag(m)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100)
                }
                
                Spacer()
                
                Button("确定") {
                    let timeString = String(format: "%02d:%02d", hour, minute)
                    onSelect(timeString)
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .navigationTitle("选择时间")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("取消") {
                        onSelect(time)
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
