//
//  CalendarViewModel.swift
//  MultiCalendarApp
//
//  日历视图模型
//

import Foundation
import Combine

/// 日历视图模型
@MainActor
class CalendarViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// 当前选中的日期
    @Published var selectedDate: Date = Date()
    
    /// 当前显示的月份
    @Published var currentMonth: Date = Date()
    
    /// 当前月份的日历数据
    @Published var calendarDays: [CalendarDay] = []
    
    /// 已加载的历法类型
    @Published var loadedCalendarTypes: [CalendarType] = []
    
    /// 是否显示农历
    @Published var showLunar: Bool = true
    
    /// 是否显示藏历
    @Published var showTibetan: Bool = false
    
    /// 当前日期的详细信息
    @Published var selectedDateInfo: CalendarDate?
    
    /// 当前月份的节日
    @Published var currentMonthFestivals: [Festival] = []
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    private let calendar = Calendar.current
    
    // MARK: - Initialization
    
    init() {
        // 监听插件加载状态
        PluginManager.shared.$loadedPlugins
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateLoadedCalendarTypes()
            }
            .store(in: &cancellables)
        
        // 初始化
        updateLoadedCalendarTypes()
        generateCalendarDays()
        loadFestivals()
    }
    
    // MARK: - Public Methods
    
    /// 选择日期
    func selectDate(_ date: Date) {
        selectedDate = date
        loadDateInfo(for: date)
    }
    
    /// 切换到上个月
    func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
            generateCalendarDays()
            loadFestivals()
        }
    }
    
    /// 切换到下个月
    func nextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
            generateCalendarDays()
            loadFestivals()
        }
    }
    
    /// 跳转到指定年月
    func jumpToYear(_ year: Int, month: Int) {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        
        if let date = calendar.date(from: components) {
            currentMonth = date
            generateCalendarDays()
            loadFestivals()
        }
    }
    
    /// 回到今天
    func goToToday() {
        selectedDate = Date()
        currentMonth = Date()
        generateCalendarDays()
        loadFestivals()
        loadDateInfo(for: Date())
    }
    
    /// 切换农历显示
    func toggleLunar() {
        showLunar.toggle()
        generateCalendarDays()
    }
    
    /// 切换藏历显示
    func toggleTibetan() {
        showTibetan.toggle()
        generateCalendarDays()
    }
    
    // MARK: - Private Methods
    
    /// 更新已加载的历法类型
    private func updateLoadedCalendarTypes() {
        loadedCalendarTypes = PluginManager.shared.getLoadedCalendarTypes()
        
        // 自动启用藏历（如果已加载）
        if loadedCalendarTypes.contains(.tibetan) && !showTibetan {
            showTibetan = true
        }
    }
    
    /// 生成日历数据
    private func generateCalendarDays() {
        var days: [CalendarDay] = []
        
        let year = calendar.component(.year, from: currentMonth)
        let month = calendar.component(.month, from: currentMonth)
        
        // 获取本月第一天
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        
        guard let firstDayOfMonth = calendar.date(from: components) else {
            return
        }
        
        // 获取本月第一天是星期几（0=周日）
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 1
        
        // 获取本月天数
        let daysInMonth = calendar.range(of: .day, in: .month, for: currentMonth)?.count ?? 30
        
        // 添加上个月的空白
        for _ in 0..<firstWeekday {
            days.append(CalendarDay(date: Date(), isEmpty: true))
        }
        
        // 添加本月日期
        for day in 1...daysInMonth {
            components.day = day
            if let date = calendar.date(from: components) {
                let calendarDay = createCalendarDay(date: date)
                days.append(calendarDay)
            }
        }
        
        calendarDays = days
    }
    
    /// 创建日历日数据
    private func createCalendarDay(date: Date) -> CalendarDay {
        var calendarDay = CalendarDay(date: date, isEmpty: false)
        
        // 公历日期
        let day = calendar.component(.day, from: date)
        calendarDay.solarDay = day
        
        // 农历日期
        if showLunar, let lunarPlugin = PluginManager.shared.getPlugin(for: .lunar),
           let calendarDate = lunarPlugin.convert(from: date),
           let lunarDate = calendarDate.lunarDate {
            calendarDay.lunarDate = lunarDate
        }
        
        // 藏历日期
        if showTibetan, let tibetanPlugin = PluginManager.shared.getPlugin(for: .tibetan),
           let calendarDate = tibetanPlugin.convert(from: date),
           let tibetanDate = calendarDate.tibetanDate {
            calendarDay.tibetanDate = tibetanDate
        }
        
        // 节日
        calendarDay.festivals = getFestivalsForDate(date)
        
        // 是否为今天
        calendarDay.isToday = calendar.isDateInToday(date)
        
        // 是否为选中日期
        calendarDay.isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        
        return calendarDay
    }
    
    /// 获取指定日期的节日
    private func getFestivalsForDate(_ date: Date) -> [Festival] {
        var festivals: [Festival] = []
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        // 农历节日
        if let lunarPlugin = PluginManager.shared.getPlugin(for: .lunar),
           let calendarDate = lunarPlugin.convert(from: date),
           let lunarDate = calendarDate.lunarDate {
            
            let lunarFestivals = lunarPlugin.getFestivals(year: year, month: month)
            festivals.append(contentsOf: lunarFestivals.filter { festival in
                if case .lunar(let m, let d) = festival.date {
                    return m == lunarDate.month && d == lunarDate.day
                }
                return false
            })
        }
        
        // 藏历节日
        if let tibetanPlugin = PluginManager.shared.getPlugin(for: .tibetan),
           let calendarDate = tibetanPlugin.convert(from: date),
           let tibetanDate = calendarDate.tibetanDate {
            
            let tibetanFestivals = tibetanPlugin.getFestivals(year: year, month: month)
            festivals.append(contentsOf: tibetanFestivals.filter { festival in
                if case .tibetan(let m, let d) = festival.date {
                    return m == tibetanDate.month && d == tibetanDate.day
                }
                return false
            })
        }
        
        return festivals
    }
    
    /// 加载节日数据
    private func loadFestivals() {
        let year = calendar.component(.year, from: currentMonth)
        let month = calendar.component(.month, from: currentMonth)
        
        var allFestivals: [Festival] = []
        
        // 农历节日
        if let lunarPlugin = PluginManager.shared.getPlugin(for: .lunar) {
            allFestivals.append(contentsOf: lunarPlugin.getFestivals(year: year, month: month))
        }
        
        // 藏历节日
        if let tibetanPlugin = PluginManager.shared.getPlugin(for: .tibetan) {
            allFestivals.append(contentsOf: tibetanPlugin.getFestivals(year: year, month: month))
        }
        
        currentMonthFestivals = allFestivals
    }
    
    /// 加载指定日期的详细信息
    private func loadDateInfo(for date: Date) {
        selectedDateInfo = nil
        
        var calendarDate = CalendarDate(solarDate: date)
        
        // 农历信息
        if let lunarPlugin = PluginManager.shared.getPlugin(for: .lunar),
           let lunarDate = lunarPlugin.convert(from: date) {
            calendarDate.lunarDate = lunarDate.lunarDate
        }
        
        // 藏历信息
        if let tibetanPlugin = PluginManager.shared.getPlugin(for: .tibetan),
           let tibetanDate = tibetanPlugin.convert(from: date) {
            calendarDate.tibetanDate = tibetanDate.tibetanDate
        }
        
        selectedDateInfo = calendarDate
    }
}

// MARK: - Supporting Types

/// 日历日数据
struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date
    let isEmpty: Bool
    
    var solarDay: Int = 0
    var lunarDate: LunarDate?
    var tibetanDate: TibetanDate?
    var festivals: [Festival] = []
    var isToday: Bool = false
    var isSelected: Bool = false
    
    /// 显示文本（优先显示节日，否则显示农历）
    var displayText: String {
        if !festivals.isEmpty {
            return festivals[0].name
        }
        if let lunarDate = lunarDate {
            if lunarDate.day == 1 {
                return lunarDate.monthName ?? "初一"
            }
            return lunarDate.dayName ?? "\(lunarDate.day)"
        }
        return ""
    }
    
    /// 藏历显示文本
    var tibetanDisplayText: String? {
        if let tibetanDate = tibetanDate {
            if tibetanDate.day == 1 {
                return tibetanDate.monthNameChinese
            }
            return tibetanDate.dayNameChinese ?? "\(tibetanDate.day)"
        }
        return nil
    }
}
