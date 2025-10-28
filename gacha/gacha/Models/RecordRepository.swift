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
            let startOfDay = Calendar.current.startOfDay(for: Date())
            let predicate = #Predicate<MeasuredRecord> { record in
                record.measuredDate >= startOfDay
            }
            let descriptor = FetchDescriptor<MeasuredRecord>(
                predicate: predicate
            )
            let records = try modelContext.fetch(descriptor)
            return !records.isEmpty
        }
    }

    func createRecord(record: MeasuredRecord) async throws -> MeasuredRecord {
        modelContext.insert(record)
        try modelContext.save()

        print("✅ Record 생성: Extension \(record.extensionAngle)°")
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

    func deleteRecord(by id: UUID) async throws {
        guard let record = try await loadRecord(by: id) else {
            throw RecordError.recordNotFound
        }
        modelContext.delete(record)
        try modelContext.save()
    }
}
