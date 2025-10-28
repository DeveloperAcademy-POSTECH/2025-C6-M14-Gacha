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

    @Published var isTouching: Bool = false // 뷰에서 사용
    @Published var isFinished: Bool = false
    private var recordingTimer: Timer?
    private var recordingStartTime: Date?
    @Published var recordingProgress: Double = 0.0
    private let recordingDurationThreshold: TimeInterval = 1.5

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
        guard recordingTimer == nil else {
            print("🚫 이미 녹화 중입니다.")
            return
        }
        
        // 초기화
        isFinished = false
        measureManager.startRecording()
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
                self.isFinished = true
                Task {
                    await self.finishRecording()
                }
            }
        }
        print("🎬 녹화 시작")
    }

    //MARK: - 기록 종료
    func stopRecording() {
        if isFinished {
            finishRecording()
        } else {
            cancelRecording()
        }
    }
    
    //MARK: - 터치 중단
    func cancelRecording() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        recordingStartTime = nil
        recordingProgress = 0.0

        measureManager.stopRecording()

        print("❌ 녹화 취소")
    }

    //MARK: - 3초 감지 완료
    func finishRecording() {
        isLoading = true
        defer { isLoading = false }  // 현재 함수가 끝날 때 자동으로 실행
        
        recordingTimer?.invalidate()
        recordingTimer = nil
        recordingProgress = 1.0

        measureManager.stopRecording()

        let count = measureManager.recordedAngles.count
        let duration = Date().timeIntervalSince(recordingStartTime ?? Date())
        print("✅ 녹화 완료: \(count)개 데이터 (\(String(format: "%.1f", duration))초)")

        // 분석 - 최빈값으로 ROM 계산
        if let angle = mode(of: measureManager.recordedAngles) {
            measuredRom = calculateKneeAngle(angle: angle)  // 무릎 각도 변환
        }

        //MARK: ⚠️ 데이터에 저장하는 flow 필요
        Task {
            switch kneeType {
            case .flexionRom:
                finishFlexion(angle: measuredRom)
            case .extensionRom:
                finishExtension(angle: measuredRom)
            }
        }

        recordingStartTime = nil
    }

    func stopMeasuring() {
        measureManager.stopMeasuring()
    }

    func finishExtension(angle: Double) {
        isLoading = true
        defer { isLoading = false }  // 현재 함수가 끝날 때 자동으로 실행

        let record = MeasuredRecord(extensionAngle: measuredRom)
        currentRecord = record
    }

    // MARK: - Flexion 측정 완료 시
    func finishFlexion(angle: Double) {
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
        
        currentRecord.flexionAngle = measuredRom
        currentRecord.measuredMinutes = measurementMinutes
        
        print(currentRecord.measuredDate, currentRecord.measuredMinutes)

    }

    // MARK: - PainLevel 측정 완료 시
    func finishPainLevel(level: Int) {
        guard let currentRecord = currentRecord else {
            errorMessage = "현재 레코드가 없습니다."
            print("⚠️ \(errorMessage ?? "")")
            return
        }

        isLoading = true
        defer { isLoading = false }

        currentRecord.painLevel = level
    }
    
    // MARK: - 측정 정보를 저장 시
    func saveCurrentRecord() async {
        guard let currentRecord = currentRecord else {
            errorMessage = "현재 레코드가 없습니다."
            print("⚠️ \(errorMessage ?? "")")
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await repository.createRecord(record: currentRecord)
        } catch {
            print("Error")
        }
    }

    // MARK: - 뒤로가기
    func back() async {
        guard let record = currentRecord else {
            errorMessage = "현재 레코드가 없습니다."
            print("⚠️ \(errorMessage ?? "")")
            return
        }

        do {
            try await repository.deleteRecord(by: record.id)
            print("🗑️ 레코드 삭제 완료")
        } catch {
            errorMessage = "레코드 삭제 실패: \(error.localizedDescription)"
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
