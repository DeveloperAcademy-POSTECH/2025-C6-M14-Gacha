//
//  HistoryViewModel.swift
//  gacha
//
//  Created by Oh Seojin on 10/29/25.
//

import Combine
import SwiftData
import SwiftUI

class HistoryViewModel: ObservableObject {
    private var repository: RecordRepository

    @Published var recentRecords: [MeasuredRecord] = []
    @Published var selectedROMDate: Date? = nil
    @Published var selectedPainDate: Date? = nil
    @Published var selectedROMIndex: Int? = nil
    @Published var selectedPainIndex: Int? = nil
    
    @Published var isLoading: Bool = false
    
    init(repository: RecordRepository) {
        self.repository = repository
    }
    
    // MARK: - calculated property
    var romAverage: Int {
        guard !recentRecords.isEmpty else { return 0 }
        let sum = recentRecords.compactMap { $0.ROM }.map { Int($0) }.reduce(0, +)
        return sum / recentRecords.count
    }
    
    var dateRangeText: String {
        guard !recentRecords.isEmpty else { return "" }
        
        // 데이터가 1개인 경우
        if recentRecords.count == 1,
           let singleDate = recentRecords.first?.measuredDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/M/d"
            return formatter.string(from: singleDate)
        }
        
        // 데이터가 2개 이상인 경우
        guard let startDate = recentRecords.first?.measuredDate,
              let endDate = recentRecords.last?.measuredDate
        else {
            return ""
        }
        return formatDateRange(startDate: startDate, endDate: endDate)
    }

    var painMin: Int {
        guard let min = recentRecords.compactMap({ $0.painLevel }).min() else {
            return 0
        }
        return min
    }

    var painMax: Int {
        guard let max = recentRecords.compactMap({ $0.painLevel }).max() else {
            return 0
        }
        return max
    }
    
    // MARK: - Summary Cards Data
    
    /// 첫 번째 (가장 오래된) 기록의 ROM
    var firstROM: Int? {
        guard let first = recentRecords.first,
              let rom = first.flexionAngle else { return nil }
        return Int(rom)
    }
    
    /// 마지막 (가장 최근) 기록의 ROM
    var latestROM: Int? {
        guard let last = recentRecords.last,
              let rom = last.flexionAngle else { return nil }
        return Int(rom)
    }
    
    /// ROM 변화량 (최근 - 오래된)
    var romChange: Int? {
        guard let first = firstROM, let latest = latestROM else { return nil }
        return latest - first
    }
    
    /// ROM 변화 설명 텍스트
    var romChangeText: String {
        guard recentRecords.count > 1,
              let change = romChange,
              change != 0 else {
            return ""
        }

        if change > 0 {
            return Strings.History.romBetter(days: daysBetweenRecords, degrees: abs(change))
        } else {
            return Strings.History.romWorse(days: daysBetweenRecords, degrees: abs(change))
        }
    }

    /// ROM 서브타이틀 (최근 일주일 이내 데이터와 오늘 데이터 비교)
    var romSubtitle: String {
        // 측정 기록이 없는 경우
        guard !recentRecords.isEmpty else {
            return Strings.History.chartRomNoRecord
        }

        // 첫 측정인 경우
        guard recentRecords.count > 1,
              let todayROM = latestROM else {
            guard let firstROM = latestROM else {
                return Strings.History.chartRomNoRecord
            }
            return Strings.History.chartRomFirstRecord(angle: firstROM)
        }

        // 최근 일주일 이내의 최대 ROM (오늘 제외)
        let previousRecords = recentRecords.dropLast()
        guard let maxPreviousROM = previousRecords.compactMap({ $0.flexionAngle }).max() else {
            return Strings.History.chartRomFirstRecord(angle: todayROM)
        }

        let maxPreviousROMInt = Int(maxPreviousROM)
        let difference = abs(todayROM - maxPreviousROMInt)

        // 비교 (ROM은 클수록 좋음)
        if Double(todayROM) > maxPreviousROM {
            return Strings.History.chartRomBetter(prevMax: maxPreviousROMInt, improvement: difference)
        } else if Double(todayROM) == maxPreviousROM {
            return Strings.History.chartRomSame(prevMax: maxPreviousROMInt)
        } else {
            return Strings.History.chartRomWorse(prevMax: maxPreviousROMInt, decline: difference)
        }
    }
    
    /// 첫 번째와 마지막 기록 사이의 날짜 차이 (일 단위)
    var daysBetweenRecords: Int {
        guard recentRecords.count > 1,
              let firstDate = recentRecords.first?.measuredDate,
              let lastDate = recentRecords.last?.measuredDate else {
            return 0
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: firstDate, to: lastDate)
        return components.day ?? 0
    }
    
    /// 첫 번째 (가장 오래된) 기록의 통증 레벨
    var firstPainLevel: Int? {
        guard let first = recentRecords.first else { return nil }
        return first.painLevel
    }
    
    /// 마지막 (가장 최근) 기록의 통증 레벨
    var latestPainLevel: Int? {
        guard let last = recentRecords.last else { return nil }
        return last.painLevel
    }
    
    /// 통증 변화량 (처음 - 최근, 양수면 줄어든 것)
    var painChange: Int? {
        guard let first = firstPainLevel, let latest = latestPainLevel else { return nil }
        return first - latest
    }
    
    /// 통증 변화 설명 텍스트
    var painChangeText: String {
        guard recentRecords.count > 1,
              let change = painChange,
              change != 0 else {
            return ""
        }

        if change > 0 {
            return Strings.History.painBetter(levels: abs(change))
        } else {
            return Strings.History.painWorse(levels: abs(change))
        }
    }

    /// 통증 레벨 서브타이틀 (최근 일주일 이내 데이터와 오늘 데이터 비교)
    var painSubtitle: String {
        // 측정 기록이 없는 경우
        guard !recentRecords.isEmpty else {
            return Strings.History.chartPainNoRecord
        }

        // 첫 측정인 경우
        guard recentRecords.count > 1,
              let todayPain = latestPainLevel else {
            guard let firstPain = latestPainLevel else {
                return Strings.History.chartPainNoRecord
            }
            return Strings.History.chartPainFirstRecord(level: firstPain)
        }

        // 최근 일주일 이내의 최소 통증 레벨 (오늘 제외, 통증은 낮을수록 좋음)
        let previousRecords = recentRecords.dropLast()
        guard let minPreviousPain = previousRecords.compactMap({ $0.painLevel }).min() else {
            return Strings.History.chartPainFirstRecord(level: todayPain)
        }

        let difference = abs(todayPain - minPreviousPain)

        // 비교 (통증은 낮을수록 좋음)
        if todayPain < minPreviousPain {
            return Strings.History.chartPainBetter(improvement: difference, from: minPreviousPain)
        } else if todayPain == minPreviousPain {
            return Strings.History.chartPainSame(level: minPreviousPain)
        } else {
            return Strings.History.chartPainWorse(increase: difference, from: minPreviousPain)
        }
    }
    
    // MARK: - Chart Y-Axis Range
    
    var romMaxValue: Double {
        // Use only finite, non-negative angles to avoid invalid ranges or NaN propagation
        let validAngles = recentRecords
            .compactMap { $0.flexionAngle }
            .filter { $0.isFinite && $0 >= 0 }
        
        guard let maxROM = validAngles.max() else {
            // Safe default when no valid angles exist
            return 0
        }
        
        // Padding for headroom; ensure upper bound is positive
        let padded = maxROM + 10
        return max(padded, 1)
    }
    
    var painMaxValue: Double {
        guard !recentRecords.isEmpty else { return 10 }
        let maxPain = recentRecords.compactMap { $0.painLevel }.map { Double($0) }.max() ?? 0
        // 데이터의 최댓값을 그대로 사용 (0일 경우 최소 1로 설정)
        return max(maxPain, 1)
    }
    
    // MARK: - Chart X-Axis Dates
    
    var recordDates: [Date] {
        recentRecords.map { $0.measuredDate }
    }
    
    var chartIndices: [Int] {
        Array(0..<recentRecords.count)
    }
    
    var chartIndicesAsDouble: [Double] {
        chartIndices.map { Double($0) }
    }
    
    // MARK: - Chart Data
    
    var chartData: [(index: Int, record: MeasuredRecord)] {
        Array(recentRecords.enumerated().map { (index: $0, record: $1) })
    }
    
    var xAxisDomain: ClosedRange<Double> {
        let maxIndex = Double(max(0, recentRecords.count-1))
        return -0.3...(maxIndex + 0.8)
    }

    // MARK: - Helper Methods

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy. M. d"
        return formatter.string(from: date)
    }

    func formatShortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        let result = formatter.string(from: date)
        return result
    }
    
    func loadRecentRecords() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let allRecords = try await repository.loadRecords()
            recentRecords = Array(allRecords.prefix(7)).reversed()
            print("📅 loadRecentRecords - Total records: \(allRecords.count), Recent records: \(recentRecords.count)")
            for (index, record) in recentRecords.enumerated() {
                print("  [\(index)] Date: \(record.measuredDate), Formatted: \(formatShortDate(record.measuredDate))")
            }
        } catch {
            print("❌ 최근 기록 로드 실패: \(error)")
            recentRecords = []
        }
    }
    
    func formatDateRange(startDate: Date, endDate: Date) -> String{
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "yyyy/M/d"

        let start = formatter.string(from: startDate)
        formatter.dateFormat = "d"
        let end = formatter.string(from: endDate)

        return "\(start)~\(end)"
    }
}
