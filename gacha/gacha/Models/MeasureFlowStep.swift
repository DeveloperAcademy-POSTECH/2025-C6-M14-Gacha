//
//  MeasureSession.swift
//  gacha
//
//  Created by 차원준 on 10/28/25.

import Foundation

/// 측정 플로우의 각 단계
enum MeasureFlowStep: Hashable {
    case home  // DailyMeasureStartView (홈 화면)
    case extensionMeasure  // ExtensionMeasureView
    case extensionCheck  // MeasureCheckedView
    case flexionMeasure  // FlexionMeasureView
    case flexionCheck  // DailyMeasureDoneView (측정 완료)
    case painLevel  // PainLevelView
    case result  // ProgressDetailView
    case summary  // DailyMeasureSummaryView (측정 완료)
}
