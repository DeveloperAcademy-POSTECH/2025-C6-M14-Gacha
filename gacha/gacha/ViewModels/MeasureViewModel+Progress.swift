//
//  ProgressViewModel.swift
//  gacha
//
//  Created by Oh Seojin on 10/29/25.
//

import Foundation
import SwiftData
import SwiftUI

// ProgressDetailView에서 필요한 로직 정리
extension MeasureViewModel {
    var hasComparison: Bool {
        previousRecord != nil && changeResult != nil
    }

    // 가장 최근 기록(어제) 불러오기
    func loadPreviousRecord() async {
        previousRecord = await self.loadLatestRecord()
        print("이전기록: \(previousRecord?.measuredDate.description ?? "없음")")
    }

    // 오늘 기록을 currentRecord로 불러오기
    func loadTodayRecord() async {
        currentRecord = await self.loadLatestRecord()
        print("이전기록: \(previousRecord?.measuredDate.description ?? "없음")")
    }

    func calculateRecordChange() {
        print("🥹", currentRecord?.measuredDate.description ?? "없음")
        print("🥹", previousRecord?.measuredDate.description ?? "없음")
        guard let current = currentRecord,
            let previous = previousRecord
        else {
            print("⚠️ 비교하기 위해 필요한 레코드가 부족합니다.")
            changeResult = nil
            return
        }
        changeResult = analyzeRecordChange(latest: current, previous: previous)
    }

    // MARK: - 가공된 데이터
    var romValue: Int {
        guard let record = currentRecord,
            let rom = record.ROM
        else { return 0 }
        return Int(rom)
    }

    // MARK: - Message Generation

    var cardTitle: String {
        // 첫 측정인 경우
        if !hasComparison {
            return Strings.Progress.FirstTake.title
        }

        guard let result = changeResult else {
            return Strings.Progress.FirstTake.title
        }

        // ROM 변화 기준으로 메시지 생성 (Flexion 중심)
        let flexState = result.flexRomDiffState
        let painState = result.painDiffState

        // 상태 확인을 위한 boolean 변수들
        let isFlexBetter = if case .better = flexState { true } else { false }
        let isFlexWarning = if case .warning = flexState { true } else { false }
        let isFlexNormal = if case .normal = flexState { true } else { false }

        let isPainBetter = if case .better = painState { true } else { false }
        let isPainWarning = if case .warning = painState { true } else { false }
        let isPainNormal = if case .normal = painState { true } else { false }
        let isPainVisitRecommended = if case .visitRecommended = painState { true } else { false }

        // 1. 통증이 심각하게 증가 (병원 방문 권장)
        if isPainVisitRecommended {
            return Strings.Progress.PainWarning.title
        }

        // 2. ROM 호전 + 통증 호전 또는 정상
        if isFlexBetter && (isPainBetter || isPainNormal) {
            return Strings.Progress.Excellent.title
        }

        // 3. ROM 호전되었지만 통증 증가
        if isFlexBetter && isPainWarning {
            return Strings.Progress.PainCaution.title
        }

        // 4. ROM 악화 + 통증 정상/호전
        if isFlexWarning && (isPainNormal || isPainBetter) {
            return Strings.Progress.Caution.title
        }

        // 5. ROM 악화 + 통증 증가
        if isFlexWarning && isPainWarning {
            return Strings.Progress.Warning.title
        }

        // 6. ROM 정상 + 통증 호전
        if isFlexNormal && isPainBetter {
            return Strings.Progress.PainNormal.title
        }

        // 7. ROM 정상 + 통증 정상
        if isFlexNormal && isPainNormal {
            return Strings.Progress.Same.title
        }

        // 8. 기타 (통증 증가 + ROM 정상)
        if isPainWarning {
            return Strings.Progress.PainCaution.title
        }

        // 9. 기본값
        return Strings.Progress.Normal.title
    }
        
    

    var feedbackMessage: String {
        // 첫 측정인 경우
        if !hasComparison {
            return Strings.Progress.FirstTake.description
        }

        guard let result = changeResult else {
            return Strings.Progress.FirstTake.description
        }

        // ROM 변화 기준으로 메시지 생성 (Flexion 중심)
        let flexState = result.flexRomDiffState
        let painState = result.painDiffState

        // 상태 확인을 위한 boolean 변수들
        let isFlexBetter = if case .better = flexState { true } else { false }
        let isFlexWarning = if case .warning = flexState { true } else { false }
        let isFlexNormal = if case .normal = flexState { true } else { false }

        let isPainBetter = if case .better = painState { true } else { false }
        let isPainWarning = if case .warning = painState { true } else { false }
        let isPainNormal = if case .normal = painState { true } else { false }
        let isPainVisitRecommended = if case .visitRecommended = painState { true } else { false }

        // 1. 통증이 심각하게 증가 (병원 방문 권장)
        if isPainVisitRecommended {
            return "\(Strings.Progress.PainWarning.description)\n\(Strings.Progress.PainWarning.emphasis)"
        }

        // 2. ROM 호전 + 통증 호전 또는 정상
        if isFlexBetter && (isPainBetter || isPainNormal) {
            return Strings.Progress.Excellent.description
        }

        // 3. ROM 호전되었지만 통증 증가
        if isFlexBetter && isPainWarning {
            return "\(Strings.Progress.PainCaution.description)\n\(Strings.Progress.PainCaution.emphasis)"
        }

        // 4. ROM 악화 + 통증 정상/호전
        if isFlexWarning && (isPainNormal || isPainBetter) {
            return "\(Strings.Progress.Caution.description)\n\(Strings.Progress.Caution.emphasis)"
        }

        // 5. ROM 악화 + 통증 증가
        if isFlexWarning && isPainWarning {
            return "\(Strings.Progress.Warning.description)\n\(Strings.Progress.Warning.emphasis)"
        }

        // 6. ROM 정상 + 통증 호전
        if isFlexNormal && isPainBetter {
            return Strings.Progress.PainNormal.description
        }

        // 7. ROM 정상 + 통증 정상
        if isFlexNormal && isPainNormal {
            return Strings.Progress.Same.description
        }

        // 8. 기타 (통증 증가 + ROM 정상)
        if isPainWarning {
            return "\(Strings.Progress.PainCaution.description)\n\(Strings.Progress.PainCaution.emphasis)"
        }

        // 9. 기본값
        return Strings.Progress.Normal.description
    }

    //     MARK: - Formatting
    func formatAngle(_ angle: Double?) -> String {
        guard let angle = angle else { return "0°" }
        return "\(Int(angle))°"
    }

    func formatPainLevel(_ level: Int?) -> String {
        guard let level = level else { return "0" }
        return "\(level)"
    }

    func changeColor(for change: Int, isPositiveGood: Bool) -> Color {
        if abs(change) < 1 {
            return .secondary
        }

        let isGoodChange = isPositiveGood ? change > 0 : change < 0
        return isGoodChange ? .blue : .red
    }
    
    // MARK: - Image Selection
    /// 굴곡 각도에 따른 이미지 이름 반환
    var flexionImageName: String {
        guard let angle = currentRecord?.flexionAngle else {
            return "70"  // 기본값
        }
        
        switch angle {
        case ...70:
            return "70"
        case 70..<80:
            return "80"
        case 80..<90:
            return "90"
        case 90..<100:
            return "100"
        case 100..<110:
            return "110"
        case 110..<120:
            return "120"
        default:  // 120 이상
            return "130"
        }
    }
}
