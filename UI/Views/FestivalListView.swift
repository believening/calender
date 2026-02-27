//
//  FestivalListView.swift
//  MultiCalendarApp
//
//  节日列表完整视图 - 显示本月/本年所有节日
//

import SwiftUI

struct FestivalListView: View {
    let year: Int
    let month: Int?
    
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedType: FestivalType?
    @State private var festivals: [Festival] = []
    @State private var searchText = ""
    
    init(year: Int, month: Int? = nil) {
        self.year = year
        self.month = month
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 筛选器
                FestivalTypeFilter(selectedType: $selectedType)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                
                // 搜索框
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("搜索节日", text: $searchText)
                        .textFieldStyle(.plain)
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(10)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                // 节日列表
                if filteredFestivals.isEmpty {
                    EmptyFestivalsView()
                } else {
                    List {
                        ForEach(groupedFestivals.keys.sorted(), id: \.self) { monthNum in
                            Section(header: Text("\(monthNum)月")) {
                                ForEach(groupedFestivals[monthNum] ?? []) { festival in
                                    FestivalListRow(festival: festival)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle(month != nil ? "\(month!)月节日" : "\(year)年节日")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                loadFestivals()
            }
        }
    }
    
    private var filteredFestivals: [Festival] {
        var result = festivals
        
        // 按类型筛选
        if let type = selectedType {
            result = result.filter { $0.type == type }
        }
        
        // 按搜索文本筛选
        if !searchText.isEmpty {
            result = result.filter { festival in
                festival.name.localizedCaseInsensitiveContains(searchText) ||
                (festival.nameTibetan?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (festival.description?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        return result
    }
    
    private var groupedFestivals: [Int: [Festival]] {
        Dictionary(grouping: filteredFestivals) { festival in
            switch festival.date {
            case .fixed(let month, _):
                return month
            case .relative(let month, _, _):
                return month
            case .lunar(let month, _):
                return month
            case .tibetan(let month, _):
                return month
            }
        }
    }
    
    private func loadFestivals() {
        // 从插件加载节日数据
        var allFestivals: [Festival] = []
        
        if let lunarPlugin = PluginManager.shared.getPlugin(for: .lunar) {
            if let m = month {
                allFestivals.append(contentsOf: lunarPlugin.getFestivals(year: year, month: m))
            } else {
                for m in 1...12 {
                    allFestivals.append(contentsOf: lunarPlugin.getFestivals(year: year, month: m))
                }
            }
        }
        
        if let tibetanPlugin = PluginManager.shared.getPlugin(for: .tibetan) {
            if let m = month {
                allFestivals.append(contentsOf: tibetanPlugin.getFestivals(year: year, month: m))
            } else {
                for m in 1...12 {
                    allFestivals.append(contentsOf: tibetanPlugin.getFestivals(year: year, month: m))
                }
            }
        }
        
        festivals = allFestivals.sorted { f1, f2 in
            let m1 = getMonth(from: f1.date)
            let m2 = getMonth(from: f2.date)
            let d1 = getDay(from: f1.date)
            let d2 = getDay(from: f2.date)
            return m1 == m2 ? d1 < d2 : m1 < m2
        }
    }
    
    private func getMonth(from date: FestivalDate) -> Int {
        switch date {
        case .fixed(let m, _): return m
        case .relative(let m, _, _): return m
        case .lunar(let m, _): return m
        case .tibetan(let m, _): return m
        }
    }
    
    private func getDay(from date: FestivalDate) -> Int {
        switch date {
        case .fixed(_, let d): return d
        case .relative(_, _, _): return 1
        case .lunar(_, let d): return d
        case .tibetan(_, let d): return d
        }
    }
}

// MARK: - 节日类型筛选器

struct FestivalTypeFilter: View {
    @Binding var selectedType: FestivalType?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "全部", isSelected: selectedType == nil) {
                    selectedType = nil
                }
                
                ForEach(FestivalType.allCases, id: \.self) { type in
                    FilterChip(title: type.rawValue, isSelected: selectedType == type) {
                        selectedType = type
                    }
                }
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

// MARK: - 节日列表行

struct FestivalListRow: View {
    let festival: Festival
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(festival.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text(formatDate(festival.date))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            if let tibetanName = festival.nameTibetan {
                Text(tibetanName)
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            
            HStack {
                Label(festival.calendarType.rawValue, systemImage: calendarIcon(for: festival.calendarType))
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text(festival.type.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(typeColor(for: festival.type).opacity(0.2))
                    .foregroundColor(typeColor(for: festival.type))
                    .cornerRadius(4)
            }
            
            if let desc = festival.description {
                Text(desc)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: FestivalDate) -> String {
        switch date {
        case .fixed(let m, let d):
            return "\(m)月\(d)日"
        case .relative(let m, let week, let weekday):
            let weekdays = ["日", "一", "二", "三", "四", "五", "六"]
            return "\(m)月第\(week)周\(weekdays[weekday])"
        case .lunar(let m, let d):
            return "农历\(m)月\(d)"
        case .tibetan(let m, let d):
            return "藏历\(m)月\(d)"
        }
    }
    
    private func calendarIcon(for type: CalendarType) -> String {
        switch type {
        case .solar: return "sun.max"
        case .lunar: return "moon.fill"
        case .tibetan: return "flame.fill"
        default: return "calendar"
        }
    }
    
    private func typeColor(for type: FestivalType) -> Color {
        switch type {
        case .traditional: return .red
        case .buddhist: return .orange
        case .national: return .blue
        case .solar: return .green
        case .custom: return .purple
        }
    }
}

// MARK: - 空状态视图

struct EmptyFestivalsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("暂无节日")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("当前筛选条件下没有找到节日")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

struct FestivalListView_Previews: PreviewProvider {
    static var previews: some View {
        FestivalListView(year: 2026, month: 1)
    }
}
