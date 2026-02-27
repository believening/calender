//
//  LunarData.swift
//  MultiCalendarApp
//
//  完整农历数据表 (1900-2100年)
//  数据格式: [年份: LunarYearInfo]
//

import Foundation

/// 农历年度信息
struct LunarYearInfo: Codable {
    let year: Int              // 农历年份
    let monthDays: [Int]       // 每月天数 (正月至腊月)
    let leapMonth: Int?        // 闰月月份 (nil表示无闰月)
    let leapMonthDays: Int?    // 闰月天数
    let springFestivalMonth: Int   // 春节所在公历月份
    let springFestivalDay: Int     // 春节所在公历日期
}

/// 完整农历数据表
/// 数据来源: 中国科学院紫金山天文台
class LunarData {
    
    // MARK: - 农历年数据
    // 每个元素代表一年，格式为16进制数
    // 低4位: 当年闰月大小(0表示无闰月,1大30天,0小29天)
    // 第5-16位: 12个月的大小月(1大30天,0小29天)，从正月开始
    // 第17-20位: 闰月月份(0表示无闰月)
    
    /// 农历数据表 (1900-2100年)
    /// 每个数字编码了该年的月份天数和闰月信息
    static let lunarInfo: [UInt32] = [
        0x04bd8, 0x04ae0, 0x0a570, 0x054d5, 0x0d260, 0x0d950, 0x16554, 0x056a0, 0x09ad0, 0x055d2, // 1900-1909
        0x04ae0, 0x0a5b6, 0x0a4d0, 0x0d250, 0x1d255, 0x0b540, 0x0d6a0, 0x0ada2, 0x095b0, 0x14977, // 1910-1919
        0x04970, 0x0a4b0, 0x0b4b5, 0x06a50, 0x06d40, 0x1ab54, 0x02b60, 0x09570, 0x052f2, 0x04970, // 1920-1929
        0x06566, 0x0d4a0, 0x0ea50, 0x06e95, 0x05ad0, 0x02b60, 0x186e3, 0x092e0, 0x1c8d7, 0x0c950, // 1930-1939
        0x0d4a0, 0x1d8a6, 0x0b550, 0x056a0, 0x1a5b4, 0x025d0, 0x092d0, 0x0d2b2, 0x0a950, 0x0b557, // 1940-1949
        0x06ca0, 0x0b550, 0x15355, 0x04da0, 0x0a5d0, 0x14573, 0x052d0, 0x0a9a8, 0x0e950, 0x06aa0, // 1950-1959
        0x0aea6, 0x0ab50, 0x04b60, 0x0aae4, 0x0a570, 0x05260, 0x0f263, 0x0d950, 0x05b57, 0x056a0, // 1960-1969
        0x096d0, 0x04dd5, 0x04ad0, 0x0a4d0, 0x0d4d4, 0x0d250, 0x0d558, 0x0b540, 0x0b5a0, 0x195a6, // 1970-1979
        0x095b0, 0x049b0, 0x0a974, 0x0a4b0, 0x0b27a, 0x06a50, 0x06d40, 0x0af46, 0x0ab60, 0x09570, // 1980-1989
        0x04af5, 0x04970, 0x064b0, 0x074a3, 0x0ea50, 0x06b58, 0x055c0, 0x0ab60, 0x096d5, 0x092e0, // 1990-1999
        0x0c960, 0x0d954, 0x0d4a0, 0x0da50, 0x07552, 0x056a0, 0x0abb7, 0x025d0, 0x092d0, 0x0cab5, // 2000-2009
        0x0a950, 0x0b4a0, 0x0baa4, 0x0ad50, 0x055d9, 0x04ba0, 0x0a5b0, 0x15176, 0x052b0, 0x0a930, // 2010-2019
        0x07954, 0x06aa0, 0x0ad50, 0x05b52, 0x04b60, 0x0a6e6, 0x0a4e0, 0x0d260, 0x0ea65, 0x0d530, // 2020-2029
        0x05aa0, 0x076a3, 0x096d0, 0x04afb, 0x04ad0, 0x0a4d0, 0x1d0b6, 0x0d250, 0x0d520, 0x0dd45, // 2030-2039
        0x0b5a0, 0x056d0, 0x055b2, 0x049b0, 0x0a577, 0x0a4b0, 0x0aa50, 0x1b255, 0x06d20, 0x0ada0, // 2040-2049
        0x14b63, 0x09370, 0x049f8, 0x04970, 0x064b0, 0x168a6, 0x0ea50, 0x06b20, 0x1a6c4, 0x0aae0, // 2050-2059
        0x0a2e0, 0x0d2e3, 0x0c960, 0x0d557, 0x0d4a0, 0x0da50, 0x05d55, 0x056a0, 0x0a6d0, 0x055d4, // 2060-2069
        0x052d0, 0x0a9b8, 0x0a950, 0x0b4a0, 0x0b6a6, 0x0ad50, 0x055a0, 0x0aba4, 0x0a5b0, 0x052b0, // 2070-2079
        0x0b273, 0x06930, 0x07337, 0x06aa0, 0x0ad50, 0x14b55, 0x04b60, 0x0a570, 0x054e4, 0x0d160, // 2080-2089
        0x0e968, 0x0d520, 0x0daa0, 0x16aa6, 0x056d0, 0x04ae0, 0x0a9d4, 0x0a2d0, 0x0d150, 0x0f252, // 2090-2099
        0x0d520                                                                  // 2100
    ]
    
    // MARK: - 节气数据
    
    /// 二十四节气名称
    static let solarTerms = [
        "小寒", "大寒", "立春", "雨水", "惊蛰", "春分",
        "清明", "谷雨", "立夏", "小满", "芒种", "夏至",
        "小暑", "大暑", "立秋", "处暑", "白露", "秋分",
        "寒露", "霜降", "立冬", "小雪", "大雪", "冬至"
    ]
    
    /// 节气计算表 (1900年小寒至2100年冬至)
    /// 每个值代表该节气相对于1900年1月1日的分钟数
    static let solarTermInfo: [Int] = [
        0, 21208, 42467, 63836, 85337, 107014, 128867, 150921, 173149, 195551, 218072, 240693,
        263343, 285989, 308563, 331033, 353350, 375494, 397447, 419210, 440795, 462224, 483532, 504758
    ]
    
    // MARK: - 常量
    
    /// 天干
    static let tianGan = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"]
    
    /// 地支
    static let diZhi = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]
    
    /// 生肖
    static let zodiacs = ["鼠", "牛", "虎", "兔", "龙", "蛇", "马", "羊", "猴", "鸡", "狗", "猪"]
    
    /// 月份名称
    static let monthNames = ["正月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "冬月", "腊月"]
    
    /// 日期名称
    static let dayNames = [
        "初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
        "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
        "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"
    ]
    
    // MARK: - 计算方法
    
    /// 获取指定年份的农历信息
    static func getYearInfo(_ year: Int) -> LunarYearInfo? {
        guard year >= 1900 && year <= 2100 else { return nil }
        
        let info = lunarInfo[year - 1900]
        
        // 解析闰月
        let leapMonth = Int((info >> 16) & 0xf)
        let hasLeapMonth = leapMonth > 0
        
        // 解析各月天数
        var monthDays: [Int] = []
        for i in 0..<12 {
            let days = (info >> (16 - i)) & 0x1
            monthDays.append(days == 1 ? 30 : 29)
        }
        
        // 闰月天数
        let leapMonthDays = hasLeapMonth ? ((info & 0x10000) != 0 ? 30 : 29) : nil
        
        return LunarYearInfo(
            year: year,
            monthDays: monthDays,
            leapMonth: hasLeapMonth ? leapMonth : nil,
            leapMonthDays: leapMonthDays,
            springFestivalMonth: 1, // 简化
            springFestivalDay: 1
        )
    }
    
    /// 获取指定年份的总天数
    static func getYearDays(_ year: Int) -> Int {
        var sum = 0
        let info = lunarInfo[year - 1900]
        
        // 计算12个月的总天数
        for i in 0..<12 {
            sum += ((info >> (16 - i)) & 0x1) == 1 ? 30 : 29
        }
        
        // 加上闰月天数
        if let leapMonth = getLeapMonth(year) {
            sum += (info & 0x10000) != 0 ? 30 : 29
        }
        
        return sum
    }
    
    /// 获取闰月月份
    static func getLeapMonth(_ year: Int) -> Int? {
        guard year >= 1900 && year <= 2100 else { return nil }
        let info = lunarInfo[year - 1900]
        let leapMonth = Int((info >> 16) & 0xf)
        return leapMonth > 0 ? leapMonth : nil
    }
    
    /// 获取指定月份的天数
    static func getMonthDays(_ year: Int, month: Int, isLeapMonth: Bool = false) -> Int {
        guard year >= 1900 && year <= 2100 else { return 30 }
        let info = lunarInfo[year - 1900]
        
        if isLeapMonth {
            return (info & 0x10000) != 0 ? 30 : 29
        } else {
            return ((info >> (16 - month + 1)) & 0x1) == 1 ? 30 : 29
        }
    }
    
    /// 计算从1900年1月31日(农历1900年正月初一)到指定日期的总天数
    static func getDaysFrom1900(year: Int, month: Int, day: Int, isLeapMonth: Bool = false) -> Int {
        var days = 0
        
        // 累加年份天数
        for y in 1900..<year {
            days += getYearDays(y)
        }
        
        // 累加月份天数
        let leapMonth = getLeapMonth(year)
        for m in 1..<month {
            days += getMonthDays(year, month: m)
            
            // 如果有闰月且闰月小于当前月，加上闰月天数
            if let lm = leapMonth, lm < m {
                days += getMonthDays(year, month: lm, isLeapMonth: true)
            }
        }
        
        // 如果是闰月
        if isLeapMonth {
            days += getMonthDays(year, month: month) // 先加正常月
        }
        
        // 加上当月天数
        days += day - 1
        
        return days
    }
}
