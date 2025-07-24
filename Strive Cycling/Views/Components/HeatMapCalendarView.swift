//
//  HeatMapCalendarView.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/19/25.
//

import SwiftUI

struct HeatMapDataPoint: Hashable {
    var date: Date
    var value: Double
}


struct HeatMapCalendarView: View {
    
    private static func date(_ string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: string) ?? Date()
    }
    
    /// Mock rides for initial UI
    let mockRideDates: [Date] = [
        date("2025-06-02"),
        date("2025-06-24"), date("2025-06-24"),
        date("2025-06-04"), date("2025-06-04"), date("2025-06-04"),
        date("2025-06-05"),
        date("2025-06-06"), date("2025-06-06"), date("2025-06-06"),
        date("2025-06-07"), date("2025-06-07"), date("2025-06-07"), date("2025-06-07"),
        date("2025-06-08"),
        date("2025-06-11"),
        date("2025-06-16"),
        date("2025-06-19"), date("2025-06-19"), date("2025-06-19"), date("2025-06-19"),
    ]
    
    
    
    @State var displayedMonth: Date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date())) ?? Date()
    @State private var selectedDate: Date? = nil
    
    let showDayNumbers: Bool = true
    let showExtraDays: Bool = false
    let calendar = Calendar.current
    
    private var dateMap: [Date: Int] {
        Dictionary(grouping: mockRideDates.map { calendar.startOfDay(for: $0)}) { $0 }
            .mapValues { $0.count }
    }
    
    private var months: [Date] {
        let currentYear = calendar.component(.year, from: displayedMonth)
        return (1...12).compactMap {
            calendar.date(from: DateComponents(year: currentYear, month: $0))
        }
    }
    
    private func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date)
    }
    
    /// Create month grid
    private func monthGrid(for month: Date) -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month) else { return [] }
        
        if showExtraDays {
            guard let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
                  let lastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)
            else { return [] }
            
            return stride(from: firstWeek.start, through: lastWeek.end, by: 86400).map {
                calendar.startOfDay(for: $0)
            }
        } else {
            return stride(from: monthInterval.start, through: monthInterval.end - 1, by: 86400).map {
                calendar.startOfDay(for: $0)
            }
        }
    }
    
    private func color(for value: Int) -> Color {
        switch value {
        case 5...: return .green
        case 4: return .green.opacity(0.8)
        case 3: return .green.opacity(0.6)
        case 2: return .green.opacity(0.4)
        case 1: return .green.opacity(0.2)
        default: return .gray.opacity(0.1)
        }
    }
    
    
    
    var body: some View {
        ScrollViewReader { proxy in
        
            ScrollView(.horizontal, showsIndicators: false) {
            
                HStack(spacing: 20) {
                    
                    ForEach(months, id: \.self) { month in
                        
                        VStack(spacing: 3) {
                            Text(monthTitle(for: month))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom)
                            
                            let days = monthGrid(for: month)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 2) {
                                
                                ForEach(days, id: \.self) { date in
                                    
                                    let isCurrentMonth = calendar.isDate(date, equalTo: month, toGranularity: .month)
                                    let day = calendar.component(.day, from: date)
                                    let value = dateMap[calendar.startOfDay(for: date)] ?? 0
                                    
                                    VStack {
                                        Text("\(day)")
                                            .font(.body)
                                       //     .foregroundStyle(isCurrentMonth ? .primary : .gray)
                                            .frame(maxWidth: .infinity, minHeight: 50)
                                            .opacity(showDayNumbers ? 1 : 0)
                                    }
                                    .background (
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(isCurrentMonth ? color(for: value) : Color.gray.opacity(0.2))
                                    )
                                    
                                    .overlay (
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(calendar.isDateInToday(date) ? Color.primary : .clear, lineWidth: 1)
                                            .padding(1)
                                    )
                                    
                                    .onTapGesture {
                                        selectedDate = calendar.startOfDay(for: date)
                                    }
                                    
                                    .popover(isPresented: Binding<Bool>(
                                        get: { selectedDate == calendar.startOfDay(for: date) },
                                        set: { if !$0 { selectedDate = nil } }
                                    )) {
                                        VStack {
                                            Text("Riding Time")
                                                .font(.headline)
                                            Text("\(value) hour\(value == 1 ? "" : "s")")
                                                .font(.body)
                                        }
                                        .presentationCompactAdaptation(.popover)
                                        .frame(width: 160)
                                    }
                                }
                            }
                            .containerRelativeFrame(.horizontal)
                            Spacer()
                        }
                        .id(month)
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        proxy.scrollTo(displayedMonth, anchor: .center)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
        }
      //  .safeAreaPadding(16)
    }
}

#Preview {
    HeatMapCalendarView()
}
