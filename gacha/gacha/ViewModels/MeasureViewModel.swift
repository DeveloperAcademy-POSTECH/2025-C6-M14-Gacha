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
    private var measureManager: MotionMeasureManager

    @Published var measuredRom: Double = 0.0

    @Published var hasTodayRecord: Bool = false

    // Modal 표시 여부
    @Published var showMeasureFlow: Bool = false

    // Modal 내부 navigation
    @Published var navigationPath = NavigationPath()

    // 재측정 플래그 (onChange에서 checkTodayRecord를 건너뛰기 위함)
    var isRemeasuring: Bool = false

    @Published var currentRecord: MeasuredRecord? = nil
    @Published var allRecords: [MeasuredRecord] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    // MARK: - Navigation Source Tracking
    /// 현재 화면으로 진입한 소스를 추적
    /// 예: PainLevel 화면에서 이전 화면이 홈인지 측정 화면인지 확인
    @Published var navigationSource: [MeasureFlowStep: NavigationSource] = [:]

    // MARK: - Progress Properties
    @Published var previousRecord: MeasuredRecord?
    @Published var changeResult: ChangeResult?
    
    // MARK: - 새로운 측정 관련 프로퍼티
    @Published var isMeasuring: Bool = false
    @Published var measurementState: MeasurementState = .idle
    @Published var detectedMaxAngle: Double = 0.0
    @Published var shouldAutoStartMeasure: Bool = false  // 자동 시작 플래그
    @Published var stabilizingProgress: Double = 0.0  // 안정화 진행률 (0.0~1.0)
    private var stableAngleTimer: Timer?
    private var lastStableAngle: Double = 0.0
    private var stableStartTime: Date?
    private let stableDurationThreshold: TimeInterval = 1.4  // 1.4초
    private let stableAngleThreshold: Double = 3.0  // ±3도
    private var lastHapticProgressLevel: Int = 0  // 마지막 햅틱 발생 레벨 (0, 1, 2...)
    
    // MARK: - 전체 측정 진행률 (0.0~1.0)
    var overallProgress: Double {
        guard isMeasuring || measurementState == .completed else { return 0.0 }

        switch measurementState {
        case .idle:
            return 0.0
        case .started:
            return 0.1  // 시작
        case .moving:
            return 0.2  // 움직임 감지
        case .stabilizing:
            // 0.3에서 1.0까지 (stabilizingProgress 기반)
            return 0.2 + (stabilizingProgress * 0.7)
        case .completed:
            return 1.0
        }
    }

    // MARK: - 현재 각도 (measureManager에서 가져옴)
    @Published var currentAngle: Double = 0

    private var cancellables = Set<AnyCancellable>()

    enum MeasurementState {
        case idle           // 대기
        case started        // 측정 시작됨
        case moving         // 움직임 감지
        case stabilizing    // 안정화 중
        case completed      // 완료
    }

    init(repository: RecordRepository) {
        self.repository = repository
        self.measureManager = MotionMeasureManager()

        // measureManager의 currentAngle 변화를 구독
        measureManager.$currentAngle
            .assign(to: &$currentAngle)
    }


    func checkTodayRecord() async {
        isLoading = true
        defer { isLoading = false }

        do {
            hasTodayRecord = try await repository.hasTodayRecord
            print("✅ [checkTodayRecord] hasTodayRecord: \(hasTodayRecord)")
            if hasTodayRecord {
                currentRecord = await loadLatestRecord()
                print("✅ [checkTodayRecord] currentRecord: \(currentRecord?.measuredDate.description ?? "없음")")
            } else {
                print("✅ [checkTodayRecord] No record today")
            }

        } catch {
            print("❌ [checkTodayRecord] 기록 확인 실패: \(error)")
            hasTodayRecord = false
        }
    }

    // MARK: - 센서 제어
    func startSensor() {
        measureManager.startMeasuring()
        print("🔵 센서 시작")
    }
    
    func stopSensor() {
        measureManager.stopMeasuring()
        print("⚫ 센서 중지")
    }
    
    // MARK: - 굴곡 측정 시작
    func startFlexionMeasure() {
        guard !isMeasuring else {
            print("⚠️ 이미 측정 중입니다.")
            return
        }
        
        isMeasuring = true
        measurementState = .started
        detectedMaxAngle = 0.0
        lastStableAngle = 0.0
        stableStartTime = nil
        lastHapticProgressLevel = 0
        measureManager.startRecording()
        
        // 안정 각도 감지 타이머 시작
        stableAngleTimer = Timer.scheduledTimer(
            withTimeInterval: 0.1,
            repeats: true
        ) { [weak self] _ in
            self?.checkAngleStability()
        }
        
        print("🏁 굴곡 측정 시작")
    }
    
    // MARK: - 각도 안정성 체크
    private func checkAngleStability() {
        let currentAngle = measureManager.currentAngle * 2  // ROM 계산

        // 최대 각도 업데이트
        if currentAngle > detectedMaxAngle {
            detectedMaxAngle = currentAngle
        }

        // 진행률 기반 햅틱 (10%마다)
        let progress = overallProgress
        let currentLevel = Int(progress * 10)  // 0, 1, 2, 3... (10%, 20%, 30%...)

        if currentLevel > lastHapticProgressLevel && currentLevel < 10 {
            lastHapticProgressLevel = currentLevel
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            print("📳 진행률 햅틱: \(currentLevel * 10)%")
        }

        // 각도 상승 감지 (5도 이상 변화)
        if measurementState == .started && abs(currentAngle) > 5.0 {
            measurementState = .moving
            print("🏃 움직임 감지됨")
        }
        
        // 움직임이 감지된 후에만 안정화 체크
        guard measurementState == .moving || measurementState == .stabilizing else {
            return
        }
        
        // 각도 안정 여부 확인
        let angleDiff = abs(currentAngle - lastStableAngle)
        
        if angleDiff <= stableAngleThreshold {
            // 각도가 안정적임
            if measurementState == .moving {
                measurementState = .stabilizing
                stableStartTime = Date()
                stabilizingProgress = 0.0
                print("⏱️ 안정화 시작")
            }
            
            // 안정화 진행률 계산
            if let startTime = stableStartTime {
                let elapsed = Date().timeIntervalSince(startTime)
                stabilizingProgress = min(elapsed / stableDurationThreshold, 1.0)
                
                
                // 1.4초 동안 안정 유지 시 측정 완료
                if elapsed >= stableDurationThreshold {
                    completeFlexionMeasure()
                }
            }
        } else {
            // 각도가 변화함 - 다시 움직임 상태로
            if measurementState == .stabilizing {
                measurementState = .moving
                stableStartTime = nil
                stabilizingProgress = 0.0
                print("🔄 움직임 재개")
            }
        }
        
        lastStableAngle = currentAngle
    }
    
    // MARK: - 측정 완료
    private func completeFlexionMeasure() {
        guard isMeasuring else { return }

        stableAngleTimer?.invalidate()
        stableAngleTimer = nil
        measureManager.stopRecording()

        isMeasuring = false
        measurementState = .completed

        // 최빈값 계산 (옵션 B: 최대값 근처만 사용)
        let finalAngle = calculateFlexionROM()
        measuredRom = finalAngle

        print("✅ 굴곡 측정 완료: \(finalAngle)°")

        // 강한 햅틱 0.5초 동안 울림
        let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
        let notificationGenerator = UINotificationFeedbackGenerator()

        heavyGenerator.prepare()
        notificationGenerator.prepare()

        // 즉시 강한 햅틱
        heavyGenerator.impactOccurred(intensity: 1.0)
        notificationGenerator.notificationOccurred(.success)

        // 0.15초 후
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            heavyGenerator.impactOccurred(intensity: 1.0)
        }

        // 0.3초 후
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            heavyGenerator.impactOccurred(intensity: 1.0)
        }

        // 0.5초 후
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            notificationGenerator.notificationOccurred(.success)
        }

        // 1초 후 다음 화면으로 이동
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.finishFlexion(angle: finalAngle)
        }
    }
    
    // MARK: - 최빈값 계산 (옵션 B)
    private func calculateFlexionROM() -> Double {
        let angles = measureManager.recordedAngles.map { $0 * 2 }  // ROM 변환
        
        guard !angles.isEmpty else {
            return detectedMaxAngle
        }
        
        // 최대값 찾기
        let maxAngle = angles.max() ?? 0
        
        // 최대값 ±5도 이내 데이터만 필터링
        let nearMaxAngles = angles.filter { abs($0 - maxAngle) <= 5.0 }
        
        // 필터링된 데이터의 최빈값 계산
        if let modeValue = mode(of: nearMaxAngles.map { Int($0) }) {
            return Double(modeValue)
        }
        
        // 최빈값 계산 실패 시 최대값 반환
        return maxAngle
    }
    
    // MARK: - 측정 취소
    func cancelFlexionMeasure() {
        stableAngleTimer?.invalidate()
        stableAngleTimer = nil
        measureManager.stopRecording()
        
        isMeasuring = false
        measurementState = .idle
        detectedMaxAngle = 0.0
        
        measureManager.recordedAngles.removeAll()
        
        print("❌ 측정 취소됨")
    }
    
    // MARK: - 재측정 준비
    func prepareForNewMeasurement() {
        // 이전 측정 상태 초기화
        measurementState = .idle
        isMeasuring = false
        detectedMaxAngle = 0.0
        lastStableAngle = 0.0
        stableStartTime = nil
        stabilizingProgress = 0.0
        
        
        // 타이머 정리
        stableAngleTimer?.invalidate()
        stableAngleTimer = nil
        
        // 기록된 각도 데이터 정리
        measureManager.recordedAngles.removeAll()
        
        // 네비게이션 소스도 초기화
        clearAllNavigationSources()
        
        print("🔄 [MeasureViewModel] 새 측정 준비 완료")
    }
    
    // MARK: - Navigation Source Management
    /// 특정 단계로의 네비게이션 소스 가져오기
    func getNavigationSource(for step: MeasureFlowStep) -> NavigationSource? {
        return navigationSource[step]
    }
    
    /// 네비게이션 소스 설정
    func setNavigationSource(for step: MeasureFlowStep, source: NavigationSource) {
        navigationSource[step] = source
    }
    
    /// 네비게이션 소스 초기화
    func clearNavigationSource(for step: MeasureFlowStep) {
        navigationSource.removeValue(forKey: step)
    }
    
    /// 네비게이션 소스 전체 초기화
    func clearAllNavigationSources() {
        navigationSource.removeAll()
    }
    
    /// 소스를 기록하며 네비게이션
    func navigate(to step: MeasureFlowStep, from source: NavigationSource) {
        setNavigationSource(for: step, source: source)
        navigationPath.append(step)
    }

    /// 측정 플로우 시작 (Modal 열기)
    func startMeasureFlow(initialStep: MeasureFlowStep, from source: NavigationSource) {
        setNavigationSource(for: initialStep, source: source)
        navigationPath = NavigationPath()  // 초기화
        navigationPath.append(initialStep)
        showMeasureFlow = true
    }

    /// 측정 플로우 종료 (Modal 닫기)
    func dismissMeasureFlow() {
        showMeasureFlow = false
        navigationPath = NavigationPath()  // 정리
    }

    // MARK: - Flexion 측정 완료 시
    func finishFlexion(angle: Double) {
        isLoading = true
        defer { isLoading = false }

        // 굴곡 각도만 측정
        let record = MeasuredRecord()
        record.flexionAngle = angle
        record.measuredSeconds = 0  // 측정 시간은 자동 계산됨

        currentRecord = record
        print("✅ Flexion: \(record.flexionAngle)°")

        // Modal 내부에서 PainLevel로 이동
        navigate(to: .completeMeasure, from: .flexionMeasure)
    }

    // MARK: - PainLevel 측정 완료 시
    func finishPainLevel(level: Int) async {
        guard let currentRecord = currentRecord else {
            errorMessage = "현재 레코드가 없습니다."
            print("⚠️ \(errorMessage ?? "")")
            return
        }

        isLoading = true

        currentRecord.painLevel = level

        isLoading = false
    }
    
    // MARK: - 통증 레벨만 입력 시 (각도 없이)
    func finishPainLevelOnly(level: Int) async {
        isLoading = true
        defer { isLoading = false }
        
        // 각도 없이 통증 레벨만 있는 새 레코드 생성
        let record = MeasuredRecord()
        record.flexionAngle = nil  // 각도 없음
        record.painLevel = level
        record.measuredSeconds = 0
        
        currentRecord = record
        print("✅ 통증 레벨만 저장: \(level)")
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
            self.clearCurrentRecord()
        } catch {
            print("Error")
        }
    }

    // MARK: - 뒤로가기
    func clearCurrentRecord() {
        currentRecord = nil
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

    // MARK: - 최근 레코드 불러오기
    func loadLatestRecord() async -> MeasuredRecord? {
        isLoading = true
        defer { isLoading = false }

        do {
            let record = try await repository.loadLatestRecord()

            if let record = record {
                print("📝 최근 레코드 로드: Flexion \(record.flexionAngle ?? 0)°")
            } else {
                print("⚠️ 저장된 레코드가 없습니다")
            }

            return record
        } catch {
            errorMessage = "최근 레코드 로드 실패: \(error.localizedDescription)"
            print("❌ \(errorMessage ?? "")")
            return nil
        }
    }
    
    // MARK: - 어제 레코드 불러오기
    func loadYesterdayRecord() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let records = try await repository.loadRecords()
            let record = records.dropFirst().first
            previousRecord = record

            if let record = previousRecord {
                print("📝 어제 레코드 로드: \(record.measuredDate)")
            } else {
                print("⚠️ 저장된 레코드가 없습니다")
            }
        } catch {
            errorMessage = "어제 레코드 로드 실패: \(error.localizedDescription)"
            print("❌ \(errorMessage ?? "")")
        }
    }

    // MARK: - 오늘 데이터가 있다면 삭제하기
    func deleteTodayRecords() async {
        do {
            print("🗑️ [deleteTodayRecords] Starting...")
            if try await repository.hasTodayRecord {
                let legacyRecord = try await repository.loadLatestRecord()
                guard let record = legacyRecord else {
                    print("🗑️ [deleteTodayRecords] No record to delete")
                    return
                }
                print("🗑️ [deleteTodayRecords] Deleting record: \(record.measuredDate)")
                try await repository.deleteRecord(by: record.id)
                currentRecord = nil
                print("✅ [deleteTodayRecords] Record deleted successfully")
            } else {
                print("🗑️ [deleteTodayRecords] No today record exists")
            }
        } catch {
            print("❌ [deleteTodayRecords] Error: \(error)")
        }
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

    private func calculateMeasurementSeconds(from startDate: Date) -> Int {
        let elapsed = Date().timeIntervalSince(startDate)
        return Int(elapsed)
    }
}
