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

    var questionText: String {
        if hasComparison {
            return "산책해 보시는건 어떤가요?"
        } else {
            return "첫 측정을 완료했어요!"
        }
    }

    var feedbackMessage: String {  // 추후 디벨롭 필요
        guard let result = changeResult else {
            return "오늘의 측정 결과가 기록되었습니다."
        }

        // ROM 변화 기준으로 메시지 생성
        let flexState = result.flexRomDiffState
        let extenState = result.extenRomDiffState
        let painState = result.painDiffState

        // 통증이 심각하게 증가한 경우
        if case .visitRecommended = painState {
            return "통증이 많이 증가했어요. 😰\n병원 방문을 권장드립니다."
        }

        // ROM 호전 + 통증 감소
        if case .better = extenState, case .better = flexState,
            case .better = painState
        {
            return "모든 지표가 좋아졌어요! 😊\n이대로 꾸준히 운동하세요."
        }

        // ROM 호전
        if case .better = extenState {
            return "지난번보다 가동범위가 늘어났어요! 👍\n꾸준한 운동이 효과를 보이고 있습니다."
        }

        // ROM 악화
        if case .warning = extenState {
            return
                "지난번보다 수치가 살짝 줄었지만,\n여전히 형상 범위예요. 😊\n몸의 컨디션에 따라 조금씩 달라질 수 있어요."
        }

        // 통증 증가
        if case .warning = painState {
            return "통증이 조금 증가했어요. 😣\n무리하지 마시고 천천히 진행하세요."
        }

        // 기본 메시지
        return "오늘도 측정을 완료했어요. 😊\n꾸준한 기록이 회복에 도움이 됩니다."
    }

    var guidanceText: String {
        if hasComparison {
            return "몸의 컨디션에 따라 조금씩 달라질 수 있어요."
        } else {
            return "다음 측정부터 비교 결과를 확인할 수 있어요."
        }
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

//    func formatChange(_ change: Int) -> String {
//        let absChange = abs(change)
//        if absChange < 1 {
//            return String(format: "%.1f", absChange)
//        } else {
//            return "\(Int(absChange))"
//        }
//    }

    func changeColor(for change: Int, isPositiveGood: Bool) -> Color {
        if abs(change) < 1 {
            return .secondary
        }

        let isGoodChange = isPositiveGood ? change > 0 : change < 0
        return isGoodChange ? .blue : .red
    }
}
