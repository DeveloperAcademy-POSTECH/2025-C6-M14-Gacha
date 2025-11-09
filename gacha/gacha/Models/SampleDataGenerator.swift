//
//  SampleDataGenerator.swift
//  gacha
//
//  Created for testing purposes
//

import Foundation
import SwiftData

@MainActor
struct SampleDataGenerator {
    static func generateSampleRecords(context: ModelContext) async throws {
        let calendar = Calendar.current
        let today = Date()
        
        // 기존 데이터 확인
        let descriptor = FetchDescriptor<MeasuredRecord>()
        let existingRecords = try context.fetch(descriptor)
        
        // 이미 데이터가 있으면 생성하지 않음
        guard existingRecords.isEmpty else {
            print("ℹ️ 이미 데이터가 존재합니다. 샘플 데이터를 생성하지 않습니다.")
            return
        }
        
        // 과거 90일 중에서 랜덤하게 10개의 날짜 선택
        let numberOfRecords = 10
        var selectedDayOffsets = Set<Int>()
        
        // 중복 없이 랜덤하게 10개의 날짜 선택
        while selectedDayOffsets.count < numberOfRecords {
            let dayOffset = Int.random(in: 0..<90)
            selectedDayOffsets.insert(dayOffset)
        }
        
        // 선택된 날짜들을 정렬 (과거부터 현재 순서)
        let sortedDayOffsets = selectedDayOffsets.sorted(by: >)
        
        var records: [MeasuredRecord] = []
        
        for (index, dayOffset) in sortedDayOffsets.enumerated() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else {
                continue
            }
            
            // 시간을 랜덤하게 설정 (오전 9시 ~ 오후 9시)
            let hour = Int.random(in: 9...21)
            let minute = Int.random(in: 0...59)
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            dateComponents.hour = hour
            dateComponents.minute = minute
            
            guard let measuredDate = calendar.date(from: dateComponents) else {
                continue
            }
            
            // 굴곡 각도: 초기에는 낮고 점진적으로 증가 (30도 ~ 120도)
            // 가장 오래된 기록(index 0)이 가장 작은 각도
            let baseAngle = 30.0
            let progressRatio = Double(index) / Double(numberOfRecords - 1)
            let flexionAngle = baseAngle + (progressRatio * 90.0) + Double.random(in: -10...10)
            
            // 통증 레벨: 초기에는 높고 점진적으로 감소 (8 ~ 2)
            let basePain = 8.0
            let painLevel = max(0, Int(basePain - (progressRatio * 6.0) + Double.random(in: -1...1)))
            
            // MeasuredRecord 생성 후 measuredDate 설정
            let record = MeasuredRecord(
                flexionAngle: flexionAngle,
                measuredSeconds: Int.random(in: 60...300),
                painLevel: painLevel
            )
            record.measuredDate = measuredDate
            
            records.append(record)
        }
        
        // 데이터 삽입
        for record in records {
            context.insert(record)
        }
        
        try context.save()
        
        print("✅ 샘플 데이터 생성 완료: \(records.count)개 기록")
    }
}

