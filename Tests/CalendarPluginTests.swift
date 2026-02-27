//
//  CalendarPluginTests.swift
//  MultiCalendarAppTests
//
//  测试用例
//

import XCTest
@testable import MultiCalendarApp

class CalendarPluginTests: XCTestCase {
    
    var lunarPlugin: LunarCalendarPlugin!
    var tibetanPlugin: TibetanCalendarPlugin!
    
    override func setUp() {
        super.setUp()
        lunarPlugin = LunarCalendarPlugin()
        tibetanPlugin = TibetanCalendarPlugin()
    }
    
    override func tearDown() {
        lunarPlugin = nil
        tibetanPlugin = nil
        super.tearDown()
    }
    
    // MARK: - 农历插件测试
    
    func testLunarPluginInfo() {
        XCTAssertEqual(lunarPlugin.identifier, "com.multicalendar.lunar")
        XCTAssertEqual(lunarPlugin.name, "农历")
        XCTAssertEqual(lunarPlugin.calendarType, .lunar)
        XCTAssertTrue(lunarPlugin.supportedYearRange.contains(2026))
    }
    
    func testSolarToLunarConversion() {
        // 测试公历转农历
        let date = Date() // 当前日期
        let calendarDate = lunarPlugin.convert(from: date)
        
        XCTAssertNotNil(calendarDate)
        XCTAssertNotNil(calendarDate?.lunarDate)
        
        print("公历 \(date) 转换为农历: \(calendarDate?.lunarDate?.yearName ?? "") \(calendarDate?.lunarDate?.monthName ?? "") \(calendarDate?.lunarDate?.dayName ?? "")")
    }
    
    func testLunarFestivals() {
        // 测试节日查询
        let festivals = lunarPlugin.getFestivals(year: 2026, month: 1)
        XCTAssertFalse(festivals.isEmpty)
        
        // 应该包含春节
        let springFestival = festivals.first { $0.name == "春节" }
        XCTAssertNotNil(springFestival)
        
        print("农历一月节日数量: \(festivals.count)")
        festivals.forEach { print("  - \($0.name)") }
    }
    
    func testLunarYearRange() {
        // 测试支持的年份范围
        XCTAssertTrue(lunarPlugin.supportedYearRange.contains(1900))
        XCTAssertTrue(lunarPlugin.supportedYearRange.contains(2100))
        XCTAssertFalse(lunarPlugin.supportedYearRange.contains(1899))
        XCTAssertFalse(lunarPlugin.supportedYearRange.contains(2101))
    }
    
    // MARK: - 藏历插件测试
    
    func testTibetanPluginInfo() {
        XCTAssertEqual(tibetanPlugin.identifier, "com.multicalendar.tibetan")
        XCTAssertEqual(tibetanPlugin.name, "藏历")
        XCTAssertEqual(tibetanPlugin.calendarType, .tibetan)
        XCTAssertTrue(tibetanPlugin.supportedYearRange.contains(2026))
    }
    
    func testSolarToTibetanConversion() {
        // 测试公历转藏历
        let date = Date()
        let calendarDate = tibetanPlugin.convert(from: date)
        
        XCTAssertNotNil(calendarDate)
        XCTAssertNotNil(calendarDate?.tibetanDate)
        
        print("公历 \(date) 转换为藏历: \(calendarDate?.tibetanDate?.yearElement ?? "") \(calendarDate?.tibetanDate?.monthNameChinese ?? "")")
    }
    
    func testTibetanFestivals() {
        // 测试藏历节日
        let festivals = tibetanPlugin.getFestivals(year: 2026, month: 1)
        XCTAssertFalse(festivals.isEmpty)
        
        // 应该包含藏历新年
        let losar = festivals.first { $0.name == "藏历新年" }
        XCTAssertNotNil(losar)
        XCTAssertNotNil(losar?.nameTibetan)
        
        print("藏历一月节日数量: \(festivals.count)")
        festivals.forEach { print("  - \($0.name) (\($0.nameTibetan ?? ""))") }
    }
    
    func testTibetanSpecialDates() {
        // 测试殊胜日
        let date = Date()
        let specialDate = tibetanPlugin.isSpecialDate(date: date)
        
        // 检查返回值是否为 nil 或有值
        if let (isSpecial, description) = specialDate {
            print("今天是否殊胜日: \(isSpecial)")
            if isSpecial {
                print("描述: \(description ?? "")")
            }
        }
    }
    
    // MARK: - 插件管理器测试
    
    func testPluginManagerRegistration() {
        let manager = PluginManager.shared
        
        // 测试农历插件注册
        let lunar = manager.getPlugin(for: .lunar)
        XCTAssertNotNil(lunar)
        
        // 测试藏历插件注册
        let tibetan = manager.getPlugin(for: .tibetan)
        XCTAssertNotNil(tibetan)
        
        // 测试已加载的历法类型
        let types = manager.getLoadedCalendarTypes()
        XCTAssertTrue(types.contains(.lunar))
        XCTAssertTrue(types.contains(.tibetan))
        
        print("已加载的历法类型: \(types.map { $0.rawValue })")
    }
    
    // MARK: - 提醒管理器测试
    
    func testNotificationManagerRules() {
        let manager = NotificationManager.shared
        
        // 检查默认提醒规则
        XCTAssertFalse(manager.reminderRules.isEmpty)
        
        // 检查是否包含初一十五提醒
        let newMoonRule = manager.reminderRules.first { $0.type == .newMoon }
        XCTAssertNotNil(newMoonRule)
        
        let fullMoonRule = manager.reminderRules.first { $0.type == .fullMoon }
        XCTAssertNotNil(fullMoonRule)
        
        print("提醒规则数量: \(manager.reminderRules.count)")
        manager.reminderRules.forEach { print("  - \($0.name): \($0.isEnabled ? "启用" : "禁用")") }
    }
    
    // MARK: - 日期转换测试
    
    func testDateConversionRoundTrip() {
        // 测试日期转换往返（公历 -> 农历 -> 公历）
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2026
        components.month = 2
        components.day = 25
        
        guard let originalDate = calendar.date(from: components) else {
            XCTFail("Failed to create date")
            return
        }
        
        // 公历转农历
        guard let lunarDate = lunarPlugin.convert(from: originalDate)?.lunarDate else {
            XCTFail("Failed to convert to lunar date")
            return
        }
        
        print("原公历: 2026-02-25")
        print("农历: \(lunarDate.yearName ?? "") \(lunarDate.monthName ?? "") \(lunarDate.dayName ?? "")")
        
        // 农历转公历
        let solarDate = lunarPlugin.convertToSolar(year: lunarDate.year, month: lunarDate.month, day: lunarDate.day, isLeapMonth: lunarDate.isLeapMonth)
        
        XCTAssertNotNil(solarDate)
        
        if let resultDate = solarDate {
            let resultComponents = calendar.dateComponents([.year, .month, .day], from: resultDate)
            print("转换后公历: \(resultComponents.year ?? 0)-\(resultComponents.month ?? 0)-\(resultComponents.day ?? 0)")
        }
    }
    
    // MARK: - 性能测试
    
    func testConversionPerformance() {
        // 测试转换性能
        measure {
            for _ in 0..<100 {
                _ = lunarPlugin.convert(from: Date())
                _ = tibetanPlugin.convert(from: Date())
            }
        }
    }
    
    func testFestivalQueryPerformance() {
        // 测试节日查询性能
        measure {
            for _ in 0..<100 {
                _ = lunarPlugin.getFestivals(year: 2026, month: 1)
                _ = tibetanPlugin.getFestivals(year: 2026, month: 1)
            }
        }
    }
}
