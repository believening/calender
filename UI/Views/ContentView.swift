//
//  ContentView.swift
//  MultiCalendarApp
//
//  主视图
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var showYearPicker = false
    @State private var showSettings = false
    @State private var showDayDetail = false
    @State private var showFestivalList = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 月份导航
                MonthNavigationView(
                    currentMonth: viewModel.currentMonth,
                    onPrevious: viewModel.previousMonth,
                    onNext: viewModel.nextMonth,
                    onToday: viewModel.goToToday,
                    onYearPicker: { showYearPicker = true }
                )
                
                // 星期标题
                WeekdayHeaderView()
                
                // 日历网格
                CalendarGridView(
                    days: viewModel.calendarDays,
                    selectedDate: viewModel.selectedDate,
                    onSelectDate: { date in
                        viewModel.selectDate(date)
                        showDayDetail = true
                    }
                )
                
                // 快捷操作栏
                QuickActionsBar(
                    festivalCount: viewModel.currentMonthFestivals.count,
                    onShowFestivals: { showFestivalList = true }
                )
                
                Spacer()
            }
            .navigationTitle("多民族日历")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gear")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        // 农历开关
                        Button(action: viewModel.toggleLunar) {
                            Image(systemName: viewModel.showLunar ? "moon.fill" : "moon")
                                .foregroundColor(viewModel.showLunar ? .blue : .gray)
                        }
                        
                        // 藏历开关
                        if viewModel.loadedCalendarTypes.contains(.tibetan) {
                            Button(action: viewModel.toggleTibetan) {
                                Image(systemName: viewModel.showTibetan ? "flame.fill" : "flame")
                                    .foregroundColor(viewModel.showTibetan ? .orange : .gray)
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showYearPicker) {
                YearPickerView(
                    currentYear: Calendar.current.component(.year, from: viewModel.currentMonth),
                    currentMonth: Calendar.current.component(.month, from: viewModel.currentMonth),
                    onSelect: { year, month in
                        viewModel.jumpToYear(year, month: month)
                        showYearPicker = false
                    }
                )
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showDayDetail) {
                if let dateInfo = viewModel.selectedDateInfo {
                    DayDetailView(date: viewModel.selectedDate, calendarDate: dateInfo)
                }
            }
            .sheet(isPresented: $showFestivalList) {
                let year = Calendar.current.component(.year, from: viewModel.currentMonth)
                let month = Calendar.current.component(.month, from: viewModel.currentMonth)
                FestivalListView(year: year, month: month)
            }
        }
    }
}

// MARK: - 快捷操作栏

struct QuickActionsBar: View {
    let festivalCount: Int
    let onShowFestivals: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: onShowFestivals) {
                HStack(spacing: 6) {
                    Image(systemName: "gift.fill")
                        .foregroundColor(.pink)
                    Text("本月节日")
                        .font(.caption)
                    if festivalCount > 0 {
                        Text("(\(festivalCount))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.pink.opacity(0.1))
                .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.03))
    }
}

// MARK: - 月份导航视图

struct MonthNavigationView: View {
    let currentMonth: Date
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onToday: () -> Void
    let onYearPicker: () -> Void
    
    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy年M月"
        return f
    }()
    
    var body: some View {
        HStack {
            Button(action: onPrevious) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .padding()
            }
            
            Spacer()
            
            Button(action: onYearPicker) {
                Text(formatter.string(from: currentMonth))
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            Spacer()
            
            Button(action: onNext) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .padding()
            }
        }
        .padding(.horizontal)
        .overlay(
            Button("今天", action: onToday)
                .font(.caption)
                .padding(6)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            , alignment: .center
        )
    }
}

// MARK: - 星期标题视图

struct WeekdayHeaderView: View {
    private let weekdays = ["日", "一", "二", "三", "四", "五", "六"]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekdays, id: \.self) { weekday in
                Text(weekday)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(weekday == "日" ? .red : .primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
        }
        .background(Color.gray.opacity(0.05))
    }
}

// MARK: - 日历网格视图

struct CalendarGridView: View {
    let days: [CalendarDay]
    let selectedDate: Date
    let onSelectDate: (Date) -> Void
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(days) { day in
                if day.isEmpty {
                    Color.clear
                        .frame(height: 70)
                } else {
                    CalendarDayCell(
                        day: day,
                        isSelected: day.isSelected,
                        onSelect: { onSelectDate(day.date) }
                    )
                }
            }
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - 日历单元格视图

struct CalendarDayCell: View {
    let day: CalendarDay
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        VStack(spacing: 2) {
            // 公历日期
            Text("\(day.solarDay)")
                .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                .foregroundColor(isSelected ? .white : .primary)
            
            // 农历/节日
            Text(day.displayText)
                .font(.system(size: 10))
                .foregroundColor(isSelected ? .white : .gray)
                .lineLimit(1)
            
            // 藏历（如果有）
            if let tibetanText = day.tibetanDisplayText {
                Text(tibetanText)
                    .font(.system(size: 9))
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .orange)
                    .lineLimit(1)
            }
            
            // 节日标记
            if !day.festivals.isEmpty {
                Circle()
                    .fill(isSelected ? Color.white : Color.red)
                    .frame(width: 4, height: 4)
            }
        }
        .frame(height: 70)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.blue : (day.isToday ? Color.blue.opacity(0.1) : Color.clear))
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onSelect)
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
