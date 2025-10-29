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
            
            // 실기기 테스트용 샘플 데이터 추가 (첫 실행 시에만)
            addSampleDataIfNeeded()
        } catch {
            fatalError("ModelContainer 초기화 실패: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MeasureFlowViewWrapper()
        }
        .modelContainer(modelContainer)
    }
    
    // MARK: - Sample Data
    
    private func addSampleDataIfNeeded() {
        let context = modelContainer.mainContext
        
        // 기존 데이터 확인
        let fetchDescriptor = FetchDescriptor<MeasuredRecord>()
        let existingRecords = try? context.fetch(fetchDescriptor)
        // 데이터가 없으면 샘플 데이터 추가
        if existingRecords?.isEmpty ?? true {
            let sampleData = [
                (days: -9, flexion: 50.0, extension: 140.0, pain: 4),
                (days: -8, flexion: 25.0, extension: 105.0, pain: 5),
                (days: -7, flexion: 28.0, extension: 98.0, pain: 5),
                (days: -6, flexion: 22.0, extension: 125.0, pain: 4),
                (days: -5, flexion: 50.0, extension: 80.0, pain: 3),
                (days: -4, flexion: 18.0, extension: 135.0, pain: 5),
                (days: -3, flexion: 55.0, extension: 160.0, pain: 6),
                (days: -2, flexion: 32.0, extension: 145.0, pain: 5),
                (days: -1, flexion: 10.0, extension: 170.0, pain: 4),
            ]
            
            let calendar = Calendar.current
            for data in sampleData {
                let date = calendar.date(byAdding: .day, value: data.days, to: Date())!
                let record = MeasuredRecord(
                    extensionAngle: data.extension,
                    flexionAngle: data.flexion,
                    measuredSeconds: 30,
                    painLevel: data.pain
                )
                record.measuredDate = date  // 샘플 데이터용 날짜 설정
                context.insert(record)
            }
            
            try? context.save()
        }
    }

    var body: some Scene {
        WindowGroup {
            MeasureFlowView()
                .environmentObject(measureVM)
        }
        .modelContainer(modelContainer)
    }
}
