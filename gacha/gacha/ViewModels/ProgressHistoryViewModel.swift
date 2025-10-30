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
        guard let startDate = recentRecords.first?.measuredDate,
            let endDate = recentRecords.last?.measuredDate
        else {
            return ""
        }
        let formattedDate = formatDateRange(startDate: startDate, endDate: endDate)
        return formattedDate
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
        formatter.dateFormat = "yyyy년 M월 d일"

        let start = formatter.string(from: startDate)
        formatter.dateFormat = "d일"
        let end = formatter.string(from: endDate)

        return "\(start)~\(end)"
    }
}
