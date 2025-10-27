//
//  MeasureViewModel.swift
//  gacha
//
//  Created by Oh Seojin on 10/26/25.
//

import Combine
import SwiftData
import SwiftUI

final class MeasureViewModel: ObservableObject {
    private var repository: RecordRepository
    private var measureManager: MeasureManager

    @Published var kneeType: KneeMotionType = .extensionRom
    @Published var measuredRom: Double = 0.0

    // 기록 관련
    var isRecording: Bool {
        measureManager.isRecording
    }
    private var recordingTimer: Timer?
    private var recordingStartTime: Date?
    @Published var recordingProgress: Double = 0.0
    private let recordingDurationThreshold: TimeInterval = 3.0  // 3.0

    @Published var currentRecord: MeasuredRecord? = nil
    @Published var allRecords: [MeasuredRecord] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    init(repository: RecordRepository) {
        self.repository = repository
        self.measureManager = MotionMeasureManager()
    }

    func startMeasuring() {
        measureManager.startMeasuring()
    }

    //MARK: - 터치 시작을 감지
    func startRecording() {
        guard measureManager.isMeasuring else {
            print("⚠️ 센서를 시작하세욥")
            return
        }

        // 초기화
        measureManager.currentAngles.removeAll()
        measureManager.isRecording = true
        recordingStartTime = Date.now
        recordingProgress = 0.0

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

            if elapsed >= self.recordingDurationThreshold {
                Task {
                    await self.finishRecording()
                }
            }
        }
        print("🎬 녹화 시작")
    }

    //MARK: - 터치 중단을 감지
    func cancleRecording() {
        guard measureManager.isRecording else { return }

        recordingTimer?.invalidate()
        recordingTimer = nil
        measureManager.isRecording = false
        recordingStartTime = nil
        recordingProgress = 0.0
        measureManager.currentAngles.removeAll()

        print("❌ 녹화 취소")
    }

    //MARK: - 3초 감지 완료
    func motionManagerDidFinishRecording(type: KneeMotionType, angle: Double) {
        Task {
            switch type {
            case .extensionRom:
                await saveExtension()
            case .flexionRom:
                await saveFlexion()
            }
        }
    }

    func finishRecording() async {
        recordingTimer?.invalidate()
        recordingTimer = nil
        measureManager.isRecording = false
        recordingProgress = 1.0

        let count = measureManager.currentAngles.count
        let duration = Date().timeIntervalSince(recordingStartTime ?? Date())

        print("✅ 녹화 완료: \(count)개 데이터 (\(String(format: "%.1f", duration))초)")

        // 분석 - 최빈값으로 ROM 계산
        if let angle = mode(of: measureManager.currentAngles) {
            measuredRom = calculateKneeAngle(angle: angle)  // 무릎 각도 변환
        }

        //MARK: ⚠️ 데이터에 저장하는 flow 필요
        Task {
            switch kneeType {
            case .flexionRom:
                await saveFlexion()
            case .extensionRom:
                await saveExtension()
            }
        }

        recordingStartTime = nil
    }

    func stopMeasuring() {
        measureManager.stopMeasuring()
    }

    func saveExtension() async {
        isLoading = true
        defer { isLoading = false }  // 현재 함수가 끝날 때 자동으로 실행

        do {
            let record = try await repository.createRecord(
                extensionAngle: measuredRom
            )
            currentRecord = record
            print(record)
        } catch {
            errorMessage = "Extension 저장 실패: \(error.localizedDescription)"
            print("❌ \(errorMessage ?? "")")
        }
    }

    // MARK: - Flexion 측정 완료 시
    func saveFlexion() async {
        guard let currentRecord = currentRecord else {
            errorMessage = "현재 레코드가 없습니다. Extension을 먼저 측정하세요."
            print("⚠️ \(errorMessage ?? "")")
            return
        }

        isLoading = true
        defer { isLoading = false }  // 현재 함수가 끝날 때 자동으로 실행

        let measurementMinutes = calculateMeasurementMinutes(
            from: currentRecord.measuredDate
        )
        do {
            let updated = try await repository.updateFlexion(
                recordId: currentRecord.id,
                flexionAngle: measuredRom,
                measuredMinutes: measurementMinutes
            )
            self.currentRecord = updated

            print("✅ Flexion 저장: \(measuredRom)°, \(measurementMinutes)분 소요")
            print("📊 ROM: \(updated.ROM ?? 0)°")
        } catch {
            errorMessage = "Flexion 저장 실패: \(error.localizedDescription)"
            print("❌ \(errorMessage ?? "")")
        }
    }

    // MARK: - PainLevel 측정 완료 시
    func savePainLevel(level: Int) async {
        guard let currentRecord = currentRecord else {
            errorMessage = "현재 레코드가 없습니다."
            print("⚠️ \(errorMessage ?? "")")
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let updated = try await repository.updatePainLevel(
                recordId: currentRecord.id,
                painLevel: level
            )
            self.currentRecord = updated

            print("✅ PainLevel 저장: \(level)")
        } catch {
            errorMessage = "PainLevel 저장 실패: \(error.localizedDescription)"
            print("❌ \(errorMessage ?? "")")
        }
    }

    // MARK: - 전체 레코드 조회
    func loadAllRecords() async {
        isLoading = true
        defer { isLoading = false }

        do {
            allRecords = try await repository.loadRecords()
            print("📚 레코드 로드 완료: \(allRecords.count)개")
        } catch {
            errorMessage = "레코드 로드 실패: \(error.localizedDescription)"
            print("❌ \(errorMessage ?? "")")
        }
    }

    // MARK: - 최근 레코드 조회
    func loadLatestRecord() async {
        isLoading = true
        defer { isLoading = false }

        do {
            currentRecord = try await repository.loadLatestRecord()

            if let record = currentRecord {
                print("📝 최근 레코드 로드: Extension \(record.extensionAngle)°")
            } else {
                print("⚠️ 저장된 레코드가 없습니다")
            }
        } catch {
            errorMessage = "최근 레코드 로드 실패: \(error.localizedDescription)"
            print("❌ \(errorMessage ?? "")")
        }
    }

    // MARK: - 새 측정 시작 (currentRecord 초기화)
    func startNewMeasurement() {
        currentRecord = nil
        errorMessage = nil
        print("🆕 새 측정 시작")
    }
}

extension MeasureViewModel {
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

    // ROM 계산 함수 : 180 - 무릎각도, 무릎각도 = 180 - (측정값 * 2) (이등변 삼각형으로 가정)
    private func calculateKneeAngle(angle: Double) -> Double {
        return angle * 2
    }

    private func calculateMeasurementMinutes(from startDate: Date) -> Int {
        let elapsed = Date().timeIntervalSince(startDate)
        return Int(elapsed / 60)  // 초 → 분
    }
}
