//
//  MockDataGenerator.swift
//  gacha
//
//  Created by Oh Seojin on 10/22/25.
//

import Foundation
import SwiftData

struct MockDataGenerator {

    /// 10/10일부터 오늘까지 매일 목업 데이터 생성
    static func generateMockData(context: ModelContext) {
        // 이미 데이터가 있는지 확인
        let descriptor = FetchDescriptor<MeasuredRecord>()
        if let existingRecords = try? context.fetch(descriptor),
           !existingRecords.isEmpty {
            print("✅ 이미 데이터가 존재합니다. 목업 데이터 생성 건너뜀")
            return
        }

        print("📊 목업 데이터 생성 시작...")

        // 시작 날짜: 2025년 10월 10일
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current

        let startDate = calendar.date(from: DateComponents(year: 2025, month: 10, day: 10))!
        let endDate = Date()  // 오늘

        // 10월 10일부터 오늘까지 날짜 계산
        let days = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0

        // 초기 각도 설정
        var currentFlexion = 90.0  // 굴곡 시작 각도
        var currentExtension = 160.0  // 신전 시작 각도

        // 매일 데이터 생성 (하루에 1개)
        for dayOffset in 0...days {
            guard let recordDate = calendar.date(byAdding: .day, value: dayOffset, to: startDate) else {
                continue
            }

            // 시간 설정 (오후 2-5시 사이 랜덤)
            let hour = Int.random(in: 14...17)
            let minute = Int.random(in: 0...59)

            guard let finalDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: recordDate) else {
                continue
            }

            // 각도 변화: 2-7도 우상향 (가동 범위 증가)
            let rangeIncrease = Double.random(in: 2...7)

            // 굴곡 감소 (더 구부러짐) - 범위 증가에 기여
            currentFlexion -= rangeIncrease
            currentFlexion = max(30, currentFlexion)

            // 신전 증가 (더 펴짐) - 범위 증가에 기여
            currentExtension += rangeIncrease
            currentExtension = min(180, currentExtension)

            // 기록 생성
            let record = MeasuredRecord(
                flexionAngle: Int(currentFlexion),
                extensionAngle: Int(currentExtension),
                isDeleted: false,
                flexionImage_id: "/mock",  // 목업 이미지 경로
                extensionImage_id: "/mock"
            )

            // 날짜 수동 설정
            record.date = finalDate

            context.insert(record)
        }

        // 저장
        do {
            try context.save()
            let descriptor = FetchDescriptor<MeasuredRecord>()
            let allRecords = try context.fetch(descriptor)
            print("✅ 목업 데이터 생성 완료: 총 \(allRecords.count)개 레코드")

            // 처음 5개와 마지막 5개 출력
            print("\n📋 처음 5개 레코드:")
            for (index, record) in allRecords.prefix(5).enumerated() {
                print("  [\(index + 1)] \(record.date.formatted(date: .abbreviated, time: .shortened)) - Flexion: \(record.flexionAngle)°, Extension: \(record.extensionAngle)°, Range: \(record.extensionAngle - record.flexionAngle)°")
            }

            print("\n📋 마지막 5개 레코드:")
            for (index, record) in allRecords.suffix(5).enumerated() {
                let actualIndex = allRecords.count - 5 + index
                print("  [\(actualIndex + 1)] \(record.date.formatted(date: .abbreviated, time: .shortened)) - Flexion: \(record.flexionAngle)°, Extension: \(record.extensionAngle)°, Range: \(record.extensionAngle - record.flexionAngle)°")
            }
        } catch {
            print("❌ 목업 데이터 저장 실패: \(error)")
        }
    }

    /// 목업 데이터 삭제 (필요 시 사용)
    static func clearMockData(context: ModelContext) {
        let descriptor = FetchDescriptor<MeasuredRecord>()

        do {
            let allRecords = try context.fetch(descriptor)

            for record in allRecords {
                context.delete(record)
            }

            try context.save()
            print("✅ 모든 목업 데이터 삭제 완료")
        } catch {
            print("❌ 목업 데이터 삭제 실패: \(error)")
        }
    }
}
