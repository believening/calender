//
//  DayDetailView.swift
//  MultiCalendarApp
//
//  日期详情视图 - 显示选中日期的完整信息
//

import SwiftUI

struct DayDetailView: View {
    let date: Date
    let calendarDate: CalendarDate?
    
    @Environment(\.presentationMode) var presentationMode
    @State private var showAddReminder = false
    
    private let calendar = Calendar.current
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 公历日期卡片
                    SolarDateCard(date: date)
                    
                    // 农历信息卡片
                    if let lunarDate = calendarDate?.lunarDate {
                        LunarDateCard(lunarDate: lunarDate, date: date)
                    }
                    
                    // 藏历信息卡片
                    if let tibetanDate = calendarDate?.tibetanDate {
                        TibetanDateCard(tibetanDate: tibetanDate, date: date)
                    }
                    
                    // 节日信息
                    if let festivals = calendarDate?.festivals, !festivals.isEmpty {
                        FestivalsCard(festivals: festivals)
                    }
                    
                    // 每日宜忌
                    if let dailyInfo = calendarDate?.dailyInfo {
                        if #available(iOS 16.0, *) {
                            DailyInfoCard(dailyInfo: dailyInfo)
                        } else {
                            DailyInfoCardFallback(dailyInfo: dailyInfo)
                        }
                    }
                    
                    // 操作按钮
                    ActionButtonsView(date: date, showAddReminder: $showAddReminder)
                }
                .padding()
            }
            .navigationTitle(formatDate(date))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日 EEEE"
        return formatter.string(from: date)
    }
}

// MARK: - 公历日期卡片

struct SolarDateCard: View {
    let date: Date
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 64, weight: .bold))
                .foregroundColor(.blue)
            
            Text(formatFullDate(date))
                .font(.title3)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.blue.opacity(0.05))
        .cornerRadius(16)
    }
    
    private func formatFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日 EEEE"
        return formatter.string(from: date)
    }
}

// MARK: - 农历日期卡片

struct LunarDateCard: View {
    let lunarDate: LunarDate
    let date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "moon.fill")
                    .foregroundColor(.orange)
                Text("农历")
                    .font(.headline)
                Spacer()
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("年份")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(lunarDate.yearName ?? "\(lunarDate.year)年")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("生肖")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(lunarDate.zodiac ?? "")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("月份")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(lunarDate.monthName ?? "\(lunarDate.month)月")
                        .font(.title2)
                        .fontWeight(.bold)
                    if lunarDate.isLeapMonth {
                        Text("(闰月)")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("日期")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(lunarDate.dayName ?? "初\(lunarDate.day)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
            
            if let ganZhi = lunarDate.ganZhi {
                HStack {
                    Text("干支：")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(ganZhi)
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.05))
        .cornerRadius(16)
    }
}

// MARK: - 藏历日期卡片

struct TibetanDateCard: View {
    let tibetanDate: TibetanDate
    let date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.red)
                Text("藏历")
                    .font(.headline)
                Spacer()
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("年份")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(tibetanDate.yearElement ?? "\(tibetanDate.year)年")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("月份")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(tibetanDate.monthNameChinese ?? "\(tibetanDate.month)月")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("日期")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(tibetanDate.dayNameChinese ?? "\(tibetanDate.day)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
            
            // 特殊标记
            HStack(spacing: 12) {
                if tibetanDate.isMissingDay {
                    Label("缺日", systemImage: "minus.circle")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                if tibetanDate.isDoubleday {
                    Label("重日", systemImage: "plus.circle")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            if let tibetanName = tibetanDate.monthNameTibetan {
                Text(tibetanName)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.red.opacity(0.05))
        .cornerRadius(16)
    }
}

// MARK: - 节日卡片

struct FestivalsCard: View {
    let festivals: [Festival]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "gift.fill")
                    .foregroundColor(.pink)
                Text("节日")
                    .font(.headline)
                Spacer()
                Text("\(festivals.count)个")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Divider()
            
            ForEach(festivals) { festival in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(festival.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text(festival.type.rawValue)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(typeColor(for: festival.type).opacity(0.2))
                            .foregroundColor(typeColor(for: festival.type))
                            .cornerRadius(4)
                    }
                    
                    if let tibetanName = festival.nameTibetan {
                        Text(tibetanName)
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    
                    if let desc = festival.description {
                        Text(desc)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                }
                .padding(.vertical, 4)
                
                if festival.id != festivals.last?.id {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color.pink.opacity(0.05))
        .cornerRadius(16)
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

// MARK: - 每日宜忌卡片

@available(iOS 16.0, *)
struct DailyInfoCard: View {
    let dailyInfo: DailyInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundColor(.green)
                Text("每日宜忌")
                    .font(.headline)
                Spacer()
            }
            
            Divider()
            
            // 宜
            if !dailyInfo.suitable.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("宜")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Spacer()
                    }
                    
                    FlowLayout(spacing: 8) {
                        ForEach(dailyInfo.suitable, id: \.self) { item in
                            Text(item)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                }
            }
            
            if !dailyInfo.suitable.isEmpty && !dailyInfo.unsuitable.isEmpty {
                Divider()
            }
            
            // 忌
            if !dailyInfo.unsuitable.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("忌")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        
                        Spacer()
                    }
                    
                    FlowLayout(spacing: 8) {
                        ForEach(dailyInfo.unsuitable, id: \.self) { item in
                            Text(item)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                }
            }
            
            // 其他信息
            if let chongSha = dailyInfo.chongSha {
                Divider()
                HStack {
                    Text("冲煞：")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(chongSha)
                        .font(.caption)
                }
            }
            
            if let fiveElements = dailyInfo.fiveElements {
                HStack {
                    Text("五行：")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(fiveElements)
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color.green.opacity(0.05))
        .cornerRadius(16)
    }
}

// MARK: - iOS 15 fallback for 每日宜忌卡片

struct DailyInfoCardFallback: View {
    let dailyInfo: DailyInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundColor(.green)
                Text("每日宜忌")
                    .font(.headline)
                Spacer()
            }

            Divider()

            // 宜
            if !dailyInfo.suitable.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("宜")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.green)

                        Spacer()
                    }

                    // Simple fallback layout for iOS 15
                    let columns = [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ]
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(dailyInfo.suitable, id: \.self) { item in
                            Text(item)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                }
            }

            if !dailyInfo.suitable.isEmpty && !dailyInfo.unsuitable.isEmpty {
                Divider()
            }

            // 忌
            if !dailyInfo.unsuitable.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("忌")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.red)

                        Spacer()
                    }

                    // Simple fallback layout for iOS 15
                    let columns = [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ]
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(dailyInfo.unsuitable, id: \.self) { item in
                            Text(item)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                }
            }

            // 其他信息
            if let chongSha = dailyInfo.chongSha {
                Divider()
                HStack {
                    Text("冲煞：")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(chongSha)
                        .font(.caption)
                }
            }

            if let fiveElements = dailyInfo.fiveElements {
                HStack {
                    Text("五行：")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(fiveElements)
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color.green.opacity(0.05))
        .cornerRadius(16)
    }
}

// MARK: - 操作按钮

struct ActionButtonsView: View {
    let date: Date
    @Binding var showAddReminder: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: { showAddReminder = true }) {
                Label("添加提醒", systemImage: "bell.badge")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            
            Button(action: { shareDate() }) {
                Label("分享", systemImage: "square.and.arrow.up")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
            }
        }
    }
    
    private func shareDate() {
        // TODO: 实现分享功能
    }
}

// MARK: - 流式布局

@available(iOS 16.0, *)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                       y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth, x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + rowHeight)
        }
    }
}

// MARK: - Preview

struct DayDetailView_Previews: PreviewProvider {
    static var previews: some View {
        DayDetailView(
            date: Date(),
            calendarDate: CalendarDate(solarDate: Date())
        )
    }
}
