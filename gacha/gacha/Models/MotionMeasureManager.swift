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

final class MotionMeasureManager: MeasureManager, ObservableObject {
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
    @Published var currentAngle: Double = 0
    var recordedAngles: [Double] = []



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
    }


    private func updateAngle(from motion: CMDeviceMotion) {
        let angle = calculateGravityAngle(gravity: motion.gravity)

        // 메인 스레드에서 @Published 속성 업데이트
        DispatchQueue.main.async { [weak self] in
            self?.currentAngle = angle
        }

        // 디버깅: 실시간 각도 출력
        if isRecording {
            print("📐 [Recording] Current Angle: \(String(format: "%.2f", angle))°")
        }
    }

    func calculateGravityAngle(gravity: CMAcceleration) -> Double {
        var angle: Double = 0.0

        switch selectedOrientation {
        case .portrait:
            // 휴대폰의 넓은 면(후면)을 허벅지 위에 올림
            // gravity.y: 휴대폰의 세로 방향 (상단→하단)
            // gravity.z: 휴대폰의 후면에 수직 방향 (화면→후면)

            // 허벅지 위에 평평하게 놓았을 때: z ≈ -1 (중력이 화면을 향함)
            // 무릎을 구부리면: y 값이 증가

            // atan2를 사용하여 절대 각도 계산 (baseline 불필요)
            // y축과 z축의 비율로 기울기 각도 계산
            angle = atan2(gravity.y, -gravity.z) * 180 / .pi

            // 디버깅: gravity 값과 계산된 각도 출력
            if isRecording {
                print("🌍 Gravity - x: \(String(format: "%.3f", gravity.x)), y: \(String(format: "%.3f", gravity.y)), z: \(String(format: "%.3f", gravity.z))")
                print("📊 Calculated Angle (raw): \(String(format: "%.2f", angle))°")
            }

            // 부호 반전: 음수였던 값은 양수로, 양수였던 값은 음수로
            angle = -angle

            // 0도 기준을 평평한 상태로 설정하고, 무릎을 구부릴수록 양수
            // 평평한 상태(z=-1, y=0)에서 각도는 0도
            // 수직(z=0, y=-1)에서 각도는 90도

            // 음수 각도는 0으로 (역방향 제한)
            if angle < 0 {
                angle = 0
            }

            // 최대 180도로 제한
            if angle > 180 {
                angle = 180
            }

            // 디버깅: 클램핑 후 최종 각도
            if isRecording {
                print("✅ Final Angle (after clamping): \(String(format: "%.2f", angle))°")
            }

        case .landscape:
            // landscape 모드
            angle = atan2(gravity.x, -gravity.z) * 180 / .pi

            if angle < 0 {
                angle = 0
            }
            if angle > 180 {
                angle = 180
            }
        }

        return angle
    }
}
