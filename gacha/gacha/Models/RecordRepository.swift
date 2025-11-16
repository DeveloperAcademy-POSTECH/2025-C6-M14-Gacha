//
//  RecordRepository.swift
//  gacha
//
//  Created by 차원준 on 10/23/25.
//
import Foundation
import SwiftData

protocol RecordRepository {
    var hasTodayRecord: Bool { get async throws }
    // @discardableResult은 프로토콜에 구현된 함수의 반환값을 사용하지 않아도 오류가 나지 않게 합니다!
    @discardableResult
    func createRecord(record: MeasuredRecord) async throws -> MeasuredRecord
    func loadRecords() async throws -> [MeasuredRecord]
    func loadRecord(by id: UUID) async throws -> MeasuredRecord?
    func loadLatestRecord() async throws -> MeasuredRecord?  // 가장 최근 데이터
    func loadRecord(by date: Date) async throws -> MeasuredRecord?  // 특정 날짜의 기록
    func loadEarliestRecord() async throws -> MeasuredRecord?  // 가장 과거 데이터
    func deleteRecord(by id: UUID) async throws
}

enum RecordError: Error {
    case recordNotFound
    case encodingFailed
    case decodingFailed
}

@MainActor
final class SwiftDataRecordRepository: RecordRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    var hasTodayRecord: Bool {
        get async throws {
            let calendar = Calendar.current
            let now = Date()

            // 현지 시간대 기준으로 오늘의 시작 시간
            guard let todayStart = calendar.startOfDay(for: now) as Date?,
                  let tomorrowStart = calendar.date(byAdding: .day, value: 1, to: todayStart) else {
                print("❌ [hasTodayRecord] 날짜 계산 실패")
                return false
            }

            print("📅 [hasTodayRecord] 현재 시간: \(now)")

            // 모든 레코드를 가져와서 현재 시간대 기준으로 필터링
            let allRecords = try await loadRecords()

            let hasToday = allRecords.contains { record in
                let isToday = record.measuredDate >= todayStart && record.measuredDate < tomorrowStart
                if isToday {
                    print("✅ [hasTodayRecord] 오늘의 기록 발견: \(record.measuredDate)")
                }
                return isToday
            }

            print("📅 [hasTodayRecord] 결과: \(hasToday)")
            return hasToday
        }
    }

    func createRecord(record: MeasuredRecord) async throws -> MeasuredRecord {
        modelContext.insert(record)
        try modelContext.save()

        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = calendar.timeZone
        let localDateString = dateFormatter.string(from: record.measuredDate)

        print("✅ Record 생성 (현지시간): \(localDateString)")
        print("   - 각도: \(record.flexionAngle ?? 0)°")
        print("   - 통증: \(record.painLevel ?? -1)")
        return record
    }

    func loadRecords() async throws -> [MeasuredRecord] {
        let descriptor = FetchDescriptor<MeasuredRecord>(sortBy: [
            SortDescriptor(\.measuredDate, order: .reverse)
        ])
        return try modelContext.fetch(descriptor)
    }

    func loadRecord(by id: UUID) async throws -> MeasuredRecord? {
        let predicate = #Predicate<MeasuredRecord> { $0.id == id }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try modelContext.fetch(descriptor).first
    }

    func loadLatestRecord() async throws -> MeasuredRecord? {
        let descriptor = FetchDescriptor<MeasuredRecord>(
            sortBy: [SortDescriptor(\.measuredDate, order: .reverse)]
        )
        return try modelContext.fetch(descriptor).first
    }
    
    func loadRecord(by date: Date) async throws -> MeasuredRecord? {
        let calendar = Calendar.current

        // 현지 시간대 기준으로 해당 날짜의 시작과 끝 시간
        guard let dayStart = calendar.startOfDay(for: date) as Date?,
              let nextDayStart = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
            print("❌ [loadRecord(by:)] 날짜 계산 실패")
            return nil
        }

        print("📅 [loadRecord(by:)] 검색 날짜: \(date)")
        print("📅 [loadRecord(by:)] 날짜 범위: \(dayStart) ~ \(nextDayStart)")

        // 모든 레코드를 가져와서 현재 시간대 기준으로 필터링
        let allRecords = try await loadRecords()

        let record = allRecords.first { record in
            let isInRange = record.measuredDate >= dayStart && record.measuredDate < nextDayStart
            if isInRange {
                print("✅ [loadRecord(by:)] 기록 발견: \(record.measuredDate)")
            }
            return isInRange
        }

        if record == nil {
            print("❌ [loadRecord(by:)] 해당 날짜의 기록 없음")
        }

        return record
    }
    
    func loadEarliestRecord() async throws -> MeasuredRecord? {
        let descriptor = FetchDescriptor<MeasuredRecord>(
            sortBy: [SortDescriptor(\.measuredDate, order: .forward)]
        )
        return try modelContext.fetch(descriptor).first
    }

    func deleteRecord(by id: UUID) async throws {
        guard let record = try await loadRecord(by: id) else {
            throw RecordError.recordNotFound
        }
        modelContext.delete(record)
        try modelContext.save()
    }
}
