//
//  YearPickerView.swift
//  MultiCalendarApp
//
//  年份选择器视图
//

import SwiftUI

struct YearPickerView: View {
    let currentYear: Int
    let currentMonth: Int
    let onSelect: (Int, Int) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedYear: Int
    @State private var selectedMonth: Int
    
    private let years = Array(1900...2100)
    private let months = Array(1...12)
    private let monthNames = ["一月", "二月", "三月", "四月", "五月", "六月",
                               "七月", "八月", "九月", "十月", "十一月", "十二月"]
    
    init(currentYear: Int, currentMonth: Int, onSelect: @escaping (Int, Int) -> Void) {
        self.currentYear = currentYear
        self.currentMonth = currentMonth
        self.onSelect = onSelect
        _selectedYear = State(initialValue: currentYear)
        _selectedMonth = State(initialValue: currentMonth)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 年份选择
                VStack(alignment: .leading, spacing: 8) {
                    Text("年份")
                        .font(.headline)
                    
                    Picker("年份", selection: $selectedYear) {
                        ForEach(years, id: \.self) { year in
                            Text("\(year)年")
                                .tag(year)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 150)
                }
                
                // 月份选择
                VStack(alignment: .leading, spacing: 8) {
                    Text("月份")
                        .font(.headline)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(months, id: \.self) { month in
                            Button(action: { selectedMonth = month }) {
                                Text(monthNames[month - 1])
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(selectedMonth == month ? Color.blue : Color.gray.opacity(0.1))
                                    .foregroundColor(selectedMonth == month ? .white : .primary)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                
                Spacer()
                
                // 确认按钮
                Button(action: {
                    onSelect(selectedYear, selectedMonth)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("确定")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle("选择年月")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct YearPickerView_Previews: PreviewProvider {
    static var previews: some View {
        YearPickerView(currentYear: 2026, currentMonth: 2) { _, _ in }
    }
}
