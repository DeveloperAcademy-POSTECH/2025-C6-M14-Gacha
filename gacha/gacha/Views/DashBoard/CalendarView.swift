//
//  CalendarView.swift
//  gacha
//
//  Created by 차원준 on 10/30/25.
//

import SwiftData
import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var calendarVM: CalendarViewModel
    
    private let calendar = Calendar.current
    @State private var scrollPosition: Date? = nil
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if calendarVM.isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(calendarVM.visibleMonths, id: \.self) { monthDate in
                            MonthCalendarView(monthDate: monthDate)
                                .environmentObject(calendarVM)
                                .id(monthDate)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                }
                .scrollPosition(id: $scrollPosition, anchor: .top)
                .background(Color("White"))
                .onChange(of: calendarVM.shouldScrollToCurrentMonth) { oldValue, newValue in
                    if newValue && !calendarVM.isLoading {
                        scrollToCurrentMonth()
                        calendarVM.shouldScrollToCurrentMonth = false
                    }
                }
                .onAppear {
                    // 뷰가 나타날 때 현재 달로 스크롤 (데이터가 이미 로드된 경우)
                    if scrollPosition == nil && !calendarVM.visibleMonths.isEmpty && !calendarVM.isLoading {
                        scrollToCurrentMonth()
                    }
                }
            }
        }
        .onChange(of: calendarVM.showRecordModal) { oldValue, newValue in
            if !newValue {
                // Modal이 닫히면 선택 해제
                calendarVM.selectedDate = nil
            }
        }
        .sheet(isPresented: $calendarVM.showRecordModal) {
            if let record = calendarVM.selectedRecord {
                CalendarRecordModal(record: record, isPresented: $calendarVM.showRecordModal)
            }
        }
    }
    
    private func scrollToCurrentMonth() {
        let today = Date()
        guard let currentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) else {
            return
        }
        
        // 현재 달이 visibleMonths에 있는지 확인
        guard calendarVM.visibleMonths.contains(where: { calendar.isDate($0, equalTo: currentMonth, toGranularity: .month) }) else {
            return
        }
        
        // 현재 달 찾기
        guard let currentMonthInList = calendarVM.visibleMonths.first(where: { 
            calendar.isDate($0, equalTo: currentMonth, toGranularity: .month) 
        }) else {
            return
        }
        
        // 약간의 지연을 주어 뷰가 렌더링된 후 스크롤
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeInOut(duration: 0.3)) {
                scrollPosition = currentMonthInList
            }
        }
    }
}

// MARK: - Month Calendar View

struct MonthCalendarView: View {
    @EnvironmentObject var calendarVM: CalendarViewModel
    let monthDate: Date
    
    private let calendar = Calendar.current
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 월 헤더
            monthHeader
            
            // 요일 헤더
            weekdayHeader
            
            // 캘린더 그리드
            calendarGrid
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - Month Header
    
    private var monthHeader: some View {
        Text(monthYearString)
            .font(.displayLargeBold)
            .foregroundStyle(Color("Gray900"))
            .padding(.bottom, 20)
            .padding(.top, isFirstMonth ? 0 : 24)
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월"
        return formatter.string(from: monthDate)
    }
    
    private var isFirstMonth: Bool {
        let today = Date()
        let todayMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today))
        let viewMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate))
        return todayMonth == viewMonth
    }
    
    // MARK: - Weekday Header
    
    private var weekdayHeader: some View {
        VStack(spacing: 0) {
            Rectangle()
                .frame(height: 0.5)
                .foregroundStyle(Color("Gray300"))
                .padding(.bottom, 12)
            
            HStack(spacing: 0) {
                ForEach(["일", "월", "화", "수", "목", "금", "토"], id: \.self) { weekday in
                    Text(weekday)
                        .font(.roundedFootnoteRegular)
                        .foregroundStyle(Color("Gray500"))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 8)
        }
    }
    
    // MARK: - Calendar Grid
    
    private var calendarGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 0) {
            ForEach(0..<daysInMonth.count, id: \.self) { index in
                if let date = daysInMonth[index] {
                    dayCell(for: date)
                } else {
                    Color.clear
                        .frame(height: 44)
                }
            }
        }
    }
    
    private func dayCell(for date: Date) -> some View {
        let isFuture = isFutureDate(date)
        let isDisabled = isFuture
        
        return Button(action: {
            if !isFuture {
                Task {
                    await calendarVM.selectDate(date)
                }
            }
        }) {
            VStack(spacing: 4) {
                // 날짜 숫자
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(dayTextColor(for: date))
                    .frame(width: 36, height: 36)
                    .background(dayBackground(for: date))
                    .clipShape(Circle())
                
                // 측정 기록 표시 점
                if calendarVM.hasRecord(for: date) {
                    Circle()
                        .fill(Color("Blue700"))
                        .frame(width: 4, height: 4)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 4, height: 4)
                }
            }
            .frame(height: 50)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled)
    }
    
    private func isFutureDate(_ date: Date) -> Bool {
        let today = Date()
        let startOfToday = calendar.startOfDay(for: today)
        let startOfDate = calendar.startOfDay(for: date)
        return startOfDate > startOfToday
    }
    
    private func dayTextColor(for date: Date) -> Color {
        let isToday = calendar.isDateInToday(date)
        let isSelected = isDateSelected(date)
        let today = Date()
        let startOfToday = calendar.startOfDay(for: today)
        let startOfDate = calendar.startOfDay(for: date)
        let isFuture = startOfDate > startOfToday
        let isCurrentMonth = calendar.isDate(date, equalTo: monthDate, toGranularity: .month)
        
        if isToday {
            return Color("White")
        } else if isSelected {
            return Color("White")
        } else if isFuture {
            return Color("Gray300")  // 미래 날짜는 더 연하게
        } else if isCurrentMonth {
            return Color("Gray900")
        } else {
            return Color("Gray300")
        }
    }
    
    private func dayBackground(for date: Date) -> Color {
        let isToday = calendar.isDateInToday(date)
        let isSelected = isDateSelected(date)
        
        if isToday {
            return Color.red // iOS 기본 캘린더 스타일: 빨간 원
        } else if isSelected {
            return Color("Gray900")  // 선택된 날짜는 검정 원
        } else {
            return Color.clear
        }
    }
    
    private func isDateSelected(_ date: Date) -> Bool {
        guard let selectedDate = calendarVM.selectedDate else {
            return false
        }
        // 날짜를 startOfDay로 정규화하여 비교
        let startOfDate = calendar.startOfDay(for: date)
        let startOfSelected = calendar.startOfDay(for: selectedDate)
        return startOfDate == startOfSelected
    }
    
    // MARK: - Computed Properties
    
    private var daysInMonth: [Date?] {
        guard let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate))
        else {
            return []
        }
        
        // 해당 월의 첫 번째 날의 요일 (0: 일요일, 6: 토요일)
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 1
        
        // 해당 월의 날짜 수
        let daysCount = calendar.range(of: .day, in: .month, for: monthDate)?.count ?? 0
        
        var days: [Date?] = []
        
        // 첫 번째 날 이전의 빈 칸들
        for _ in 0..<firstWeekday {
            days.append(nil)
        }
        
        // 해당 월의 날짜들
        for day in 1...daysCount {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
}
