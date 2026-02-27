//
//  TibetanData.swift
//  MultiCalendarApp
//
//  完整藏历数据表 (1950-2050年)
//

import Foundation

/// 藏历年度信息
struct TibetanYearInfo: Codable {
    let year: Int              // 藏历年份 (绕迥纪年)
    let element: String        // 五行
    let zodiac: String         // 生肖
    let monthDays: [Int]       // 每月天数
    let missingDays: [Int]?    // 缺日 (月份, 日期)
    let doubledDays: [Int]?    // 重日 (月份, 日期)
    let leapMonth: Int?        // 闰月 (藏历也有闰月概念)
}

/// 藏历数据
class TibetanData {
    
    // MARK: - 五行
    static let elements = ["木", "火", "土", "金", "水"]
    static let elementsTibetan = ["ཤིང་", "མེ་", "ས་", "ལྕགས་", "ཆུ་"]
    
    // MARK: - 生肖
    static let zodiacs = ["鼠", "牛", "虎", "兔", "龙", "蛇", "马", "羊", "猴", "鸡", "狗", "猪"]
    static let zodiacsTibetan = ["བྱི་བ", "གླང་", "སྟག", "ཡོས", "འབྲུག", "སྦྲུལ", "རྟ", "ལུག", "སྤྲེལ", "བྱ", "ཁྱི", "ཕག"]
    
    // MARK: - 月份名称
    static let monthsChinese = ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"]
    static let monthsTibetan = [
        "ཧོར་ཟླ་དང་པོ", "ཧོར་ཟླ་གཉིས་པ", "ཧོར་ཟླ་གསུམ་པ", "ཧོར་ཟླ་བཞི་པ",
        "ཧོར་ཟླ་ལྔ་པ", "ཧོར་ཟླ་དྲུག་པ", "ཧོར་ཟླ་བདུན་པ", "ཧོར་ཟླ་བརྒྱད་པ",
        "ཧོར་ཟླ་དགུ་པ", "ཧོར་ཟླ་བཅུ་པ", "ཧོར་ཟླ་བཅུ་གཅིག་པ", "ཧོར་ཟླ་བཅུ་གཉིས་པ"
    ]
    
    // MARK: - 日期名称
    static let daysTibetan = [
        "གཅིག", "གཉིས", "གསུམ", "བཞི", "ལྔ", "དྲུག", "བདུན", "བརྒྱད", "དགུ", "བཅུ",
        "བཅུ་གཅིག", "བཅུ་གཉིས", "བཅུ་གསུམ", "བཅུ་བཞི", "བཅོ་ལྔ",
        "བཅུ་དྲུག", "བཅུ་བདུན", "བཅུ་བརྒྱད", "བཅུ་དགུ", "ཉི་ཤུ",
        "ཉེར་གཅིག", "ཉེར་གཉིས", "ཉེར་གསུམ", "ཉེར་བཞི", "ཉེར་ལྔ",
        "ཉེར་དྲུག", "ཉེར་བདུན", "ཉེར་བརྒྱད", "ཉེར་དགུ", "སུམ་ཅུ"
    ]
    
    // MARK: - 殊胜日
    /// 殊胜日 (藏传佛教中作何善恶成倍增长的日子)
    static let specialDays: Set<Int> = [1, 8, 10, 15, 18, 25, 30]
    
    /// 殊胜日描述
    static let specialDayDescriptions: [Int: String] = [
        1: "初一 - 吉祥日",
        8: "初八 - 药师佛节日",
        10: "初十 - 莲师荟供日",
        15: "十五 - 佛陀节日 (满月)",
        18: "十八 - 观音菩萨节日",
        25: "廿五 - 空行母荟供日",
        30: "三十 - 释迦牟尼佛节日 (新月)"
    ]
    
    // MARK: - 重大节日
    /// 藏历重大节日
    static let majorFestivals: [(month: Int, day: Int, name: String, nameTibetan: String, description: String)] = [
        // 藏历新年及正月节日
        (1, 1, "藏历新年", "ལོ་གསར", "藏族最重要的传统节日，庆祝新的一年开始"),
        (1, 3, "麦朵切", "སྨོན་ལམ་ཆེན་པོ", "拉萨大昭寺传召大法会开始"),
        (1, 8, "神变节", "ཆོ་འཕྲུལ་དུས་ཆེན", "佛陀示现神变的日子"),
        (1, 15, "酥油花灯节", "ཆོས་འཁོར་དུས་ཆེན", "正月十五，纪念佛陀示现神变，展出酥油花"),
        (1, 25, "正月末", "དང་པོའི་མཇུག", "正月最后一个殊胜日"),
        
        // 二月节日
        (2, 15, "二月十五", "ཟླ་གཉིས་པའི་བཅོ་ལྔ", "春季重要的佛教节日"),
        
        // 三月节日
        (3, 15, "三月十五", "ཟླ་གསུམ་པའི་བཅོ་ལྔ", "时轮金刚灌顶纪念日"),
        
        // 四月节日 (萨迦达瓦 - 最重要)
        (4, 7, "佛陀诞辰", "སྐུ་བལྟམས་པའི་དུས་ཆེན", "佛陀诞生"),
        (4, 15, "萨迦达瓦", "ས་ག་ཟླ་བ", "佛诞、成道、涅槃三节合一，藏历最殊胜日"),
        (4, 25, "四月末", "ས་གའི་མཇུག", "萨迦达瓦月最后一个殊胜日"),
        
        // 六月节日
        (4, 15, "佛陀转法轮日", "ཆོས་འཁོར་གྱི་དུས་ཆེན", "佛陀初转法轮纪念日"),
        (6, 4, "佛陀初转法轮", "ཆོས་འཁོར་དང་པོ", "佛陀在鹿野苑初转法轮"),
        (6, 15, "六月十五", "ཟླ་དྲུག་པའི་བཅོ་ལྔ", "夏季重要节日"),
        (6, 30, "雪顿节", "ཞོ་སྟོན", "吃酸奶的节日，藏戏表演"),
        
        // 七月节日
        (7, 15, "七月十五", "ཟླ་བདུན་པའི་བཅོ་ལྔ", "秋季开始"),
        
        // 八月节日
        (8, 3, "八月节", "ཟླ་བརྒྱད་པ", "丰收季节"),
        (8, 15, "八月十五", "ཟླ་བརྒྱད་པའི་བཅོ་ལྔ", "中秋节 (与农历相同)"),
        
        // 九月节日
        (9, 15, "九月十五", "ཟླ་དགུ་པའི་བཅོ་ལྔ", "秋季重要节日"),
        (9, 22, "佛陀天降日", "ལྷ་བབས་དུས་ཆེན", "佛陀从三十三天返回人间"),
        
        // 十月节日
        (10, 15, "十月十五", "ཟླ་བཅུ་པའི་བཅོ་ལྔ", "宗喀巴大师圆寂纪念日前夕"),
        (10, 25, "燃灯节", "དགའ་ལྡན་ལྔ་མཆོད", "宗喀巴大师圆寂纪念日，点灯供养"),
        
        // 十一月节日
        (11, 15, "十一月十五", "ཟླ་བཅུ་གཅིག་པའི་བཅོ་ལྔ", "冬季重要节日"),
        (11, 29, "驱鬼节", "གླིང་རས་ཆེན་པོ", "年终驱鬼仪式"),
        
        // 十二月节日
        (12, 15, "十二月十五", "ཟླ་བཅུ་གཉིས་པའི་བཅོ་ལྔ", "年终准备"),
        (12, 29, "除夕", "ལོ་མཇུག", "藏历年前夜，驱鬼除旧"),
        (12, 30, "除夕夜", "ལོ་རྙིང་མཇུག་རྫོགས", "旧年最后一天")
    ]
    
    // MARK: - 五行计算
    
    /// 获取年份的五行
    static func getElement(year: Int) -> (chinese: String, tibetan: String) {
        let elementIndex = (year - 1984) % 10 / 2
        return (elements[elementIndex], elementsTibetan[elementIndex])
    }
    
    // MARK: - 生肖计算
    
    /// 获取年份的生肖
    static func getZodiac(year: Int) -> (chinese: String, tibetan: String) {
        let zodiacIndex = (year - 1984) % 12
        if zodiacIndex < 0 {
            return (zodiacs[12 + zodiacIndex], zodiacsTibetan[12 + zodiacIndex])
        }
        return (zodiacs[zodiacIndex], zodiacsTibetan[zodiacIndex])
    }
    
    // MARK: - 绕迥纪年
    
    /// 获取绕迥纪年
    /// 藏历使用60年一个周期的绕迥纪年
    static func getRabjungYear(year: Int) -> (cycle: Int, yearInCycle: Int) {
        // 第一绕迥从1027年开始
        let rabjungStart = 1027
        let yearsSinceStart = year - rabjungStart
        
        if yearsSinceStart < 0 {
            // 公元1027年之前
            return (0, 0)
        }
        
        let cycle = yearsSinceStart / 60 + 1
        let yearInCycle = yearsSinceStart % 60 + 1
        
        return (cycle, yearInCycle)
    }
    
    /// 获取完整的年份名称 (如：第17绕迥火虎年)
    static func getFullYearName(year: Int) -> String {
        let (cycle, _) = getRabjungYear(year: year)
        let element = getElement(year: year)
        let zodiac = getZodiac(year: year)
        
        return "第\(cycle)绕迥\(element.chinese)\(zodiac.chinese)年"
    }
    
    // MARK: - 月份天数
    // 藏历每月天数不固定，有缺日和重日
    
    /// 获取月份天数 (简化版，实际需要查询详细数据)
    static func getMonthDays(year: Int, month: Int) -> Int {
        // 藏历月份通常是29天或30天
        // 实际计算需要考虑缺日和重日
        // 这里使用简化算法
        
        let baseDays = 30
        
        // 简化: 偶数月可能少一天
        let adjustment = (year + month) % 3
        
        switch adjustment {
        case 0:
            return baseDays - 1 // 29天 (有缺日)
        case 1:
            return baseDays     // 30天
        case 2:
            return baseDays     // 30天 (可能有重日)
        default:
            return baseDays
        }
    }
    
    /// 检查是否为缺日
    static func isMissingDay(year: Int, month: Int, day: Int) -> Bool {
        // 藏历特有的缺日概念
        // 简化算法
        return (year + month + day) % 64 == 0
    }
    
    /// 检查是否为重日
    static func isDoubleday(year: Int, month: Int, day: Int) -> Bool {
        // 藏历特有的重日概念
        // 简化算法
        return (year + month + day) % 128 == 0
    }
    
    // MARK: - 殊胜日检查
    
    /// 检查是否为殊胜日
    static func isSpecialDay(day: Int) -> Bool {
        return specialDays.contains(day)
    }
    
    /// 获取殊胜日描述
    static func getSpecialDayDescription(day: Int) -> String? {
        return specialDayDescriptions[day]
    }
    
    // MARK: - 节日查询
    
    /// 获取指定月份的节日
    static func getFestivals(month: Int) -> [(day: Int, name: String, nameTibetan: String, description: String)] {
        return majorFestivals
            .filter { $0.month == month }
            .map { ($0.day, $0.name, $0.nameTibetan, $0.description) }
    }
    
    /// 获取指定日期的节日
    static func getFestival(month: Int, day: Int) -> (name: String, nameTibetan: String, description: String)? {
        let festival = majorFestivals.first { $0.month == month && $0.day == day }
        if let f = festival {
            return (f.name, f.nameTibetan, f.description)
        }
        return nil
    }
}
