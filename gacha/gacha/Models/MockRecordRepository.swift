//
//  MockRecordRepository.swift
//  gacha
//
//  Created for Preview and Testing
//

import Foundation

@MainActor
final class MockRecordRepository: RecordRepository {
    private var records: [MeasuredRecord] = []
    
    init(scenario: Scenario = .multipleRecordsPositive) {
        self.records = scenario.createRecords()
    }
    
    var hasTodayRecord: Bool {
        get async throws {
            let startOfDay = Calendar.current.startOfDay(for: Date())
            return records.contains { $0.measuredDate >= startOfDay }
        }
    }
    
    func createRecord(record: MeasuredRecord) async throws -> MeasuredRecord {
        records.append(record)
        return record
    }
    
    func loadRecords() async throws -> [MeasuredRecord] {
        return records.sorted { $0.measuredDate > $1.measuredDate }
    }
    
    func loadRecord(by id: UUID) async throws -> MeasuredRecord? {
        return records.first { $0.id == id }
    }
    
    func loadLatestRecord() async throws -> MeasuredRecord? {
        return records.max { $0.measuredDate < $1.measuredDate }
    }
    
    func loadRecord(by date: Date) async throws -> MeasuredRecord? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        
        return records.first { record in
            record.measuredDate >= startOfDay && record.measuredDate < endOfDay
        }
    }
    
    func loadEarliestRecord() async throws -> MeasuredRecord? {
        return records.min { $0.measuredDate < $1.measuredDate }
    }
    
    func deleteRecord(by id: UUID) async throws {
        records.removeAll { $0.id == id }
    }
}

// MARK: - Scenarios

extension MockRecordRepository {
    enum Scenario {
        case noRecord               // 데이터 없음
        case singleRecord           // 기록 1개만
        case multipleRecordsPositive // ROM 증가, 통증 감소 (긍정적)
        case multipleRecordsNegative // ROM 감소, 통증 증가 (부정적)
        case sevenRecords23Days     // 7개 기록, 23일간
        case noChange               // 변화 없음

        func createRecords() -> [MeasuredRecord] {
            let calendar = Calendar.current
            let today = Date()
            
            switch self {
            case .noRecord:
                return []

            case .singleRecord:
                return [
                    MeasuredRecord(
                        flexionAngle: 85,
                        measuredSeconds: 120,
                        painLevel: 5
                    )
                ]
                
            case .multipleRecordsPositive:
                // 이미지와 유사: 67° → 97°, 통증 5 → 4
                let dates = [
                    calendar.date(byAdding: .day, value: -23, to: today)!,
                    calendar.date(byAdding: .day, value: -20, to: today)!,
                    calendar.date(byAdding: .day, value: -15, to: today)!,
                    calendar.date(byAdding: .day, value: -10, to: today)!,
                    calendar.date(byAdding: .day, value: -5, to: today)!,
                    calendar.date(byAdding: .day, value: -2, to: today)!,
                    today
                ]
                
                let roms: [Double] = [67, 72, 78, 85, 90, 94, 97]
                let pains = [5, 5, 4, 4, 4, 4, 4]
                
                return zip(zip(dates, roms), pains).map { data, pain in
                    let (date, rom) = data
                    let record = MeasuredRecord(
                        flexionAngle: rom,
                        measuredSeconds: 120,
                        painLevel: pain
                    )
                    // measuredDate를 수동으로 설정
                    record.measuredDate = date
                    return record
                }
                
            case .multipleRecordsNegative:
                // ROM 감소, 통증 증가
                let dates = [
                    calendar.date(byAdding: .day, value: -15, to: today)!,
                    calendar.date(byAdding: .day, value: -12, to: today)!,
                    calendar.date(byAdding: .day, value: -9, to: today)!,
                    calendar.date(byAdding: .day, value: -6, to: today)!,
                    calendar.date(byAdding: .day, value: -3, to: today)!,
                    today
                ]
                
                let roms: [Double] = [95, 92, 88, 85, 82, 78]
                let pains = [3, 4, 4, 5, 5, 6]
                
                return zip(zip(dates, roms), pains).map { data, pain in
                    let (date, rom) = data
                    let record = MeasuredRecord(
                        flexionAngle: rom,
                        measuredSeconds: 120,
                        painLevel: pain
                    )
                    record.measuredDate = date
                    return record
                }
                
            case .sevenRecords23Days:
                // 정확히 7개의 기록, 23일간
                let dates = [
                    calendar.date(byAdding: .day, value: -23, to: today)!,
                    calendar.date(byAdding: .day, value: -19, to: today)!,
                    calendar.date(byAdding: .day, value: -15, to: today)!,
                    calendar.date(byAdding: .day, value: -11, to: today)!,
                    calendar.date(byAdding: .day, value: -7, to: today)!,
                    calendar.date(byAdding: .day, value: -3, to: today)!,
                    today
                ]
                
                let roms: [Double] = [60, 68, 75, 82, 88, 93, 98]
                let pains = [7, 6, 6, 5, 4, 4, 3]
                
                return zip(zip(dates, roms), pains).map { data, pain in
                    let (date, rom) = data
                    let record = MeasuredRecord(
                        flexionAngle: rom,
                        measuredSeconds: 120,
                        painLevel: pain
                    )
                    record.measuredDate = date
                    return record
                }
                
            case .noChange:
                // 변화 없음
                let dates = [
                    calendar.date(byAdding: .day, value: -10, to: today)!,
                    calendar.date(byAdding: .day, value: -7, to: today)!,
                    calendar.date(byAdding: .day, value: -4, to: today)!,
                    today
                ]
                
                return dates.map { date in
                    let record = MeasuredRecord(
                        flexionAngle: 85,
                        measuredSeconds: 120,
                        painLevel: 5
                    )
                    record.measuredDate = date
                    return record
                }
            }
        }
    }
}

