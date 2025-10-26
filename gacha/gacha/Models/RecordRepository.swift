//
//  RecordRepository.swift
//  gacha
//
//  Created by 차원준 on 10/23/25.
//
import Foundation
import SwiftData

protocol RecordRepository {
    // @discardableResult은 프로토콜에 구현된 함수의 반환값을 사용하지 않아도 오류가 나지 않게 합니다!
    @discardableResult
    func createRecord(extensionAngle: Double) async throws -> MeasuredRecord
    func updateFlexion(recordId: UUID, flexionAngle: Double, measuredMinutes: Int) async throws -> MeasuredRecord
    func updatePainLevel(recordId: UUID, painLevel: Int) async throws -> MeasuredRecord
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
class SwiftDataRecordRepository: RecordRepository {
      private let modelContext: ModelContext

      init(modelContext: ModelContext) {
          self.modelContext = modelContext
      }

      func createRecord(extensionAngle: Double) async throws -> MeasuredRecord {
          let record = MeasuredRecord(extensionAngle: extensionAngle)
          modelContext.insert(record)
          try modelContext.save()

          print("✅ Record 생성: Extension \(extensionAngle)°")
          return record
      }

      func updateFlexion(recordId: UUID, flexionAngle: Double, measuredMinutes: Int) async throws -> MeasuredRecord {
          // #Predicate: SwiftData의 타입 안전 쿼리 매크로
          // <MeasuredRecord>: 검색할 모델 타입
          let predicate = #Predicate<MeasuredRecord> { $0.id == recordId }
          let descriptor = FetchDescriptor(predicate: predicate)

          guard let record = try modelContext.fetch(descriptor).first else {
              throw RecordError.recordNotFound
          }

          record.flexionAngle = flexionAngle
          record.measuredMinutes = measuredMinutes
          try modelContext.save()

          print("✅ Record 업데이트: Flexion \(flexionAngle)°, \(measuredMinutes)분")
          return record
      }

      func updatePainLevel(recordId: UUID, painLevel: Int) async throws -> MeasuredRecord {
          let predicate = #Predicate<MeasuredRecord> { $0.id == recordId }
          let descriptor = FetchDescriptor(predicate: predicate)

          guard let record = try modelContext.fetch(descriptor).first else {
              throw RecordError.recordNotFound
          }

          record.painLevel = painLevel
          try modelContext.save()

          print("✅ Record 업데이트: Pain Level \(painLevel)")
          return record
      }

      func loadRecords() async throws -> [MeasuredRecord] {
          let descriptor = FetchDescriptor<MeasuredRecord>(sortBy: [SortDescriptor(\.measuredDate, order: .reverse)])
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
