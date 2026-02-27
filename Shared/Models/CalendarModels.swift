//
//  CalendarModels.swift
//  MultiCalendarApp
//
//  多民族日历核心数据模型
//

import Foundation

// MARK: - 日历日期模型

/// 统一的日历日期表示
struct CalendarDate: Identifiable, Hashable {
    let id = UUID()
    
    /// 公历日期
    let solarDate: Date
    
    /// 农历日期（可选）
    var lunarDate: LunarDate?
    
    /// 藏历日期（可选）
    var tibetanDate: TibetanDate?
    
    /// 其他历法日期（扩展用）
    var otherDates: [String: Any] = [:]
}

/// 农历日期
struct LunarDate: Codable, Hashable {
    let year: Int           // 农历年
    let month: Int          // 农历月
    let day: Int            // 农历日
    let isLeapMonth: Bool   // 是否闰月
    
    /// 年份名称（如：甲子年）
    var yearName: String?
    
    /// 月份名称（如：正月）
    var monthName: String?
    
    /// 日期名称（如：初一）
    var dayName: String?
    
    /// 生肖（如：鼠）
    var zodiac: String?
    
    /// 天干地支
    var ganZhi: String?
}

/// 藏历日期
struct TibetanDate: Codable, Hashable {
    let year: Int           // 藏历年
    let month: Int          // 藏历月
    let day: Int            // 藏历日
    
    /// 五行+生肖纪年（如：火马年）
    var yearElement: String?
    
    /// 月份名称（藏文）
    var monthNameTibetan: String?
    
    /// 月份名称（中文）
    var monthNameChinese: String?
    
    /// 日期名称（藏文）
    var dayNameTibetan: String?
    
    /// 日期名称（中文）
    var dayNameChinese: String?
    
    /// 是否缺日
    var isMissingDay: Bool = false
    
    /// 是否重日
    var isDoubleday: Bool = false
}

// MARK: - 节日模型

/// 节日
struct Festival: Identifiable, Codable, Hashable {
    let id: String
    let name: String                // 节日名称
    let nameTibetan: String?        // 藏文名称
    let date: FestivalDate          // 日期
    let calendarType: CalendarType  // 所属历法
    
    /// 节日类型
    var type: FestivalType = .traditional
    
    /// 节日描述
    var description: String?
    
    /// 相关图片
    var imageURL: String?
}

/// 节日日期（可能是固定日期或相对日期）
enum FestivalDate: Codable, Hashable {
    case fixed(month: Int, day: Int)           // 固定日期
    case relative(month: Int, week: Int, weekday: Int)  // 相对日期（如：五月第二个星期日）
    case lunar(month: Int, day: Int)           // 农历日期
    case tibetan(month: Int, day: Int)         // 藏历日期
}

/// 节日类型
enum FestivalType: String, Codable {
    case traditional = "传统节日"
    case buddhist = "佛教节日"
    case national = "国家节日"
    case solar = "节气"
    case custom = "自定义"
}

/// 历法类型
enum CalendarType: String, Codable, CaseIterable {
    case solar = "公历"
    case lunar = "农历"
    case tibetan = "藏历"
    case islamic = "伊斯兰历"
    case dai = "傣历"
    case yi = "彝历"
}

// MARK: - 每日信息模型

/// 每日详细信息
struct DailyInfo: Codable, Hashable {
    let date: Date
    
    /// 宜
    var suitable: [String] = []
    
    /// 忌
    var unsuitable: [String] = []
    
    /// 吉神方位
    var luckyDirections: [String] = []
    
    /// 凶神方位
    var unluckyDirections: [String] = []
    
    /// 胎神方位
    var fetusGodDirection: String?
    
    /// 彭祖百忌
    var pengzuTaboo: String?
    
    /// 五行
    var fiveElements: String?
    
    /// 冲煞
    var chongSha: String?
    
    /// 备注
    var note: String?
}

// MARK: - 提醒模型

/// 提醒规则
struct ReminderRule: Identifiable, Codable, Hashable {
    let id: String
    
    /// 提醒名称
    let name: String
    
    /// 提醒类型
    let type: ReminderType
    
    /// 是否启用
    var isEnabled: Bool = true
    
    /// 提前天数
    var advanceDays: Int = 0
    
    /// 提醒时间（小时:分钟）
    var reminderTime: String = "09:00"
}

/// 提醒类型
enum ReminderType: String, Codable, CaseIterable {
    case newMoon = "初一提醒"           // 每月初一
    case fullMoon = "十五提醒"          // 每月十五
    case buddhistFestival = "佛教节日"  // 佛教节日
    case traditionalFestival = "传统节日" // 传统节日
    case solarTerm = "节气"             // 节气
    case tibetanFestival = "藏历节日"   // 藏历节日
    case custom = "自定义"              // 自定义日期
}

// MARK: - 插件模型

/// 日历插件元数据
struct CalendarPluginMetadata: Codable {
    let identifier: String       // 插件标识
    let name: String             // 插件名称
    let nameEn: String?          // 英文名称
    let version: String          // 版本号
    let author: String?          // 作者
    let description: String?     // 描述
    let calendarType: CalendarType  // 历法类型
    
    /// 支持的年份范围
    let supportedYearRange: ClosedRange<Int>
    
    /// 支持的语言
    let supportedLanguages: [String]
    
    /// 资源下载地址（可选）
    let downloadURL: String?
    
    /// 资源版本
    let resourceVersion: String?
    
    /// 资源大小（字节）
    let resourceSize: Int64?
}

/// 插件状态
enum PluginState: String {
    case notInstalled = "未安装"
    case installed = "已安装"
    case needsUpdate = "需要更新"
    case error = "错误"
}
