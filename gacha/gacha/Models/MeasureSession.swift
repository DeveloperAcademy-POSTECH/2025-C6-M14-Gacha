//
//  MeasureSession.swift
//  gacha
//
//  Created by 차원준 on 10/28/25.


import Foundation

/// 측정 플로우의 각 단계
enum MeasureFlowStep: Hashable {
    case home                // DailyMeasureStartView (홈 화면)
    case extensionGuide      // ExtensionMeasureView
    case extensionMeasuring  // ContentView (신전 모드)
    case flexionGuide        // FlexionMeasureView
    case flexionMeasuring    // ContentView (굴곡 모드)
    case painLevel           // PainLevelView
    case result              // ProgressDetailView
    case summary             // DailyMeasureSummaryView (측정 완료)
}

/// 측정 세션 관리 클래스
@Observable
class MeasureSession {
    // MARK: - Measurement Data
    
    /// 측정 시작 시간
    var startTime: Date = Date()
    
    /// 측정값
    var extensionAngle: Double = 0.0
    var flexionAngle: Double = 0.0
    var painLevel: Double = 0.0
    
    /// 계산된 ROM (읽기 전용)
    var ROM: Double {
        extensionAngle - flexionAngle
    }
    
    // MARK: - Data Management
    
    /// 측정 데이터 초기화
    func resetData() {
        extensionAngle = 0.0
        flexionAngle = 0.0
        painLevel = 0.0
        startTime = Date()
    }
}
