//
//  LunarAlgorithm.swift
//  MultiCalendarApp
//
//  完整农历转换算法
//

import Foundation

/// 农历算法引擎
class LunarAlgorithm {
    
    // MARK: - 农历转公历
    
    /// 农历转公历
    /// - Parameters:
    ///   - year: 农历年
    ///   - month: 农历月
    ///   - day: 农历日
    ///   - isLeapMonth: 是否闰月
    /// - Returns: 公历日期
    static func lunarToSolar(year: Int, month: Int, day: Int, isLeapMonth: Bool = false) -> Date? {
        // 参数校验
        guard year >= 1900 && year <= 2100 else { return nil }
        guard month >= 1 && month <= 12 else { return nil }
        guard day >= 1 && day <= 30 else { return nil }
        
        // 计算从1900年1月31日(农历正月初一)到目标日期的天数
        var offset = 0
        
        // 累加年份天数
        for y in 1900..<year {
            offset += LunarData.getYearDays(y)
        }
        
        // 获取闰月信息
        let leapMonth = LunarData.getLeapMonth(year)
        
        // 累加月份天数
        if isLeapMonth {
            // 如果是闰月，先加上正常月份的天数
            for m in 1...month {
                offset += LunarData.getMonthDays(year, month: m)
            }
        } else {
            for m in 1..<month {
                offset += LunarData.getMonthDays(year, month: m)
                
                // 如果有闰月且闰月小于当前月，加上闰月天数
                if let lm = leapMonth, lm == m {
                    offset += LunarData.getMonthDays(year, month: lm, isLeapMonth: true)
                }
            }
        }
        
        // 加上当月天数
        offset += day - 1
        
        // 从1900年1月31日开始计算
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai")!
        
        let baseDate = DateComponents(calendar: calendar, year: 1900, month: 1, day: 31).date!
        
        return calendar.date(byAdding: .day, value: offset, to: baseDate)
    }
    
    // MARK: - 公历转农历
    
    /// 公历转农历
    /// - Parameter date: 公历日期
    /// - Returns: 农历日期信息
    static func solarToLunar(_ date: Date) -> LunarDate? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        guard let year = components.year,
              let month = components.month,
              let day = components.day else {
            return nil
        }
        
        return solarToLunar(year: year, month: month, day: day)
    }
    
    /// 公历转农历
    static func solarToLunar(year: Int, month: Int, day: Int) -> LunarDate? {
        // 参数校验
        guard year >= 1900 && year <= 2100 else { return nil }
        guard month >= 1 && month <= 12 else { return nil }
        guard day >= 1 && day <= 31 else { return nil }
        
        // 计算目标日期与1900年1月31日的天数差
        let calendar = Calendar.current
        let baseDate = DateComponents(calendar: calendar, year: 1900, month: 1, day: 31).date!
        let targetDate = DateComponents(calendar: calendar, year: year, month: month, day: day).date!
        
        guard let offset = calendar.dateComponents([.day], from: baseDate, to: targetDate).day else {
            return nil
        }
        
        // 确保偏移量为正
        guard offset >= 0 else { return nil }
        
        // 查找年份
        var lunarYear = 1900
        var temp = offset
        
        while lunarYear < 2100 {
            let yearDays = LunarData.getYearDays(lunarYear)
            if temp < yearDays {
                break
            }
            temp -= yearDays
            lunarYear += 1
        }
        
        // 查找月份
        var lunarMonth = 1
        var isLeapMonth = false
        let leapMonth = LunarData.getLeapMonth(lunarYear)
        
        while lunarMonth <= 12 {
            let monthDays = LunarData.getMonthDays(lunarYear, month: lunarMonth)
            
            if temp < monthDays {
                break
            }
            
            temp -= monthDays
            
            // 检查是否有闰月
            if let lm = leapMonth, lm == lunarMonth {
                let leapDays = LunarData.getMonthDays(lunarYear, month: lunarMonth, isLeapMonth: true)
                if temp < leapDays {
                    isLeapMonth = true
                    break
                }
                temp -= leapDays
            }
            
            lunarMonth += 1
        }
        
        let lunarDay = temp + 1
        
        // 计算天干地支
        let ganIndex = (lunarYear - 4) % 10
        let zhiIndex = (lunarYear - 4) % 12
        let ganZhi = "\(LunarData.tianGan[ganIndex])\(LunarData.diZhi[zhiIndex])"
        let zodiac = LunarData.zodiacs[zhiIndex]
        
        return LunarDate(
            year: lunarYear,
            month: lunarMonth,
            day: lunarDay,
            isLeapMonth: isLeapMonth,
            yearName: "\(ganZhi)年",
            monthName: isLeapMonth ? "闰\(LunarData.monthNames[lunarMonth - 1])" : LunarData.monthNames[lunarMonth - 1],
            dayName: LunarData.dayNames[lunarDay - 1],
            zodiac: zodiac,
            ganZhi: ganZhi
        )
    }
    
    // MARK: - 节气计算
    
    /// 获取指定年份的所有节气
    static func getSolarTerms(year: Int) -> [(name: String, date: Date)] {
        var result: [(String, Date)] = []
        let calendar = Calendar.current
        
        // 基准日期: 1900年1月6日 02:05 (小寒)
        let baseDate = DateComponents(calendar: calendar, year: 1900, month: 1, day: 6, hour: 2, minute: 5).date!
        
        // 计算从1900年到目标年份的分钟数
        let yearStart = DateComponents(calendar: calendar, year: year, month: 1, day: 1).date!
        let minutesFrom1900 = calendar.dateComponents([.minute], from: baseDate, to: yearStart).minute!
        
        for i in 0..<24 {
            // 节气周期约为365.2422天，24个节气平均15.22天
            let termMinutes = minutesFrom1900 + LunarData.solarTermInfo[i % 24] + (year - 1900) * 525949 // 525949 ≈ 365.2422 * 24 * 60
            
            if let termDate = calendar.date(byAdding: .minute, value: termMinutes, to: baseDate) {
                result.append((LunarData.solarTerms[i], termDate))
            }
        }
        
        return result
    }
    
    /// 获取指定日期最近的节气
    static func getCurrentSolarTerm(_ date: Date) -> (name: String, date: Date)? {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        
        let terms = getSolarTerms(year: year)
        
        for term in terms {
            if term.date >= date {
                return term
            }
        }
        
        // 如果当年的节气都过了，返回明年的第一个
        if let nextYear = calendar.date(byAdding: .year, value: 1, to: date),
           let nextTerms = getSolarTerms(year: calendar.component(.year, from: nextYear)).first {
            return nextTerms
        }
        
        return nil
    }
    
    // MARK: - 三伏天计算
    
    /// 计算三伏天
    static func getSanfuDays(year: Int) -> (chufu: Date, mofu: Date) {
        // 三伏天计算规则:
        // 初伏: 夏至后第三个庚日
        // 中伏: 初伏后10天 (或20天)
        // 末伏: 立秋后第一个庚日前10天
        
        let calendar = Calendar.current
        let terms = getSolarTerms(year: year)
        
        // 找到夏至和立秋
        guard let xiazhi = terms.first(where: { $0.name == "夏至" })?.date,
              let liqiu = terms.first(where: { $0.name == "立秋" })?.date else {
            fatalError("Cannot find solar terms")
        }
        
        // 找夏至后第三个庚日
        var currentDate = xiazhi
        var gengCount = 0
        var chufu: Date?
        
        while gengCount < 3 {
            let day = calendar.component(.day, from: currentDate)
            let ganIndex = (day + 6) % 10 // 庚日干支索引为6
            
            if ganIndex == 6 {
                gengCount += 1
                if gengCount == 3 {
                    chufu = currentDate
                    break
                }
            }
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        // 末伏: 立秋后第一个庚日
        currentDate = liqiu
        var mofu: Date?
        
        while mofu == nil {
            let day = calendar.component(.day, from: currentDate)
            let ganIndex = (day + 6) % 10
            
            if ganIndex == 6 {
                mofu = currentDate
                break
            }
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return (chufu ?? Date(), mofu ?? Date())
    }
    
    // MARK: - 九九计算
    
    /// 计算数九
    static func getJiujiuDays(year: Int) -> [(name: String, start: Date, end: Date)] {
        // 数九从冬至开始，每九天为一九
        let calendar = Calendar.current
        let terms = getSolarTerms(year: year)
        
        guard let dongzhi = terms.first(where: { $0.name == "冬至" })?.date else {
            return []
        }
        
        let jiuNames = ["一九", "二九", "三九", "四九", "五九", "六九", "七九", "八九", "九九"]
        var result: [(String, Date, Date)] = []
        
        for (index, name) in jiuNames.enumerated() {
            let start = calendar.date(byAdding: .day, value: index * 9, to: dongzhi)!
            let end = calendar.date(byAdding: .day, value: (index + 1) * 9 - 1, to: dongzhi)!
            result.append((name, start, end))
        }
        
        return result
    }
    
    // MARK: - 每日宜忌
    
    /// 获取每日宜忌信息
    static func getDailyYiJi(date: Date) -> (yi: [String], ji: [String]) {
        // 简化版宜忌，基于农历日期
        guard let lunarDate = solarToLunar(date) else {
            return ([], [])
        }
        
        // 根据农历日期和天干地支计算宜忌
        // 这里使用简化算法
        let yiList = [
            "祭祀", "祈福", "求嗣", "开光", "出行", "解除",
            "纳采", "冠笄", "嫁娶", "纳婿", "安床", "移徙",
            "入宅", "安香", "拆卸", "动土", "挂匾", "开市",
            "立券", "纳财", "沐浴", "理发", "安门", "修造",
            "盖屋", "合脊", "起基", "定磉", "安碓硙", "放水",
            "掘井", "破土", "安葬", "启钻", "除服", "成服"
        ]
        
        let jiList = [
            "嫁娶", "安葬", "出行", "动土", "开市", "入宅",
            "移徙", "祭祀", "祈福", "开光", "纳采", "安床",
            "拆卸", "掘井", "破土", "作灶", "伐木", "探病"
        ]
        
        // 基于农历日期选择宜忌
        let dayIndex = (lunarDate.day - 1) % yiList.count
        let monthIndex = (lunarDate.month - 1) % jiList.count
        
        var yi: [String] = []
        var ji: [String] = []
        
        // 选择4-6个宜
        for i in 0..<5 {
            let index = (dayIndex + i * 3) % yiList.count
            yi.append(yiList[index])
        }
        
        // 选择3-4个忌
        for i in 0..<4 {
            let index = (monthIndex + i * 5) % jiList.count
            ji.append(jiList[index])
        }
        
        return (yi, ji)
    }
}
