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

    // MARK: - Pain Level Category Helper
    /// 통증 수준을 카테고리로 분류
    /// - Parameter painLevel: 통증 수준 (0-10)
    /// - Returns: "nopain", "mildpain", "moderatepain", "severepain", "excruciatingpain"
    private func painCategory(for painLevel: Int) -> String {
        switch painLevel {
        case 0:
            return "nopain"
        case 1...3:
            return "mildpain"
        case 4...6:
            return "moderatepain"
        case 7...9:
            return "severepain"
        case 10:
            return "excruciatingpain"
        default:
            return "nopain"
        }
    }

    // MARK: - Message Generation

    var cardTitle: String {
        // 첫 측정인 경우
        if !hasComparison {
            return Strings.Progress.firstRecordTitle
        }

        guard let result = changeResult,
              let currentPainLevel = currentRecord?.painLevel else {
            return Strings.Progress.firstRecordTitle
        }

        // ROM 변화 상태 판별
        let flexState = result.flexRomDiffState
        let painCat = painCategory(for: currentPainLevel)

        // ROM 변화에 따른 분기
        let isFlexBetter = if case .better = flexState { true } else { false }
        let isFlexWarning = if case .warning = flexState { true } else { false }
        let isFlexNormal = if case .normal = flexState { true } else { false }

        // 가동범위 증가 (better)
        if isFlexBetter {
            switch painCat {
            case "nopain":
                return Strings.Progress.betterNoPainTitle
            case "mildpain":
                return Strings.Progress.betterMildPainTitle
            case "moderatepain":
                return Strings.Progress.betterModeratePainTitle
            case "severepain":
                return Strings.Progress.betterSeverePainTitle
            case "excruciatingpain":
                return Strings.Progress.betterExcruciatingPainTitle
            default:
                return Strings.Progress.betterNoPainTitle
            }
        }

        // 가동범위 동일 (normal, 0~-10도)
        if isFlexNormal {
            switch painCat {
            case "nopain":
                return Strings.Progress.sameNoPainTitle
            case "mildpain":
                return Strings.Progress.sameMildPainTitle
            case "moderatepain":
                return Strings.Progress.sameModeratePainTitle
            case "severepain":
                return Strings.Progress.sameSeverePainTitle
            case "excruciatingpain":
                return Strings.Progress.sameExcruciatingPainTitle
            default:
                return Strings.Progress.sameNoPainTitle
            }
        }

        // 가동범위 악화 (warning)
        if isFlexWarning {
            switch painCat {
            case "nopain":
                return Strings.Progress.worseNoPainTitle
            case "mildpain":
                return Strings.Progress.worseMildPainTitle
            case "moderatepain":
                return Strings.Progress.worseModeratePainTitle
            case "severepain":
                return Strings.Progress.worseSeverePainTitle
            case "excruciatingpain":
                return Strings.Progress.worseExcruciatingPainTitle
            default:
                return Strings.Progress.worseNoPainTitle
            }
        }

        // 기본값
        return Strings.Progress.firstRecordTitle
    }

    var feedbackMessage: String {
        // 첫 측정인 경우
        if !hasComparison {
            return Strings.Progress.firstRecordDescription
        }

        guard let result = changeResult,
              let currentPainLevel = currentRecord?.painLevel else {
            return Strings.Progress.firstRecordDescription
        }

        // ROM 변화 상태 판별
        let flexState = result.flexRomDiffState
        let painCat = painCategory(for: currentPainLevel)

        // ROM 변화에 따른 분기
        let isFlexBetter = if case .better = flexState { true } else { false }
        let isFlexWarning = if case .warning = flexState { true } else { false }
        let isFlexNormal = if case .normal = flexState { true } else { false }

        // 가동범위 증가 (better)
        if isFlexBetter {
            switch painCat {
            case "nopain":
                return Strings.Progress.betterNoPainDescription
            case "mildpain":
                return Strings.Progress.betterMildPainDescription
            case "moderatepain":
                return Strings.Progress.betterModeratePainDescription
            case "severepain":
                return Strings.Progress.betterSeverePainDescription
            case "excruciatingpain":
                return Strings.Progress.betterExcruciatingPainDescription
            default:
                return Strings.Progress.betterNoPainDescription
            }
        }

        // 가동범위 동일 (normal, 0~-10도)
        if isFlexNormal {
            switch painCat {
            case "nopain":
                return Strings.Progress.sameNoPainDescription
            case "mildpain":
                return Strings.Progress.sameMildPainDescription
            case "moderatepain":
                return Strings.Progress.sameModeratePainDescription
            case "severepain":
                return Strings.Progress.sameSeverePainDescription
            case "excruciatingpain":
                return Strings.Progress.sameExcruciatingPainDescription
            default:
                return Strings.Progress.sameNoPainDescription
            }
        }

        // 가동범위 악화 (warning)
        if isFlexWarning {
            switch painCat {
            case "nopain":
                return Strings.Progress.worseNoPainDescription
            case "mildpain":
                return Strings.Progress.worseMildPainDescription
            case "moderatepain":
                return Strings.Progress.worseModeratePainDescription
            case "severepain":
                return Strings.Progress.worseSeverePainDescription
            case "excruciatingpain":
                return Strings.Progress.worseExcruciatingPainDescription
            default:
                return Strings.Progress.worseNoPainDescription
            }
        }

        // 기본값
        return Strings.Progress.firstRecordDescription
    }

    //     MARK: - Formatting
    func formatAngle(_ angle: Double?) -> String {
        guard let angle = angle else { return "-" }
        return "\(Int(angle))°"
    }

    func formatPainLevel(_ level: Int?) -> String {
        guard let level = level else { return "-" }
        return "\(level)"
    }

    /// 어제 대비 각도 변화량 포맷팅 (예: "+5°", "-3°", "동일")
    var angleTrendText: String? {
        guard let result = changeResult else { return nil }

        let delta = result.flexRomDiff

        if delta > 0 {
            return "↑\(Int(delta))°"
        } else {
            return nil
        }
    }

    /// 통증 카테고리 텍스트 (예: "통증 없음", "약간의 통증")
    var painCategoryText: String {
        guard let painLevel = currentRecord?.painLevel else {
            return ""
        }
        return Strings.PainCategory.category(for: painLevel)
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
            return "noRecord"  // 기록이 없을 때
        }

        switch angle {
        case ...60:
            return "result45"
        case 60..<75:
            return "result60"
        case 75..<90:
            return "result75"
        case 90..<105:
            return "result90"
        case 105..<120:
            return "result105"
        case 120..<135:
            return "result120"
        default:  // 135 이상
            return "result135"
        }
    }
}
