//
//  gachaApp.swift
//  gacha
//
//  Created by Oh Seojin on 10/20/25.
//

import SwiftData
import SwiftUI

@main
struct gachaApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: MeasuredRecord.self)

            // 예시 데이터 생성 (데모/프레젠테이션용)
            insertSampleDataIfNeeded(container: modelContainer)
        } catch {
            fatalError("ModelContainer 초기화 실패: \(error)")
        }
    }

    // MARK: - 예시 데이터 생성
    private func insertSampleDataIfNeeded(container: ModelContainer) {
        let context = container.mainContext

        // 이미 데이터가 있는지 확인
        let fetchDescriptor = FetchDescriptor<MeasuredRecord>()
        let existingRecords = try? context.fetch(fetchDescriptor)

        if let records = existingRecords, !records.isEmpty {
            print("📊 기존 데이터 존재, 예시 데이터 생성 건너뜀")
            return
        }

        let calendar = Calendar.current
        let today = Date()

        // 9일 전 데이터 (낮은 값)
        if let date9DaysAgo = calendar.date(byAdding: .day, value: -9, to: today),
           let recordDate = calendar.date(bySettingHour: 14, minute: 30, second: 0, of: date9DaysAgo) {
            let record = MeasuredRecord()
            record.measuredDate = recordDate
            record.extensionAngle = 10.0  // 높은 신전 각도 (자유롭게 수정)
            record.flexionAngle = 60.0    // 낮은 굴곡 각도 (자유롭게 수정)
            record.painLevel = 6          // 높은 통증 (자유롭게 수정)
            record.measuredSeconds = 0
            context.insert(record)
        }

        // 7일 전 ~ 1일 전 (우상향 데이터)
        for daysAgo in (1...7).reversed() {
            if let date = calendar.date(byAdding: .day, value: -daysAgo, to: today),
               let recordDate = calendar.date(bySettingHour: 14, minute: 30, second: 0, of: date) {
                let record = MeasuredRecord()
                record.measuredDate = recordDate

                // 우상향: 신전 각도는 감소, 굴곡 각도는 증가, 통증은 감소
                let progress = Double(8 - daysAgo) / 7.0  // 0.14 ~ 1.0
                record.extensionAngle = 8.0 - (progress * 8.0)  // 10° → 5° (자유롭게 수정)
                record.flexionAngle = 60.0 + (progress * 60.0)   // 60° → 120° (자유롭게 수정)
                record.painLevel = 5 - Int(progress * 3.0)       // 5 → 2 (자유롭게 수정)
                record.measuredSeconds = 0

                context.insert(record)
            }
        }

        // 저장
        do {
            try context.save()
            print("✅ 예시 데이터 8개 생성 완료")
        } catch {
            print("❌ 예시 데이터 저장 실패: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            MeasureFlowWrapper()
                .preferredColorScheme(.light)
        }
        .modelContainer(modelContainer)
    }              
}
