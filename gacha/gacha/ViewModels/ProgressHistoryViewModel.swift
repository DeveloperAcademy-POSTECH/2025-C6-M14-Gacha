//
//  ProgressHistoryViewModel.swift
//  gacha
//
//  Created by Oh Seojin on 10/29/25.
//

import Combine
import SwiftData
import SwiftUI

class ProgressHistoryViewModel: ObservableObject {
    private var repository: RecordRepository

    @Published var recentRecords: [MeasuredRecord] = []
    @Published var selectedROMDate: Date? = nil
    @Published var selectedPainDate: Date? = nil
    
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

    // MARK: - Helper Methods

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy. M. d"
        return formatter.string(from: date)
    }

    func formatShortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
    
    func loadRecentRecords() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let allRecords = try await repository.loadRecords()
            recentRecords = Array(allRecords.prefix(7)).reversed()
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
