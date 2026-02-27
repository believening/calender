//
//  NotificationManager.swift
//  MultiCalendarApp
//
//  提醒管理器 - 负责节日提醒、初一十五提醒等
//

import Foundation
import UserNotifications
import Combine

/// 提醒管理器
class NotificationManager: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = NotificationManager()
    
    // MARK: - Published Properties
    
    @Published var reminderRules: [ReminderRule] = []
    @Published var isNotificationEnabled: Bool = false
    
    // MARK: - Private Properties
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let defaults = UserDefaults.standard
    private let reminderRulesKey = "reminderRules"
    
    // MARK: - Initialization
    
    private init() {
        loadReminderRules()
        checkNotificationStatus()
    }
    
    // MARK: - 权限管理
    
    /// 请求通知权限
    func requestNotificationPermission() async -> Bool {
        do {
            let options: UNAuthorizationOptions = [.alert, .sound, .badge]
            let granted = try await notificationCenter.requestAuthorization(options: options)
            await MainActor.run {
                self.isNotificationEnabled = granted
            }
            return granted
        } catch {
            print("Failed to request notification permission: \(error)")
            return false
        }
    }
    
    /// 检查通知状态
    func checkNotificationStatus() {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isNotificationEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - 提醒规则管理
    
    /// 加载提醒规则
    private func loadReminderRules() {
        if let data = defaults.data(forKey: reminderRulesKey),
           let rules = try? JSONDecoder().decode([ReminderRule].self, from: data) {
            reminderRules = rules
        } else {
            // 默认规则
            reminderRules = [
                ReminderRule(
                    id: "new-moon",
                    name: "初一提醒",
                    type: .newMoon,
                    isEnabled: true,
                    advanceDays: 0,
                    reminderTime: "09:00"
                ),
                ReminderRule(
                    id: "full-moon",
                    name: "十五提醒",
                    type: .fullMoon,
                    isEnabled: true,
                    advanceDays: 0,
                    reminderTime: "09:00"
                ),
                ReminderRule(
                    id: "buddhist-festival",
                    name: "佛教节日提醒",
                    type: .buddhistFestival,
                    isEnabled: true,
                    advanceDays: 1,
                    reminderTime: "08:00"
                ),
                ReminderRule(
                    id: "traditional-festival",
                    name: "传统节日提醒",
                    type: .traditionalFestival,
                    isEnabled: true,
                    advanceDays: 0,
                    reminderTime: "09:00"
                ),
                ReminderRule(
                    id: "tibetan-festival",
                    name: "藏历节日提醒",
                    type: .tibetanFestival,
                    isEnabled: true,
                    advanceDays: 1,
                    reminderTime: "08:00"
                )
            ]
            saveReminderRules()
        }
    }
    
    /// 保存提醒规则
    func saveReminderRules() {
        if let data = try? JSONEncoder().encode(reminderRules) {
            defaults.set(data, forKey: reminderRulesKey)
        }
    }
    
    /// 更新提醒规则
    func updateReminderRule(_ rule: ReminderRule) {
        if let index = reminderRules.firstIndex(where: { $0.id == rule.id }) {
            reminderRules[index] = rule
            saveReminderRules()
            scheduleAllReminders()
        }
    }
    
    /// 添加自定义提醒规则
    func addCustomReminderRule(name: String, date: Date) {
        let rule = ReminderRule(
            id: UUID().uuidString,
            name: name,
            type: .custom,
            isEnabled: true,
            advanceDays: 0,
            reminderTime: "09:00"
        )
        reminderRules.append(rule)
        saveReminderRules()
        scheduleCustomReminder(rule: rule, date: date)
    }
    
    /// 删除提醒规则
    func deleteReminderRule(id: String) {
        reminderRules.removeAll { $0.id == id }
        saveReminderRules()
        cancelReminder(id: id)
    }
    
    // MARK: - 提醒调度
    
    /// 调度所有提醒
    func scheduleAllReminders() {
        // 取消所有现有提醒
        notificationCenter.removeAllPendingNotificationRequests()
        
        // 为每个启用的规则调度提醒
        for rule in reminderRules where rule.isEnabled {
            scheduleReminders(for: rule)
        }
    }
    
    /// 为特定规则调度提醒
    private func scheduleReminders(for rule: ReminderRule) {
        switch rule.type {
        case .newMoon:
            scheduleNewMoonReminders(rule: rule)
        case .fullMoon:
            scheduleFullMoonReminders(rule: rule)
        case .buddhistFestival:
            scheduleBuddhistFestivalReminders(rule: rule)
        case .traditionalFestival:
            scheduleTraditionalFestivalReminders(rule: rule)
        case .tibetanFestival:
            scheduleTibetanFestivalReminders(rule: rule)
        case .custom:
            break  // 自定义提醒单独处理
        case .solarTerm:
            scheduleSolarTermReminders(rule: rule)
        }
    }
    
    /// 调度初一提醒
    private func scheduleNewMoonReminders(rule: ReminderRule) {
        let calendar = Calendar.current
        let currentDate = Date()
        
        // 获取未来12个月的初一日期
        for monthOffset in 0..<12 {
            if let date = calendar.date(byAdding: .month, value: monthOffset, to: currentDate),
               let year = calendar.dateComponents([.year], from: date).year,
               let month = calendar.dateComponents([.month], from: date).month {
                
                // 计算农历初一对应的公历日期
                if let lunarPlugin = PluginManager.shared.getPlugin(for: .lunar),
                   let solarDate = lunarPlugin.convertToSolar(year: year, month: month, day: 1) {
                    scheduleReminder(
                        id: "\(rule.id)-\(year)-\(month)",
                        title: "初一提醒",
                        body: "今天是农历\(month)月初一",
                        date: solarDate,
                        time: rule.reminderTime,
                        advanceDays: rule.advanceDays
                    )
                }
            }
        }
    }
    
    /// 调度十五提醒
    private func scheduleFullMoonReminders(rule: ReminderRule) {
        let calendar = Calendar.current
        let currentDate = Date()
        
        // 获取未来12个月的十五日期
        for monthOffset in 0..<12 {
            if let date = calendar.date(byAdding: .month, value: monthOffset, to: currentDate),
               let year = calendar.dateComponents([.year], from: date).year,
               let month = calendar.dateComponents([.month], from: date).month {
                
                // 计算农历十五对应的公历日期
                if let lunarPlugin = PluginManager.shared.getPlugin(for: .lunar),
                   let solarDate = lunarPlugin.convertToSolar(year: year, month: month, day: 15) {
                    scheduleReminder(
                        id: "\(rule.id)-\(year)-\(month)",
                        title: "十五提醒",
                        body: "今天是农历\(month)月十五",
                        date: solarDate,
                        time: rule.reminderTime,
                        advanceDays: rule.advanceDays
                    )
                }
            }
        }
    }
    
    /// 调度佛教节日提醒
    private func scheduleBuddhistFestivalReminders(rule: ReminderRule) {
        guard let lunarPlugin = PluginManager.shared.getPlugin(for: .lunar) else { return }
        
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        
        // 获取今年和明年的佛教节日
        for year in [currentYear, currentYear + 1] {
            let festivals = lunarPlugin.getFestivals(year: year)
            let buddhistFestivals = festivals.filter { $0.type == .buddhist }
            
            for festival in buddhistFestivals {
                if case .lunar(let month, let day) = festival.date,
                   let solarDate = lunarPlugin.convertToSolar(year: year, month: month, day: day) {
                    scheduleReminder(
                        id: "\(rule.id)-\(festival.id)",
                        title: festival.name,
                        body: festival.description ?? "佛教殊胜日",
                        date: solarDate,
                        time: rule.reminderTime,
                        advanceDays: rule.advanceDays
                    )
                }
            }
        }
    }
    
    /// 调度传统节日提醒
    private func scheduleTraditionalFestivalReminders(rule: ReminderRule) {
        guard let lunarPlugin = PluginManager.shared.getPlugin(for: .lunar) else { return }
        
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        
        for year in [currentYear, currentYear + 1] {
            let festivals = lunarPlugin.getFestivals(year: year)
            let traditionalFestivals = festivals.filter { $0.type == .traditional }
            
            for festival in traditionalFestivals {
                if case .lunar(let month, let day) = festival.date,
                   let solarDate = lunarPlugin.convertToSolar(year: year, month: month, day: day) {
                    scheduleReminder(
                        id: "\(rule.id)-\(festival.id)",
                        title: festival.name,
                        body: festival.description ?? "传统节日",
                        date: solarDate,
                        time: rule.reminderTime,
                        advanceDays: rule.advanceDays
                    )
                }
            }
        }
    }
    
    /// 调度藏历节日提醒
    private func scheduleTibetanFestivalReminders(rule: ReminderRule) {
        guard let tibetanPlugin = PluginManager.shared.getPlugin(for: .tibetan) else { return }
        
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        
        for year in [currentYear, currentYear + 1] {
            let festivals = tibetanPlugin.getFestivals(year: year)
            
            for festival in festivals {
                if case .tibetan(let month, let day) = festival.date,
                   let solarDate = tibetanPlugin.convertToSolar(year: year, month: month, day: day) {
                    scheduleReminder(
                        id: "\(rule.id)-\(festival.id)",
                        title: festival.name,
                        body: festival.description ?? "藏历节日",
                        date: solarDate,
                        time: rule.reminderTime,
                        advanceDays: rule.advanceDays
                    )
                }
            }
        }
    }
    
    /// 调度节气提醒
    private func scheduleSolarTermReminders(rule: ReminderRule) {
        // TODO: 实现节气提醒
    }
    
    /// 调度自定义提醒
    private func scheduleCustomReminder(rule: ReminderRule, date: Date) {
        scheduleReminder(
            id: rule.id,
            title: rule.name,
            body: "您设置的提醒",
            date: date,
            time: rule.reminderTime,
            advanceDays: rule.advanceDays
        )
    }
    
    // MARK: - 通知创建
    
    /// 创建并调度通知
    private func scheduleReminder(
        id: String,
        title: String,
        body: String,
        date: Date,
        time: String,
        advanceDays: Int
    ) {
        let calendar = Calendar.current
        
        // 解析时间
        let timeComponents = time.split(separator: ":")
        guard let hour = Int(timeComponents[0]),
              let minute = Int(timeComponents[1]) else {
            return
        }
        
        // 计算提醒日期（可能提前几天）
        var reminderDate = date
        if advanceDays > 0 {
            reminderDate = calendar.date(byAdding: .day, value: -advanceDays, to: date) ?? date
        }
        
        // 设置提醒时间
        var components = calendar.dateComponents([.year, .month, .day], from: reminderDate)
        components.hour = hour
        components.minute = minute
        
        guard let notificationDate = calendar.date(from: components) else {
            return
        }
        
        // 只调度未来的提醒
        guard notificationDate > Date() else {
            return
        }
        
        // 创建通知内容
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        
        // 创建触发器
        let triggerDate = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        // 创建请求
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        // 添加通知
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
    
    /// 取消提醒
    func cancelReminder(id: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    /// 取消所有提醒
    func cancelAllReminders() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
}
