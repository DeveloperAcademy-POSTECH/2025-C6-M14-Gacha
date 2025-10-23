//
//  PatientStates.swift
//  gacha
//
//  Created by 차원준 on 10/23/25.
//

/**
 - `enum` RomThreshold
     - alert = 5.0
 - `enum` RomChangeState
     - Normal
     - Warning : alert도 이상 하락
     - Better : alert도 이상 상승
     - calculate(latestAngle, previousAngle) → RomChangeState
 - `enum` PainThreshold
     - safe = 1.3
     - alert = 2.0
 - `enum` PainChangeState
     - Normal : safe도 이하
     - Warning : safe도 이상 상승
     - Better: safe도 이상 하락
     - VisitRecommended: alert각도 이상 상승
     - calculate(latestPainLevel, previousPainLevel) → PainChangeState
 **/

// MARK: - ROM, 통증 임계값 (Threshold)

public enum RomThreshold: Double {
    case alert = 5.0
}


public enum PainThreshold: Double {
    case safe = 1.3
    case alert = 2.0
}

// MARK: - ROM, 통증 상태 (State)


// ROM 상태
public enum RomChangeState: Equatable {
    case normal(delta: Double)    // 변화가 경미함
    // delta를 파라미터로 설정하여 상태와 수치(변화량)도 함께 담는 연관값
    case warning(delta: Double) // alert 이상 "하락"(나빠짐)
    case better(delta: Double)  // alert 이상 "상승"(호전)

    public static func calculate(
        latestAngle: Double,
        previousAngle: Double,
        threshold: RomThreshold = .alert
    ) -> RomChangeState {
        /// latestAngle - previousAngle의 부호 기준: +값: "상승(호전)",  -값: "하락(악화)"
        let delta = latestAngle - previousAngle
        let limit = threshold.rawValue

        if delta >= limit {
            return .better(delta: delta)
        } else if delta <= -limit {
            return .warning(delta: delta)
        } else {
            return .normal(delta: delta)
        }
    }
}

// 통증 상태
public enum PainChangeState: Equatable {
    case normal(delta: Double)  // 통증 보통
    case warning(delta: Double) // 통증이 심함
    case better(delta: Double)  // 통증 감소
    case visitRecommended(delta: Double) // 내원 필요
    
    public static func calculate(
        lastPainLevel: Double,
        previousPainLevel: Double,
        alertThreshold: PainThreshold = .alert,
        safeThreshold: PainThreshold = .safe
    ) -> PainChangeState {
        /// lastPainLevel - previousPainLevel의 부호 기준: +값: "하락(악화)",  -값: "상승(호전)"

        let delta = lastPainLevel - previousPainLevel
        let alertValue = alertThreshold.rawValue
        let safeValue = safeThreshold.rawValue
        
        if delta >= alertValue { // alert 수치 이상 증가했을 때
            return .visitRecommended(delta: delta)
        }
        else {                   // alert 수치 이상보다 작을 때
            if delta >= safeValue {
                return .warning(delta: delta)
            } else if delta <= -safeValue {
                return .better(delta: delta)
            } else {
                return .normal(delta: delta)
            }
        }
    }
}

