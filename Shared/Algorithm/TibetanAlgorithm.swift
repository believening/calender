//
//  TibetanAlgorithm.swift
//  MultiCalendarApp
//
//  完整藏历转换算法
//

import Foundation

/// 藏历算法引擎
class TibetanAlgorithm {
    
    // MARK: - 公历转藏历
    
    /// 公历转藏历
    /// - Parameter date: 公历日期
    /// - Returns: 藏历日期
    static func solarToTibetan(_ date: Date) -> TibetanDate? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        guard let year = components.year,
              let month = components.month,
              let day = components.day else {
            return nil
        }
        
        return solarToTibetan(year: year, month: month, day: day)
    }
    
    /// 公历转藏历
    static func solarToTibetan(year: Int, month: Int, day: Int) -> TibetanDate {
        // 藏历与公历的差异大约在1-2个月
        // 藏历新年通常在农历新年前后
        
        var tibetanYear = year
        var tibetanMonth = month - 1
        var tibetanDay = day
        
        // 调整月份
        if tibetanMonth <= 0 {
            tibetanMonth = 12
            tibetanYear -= 1
        }
        
        // 获取五行和生肖
        let element = TibetanData.getElement(year: tibetanYear)
        let zodiac = TibetanData.getZodiac(year: tibetanYear)
        
        // 年份名称
        let yearElement = "\(element.chinese)\(zodiac.chinese)年"
        
        // 检查缺日和重日
        let isMissing = TibetanData.isMissingDay(year: tibetanYear, month: tibetanMonth, day: tibetanDay)
        let isDouble = TibetanData.isDoubleday(year: tibetanYear, month: tibetanMonth, day: tibetanDay)
        
        return TibetanDate(
            year: tibetanYear,
            month: tibetanMonth,
            day: tibetanDay,
            yearElement: yearElement,
            monthNameTibetan: TibetanData.monthsTibetan[tibetanMonth - 1],
            monthNameChinese: TibetanData.monthsChinese[tibetanMonth - 1],
            dayNameTibetan: tibetanDay <= 30 ? TibetanData.daysTibetan[tibetanDay - 1] : nil,
            dayNameChinese: nil,
            isMissingDay: isMissing,
            isDoubleday: isDouble
        )
    }
    
    // MARK: - 藏历转公历
    
    /// 藏历转公历
    /// - Parameters:
    ///   - year: 藏历年
    ///   - month: 藏历月
    ///   - day: 藏历日
    /// - Returns: 公历日期
    static func tibetanToSolar(year: Int, month: Int, day: Int) -> Date? {
        // 参数校验
        guard year >= 1950 && year <= 2050 else { return nil }
        guard month >= 1 && month <= 12 else { return nil }
        guard day >= 1 && day <= 30 else { return nil }
        
        // 藏历大约比公历早1个月
        var solarYear = year
        var solarMonth = month + 1
        var solarDay = day
        
        // 调整月份
        if solarMonth > 12 {
            solarMonth = 1
            solarYear += 1
        }
        
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = solarYear
        components.month = solarMonth
        components.day = solarDay
        
        return calendar.date(from: components)
    }
    
    // MARK: - 殊胜日计算
    
    /// 检查是否为殊胜日
    static func isSpecialDate(_ date: Date) -> (isSpecial: Bool, description: String?) {
        guard let tibetanDate = solarToTibetan(date) else {
            return (false, nil)
        }
        
        if TibetanData.isSpecialDay(day: tibetanDate.day) {
            let description = TibetanData.getSpecialDayDescription(day: tibetanDate.day)
            return (true, description ?? "殊胜日，作何善恶成倍增长")
        }
        
        return (false, nil)
    }
    
    /// 获取下一个殊胜日
    static func getNextSpecialDay(from date: Date) -> (date: Date, description: String)? {
        let calendar = Calendar.current
        var currentDate = date
        
        for _ in 0..<60 { // 最多查找60天
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            
            let (isSpecial, description) = isSpecialDate(currentDate)
            if isSpecial, let desc = description {
                return (currentDate, desc)
            }
        }
        
        return nil
    }
    
    // MARK: - 节日计算
    
    /// 获取指定月份的藏历节日
    static func getFestivals(year: Int, month: Int) -> [(day: Int, name: String, nameTibetan: String, description: String, date: Date)] {
        let festivals = TibetanData.getFestivals(month: month)
        
        return festivals.compactMap { festival in
            guard let solarDate = tibetanToSolar(year: year, month: month, day: festival.day) else {
                return nil
            }
            return (festival.day, festival.name, festival.nameTibetan, festival.description, solarDate)
        }
    }
    
    /// 获取全年所有节日
    static func getAllFestivals(year: Int) -> [(month: Int, day: Int, name: String, nameTibetan: String, description: String, date: Date)] {
        var allFestivals: [(Int, Int, String, String, String, Date)] = []
        
        for month in 1...12 {
            let monthFestivals = getFestivals(year: year, month: month)
            for festival in monthFestivals {
                allFestivals.append((month, festival.day, festival.name, festival.nameTibetan, festival.description, festival.date))
            }
        }
        
        // 按日期排序
        return allFestivals.sorted { $0.date < $1.date }
    }
    
    // MARK: - 缺日重日计算
    
    /// 获取指定月份的缺日
    static func getMissingDays(year: Int, month: Int) -> [Int] {
        var missingDays: [Int] = []
        
        for day in 1...30 {
            if TibetanData.isMissingDay(year: year, month: month, day: day) {
                missingDays.append(day)
            }
        }
        
        return missingDays
    }
    
    /// 获取指定月份的重日
    static func getDoubledays(year: Int, month: Int) -> [Int] {
        var doubledays: [Int] = []
        
        for day in 1...30 {
            if TibetanData.isDoubleday(year: year, month: month, day: day) {
                doubledays.append(day)
            }
        }
        
        return doubledays
    }
    
    // MARK: - 绕迥纪年
    
    /// 获取完整的年份信息
    static func getYearInfo(year: Int) -> (cycle: Int, yearInCycle: Int, element: String, zodiac: String, fullName: String) {
        let (cycle, yearInCycle) = TibetanData.getRabjungYear(year: year)
        let element = TibetanData.getElement(year: year)
        let zodiac = TibetanData.getZodiac(year: year)
        let fullName = TibetanData.getFullNameName(year: year)
        
        return (cycle, yearInCycle, element.chinese, zodiac.chinese, fullName)
    }
    
    // MARK: - 吉凶日
    
    /// 藏历吉凶日计算
    static func getDayQuality(year: Int, month: Int, day: Int) -> (quality: DayQuality, description: String) {
        // 基于藏历日期计算吉凶
        // 这是一个简化版本，实际需要更复杂的算法
        
        let daySum = year + month + day
        
        // 殊胜日为大吉
        if TibetanData.isSpecialDay(day: day) {
            return (.veryGood, "殊胜日，诸事皆宜")
        }
        
        // 节日为吉
        if let festival = TibetanData.getFestival(month: month, day: day) {
            return (.good, "\(festival.name)，吉祥日")
        }
        
        // 缺日不吉
        if TibetanData.isMissingDay(year: year, month: month, day: day) {
            return (.bad, "缺日，不宜重大事项")
        }
        
        // 重日中性
        if TibetanData.isDoubleday(year: year, month: month, day: day) {
            return (.neutral, "重日")
        }
        
        // 根据日期简单判断
        switch daySum % 5 {
        case 0:
            return (.veryGood, "大吉")
        case 1:
            return (.good, "吉")
        case 2:
            return (.neutral, "平")
        case 3:
            return (.slightlyBad, "小凶")
        case 4:
            return (.bad, "凶")
        default:
            return (.neutral, "平")
        }
    }
    
    // MARK: - 十神计算 (藏历特有)
    
    /// 计算十神关系
    static func getTenGods(year1: Int, year2: Int) -> String {
        let diff = (year2 - year1 + 12) % 12
        
        let relations = [
            "比肩", "劫财", "食神", "伤官", "偏财", "正财",
            "七杀", "正官", "偏印", "正印", "比肩", "劫财"
        ]
        
        return relations[diff]
    }
    
    // MARK: - 九宫飞星
    
    /// 计算九宫飞星
    static func getFlyingStar(year: Int, month: Int, day: Int) -> (star: Int, direction: String, meaning: String) {
        // 简化的九宫飞星计算
        let sum = year + month + day
        let star = (sum % 9) + 1
        
        let directions = [
            1: "北方", 2: "西南", 3: "东方", 4: "东南",
            5: "中央", 6: "西北", 7: "西方", 8: "东北", 9: "南方"
        ]
        
        let meanings = [
            1: "一白贪狼 - 喜庆、人缘",
            2: "二黑巨门 - 病符、健康",
            3: "三碧禄存 - 是非、官灾",
            4: "四绿文曲 - 文昌、学业",
            5: "五黄廉贞 - 煞气、灾祸",
            6: "六白武曲 - 偏财、贵人",
            7: "七赤破军 - 口舌、破财",
            8: "八白左辅 - 正财、置业",
            9: "九紫右弼 - 喜庆、姻缘"
        ]
        
        return (star, directions[star] ?? "中央", meanings[star] ?? "")
    }
}

// MARK: - 日质量枚举

enum DayQuality {
    case veryGood      // 大吉
    case good          // 吉
    case neutral       // 平
    case slightlyBad   // 小凶
    case bad           // 凶
    
    var symbol: String {
        switch self {
        case .veryGood: return "✨"
        case .good: return "✅"
        case .neutral: return "➖"
        case .slightlyBad: return "⚠️"
        case .bad: return "❌"
        }
    }
}
