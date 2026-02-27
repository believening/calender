//
//  LunarCalendarPlugin.swift
//  MultiCalendarApp
//
//  农历插件 - 使用完整算法
//

import Foundation

/// 农历插件
class LunarCalendarPlugin: BaseCalendarPlugin {
    
    // MARK: - 节日数据
    
    private var festivals: [Festival] = []
    
    // MARK: - Initialization
    
    init() {
        super.init(
            identifier: "com.multicalendar.lunar",
            name: "农历",
            version: "2.0.0",
            calendarType: .lunar,
            supportedYearRange: 1900...2100
        )
        
        loadFestivals()
    }
    
    private func loadFestivals() {
        // 农历传统节日
        festivals = [
            Festival(
                id: "lunar-spring-festival",
                name: "春节",
                nameTibetan: nil,
                date: .lunar(month: 1, day: 1),
                calendarType: .lunar,
                type: .traditional,
                description: "农历新年，最重要的传统节日"
            ),
            Festival(
                id: "lunar-lantern-festival",
                name: "元宵节",
                nameTibetan: nil,
                date: .lunar(month: 1, day: 15),
                calendarType: .lunar,
                type: .traditional,
                description: "正月十五，又称上元节"
            ),
            Festival(
                id: "lunar-dragon-head",
                name: "龙抬头",
                nameTibetan: nil,
                date: .lunar(month: 2, day: 2),
                calendarType: .lunar,
                type: .traditional,
                description: "二月二，青龙节"
            ),
            Festival(
                id: "lunar-shangsi",
                name: "上巳节",
                nameTibetan: nil,
                date: .lunar(month: 3, day: 3),
                calendarType: .lunar,
                type: .traditional,
                description: "三月三"
            ),
            Festival(
                id: "lunar-buddha-birthday",
                name: "佛诞日",
                nameTibetan: nil,
                date: .lunar(month: 4, day: 8),
                calendarType: .lunar,
                type: .buddhist,
                description: "四月初八，释迦牟尼佛诞辰"
            ),
            Festival(
                id: "lunar-dragon-boat-festival",
                name: "端午节",
                nameTibetan: nil,
                date: .lunar(month: 5, day: 5),
                calendarType: .lunar,
                type: .traditional,
                description: "五月初五"
            ),
            Festival(
                id: "lunar-qixi",
                name: "七夕节",
                nameTibetan: nil,
                date: .lunar(month: 7, day: 7),
                calendarType: .lunar,
                type: .traditional,
                description: "七月初七，中国情人节"
            ),
            Festival(
                id: "lunar-ghost-festival",
                name: "中元节",
                nameTibetan: nil,
                date: .lunar(month: 7, day: 15),
                calendarType: .lunar,
                type: .traditional,
                description: "七月十五，鬼节"
            ),
            Festival(
                id: "lunar-mid-autumn-festival",
                name: "中秋节",
                nameTibetan: nil,
                date: .lunar(month: 8, day: 15),
                calendarType: .lunar,
                type: .traditional,
                description: "八月十五"
            ),
            Festival(
                id: "lunar-double-ninth-festival",
                name: "重阳节",
                nameTibetan: nil,
                date: .lunar(month: 9, day: 9),
                calendarType: .lunar,
                type: .traditional,
                description: "九月初九"
            ),
            Festival(
                id: "lunar-xiayuan",
                name: "下元节",
                nameTibetan: nil,
                date: .lunar(month: 10, day: 15),
                calendarType: .lunar,
                type: .traditional,
                description: "十月十五"
            ),
            Festival(
                id: "lunar-dongzhi",
                name: "冬至",
                nameTibetan: nil,
                date: .fixed(month: 12, day: 22), // 近似
                calendarType: .solar,
                type: .solar,
                description: "二十四节气之一"
            ),
            Festival(
                id: "lunar-laba-festival",
                name: "腊八节",
                nameTibetan: nil,
                date: .lunar(month: 12, day: 8),
                calendarType: .lunar,
                type: .traditional,
                description: "腊月初八"
            ),
            Festival(
                id: "lunar-new-year-eve",
                name: "除夕",
                nameTibetan: nil,
                date: .lunar(month: 12, day: 30),
                calendarType: .lunar,
                type: .traditional,
                description: "腊月最后一天"
            )
        ]
    }
    
    // MARK: - CalendarPlugin Implementation
    
    override func convert(from date: Date) -> CalendarDate? {
        // 使用完整算法转换
        guard let lunarDate = LunarAlgorithm.solarToLunar(date) else {
            return nil
        }
        
        var calendarDate = CalendarDate(solarDate: date)
        calendarDate.lunarDate = lunarDate
        
        return calendarDate
    }
    
    override func convertToSolar(year: Int, month: Int, day: Int, isLeapMonth: Bool = false) -> Date? {
        // 使用完整算法转换
        return LunarAlgorithm.lunarToSolar(
            year: year,
            month: month,
            day: day,
            isLeapMonth: isLeapMonth
        )
    }
    
    override func getFestivals(year: Int, month: Int) -> [Festival] {
        return festivals.filter { festival in
            switch festival.date {
            case .lunar(let m, _):
                return m == month
            case .fixed(let m, _):
                return m == month
            default:
                return false
            }
        }
    }
    
    override func getDailyInfo(date: Date) -> DailyInfo? {
        // 使用完整算法获取宜忌
        let (yi, ji) = LunarAlgorithm.getDailyYiJi(date: date)
        
        // 获取节气信息
        let solarTerm = LunarAlgorithm.getCurrentSolarTerm(date)
        
        // 获取三伏天
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let sanfu = LunarAlgorithm.getSanfuDays(year: year)
        
        // 检查是否在三伏天
        var note: String? = nil
        if date >= sanfu.chufu && date <= sanfu.mofu {
            note = "三伏天"
        }
        
        // 获取数九
        let jiujiu = LunarAlgorithm.getJiujiuDays(year: year)
        for jiu in jiujiu {
            if date >= jiu.start && date <= jiu.end {
                note = jiu.name
                break
            }
        }
        
        return DailyInfo(
            date: date,
            suitable: yi,
            unsuitable: ji,
            luckyDirections: [],
            unluckyDirections: [],
            fetusGodDirection: nil,
            pengzuTaboo: nil,
            fiveElements: nil,
            chongSha: nil,
            note: note ?? solarTerm?.name
        )
    }
    
    func getSolarTerms(year: Int) -> [Festival]? {
        let terms = LunarAlgorithm.getSolarTerms(year: year)
        
        return terms.map { name, date in
            Festival(
                id: "solar-term-\(name)",
                name: name,
                nameTibetan: nil,
                date: .fixed(
                    month: Calendar.current.component(.month, from: date),
                    day: Calendar.current.component(.day, from: date)
                ),
                calendarType: .solar,
                type: .solar,
                description: "二十四节气"
            )
        }
    }
    
    // MARK: - 额外功能
    
    /// 获取指定年份的三伏天日期
    func getSanfuDays(year: Int) -> (chufu: Date, zhongfu: Date, mofu: Date)? {
        let (chufu, mofu) = LunarAlgorithm.getSanfuDays(year: year)
        
        // 中伏在初伏后10天或20天
        let calendar = Calendar.current
        let zhongfu = calendar.date(byAdding: .day, value: 10, to: chufu)!
        
        return (chufu, zhongfu, mofu)
    }
    
    /// 获取指定年份的数九
    func getJiujiuDays(year: Int) -> [(name: String, start: Date, end: Date)] {
        return LunarAlgorithm.getJiujiuDays(year: year)
    }
    
    /// 获取指定日期的节气
    func getCurrentSolarTerm(_ date: Date) -> (name: String, date: Date)? {
        return LunarAlgorithm.getCurrentSolarTerm(date)
    }
}
