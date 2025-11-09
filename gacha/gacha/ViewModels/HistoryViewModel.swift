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
    
    var painLevelLabel: String {
        if recentRecords.count == 1 {
            return Strings.Card.painLevel
        } else {
            return Strings.History.painMin + "~" + Strings.History.painMax
        }
    }
    
    var painLevelValue: String {
        if recentRecords.count == 1 {
            return "\(painMin)"
        } else {
            return "\(painMin)~\(painMax)"
        }
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
            return "지난 \(daysBetweenRecords)일간\n무릎 굽힘 범위가\n\(abs(change))도 늘어났어요!"
        } else {
            return "지난 \(daysBetweenRecords)일간\n무릎 굽힘 범위가\n\(abs(change))도 줄어들었어요"
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
            return "처음에 비해\n통증이\n\(abs(change))단계 줄어들었어요!"
        } else {
            return "처음에 비해\n통증이\n\(abs(change))단계 늘어났어요"
        }
    }
    
    // MARK: - Chart Y-Axis Range
    
    var romMaxValue: Double {
        guard !recentRecords.isEmpty else { return 190 }
        let maxROM = recentRecords.compactMap { $0.flexionAngle }.max() ?? 0
        return maxROM + 10
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
        print("🔍 formatShortDate - Input: \(date), Output: '\(result)'")
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
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy/M/d"

        let start = formatter.string(from: startDate)
        formatter.dateFormat = "d"
        let end = formatter.string(from: endDate)

        return "\(start)~\(end)"
    }
}
