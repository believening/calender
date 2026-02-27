//
//  TibetanCalendarPlugin.swift
//  MultiCalendarApp
//
//  藏历插件 - 使用完整算法
//

import Foundation

/// 藏历插件
class TibetanCalendarPlugin: BaseCalendarPlugin {
    
    // MARK: - 节日数据
    
    private var festivals: [Festival] = []
    
    // MARK: - Initialization
    
    init() {
        super.init(
            identifier: "com.multicalendar.tibetan",
            name: "藏历",
            version: "2.0.0",
            calendarType: .tibetan,
            supportedYearRange: 1950...2050
        )
        
        loadFestivals()
    }
    
    /// 从 Bundle 初始化（动态加载）
    convenience init?(bundle: Bundle) {
        self.init()
    }
    
    private func loadFestivals() {
        // 从 TibetanData 加载节日
        for festival in TibetanData.majorFestivals {
            festivals.append(Festival(
                id: "tibetan-\(festival.month)-\(festival.day)",
                name: festival.name,
                nameTibetan: festival.nameTibetan,
                date: .tibetan(month: festival.month, day: festival.day),
                calendarType: .tibetan,
                type: festival.name.contains("佛") || festival.name.contains("萨迦") ? .buddhist : .traditional,
                description: festival.description
            ))
        }
    }
    
    // MARK: - CalendarPlugin Implementation
    
    override func convert(from date: Date) -> CalendarDate? {
        // 使用完整算法转换
        let tibetanDate = TibetanAlgorithm.solarToTibetan(date)
        
        var calendarDate = CalendarDate(solarDate: date)
        calendarDate.tibetanDate = tibetanDate
        
        return calendarDate
    }
    
    override func convertToSolar(year: Int, month: Int, day: Int, isLeapMonth: Bool = false) -> Date? {
        return TibetanAlgorithm.tibetanToSolar(year: year, month: month, day: day)
    }
    
    override func getFestivals(year: Int, month: Int) -> [Festival] {
        return festivals.filter { festival in
            if case .tibetan(let m, _) = festival.date {
                return m == month
            }
            return false
        }
    }
    
    override func getDailyInfo(date: Date) -> DailyInfo? {
        guard let tibetanDate = convert(from: date)?.tibetanDate else {
            return nil
        }
        
        // 获取吉凶
        let (quality, description) = TibetanAlgorithm.getDayQuality(
            year: tibetanDate.year,
            month: tibetanDate.month,
            day: tibetanDate.day
        )
        
        // 获取九宫飞星
        let flyingStar = TibetanAlgorithm.getFlyingStar(
            year: tibetanDate.year,
            month: tibetanDate.month,
            day: tibetanDate.day
        )
        
        // 宜忌基于吉凶
        var suitable: [String] = []
        var unsuitable: [String] = []
        
        switch quality {
        case .veryGood, .good:
            suitable = ["祈福", "供养", "修法", "放生", "布施", "诵经"]
        case .neutral:
            suitable = ["日常事务"]
            unsuitable = ["重大决策"]
        case .slightlyBad, .bad:
            unsuitable = ["开业", "婚嫁", "远行", "动土"]
        }
        
        // 如果是殊胜日，添加特殊宜
        let (isSpecial, specialDesc) = TibetanAlgorithm.isSpecialDate(date)
        if isSpecial {
            suitable.append("殊胜日修行")
        }
        
        var note = description
        if isSpecial, let desc = specialDesc {
            note = "\(desc) - \(description)"
        }
        
        return DailyInfo(
            date: date,
            suitable: suitable,
            unsuitable: unsuitable,
            luckyDirections: [flyingStar.direction],
            unluckyDirections: flyingStar.star == 5 ? ["中央"] : [],
            fetusGodDirection: nil,
            pengzuTaboo: nil,
            fiveElements: tibetanDate.yearElement,
            chongSha: nil,
            note: note
        )
    }
    
    override func isSpecialDate(date: Date) -> (Bool, String?)? {
        let (isSpecial, description) = TibetanAlgorithm.isSpecialDate(date)
        return (isSpecial, description)
    }
    
    // MARK: - 额外功能
    
    /// 获取下一个殊胜日
    func getNextSpecialDay(from date: Date) -> (date: Date, description: String)? {
        return TibetanAlgorithm.getNextSpecialDay(from: date)
    }
    
    /// 获取全年节日
    func getAllFestivals(year: Int) -> [(month: Int, day: Int, name: String, nameTibetan: String, description: String, date: Date)] {
        return TibetanAlgorithm.getAllFestivals(year: year)
    }
    
    /// 获取年份信息（绕迥纪年）
    func getYearInfo(year: Int) -> (cycle: Int, yearInCycle: Int, element: String, zodiac: String, fullName: String) {
        return TibetanAlgorithm.getYearInfo(year: year)
    }
    
    /// 获取缺日
    func getMissingDays(year: Int, month: Int) -> [Int] {
        return TibetanAlgorithm.getMissingDays(year: year, month: month)
    }
    
    /// 获取重日
    func getDoubledays(year: Int, month: Int) -> [Int] {
        return TibetanAlgorithm.getDoubledays(year: year, month: month)
    }
    
    /// 获取九宫飞星
    func getFlyingStar(year: Int, month: Int, day: Int) -> (star: Int, direction: String, meaning: String) {
        return TibetanAlgorithm.getFlyingStar(year: year, month: month, day: day)
    }
}
