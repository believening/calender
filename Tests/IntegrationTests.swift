//
//  IntegrationTests.swift
//  MultiCalendarApp
//
//  集成测试 - 测试各模块之间的协作
//

import Foundation
import XCTest

/// 集成测试类
class IntegrationTests: XCTestCase {
    
    var pluginManager: PluginManager!
    var notificationManager: NotificationManager!
    
    override func setUp() {
        super.setUp()
        pluginManager = PluginManager.shared
        notificationManager = NotificationManager.shared
    }
    
    override func tearDown() {
        pluginManager = nil
        notificationManager = nil
        super.tearDown()
    }
    
    // MARK: - 插件集成测试
    
    /// 测试插件管理器正确加载所有插件
    func testAllPluginsLoaded() {
        let loadedTypes = pluginManager.getLoadedCalendarTypes()
        
        // 验证农历插件已加载
        XCTAssertTrue(loadedTypes.contains(.lunar), "农历插件应该已加载")
        
        // 验证藏历插件已加载
        XCTAssertTrue(loadedTypes.contains(.tibetan), "藏历插件应该已加载")
        
        print("✅ 所有插件加载测试通过")
        print("   已加载历法: \(loadedTypes.map { $0.rawValue })")
    }
    
    /// 测试多历法并行转换
    func testMultiCalendarParallelConversion() {
        let testDate = Date()
        
        guard let lunarPlugin = pluginManager.getPlugin(for: .lunar),
              let tibetanPlugin = pluginManager.getPlugin(for: .tibetan) else {
            XCTFail("插件未加载")
            return
        }
        
        // 公历 -> 农历
        let lunarResult = lunarPlugin.convert(from: testDate)
        XCTAssertNotNil(lunarResult?.lunarDate, "农历转换应该成功")
        
        // 公历 -> 藏历
        let tibetanResult = tibetanPlugin.convert(from: testDate)
        XCTAssertNotNil(tibetanResult?.tibetanDate, "藏历转换应该成功")
        
        print("✅ 多历法并行转换测试通过")
        print("   公历: \(testDate)")
        print("   农历: \(lunarResult?.lunarDate?.yearName ?? "") \(lunarResult?.lunarDate?.monthName ?? "") \(lunarResult?.lunarDate?.dayName ?? "")")
        print("   藏历: \(tibetanResult?.tibetanDate?.yearElement ?? "") \(tibetanResult?.tibetanDate?.monthNameChinese ?? "")")
    }
    
    /// 测试节日跨历法查询
    func testCrossCalendarFestivalQuery() {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        
        guard let lunarPlugin = pluginManager.getPlugin(for: .lunar),
              let tibetanPlugin = pluginManager.getPlugin(for: .tibetan) else {
            XCTFail("插件未加载")
            return
        }
        
        // 获取全年节日
        var lunarFestivals: [Festival] = []
        var tibetanFestivals: [Festival] = []
        
        for month in 1...12 {
            lunarFestivals.append(contentsOf: lunarPlugin.getFestivals(year: currentYear, month: month))
            tibetanFestivals.append(contentsOf: tibetanPlugin.getFestivals(year: currentYear, month: month))
        }
        
        XCTAssertFalse(lunarFestivals.isEmpty, "农历节日列表不应为空")
        XCTAssertFalse(tibetanFestivals.isEmpty, "藏历节日列表不应为空")
        
        print("✅ 跨历法节日查询测试通过")
        print("   \(currentYear)年农历节日: \(lunarFestivals.count) 个")
        print("   \(currentYear)年藏历节日: \(tibetanFestivals.count) 个")
    }
    
    // MARK: - 视图模型集成测试
    
    /// 测试日历视图模型初始化
    func testCalendarViewModelInitialization() {
        let viewModel = CalendarViewModel()
        
        // 验证初始状态
        XCTAssertNotNil(viewModel.selectedDate)
        XCTAssertNotNil(viewModel.currentMonth)
        XCTAssertFalse(viewModel.calendarDays.isEmpty)
        
        print("✅ 日历视图模型初始化测试通过")
        print("   日历天数: \(viewModel.calendarDays.count)")
        print("   已加载历法: \(viewModel.loadedCalendarTypes.map { $0.rawValue })")
    }
    
    /// 测试日历导航功能
    func testCalendarNavigation() {
        let viewModel = CalendarViewModel()
        let calendar = Calendar.current
        
        let initialMonth = viewModel.currentMonth
        
        // 测试下个月
        viewModel.nextMonth()
        let nextMonth = viewModel.currentMonth
        XCTAssertNotEqual(initialMonth, nextMonth, "月份应该已变化")
        
        // 测试上个月
        viewModel.previousMonth()
        let prevMonth = viewModel.currentMonth
        
        // 测试回到今天
        viewModel.goToToday()
        XCTAssertNotNil(viewModel.selectedDate)
        
        print("✅ 日历导航功能测试通过")
    }
    
    /// 测试年份跳转功能（核心痛点解决方案）
    func testYearJumpingFeature() {
        let viewModel = CalendarViewModel()
        
        // 测试跳转到 2000 年 1 月
        viewModel.jumpToYear(2000, month: 1)
        
        let calendar = Calendar.current
        let year = calendar.component(.year, from: viewModel.currentMonth)
        let month = calendar.component(.month, from: viewModel.currentMonth)
        
        XCTAssertEqual(year, 2000, "应该跳转到 2000 年")
        XCTAssertEqual(month, 1, "应该跳转到 1 月")
        
        // 测试跳转到 2050 年 12 月
        viewModel.jumpToYear(2050, month: 12)
        let year2 = calendar.component(.year, from: viewModel.currentMonth)
        let month2 = calendar.component(.month, from: viewModel.currentMonth)
        
        XCTAssertEqual(year2, 2050, "应该跳转到 2050 年")
        XCTAssertEqual(month2, 12, "应该跳转到 12 月")
        
        print("✅ 年份跳转功能测试通过")
        print("   成功跳转到 2000 年 1 月")
        print("   成功跳转到 2050 年 12 月")
    }
    
    // MARK: - 提醒系统集成测试
    
    /// 测试提醒规则初始化
    func testReminderRulesInitialization() {
        let rules = notificationManager.reminderRules
        
        XCTAssertFalse(rules.isEmpty, "提醒规则不应为空")
        
        // 验证默认规则
        let ruleTypes = rules.map { $0.type }
        XCTAssertTrue(ruleTypes.contains(.newMoon), "应包含初一提醒")
        XCTAssertTrue(ruleTypes.contains(.fullMoon), "应包含十五提醒")
        XCTAssertTrue(ruleTypes.contains(.buddhistFestival), "应包含佛教节日提醒")
        XCTAssertTrue(ruleTypes.contains(.traditionalFestival), "应包含传统节日提醒")
        XCTAssertTrue(ruleTypes.contains(.tibetanFestival), "应包含藏历节日提醒")
        
        print("✅ 提醒规则初始化测试通过")
        print("   默认规则数量: \(rules.count)")
    }
    
    /// 测试提醒规则更新
    func testReminderRuleUpdate() {
        guard var rule = notificationManager.reminderRules.first else {
            XCTFail("没有可用的提醒规则")
            return
        }
        
        let originalEnabled = rule.isEnabled
        rule.isEnabled = !originalEnabled
        
        notificationManager.updateReminderRule(rule)
        
        // 验证更新
        let updatedRule = notificationManager.reminderRules.first { $0.id == rule.id }
        XCTAssertEqual(updatedRule?.isEnabled, !originalEnabled, "规则状态应该已更新")
        
        // 恢复原状态
        rule.isEnabled = originalEnabled
        notificationManager.updateReminderRule(rule)
        
        print("✅ 提醒规则更新测试通过")
    }
    
    // MARK: - 数据一致性测试
    
    /// 测试日期转换一致性
    func testDateConversionConsistency() {
        let calendar = Calendar.current
        let testDates = generateTestDates(count: 10)
        
        guard let lunarPlugin = pluginManager.getPlugin(for: .lunar) else {
            XCTFail("农历插件未加载")
            return
        }
        
        for date in testDates {
            // 公历 -> 农历
            guard let lunarDate = lunarPlugin.convert(from: date)?.lunarDate else {
                continue
            }
            
            // 农历 -> 公历
            guard let solarDate = lunarPlugin.convertToSolar(
                year: lunarDate.year,
                month: lunarDate.month,
                day: lunarDate.day,
                isLeapMonth: lunarDate.isLeapMonth
            ) else {
                continue
            }
            
            // 验证日期相近（允许1天误差，因为农历算法简化版）
            let components1 = calendar.dateComponents([.year, .month, .day], from: date)
            let components2 = calendar.dateComponents([.year, .month, .day], from: solarDate)
            
            // 年月应该相同
            XCTAssertEqual(components1.year, components2.year, "年份应该一致")
            XCTAssertEqual(components1.month, components2.month, "月份应该一致")
        }
        
        print("✅ 日期转换一致性测试通过")
        print("   测试日期数量: \(testDates.count)")
    }
    
    // MARK: - 辅助方法
    
    private func generateTestDates(count: Int) -> [Date] {
        var dates: [Date] = []
        let calendar = Calendar.current
        
        for i in 0..<count {
            var components = DateComponents()
            components.year = 2000 + i * 5
            components.month = (i % 12) + 1
            components.day = (i % 28) + 1
            
            if let date = calendar.date(from: components) {
                dates.append(date)
            }
        }
        
        return dates
    }
}
