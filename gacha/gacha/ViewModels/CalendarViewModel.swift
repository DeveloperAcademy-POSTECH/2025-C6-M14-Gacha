//
//  CalendarViewModel.swift
//  gacha
//
//  Created by 차원준 on 10/30/25.
//

import Combine
import Foundation

@MainActor
class CalendarViewModel: ObservableObject {
    private var repository: RecordRepository
    
    @Published var measuredDates: Set<Date> = []
    @Published var isLoading: Bool = false
    @Published var selectedDate: Date? = nil
    @Published var selectedRecord: MeasuredRecord? = nil
    @Published var showRecordModal: Bool = false
    @Published var visibleMonths: [Date] = []  // 날짜 범위
    @Published var shouldScrollToCurrentMonth: Bool = false  // 스크롤 트리거
    
    init(repository: RecordRepository) {
        self.repository = repository
    }
    
    // MARK: - Methods
    
    func loadMeasuredDates() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let records = try await repository.loadRecords()
            let calendar = Calendar.current

            print("📅 [loadMeasuredDates] 로드된 기록 수: \(records.count)")

            // 측정 기록의 날짜를 날짜만 추출하여 Set에 저장
            measuredDates = Set(records.map { record in
                let startOfDay = calendar.startOfDay(for: record.measuredDate)

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                dateFormatter.timeZone = calendar.timeZone
                print("   - 기록: \(dateFormatter.string(from: record.measuredDate)) -> \(dateFormatter.string(from: startOfDay))")

                return startOfDay
            })

            print("📅 [loadMeasuredDates] 측정된 날짜 수: \(measuredDates.count)")

            // 날짜 범위 계산
            await calculateDateRange(records: records)

            // 데이터 로드 완료 후 현재 달로 스크롤
            shouldScrollToCurrentMonth = true
        } catch {
            print("❌ 측정 기록 로드 실패: \(error)")
            measuredDates = []
            await calculateDateRange(records: [])
            shouldScrollToCurrentMonth = true
        }
    }
    
    private func calculateDateRange(records: [MeasuredRecord]) async {
        let calendar = Calendar.current
        let today = Date()
        guard let currentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today))
        else {
            visibleMonths = []
            return
        }

        var startMonth: Date
        var endMonth: Date

        if records.isEmpty {
            // 기록이 없는 경우: 현재 달부터 현재 달 +3개월까지
            startMonth = currentMonth
            endMonth = calendar.date(byAdding: .month, value: 3, to: currentMonth) ?? currentMonth
        } else {
            // 기록이 있는 경우: 가장 오래된 기록의 달부터 가장 최근 기록의 달 +3개월까지
            do {
                guard let earliestRecord = try await repository.loadEarliestRecord(),
                      let latestRecord = try await repository.loadLatestRecord() else {
                    startMonth = currentMonth
                    endMonth = calendar.date(byAdding: .month, value: 3, to: currentMonth) ?? currentMonth
                    visibleMonths = [currentMonth]
                    return
                }

                // 가장 오래된 기록의 달
                if let earliestMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: earliestRecord.measuredDate)) {
                    startMonth = earliestMonth
                } else {
                    startMonth = currentMonth
                }

                // 가장 최근 기록의 달 +3개월
                if let latestMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: latestRecord.measuredDate)),
                   let latestPlusThree = calendar.date(byAdding: .month, value: 3, to: latestMonth) {
                    endMonth = latestPlusThree
                } else {
                    endMonth = calendar.date(byAdding: .month, value: 3, to: currentMonth) ?? currentMonth
                }

            } catch {
                print("❌ 기록 로드 실패: \(error)")
                startMonth = currentMonth
                endMonth = calendar.date(byAdding: .month, value: 3, to: currentMonth) ?? currentMonth
            }
        }

        // 시작 달부터 끝 달까지 모든 월 생성 (시간 순서대로)
        var months: [Date] = []
        var currentIterMonth = startMonth

        while currentIterMonth <= endMonth {
            months.append(currentIterMonth)
            if let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentIterMonth) {
                currentIterMonth = nextMonth
            } else {
                break
            }
        }

        visibleMonths = months
    }
    
    func hasRecord(for date: Date) -> Bool {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let hasRecord = measuredDates.contains(startOfDay)

        // 디버깅용 로그 (필요시 주석 해제)
        // if hasRecord {
        //     print("✅ [hasRecord] 기록 있음: \(startOfDay)")
        // }

        return hasRecord
    }
    
    func selectDate(_ date: Date) async {
        // 미래 날짜는 선택 불가
        let calendar = Calendar.current
        let today = Date()
        let startOfToday = calendar.startOfDay(for: today)
        let startOfDate = calendar.startOfDay(for: date)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = calendar.timeZone

        print("📅 [selectDate] 선택한 날짜: \(dateFormatter.string(from: date))")
        print("📅 [selectDate] 정규화된 날짜: \(dateFormatter.string(from: startOfDate))")
        print("📅 [selectDate] 오늘: \(dateFormatter.string(from: startOfToday))")

        if startOfDate > startOfToday {
            // 미래 날짜는 선택 불가
            print("⚠️ 미래 날짜는 선택할 수 없습니다")
            return
        }

        // 날짜를 startOfDay로 정규화하여 저장
        selectedDate = startOfDate

        // 기록이 있는 날짜인지 확인
        if hasRecord(for: date) {
            do {
                selectedRecord = try await repository.loadRecord(by: date)
                showRecordModal = true
                print("✅ 기록 로드 성공: \(selectedRecord?.id ?? UUID())")
            } catch {
                print("❌ 기록 로드 실패: \(error)")
                selectedRecord = nil
            }
        } else {
            selectedRecord = nil
            showRecordModal = false
            print("ℹ️ 기록이 없는 날짜입니다")
        }
    }
    
    func scrollToCurrentMonth() {
        shouldScrollToCurrentMonth = true
    }
    
    func dismissModal() {
        showRecordModal = false
        selectedRecord = nil
    }
}

