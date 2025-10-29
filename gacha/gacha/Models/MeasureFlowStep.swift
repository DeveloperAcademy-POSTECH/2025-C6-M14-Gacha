//
//  MeasureSession.swift
//  gacha
//
//  Created by 차원준 on 10/28/25.


import Foundation

/// 측정 플로우의 각 단계
enum MeasureFlowStep: Hashable {
    case home                // DailyMeasureStartView (홈 화면)
    case extensionMeasure      // ExtensionMeasureView
    case measureChecked    // MeasureCheckedView (측정 완료)
    case flexionMeasure        // FlexionMeasureView
    case painLevel           // PainLevelView
    case result              // ProgressDetailView
    case summary             // DailyMeasureSummaryView (측정 완료)
}
