//
//  KneeSelection.swift
//  gacha
//
//  Created by Oh Seojin on 10/21/25.
//

import Foundation
import Vision

// 무릎 선택 enum 추가 (class 내부)
enum KneeSelection: String, CaseIterable {
    case left = "왼쪽 무릎"
    case right = "오른쪽 무릎"
    case both = "양쪽 무릎"

    func jointGroupForSelectedKnee()
        -> VNHumanBodyPoseObservation.JointsGroupName
    {
        switch self {
        case .left:
            return .leftLeg
        case .right:
            return .rightLeg
        case .both:
            return .all  // 양쪽의 경우 전체

        }
    }
}
