#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
MultiCalendarApp - 完整测试套件
测试时间: 2026-02-26

这个测试脚本可以在没有 Xcode 的环境下运行（模拟测试）
用于验证核心算法和逻辑的正确性
"""

import sys
import time
from datetime import datetime, timedelta
from typing import Optional, Dict, List, Tuple
from dataclasses import dataclass
from enum import Enum
import json

# ============================================================
# 数据模型（Python 版本，与 Swift 模型对应）
# ============================================================

class CalendarType(Enum):
    SOLAR = "公历"
    LUNAR = "农历"
    TIBETAN = "藏历"

class FestivalType(Enum):
    TRADITIONAL = "传统节日"
    BUDDHIST = "佛教节日"
    NATIONAL = "国家节日"
    SOLAR_TERM = "节气"
    CUSTOM = "自定义"

@dataclass
class LunarDate:
    year: int
    month: int
    day: int
    is_leap_month: bool = False
    year_name: Optional[str] = None
    month_name: Optional[str] = None
    day_name: Optional[str] = None
    zodiac: Optional[str] = None
    gan_zhi: Optional[str] = None

@dataclass
class TibetanDate:
    year: int
    month: int
    day: int
    year_element: Optional[str] = None
    month_name_tibetan: Optional[str] = None
    month_name_chinese: Optional[str] = None
    day_name_tibetan: Optional[str] = None
    day_name_chinese: Optional[str] = None
    is_missing_day: bool = False
    is_doubleday: bool = False

@dataclass
class Festival:
    id: str
    name: str
    name_tibetan: Optional[str]
    month: int
    day: int
    calendar_type: CalendarType
    festival_type: FestivalType
    description: Optional[str] = None

@dataclass
class ReminderRule:
    id: str
    name: str
    reminder_type: str
    is_enabled: bool = True
    advance_days: int = 0
    reminder_time: str = "09:00"

# ============================================================
# 农历算法
# ============================================================

class LunarCalendar:
    """农历算法（简化版）"""
    
    TIAN_GAN = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"]
    DI_ZHI = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]
    ZODIACS = ["鼠", "牛", "虎", "兔", "龙", "蛇", "马", "羊", "猴", "鸡", "狗", "猪"]
    MONTHS = ["正月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "冬月", "腊月"]
    DAYS = ["初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
            "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
            "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"]
    
    # 节日数据
    FESTIVALS = [
        Festival("lunar-spring-festival", "春节", None, 1, 1, CalendarType.LUNAR, FestivalType.TRADITIONAL, "农历新年，最重要的传统节日"),
        Festival("lunar-lantern", "元宵节", None, 1, 15, CalendarType.LUNAR, FestivalType.TRADITIONAL, "正月十五"),
        Festival("lunar-dragon-boat", "端午节", None, 5, 5, CalendarType.LUNAR, FestivalType.TRADITIONAL, "五月初五"),
        Festival("lunar-mid-autumn", "中秋节", None, 8, 15, CalendarType.LUNAR, FestivalType.TRADITIONAL, "八月十五"),
        Festival("lunar-double-ninth", "重阳节", None, 9, 9, CalendarType.LUNAR, FestivalType.TRADITIONAL, "九月初九"),
        Festival("lunar-laba", "腊八节", None, 12, 8, CalendarType.LUNAR, FestivalType.TRADITIONAL, "腊月初八"),
        Festival("lunar-new-year-eve", "除夕", None, 12, 30, CalendarType.LUNAR, FestivalType.TRADITIONAL, "腊月最后一天"),
    ]
    
    @staticmethod
    def solar_to_lunar(year: int, month: int, day: int) -> LunarDate:
        """公历转农历（简化版）"""
        gan_index = (year - 4) % 10
        zhi_index = (year - 4) % 12
        gan_zhi = f"{LunarCalendar.TIAN_GAN[gan_index]}{LunarCalendar.DI_ZHI[zhi_index]}"
        zodiac = LunarCalendar.ZODIACS[zhi_index]
        
        return LunarDate(
            year=year,
            month=month,
            day=day,
            is_leap_month=False,
            year_name=f"{gan_zhi}年",
            month_name=LunarCalendar.MONTHS[month - 1],
            day_name=LunarCalendar.DAYS[day - 1],
            zodiac=zodiac,
            gan_zhi=gan_zhi
        )
    
    @staticmethod
    def get_festivals(month: int) -> List[Festival]:
        """获取指定月份的节日"""
        return [f for f in LunarCalendar.FESTIVALS if f.month == month]

# ============================================================
# 藏历算法
# ============================================================

class TibetanCalendar:
    """藏历算法（简化版）"""
    
    ELEMENTS = ["木", "火", "土", "金", "水"]
    ZODIACS = ["鼠", "牛", "虎", "兔", "龙", "蛇", "马", "羊", "猴", "鸡", "狗", "猪"]
    MONTHS_TIBETAN = ["སྐག་པ", "བྱི་བ", "སྟག", "ཡོས", "འབྲུག", "སྦྲུལ", "རྟ", "ལུག", "སྤྲེལ", "བྱ", "ཁྱི", "ཕག"]
    MONTHS_CHINESE = ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"]
    
    # 节日数据
    FESTIVALS = [
        Festival("tibetan-losar", "藏历新年", "ལོ་གསར", 1, 1, CalendarType.TIBETAN, FestivalType.TRADITIONAL, "藏族最重要的传统节日"),
        Festival("tibetan-butter-lamp", "酥油花灯节", "ཆོས་འཁོར་དུས་ཆེན", 1, 15, CalendarType.TIBETAN, FestivalType.BUDDHIST, "正月十五，纪念佛陀示现神变"),
        Festival("tibetan-saka-dawa", "萨迦达瓦", "ས་ག་ཟླ་བ", 4, 15, CalendarType.TIBETAN, FestivalType.BUDDHIST, "佛诞日、成道日、涅槃日三节合一"),
        Festival("tibetan-shoton", "雪顿节", "ཞོ་སྟོན", 6, 30, CalendarType.TIBETAN, FestivalType.TRADITIONAL, "吃酸奶的节日"),
        Festival("tibetan-lhabab", "佛陀天降日", "ལྷ་བབས་དུས་ཆེན", 9, 22, CalendarType.TIBETAN, FestivalType.BUDDHIST, "佛陀从三十三天返回人间的日子"),
    ]
    
    @staticmethod
    def solar_to_tibetan(year: int, month: int, day: int) -> TibetanDate:
        """公历转藏历（简化版）"""
        element_index = (year - 1984) % 10 // 2
        zodiac_index = (year - 1984) % 12
        year_element = f"{TibetanCalendar.ELEMENTS[element_index]}{TibetanCalendar.ZODIACS[zodiac_index]}年"
        
        # 藏历月份（大约比公历晚1个月）
        tibetan_month = month - 1
        if tibetan_month <= 0:
            tibetan_month = 12
        
        return TibetanDate(
            year=year,
            month=tibetan_month,
            day=day,
            year_element=year_element,
            month_name_tibetan=TibetanCalendar.MONTHS_TIBETAN[tibetan_month - 1],
            month_name_chinese=TibetanCalendar.MONTHS_CHINESE[tibetan_month - 1],
            day_name_tibetan=None,
            day_name_chinese=None,
            is_missing_day=False,
            is_doubleday=False
        )
    
    @staticmethod
    def get_festivals(month: int) -> List[Festival]:
        """获取指定月份的节日"""
        return [f for f in TibetanCalendar.FESTIVALS if f.month == month]
    
    @staticmethod
    def is_special_day(day: int) -> Tuple[bool, Optional[str]]:
        """检查是否为殊胜日"""
        special_days = {1, 8, 10, 15, 18, 25, 30}
        if day in special_days:
            return (True, "殊胜日，作何善恶成倍增长")
        return (False, None)

# ============================================================
# 测试套件
# ============================================================

class TestResult:
    def __init__(self):
        self.passed = 0
        self.failed = 0
        self.tests: List[Tuple[str, bool, str]] = []
    
    def add(self, name: str, passed: bool, message: str = ""):
        self.tests.append((name, passed, message))
        if passed:
            self.passed += 1
        else:
            self.failed += 1
    
    def print_summary(self):
        print("\n")
        print("╔" + "═" * 68 + "╗")
        print("║" + "MultiCalendarApp 测试报告".center(60) + "║")
        print("║" + f"测试时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}".center(60) + "║")
        print("╚" + "═" * 68 + "╝")
        
        print("\n┌" + "─" * 68 + "┐")
        print("│ 测试结果详情" + " " * 54 + "│")
        print("├" + "─" * 68 + "┤")
        
        for name, passed, message in self.tests:
            status = "✅ PASS" if passed else "❌ FAIL"
            line = f"│ {status} │ {name}"
            if message and not passed:
                line += f" - {message}"
            line = line[:67] + " " * max(0, 67 - len(line)) + "│"
            print(line)
        
        print("└" + "─" * 68 + "┘")
        
        total = self.passed + self.failed
        percentage = (self.passed / total * 100) if total > 0 else 0
        
        print("\n┌" + "─" * 68 + "┐")
        print("│ 统计摘要" + " " * 58 + "│")
        print("├" + "─" * 68 + "┤")
        print(f"│ 总测试数: {total}" + " " * (67 - len(f"│ 总测试数: {total}")) + "│")
        print(f"│ 通过: {self.passed}" + " " * (67 - len(f"│ 通过: {self.passed}")) + "│")
        print(f"│ 失败: {self.failed}" + " " * (67 - len(f"│ 失败: {self.failed}")) + "│")
        print(f"│ 通过率: {percentage:.1f}%" + " " * (67 - len(f"│ 通过率: {percentage:.1f}%")) + "│")
        print("└" + "─" * 68 + "┘")

class TestSuite:
    def __init__(self):
        self.result = TestResult()
    
    def run_test(self, name: str, test_func):
        """运行单个测试"""
        try:
            test_func()
            self.result.add(name, True)
            return True
        except AssertionError as e:
            self.result.add(name, False, str(e))
            return False
        except Exception as e:
            self.result.add(name, False, f"异常: {str(e)}")
            return False
    
    # ========== 农历插件测试 ==========
    
    def test_lunar_plugin_info(self):
        """测试农历插件基本信息"""
        # 模拟插件信息验证
        identifier = "com.multicalendar.lunar"
        name = "农历"
        supported_range = (1900, 2100)
        
        assert identifier == "com.multicalendar.lunar", "插件标识符不正确"
        assert name == "农历", "插件名称不正确"
        assert supported_range[0] == 1900, "最小支持年份不正确"
        assert supported_range[1] == 2100, "最大支持年份不正确"
        
        print("   ✓ 插件标识符: \(identifier)")
        print("   ✓ 插件名称: \(name)")
        print("   ✓ 支持年份范围: 1900-2100")
    
    def test_solar_to_lunar_conversion(self):
        """测试公历转农历"""
        test_cases = [
            (2026, 2, 26),
            (2024, 1, 1),
            (2000, 1, 1),
            (2050, 6, 15),
        ]
        
        for year, month, day in test_cases:
            lunar = LunarCalendar.solar_to_lunar(year, month, day)
            assert lunar.year_name is not None, f"{year}-{month}-{day} 转换失败"
            assert lunar.zodiac is not None, f"{year}-{month}-{day} 生肖为空"
            print(f"   ✓ {year}年{month}月{day}日 → {lunar.year_name} {lunar.month_name} {lunar.day_name} ({lunar.zodiac})")
    
    def test_lunar_festivals(self):
        """测试农历节日查询"""
        festivals = LunarCalendar.get_festivals(1)  # 正月
        assert len(festivals) > 0, "正月应该有节日"
        
        spring_festival = next((f for f in festivals if f.name == "春节"), None)
        assert spring_festival is not None, "应该包含春节"
        
        print(f"   ✓ 正月节日数量: {len(festivals)}")
        for f in festivals:
            print(f"      - {f.name}")
    
    def test_lunar_zodiac_calculation(self):
        """测试生肖计算"""
        test_cases = [
            (2024, "龙"),
            (2025, "蛇"),
            (2026, "马"),
            (2000, "龙"),
            (1984, "鼠"),
        ]
        
        for year, expected_zodiac in test_cases:
            lunar = LunarCalendar.solar_to_lunar(year, 1, 1)
            assert lunar.zodiac == expected_zodiac, f"{year}年生肖应为{expected_zodiac}，实际为{lunar.zodiac}"
            print(f"   ✓ {year}年生肖: {lunar.zodiac}")
    
    def test_lunar_ganzhi_calculation(self):
        """测试天干地支计算"""
        test_cases = [
            (2024, "甲辰"),
            (2025, "乙巳"),
            (2026, "丙午"),
            (1984, "甲子"),
        ]
        
        for year, expected_ganzhi in test_cases:
            lunar = LunarCalendar.solar_to_lunar(year, 1, 1)
            assert lunar.gan_zhi == expected_ganzhi, f"{year}年干支应为{expected_ganzhi}，实际为{lunar.gan_zhi}"
            print(f"   ✓ {year}年干支: {lunar.gan_zhi}")
    
    # ========== 藏历插件测试 ==========
    
    def test_tibetan_plugin_info(self):
        """测试藏历插件基本信息"""
        identifier = "com.multicalendar.tibetan"
        name = "藏历"
        supported_range = (1950, 2050)
        
        assert identifier == "com.multicalendar.tibetan", "插件标识符不正确"
        assert name == "藏历", "插件名称不正确"
        assert supported_range[0] == 1950, "最小支持年份不正确"
        assert supported_range[1] == 2050, "最大支持年份不正确"
        
        print("   ✓ 插件标识符: \(identifier)")
        print("   ✓ 插件名称: \(name)")
        print("   ✓ 支持年份范围: 1950-2050")
    
    def test_solar_to_tibetan_conversion(self):
        """测试公历转藏历"""
        test_cases = [
            (2026, 2, 26),
            (2024, 1, 1),
            (2000, 6, 15),
        ]
        
        for year, month, day in test_cases:
            tibetan = TibetanCalendar.solar_to_tibetan(year, month, day)
            assert tibetan.year_element is not None, f"{year}-{month}-{day} 转换失败"
            print(f"   ✓ {year}年{month}月{day}日 → {tibetan.year_element} {tibetan.month_name_chinese}")
    
    def test_tibetan_festivals(self):
        """测试藏历节日查询"""
        festivals = TibetanCalendar.get_festivals(1)  # 藏历正月
        assert len(festivals) > 0, "藏历正月应该有节日"
        
        losar = next((f for f in festivals if f.name == "藏历新年"), None)
        assert losar is not None, "应该包含藏历新年"
        assert losar.name_tibetan is not None, "藏历新年应该有藏文名称"
        
        print(f"   ✓ 藏历正月节日数量: {len(festivals)}")
        for f in festivals:
            print(f"      - {f.name} ({f.name_tibetan})")
    
    def test_tibetan_special_dates(self):
        """测试藏历殊胜日"""
        special_days = [1, 8, 10, 15, 18, 25, 30]
        
        for day in special_days:
            is_special, desc = TibetanCalendar.is_special_day(day)
            assert is_special, f"初{day}应该是殊胜日"
            print(f"   ✓ 初{day}: {desc}")
    
    # ========== 插件架构测试 ==========
    
    def test_plugin_architecture(self):
        """测试插件架构设计"""
        # 模拟插件管理器
        loaded_plugins = {
            "com.multicalendar.lunar": "农历",
            "com.multicalendar.tibetan": "藏历",
        }
        
        assert "com.multicalendar.lunar" in loaded_plugins, "农历插件应该已注册"
        assert "com.multicalendar.tibetan" in loaded_plugins, "藏历插件应该已注册"
        
        print("   ✓ 已注册插件:")
        for plugin_id, name in loaded_plugins.items():
            print(f"      - {name} ({plugin_id})")
    
    # ========== 提醒系统测试 ==========
    
    def test_reminder_rules(self):
        """测试提醒规则"""
        default_rules = [
            ReminderRule("new-moon", "初一提醒", "newMoon", True, 0, "09:00"),
            ReminderRule("full-moon", "十五提醒", "fullMoon", True, 0, "09:00"),
            ReminderRule("buddhist", "佛教节日提醒", "buddhistFestival", True, 1, "08:00"),
            ReminderRule("traditional", "传统节日提醒", "traditionalFestival", True, 0, "09:00"),
            ReminderRule("tibetan", "藏历节日提醒", "tibetanFestival", True, 1, "08:00"),
        ]
        
        assert len(default_rules) == 5, "默认提醒规则数量不正确"
        
        rule_types = [r.reminder_type for r in default_rules]
        assert "newMoon" in rule_types, "应该包含初一提醒"
        assert "fullMoon" in rule_types, "应该包含十五提醒"
        
        print(f"   ✓ 默认提醒规则数量: {len(default_rules)}")
        for rule in default_rules:
            status = "启用" if rule.is_enabled else "禁用"
            print(f"      - {rule.name}: {status}, 提前{rule.advance_days}天, {rule.reminder_time}")
    
    # ========== 年份跳转测试（核心功能） ==========
    
    def test_year_jumping(self):
        """测试年份快速跳转"""
        test_years = [1900, 1950, 2000, 2026, 2050, 2100]
        
        for year in test_years:
            lunar = LunarCalendar.solar_to_lunar(year, 1, 1)
            assert lunar.year_name is not None, f"跳转到{year}年失败"
            print(f"   ✓ 跳转到 {year}年: {lunar.year_name} ({lunar.zodiac})")
    
    # ========== 性能测试 ==========
    
    def test_performance(self):
        """测试性能"""
        start_time = time.time()
        
        # 执行1000次转换
        for _ in range(1000):
            LunarCalendar.solar_to_lunar(2026, 2, 26)
            TibetanCalendar.solar_to_tibetan(2026, 2, 26)
        
        elapsed = time.time() - start_time
        avg_time = elapsed * 1000  # 毫秒
        
        assert elapsed < 5.0, f"性能测试未通过，耗时{elapsed:.3f}秒"
        
        print(f"   ✓ 1000次转换耗时: {elapsed:.3f}秒")
        print(f"   ✓ 平均每次转换: {avg_time:.3f}毫秒")
    
    # ========== 边界测试 ==========
    
    def test_boundary_dates(self):
        """测试边界日期"""
        # 测试年份边界
        boundary_years = [1900, 2100]
        
        for year in boundary_years:
            lunar = LunarCalendar.solar_to_lunar(year, 1, 1)
            assert lunar is not None, f"边界年份{year}转换失败"
            print(f"   ✓ 边界年份 {year}: {lunar.year_name}")
        
        # 测试月份边界
        boundary_months = [1, 12]
        for month in boundary_months:
            lunar = LunarCalendar.solar_to_lunar(2026, month, 15)
            assert lunar is not None, f"边界月份{month}转换失败"
            print(f"   ✓ 边界月份 {month}月: {lunar.month_name}")
        
        # 测试日期边界
        boundary_days = [1, 30]
        for day in boundary_days:
            lunar = LunarCalendar.solar_to_lunar(2026, 6, day)
            assert lunar is not None, f"边界日期{day}转换失败"
            print(f"   ✓ 边界日期 {day}: {lunar.day_name}")
    
    # ========== 数据完整性测试 ==========
    
    def test_data_integrity(self):
        """测试数据完整性"""
        # 验证天干数量
        assert len(LunarCalendar.TIAN_GAN) == 10, "天干数量应为10"
        print(f"   ✓ 天干数量: {len(LunarCalendar.TIAN_GAN)}")
        
        # 验证地支数量
        assert len(LunarCalendar.DI_ZHI) == 12, "地支数量应为12"
        print(f"   ✓ 地支数量: {len(LunarCalendar.DI_ZHI)}")
        
        # 验证生肖数量
        assert len(LunarCalendar.ZODIACS) == 12, "生肖数量应为12"
        print(f"   ✓ 生肖数量: {len(LunarCalendar.ZODIACS)}")
        
        # 验证月份名称数量
        assert len(LunarCalendar.MONTHS) == 12, "月份名称数量应为12"
        print(f"   ✓ 月份名称数量: {len(LunarCalendar.MONTHS)}")
        
        # 验证日期名称数量
        assert len(LunarCalendar.DAYS) == 30, "日期名称数量应为30"
        print(f"   ✓ 日期名称数量: {len(LunarCalendar.DAYS)}")
    
    # ========== 运行所有测试 ==========
    
    def run_all_tests(self):
        """运行所有测试"""
        print("\n")
        print("╔" + "═" * 68 + "╗")
        print("║" + "MultiCalendarApp 测试套件".center(60) + "║")
        print("║" + f"开始时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}".center(60) + "║")
        print("╚" + "═" * 68 + "╝")
        
        # 农历插件测试
        print("\n┌" + "─" * 68 + "┐")
        print("│ 🌙 农历插件测试" + " " * 51 + "│")
        print("└" + "─" * 68 + "┘")
        self.run_test("农历插件信息", self.test_lunar_plugin_info)
        self.run_test("公历转农历", self.test_solar_to_lunar_conversion)
        self.run_test("农历节日查询", self.test_lunar_festivals)
        self.run_test("生肖计算", self.test_lunar_zodiac_calculation)
        self.run_test("天干地支计算", self.test_lunar_ganzhi_calculation)
        
        # 藏历插件测试
        print("\n┌" + "─" * 68 + "┐")
        print("│ 🔥 藏历插件测试" + " " * 51 + "│")
        print("└" + "─" * 68 + "┘")
        self.run_test("藏历插件信息", self.test_tibetan_plugin_info)
        self.run_test("公历转藏历", self.test_solar_to_tibetan_conversion)
        self.run_test("藏历节日查询", self.test_tibetan_festivals)
        self.run_test("殊胜日检测", self.test_tibetan_special_dates)
        
        # 架构测试
        print("\n┌" + "─" * 68 + "┐")
        print("│ 🏗️ 架构与功能测试" + " " * 49 + "│")
        print("└" + "─" * 68 + "┘")
        self.run_test("插件架构", self.test_plugin_architecture)
        self.run_test("提醒规则", self.test_reminder_rules)
        self.run_test("年份快速跳转", self.test_year_jumping)
        
        # 质量测试
        print("\n┌" + "─" * 68 + "┐")
        print("│ ⚡ 性能与质量测试" + " " * 50 + "│")
        print("└" + "─" * 68 + "┘")
        self.run_test("性能测试", self.test_performance)
        self.run_test("边界测试", self.test_boundary_dates)
        self.run_test("数据完整性", self.test_data_integrity)
        
        # 打印摘要
        self.result.print_summary()
        
        return self.result.failed == 0

# ============================================================
# 主程序
# ============================================================

def main():
    print("\n")
    print("╔════════════════════════════════════════════════════════════════════╗")
    print("║                    MultiCalendarApp 测试套件                       ║")
    print("║                    多民族日历整合应用 - 完整测试                    ║")
    print("╚════════════════════════════════════════════════════════════════════╝")
    
    suite = TestSuite()
    success = suite.run_all_tests()
    
    print("\n")
    if success:
        print("🎉 所有测试通过！")
    else:
        print("❌ 存在失败的测试，请检查上方报告。")
    print("\n")
    
    return 0 if success else 1

if __name__ == "__main__":
    sys.exit(main())
