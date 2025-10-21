//
//  BodyModelView.swift
//  gacha
//
//  Created by Oh Seojin on 10/20/25.
//

import Vision

// MARK: - 데이터 모델
/// 감지된 신체 정보를 저장하는 구조체
struct DetectedBody: @unchecked Sendable {
    let points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]
}

/// 신체 각도 정보를 저장하는 구조체
struct BodyAngles: Sendable {
    let rightKnee: Double?
    let leftKnee: Double?
}
