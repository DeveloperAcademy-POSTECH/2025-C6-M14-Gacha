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
    var currentAngle: Double { get }
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

    // 상태
    @Published var isMeasuring = false  // 센서 작동 중
    @Published var isRecording = false  // 데이터 수집 중

    // 데이터
    @Published var currentAngle: Double = 0
    @Published var currentMeasurements: [Double] = []

    enum KneeMotionType: String {
        case flexionRom = "굴곡"
        case extensionRom = "신전"
    }
    @Published var kneeMotion: KneeMotionType = .extensionRom
    @Published var measuredROM: Double = 0.0  // 측정된 ROM 값

    // 녹화 관련
    private var recordingTimer: Timer?
    private var recordingStartTime: Date?
    private var recordingEndTime: Date?
    @Published var recordingProgress: Double = 0.0
    private let recordingDurationThreshold: TimeInterval = 3.0  // 3.0

    // 상대 각도용
    @Published var baselinePitch: Double = 0.0
    @Published var baselineRoll: Double = 0.0

    init() {
        checkMotionAvailability()
    }

    private func checkMotionAvailability() {
        isMotionAvailable = motionManager.isDeviceMotionAvailable
    }

    // 1. 앱 시작 - 센서만 켜두기
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

            // 기록 중이면 배열에 추가
            if self.isRecording {
                self.currentMeasurements.append(self.currentAngle)
            }
        }

        isMeasuring = true
        print("🏁 센서 시작")
    }

    // 2-1. 터치 시작 - 기록 시작
    func startRecording() {
        guard isMeasuring else {
            print("⚠️ 센서를 먼저 시작하세요")
            return
        }

        currentMeasurements.removeAll()
        isRecording = true
        recordingStartTime = Date()
        recordingProgress = 0.0

        // 진행률 업데이트 타이머
        recordingTimer = Timer.scheduledTimer(
            withTimeInterval: 0.1,
            repeats: true
        ) { [weak self] _ in
            guard let self = self,
                let startTime = self.recordingStartTime
            else { return }

            let elapsed = Date().timeIntervalSince(startTime)
            self.recordingProgress = min(
                1.0,
                elapsed / self.recordingDurationThreshold
            )

            // 3초 도달 시 자동 완료
            if elapsed >= self.recordingDurationThreshold {
                self.finishRecording()
            }
        }
        print("🎬 녹화 시작")
    }

    // 2-2. 터치 종료 - 즉시 종료
    func stopRecording() {
        guard isRecording else { return }
        cancelRecording()
    }

    // 3-2. 녹화 취소
    func cancelRecording(reason: String = "취소됨") {
        recordingTimer?.invalidate()
        recordingTimer = nil
        isRecording = false
        recordingStartTime = nil
        recordingProgress = 0.0
        currentMeasurements.removeAll()

        print("❌ 녹화 취소: \(reason)")
    }

    // 4. 녹화 완료
    private func finishRecording() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        isRecording = false
        recordingProgress = 1.0

        let count = currentMeasurements.count
        let duration = Date().timeIntervalSince(recordingStartTime ?? Date())

        print("✅ 녹화 완료: \(count)개 데이터 (\(String(format: "%.1f", duration))초)")

        // 분석 - 최빈값으로 ROM 계산
        if let angle = mode(of: currentMeasurements) {
            measuredROM = calculateKneeAngle(angle: angle)  // 무릎 각도 변환
            print("📊 \(kneeMotion.rawValue) ROM: \(String(format: "%.1f", measuredROM))°")
        }

        //MARK: ⚠️ 데이터에 저장하는 flow 필요
        recordingStartTime = nil
    }

    // 5. 앱 종료 시
    func stopMeasuring() {
        if isRecording {
            cancelRecording(reason: "측정 중지")
        }

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

    // ROM 계산 함수 : 180 - 무릎각도, 무릎각도 = 180 - (측정값 * 2) (이등변 삼각형으로 가정)
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

        return angleDiff
    }

    func mode<T: Hashable>(of array: [T]) -> T? {
        guard !array.isEmpty else { return nil }

        // 빈도수 계산
        var counts: [T: Int] = [:]
        for element in array {
            counts[element, default: 0] += 1
        }

        // 최대 빈도수 찾기
        return counts.max(by: { $0.value < $1.value })?.key
    }
}
