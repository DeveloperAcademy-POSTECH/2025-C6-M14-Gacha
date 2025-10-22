//
//  KneeSelection.swift
//  gacha
//
//  Created by Oh Seojin on 10/21/25.
//

import Foundation
import Vision

// Knee selection enum
enum KneeSelection: String, CaseIterable {
    case left = "Left Knee"
    case right = "Right Knee"
    case both = "Both Knees"

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
