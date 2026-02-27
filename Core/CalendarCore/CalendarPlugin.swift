//
//  CalendarPlugin.swift
//  MultiCalendarApp
//
//  日历插件协议定义
//

import Foundation

/// 日历插件协议
protocol CalendarPlugin {
    
    // MARK: - 插件信息
    
    /// 插件标识符（唯一）
    var identifier: String { get }
    
    /// 插件名称
    var name: String { get }
    
    /// 插件版本
    var version: String { get }
    
    /// 历法类型
    var calendarType: CalendarType { get }
    
    /// 支持的年份范围
    var supportedYearRange: ClosedRange<Int> { get }
    
    /// 插件元数据
    var metadata: CalendarPluginMetadata { get }
    
    // MARK: - 核心功能
    
    /// 将公历日期转换为该历法日期
    /// - Parameter date: 公历日期
    /// - Returns: 转换后的日历日期
    func convert(from date: Date) -> CalendarDate?
    
    /// 将该历法日期转换为公历日期
    /// - Parameter year: 年
    /// - Parameter month: 月
    /// - Parameter day: 日
    /// - Parameter isLeapMonth: 是否闰月（农历用）
    /// - Returns: 公历日期
    func convertToSolar(year: Int, month: Int, day: Int, isLeapMonth: Bool) -> Date?
    
    /// 获取指定月份的所有节日
    /// - Parameters:
    ///   - year: 年
    ///   - month: 月
    /// - Returns: 节日列表
    func getFestivals(year: Int, month: Int) -> [Festival]
    
    /// 获取指定日期的详细信息（宜忌等）
    /// - Parameter date: 日期
    /// - Returns: 每日信息
    func getDailyInfo(date: Date) -> DailyInfo?
    
    // MARK: - 可选功能
    
    /// 获取指定年份的所有节日
    /// - Parameter year: 年
    /// - Returns: 节日列表
    func getFestivals(year: Int) -> [Festival]
    
    /// 获取节气（如果支持）
    /// - Parameter year: 年
    /// - Returns: 节气列表
    func getSolarTerms(year: Int) -> [Festival]?
    
    /// 检查是否为特殊日期（如：佛教殊胜日）
    /// - Parameter date: 日期
    /// - Returns: 是否特殊日期及描述
    func isSpecialDate(date: Date) -> (Bool, String?)?
}

// MARK: - 默认实现

extension CalendarPlugin {
    
    func getFestivals(year: Int) -> [Festival] {
        var allFestivals: [Festival] = []
        for month in 1...12 {
            allFestivals.append(contentsOf: getFestivals(year: year, month: month))
        }
        return allFestivals
    }
    
    func getSolarTerms(year: Int) -> [Festival]? {
        return nil
    }
    
    func isSpecialDate(date: Date) -> (Bool, String?)? {
        return nil
    }
}

// MARK: - 插件基类

/// 日历插件基类（提供通用功能）
class BaseCalendarPlugin: CalendarPlugin {
    
    let identifier: String
    let name: String
    let version: String
    let calendarType: CalendarType
    let supportedYearRange: ClosedRange<Int>
    var metadata: CalendarPluginMetadata {
        return CalendarPluginMetadata(
            identifier: identifier,
            name: name,
            nameEn: nil,
            version: version,
            author: nil,
            description: nil,
            calendarType: calendarType,
            minYear: supportedYearRange.lowerBound,
            maxYear: supportedYearRange.upperBound,
            supportedLanguages: ["zh-Hans"],
            downloadURL: nil,
            resourceVersion: nil,
            resourceSize: nil
        )
    }
    
    init(identifier: String, name: String, version: String, calendarType: CalendarType, supportedYearRange: ClosedRange<Int>) {
        self.identifier = identifier
        self.name = name
        self.version = version
        self.calendarType = calendarType
        self.supportedYearRange = supportedYearRange
    }
    
    func convert(from date: Date) -> CalendarDate? {
        fatalError("Must override convert(from:)")
    }
    
    func convertToSolar(year: Int, month: Int, day: Int, isLeapMonth: Bool) -> Date? {
        fatalError("Must override convertToSolar")
    }
    
    func getFestivals(year: Int, month: Int) -> [Festival] {
        return []
    }
    
    func getDailyInfo(date: Date) -> DailyInfo? {
        return nil
    }
}
