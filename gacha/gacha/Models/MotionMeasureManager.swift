//
//  MeasureManager.swift
//  gacha
//
//  Created by Oh Seojin on 10/23/25.
//

import Combine
import CoreMotion
import Foundation
import UIKit

enum KneeMotionType: String {
    case flexionRom = "굴곡"
}

// MARK: - MeasureManager Protocol
protocol MeasureManager {
    var currentAngle: Double { get }
    var recordedAngles: [Double] { get set }
    
    func startMeasuring()
    func stopMeasuring()
    
    func startRecording()
    func cancelRecording()
    func stopRecording()
}

final class MotionMeasureManager: MeasureManager {
    private let motionManager = CMMotionManager()

    enum DeviceOrientation: String {
        case portrait = "세로"
        case landscape = "가로"
    }
    var selectedOrientation: DeviceOrientation = .portrait
    var isMotionAvailable = false

    // 상태
    var isMeasuring = false // 센서 작동 중
    var isRecording = false

    // 데이터
    var currentAngle: Double = 0
    var recordedAngles: [Double] = []


    // 상대 각도용
    var baselinePitch: Double = 0.0
    var baselineRoll: Double = 0.0

    init() {
        checkMotionAvailability()
    }

    private func checkMotionAvailability() {
        isMotionAvailable = motionManager.isDeviceMotionAvailable
    }

    // 1. 앱 시작
    func startMeasuring() {
        guard isMotionAvailable else {
            print("❌ Motion 센서를 사용할 수 없습니다")
            print("⚠️ 실제 기기에서 테스트하세요 (시뮬레이터는 모션 센서 없음)")
            return
        }

        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0

        motionManager.startDeviceMotionUpdates(to: .main) {
            [weak self] motion, error in

            // 에러 체크
            if let error = error {
                print("❌ Motion 업데이트 에러: \(error.localizedDescription)")
                return
            }

            guard let self = self, let motion = motion else { return }

            self.updateAngle(from: motion)
            
            if self.isRecording {
                self.recordedAngles.append(self.currentAngle)
            }
        }
        isMeasuring = true
        print("🏁 센서 시작")
    }
    
    func startRecording() {
        isRecording = true
        recordedAngles.removeAll()
    }
    
    func cancelRecording() {
        isRecording = false
        recordedAngles.removeAll()
    }
    
    func stopRecording() {
        isRecording = false
    }

    // 앱 종료 시
    func stopMeasuring() {
        isMeasuring = false
        motionManager.stopDeviceMotionUpdates()
        print("센서 중지")
    }

    // (사용X) 영점 조절 함수
    func setBaseline(from motion: CMDeviceMotion? = nil) {
        let motionData = motion ?? motionManager.deviceMotion

        guard let motionData = motionData else {
            print("❌ Motion 데이터 없음")
            return
        }

        baselinePitch = motionData.attitude.pitch
        baselineRoll = motionData.attitude.roll
        print(
            "📍 Baseline 설정 - Pitch: \(String(format: "%.2f", baselinePitch)), Roll: \(String(format: "%.2f", baselineRoll)) radians"
        )
    }

    private func updateAngle(from motion: CMDeviceMotion) {
        let attitude = motion.attitude
        var angle: Double = 0.0

        angle = calculateAttitudeAngle(attitude: attitude)
        currentAngle = angle
    }

    func calculateAttitudeAngle(attitude: CMAttitude) -> Double {
        var angleDiff: Double = 0.0
        switch selectedOrientation {
        case .portrait:
            // 홈버튼/음량버튼이 있는 긴 측면을 종아리에 부착
            // pitch 축 사용: 무릎을 구부릴 때의 각도 변화 측정
            // 부호를 반전시켜 무릎을 구부릴수록 양수 값이 나오도록 조정
            angleDiff = -(attitude.pitch - baselinePitch) * 180 / .pi
        case .landscape:
            angleDiff = (attitude.pitch - baselinePitch) * 180 / .pi
        }

        return angleDiff
    }
}
