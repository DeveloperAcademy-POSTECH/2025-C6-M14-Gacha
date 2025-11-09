//
//  MeasureSession.swift
//  gacha
//
//  Created by 차원준 on 10/28/25.

import Foundation

/// 측정 플로우의 각 단계
enum MeasureFlowStep: Hashable {
    case home  // DailyMeasureStartView (홈 화면)
    case flexionMeasure  // FlexionMeasure
    case flexionCheck  // MeasureFlag (측정 완료)
    case painLevel  // PainLevel
    case summary  // MainViewAfter (측정 완료)
}

/// 네비게이션 소스 - 각 화면으로 진입한 경로를 추적
enum NavigationSource: Hashable {
    case home              // 홈 화면에서 직접 진입
    case flexionMeasure    // 굴곡 측정 화면에서 진입
    case flexionCheck      // 측정 확인 화면에서 진입
    case painLevel         // 통증 레벨 화면에서 진입
    case summary           // 결과 화면에서 진입
    case calendar          // 캘린더에서 진입
    case history           // 히스토리에서 진입
    
    /// 현재 단계로부터 소스를 추론하는 헬퍼
    static func from(step: MeasureFlowStep) -> NavigationSource {
        switch step {
        case .home: return .home
        case .flexionMeasure: return .flexionMeasure
        case .flexionCheck: return .flexionCheck
        case .painLevel: return .painLevel
        case .summary: return .summary
        }
    }
}
