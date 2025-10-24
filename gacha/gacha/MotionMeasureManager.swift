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

protocol MeasureManager {
    var extensionAngle: Double { get }
    var flexionAngle: Double { get }

    func startMeasuring()
    func stopMeasuring()
}

class MotionMeasureManager: ObservableObject, MeasureManager {
    private let motionManager = CMMotionManager()
    private let cancellables = Set<AnyCancellable>()

    enum DeviceOrientation: String {
        case portrait = "세로"
        case landscape = "가로"
    }

    @Published var selectedOrientation: DeviceOrientation = .portrait
    @Published var isMotionAvailable = false
    @Published var isMeasuring = false

    @Published var currentMeasurements: [Double] = []
    @Published var extensionAngle: Double = 180  // 0-180
    @Published var flexionAngle: Double = 0  // 180-0
    
    // 타이머
    private var measurementTimer: Timer?
    private var touchEndTime: Date?

    // 상대 각도용
    @Published var baselinePitch: Double = 0.0
    @Published var baselineRoll: Double = 0.0

    init() {
        checkMotionAvailability()
    }

    private func checkMotionAvailability() {
        isMotionAvailable = motionManager.isDeviceMotionAvailable
    }

    func startMeasuring() {
        guard isMotionAvailable else {
            print("❌ Motion 센서를 사용할 수 없습니다")
            return
        }

        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0

        motionManager.startDeviceMotionUpdates(to: .main) {
            [weak self] motion, error in
            guard let self = self, let motion = motion else { return }

            self.updateAngle(from: motion)
        }
        isMeasuring = true
        print("🏁 측정 시작")
    }

    func stopMeasuring() {
        isMeasuring = false
        motionManager.stopDeviceMotionUpdates()
    }

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
        extensionAngle = min(extensionAngle, calculateKneeAngle(angle: angle))
        flexionAngle = max(flexionAngle, calculateKneeAngle(angle: angle))
    }
    
    private func calculateKneeAngle(angle: Double) -> Double {
        return angle * 2
    }

    func calculateAttitudeAngle(attitude: CMAttitude) -> Double {
        var angleDiff: Double = 0.0

        switch selectedOrientation {
        case .portrait:
            angleDiff = (attitude.pitch - baselinePitch) * 180 / .pi
        case .landscape:
            angleDiff = (attitude.roll - baselineRoll) * 180 / .pi
        }

        let angle = angleDiff

        // 0 ~ 180도로 제한
//        return max(0, min(180, angle))
        return angle
    }

}
