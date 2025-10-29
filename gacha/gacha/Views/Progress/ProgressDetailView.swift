//
//  ProgressDetailView.swift
//  gacha
//
//  Created by 차원준 on 10/26/25.
//

import SwiftData
import SwiftUI

struct ProgressDetailView: View {
    @EnvironmentObject var vm: MeasureViewModel
    
    var body: some View {
        VStack {
            Text("ProgressDetailView")

            Button {
                Task {
                    await vm.saveCurrentRecord()
                }
                vm.navigationPath.append(MeasureFlowStep.summary)
            } label: {
                Text("확인")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundStyle(.white)
                    .background(Color.blue)
                    .cornerRadius(25)
            }
        }
    }
}

//struct ProgressDetailView: View {
//    // MARK: - Properties
//
//    @EnvironmentObject var vm: MeasureViewModel
//    let onRemeasure: () -> Void
//    let onConfirm: () -> Void
//
//    @Environment(\.modelContext) private var modelContext
//
//    @State private var previousRecord: MeasuredRecord?
//    @State private var changeResult: ChangeResult?
//    @State private var showHistoryModal: Bool = false
//
//    // MARK: - Computed Properties
//
//    private var romValue: Int {
//        guard let record = vm.currentRecord else { return 0 }
//        return Int(record.ROM)
//    }
//
//    private var hasComparison: Bool {
//        previousRecord != nil && changeResult != nil
//    }
//
//    // MARK: - Body
//
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 24) {
//                // 헤더
//                VStack(spacing: 8) {
//                    Text("측정 결과")
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//
//                    Text("지난 측정과 비교한 결과가 제공됩니다")
//                        .font(.subheadline)
//                        .foregroundStyle(.secondary)
//                }
//                .padding(.top, 40)
//
//                // 결과 카드
//                resultCard
//                    .padding(.horizontal, 20)
//
//                // 측정값 그리드
//                measurementGrid
//                    .padding(.horizontal, 20)
//
//                Spacer()
//
//                // 버튼들
//                buttonStack
//                    .padding(.horizontal, 40)
//                    .padding(.bottom, 40)
//            }
//        }
//        .sheet(isPresented: $showHistoryModal, onDismiss: {
//                // 닫힌 뒤 후처리
//
//            }) {
//                ProgressHistoryView()
//            }
////        .fullScreenCover(isPresented: $showHistoryModal) {
////            ProgressHistoryView()
////        }
//        .onAppear {
//            loadPreviousRecord()
//        }
//    }
//
//    // MARK: - Subviews
//
//    private var resultCard: some View {
//        VStack(spacing: 16) {
//            Text(questionText)
//                .font(.title3)
//                .fontWeight(.semibold)
//                .multilineTextAlignment(.center)
//
//            // 일러스트 영역 (추후 추가)
//            Rectangle()
//                .fill(Color(.systemGray6))
//                .frame(height: 180)
//                .cornerRadius(12)
//
//            VStack(spacing: 8) {
//                Text(feedbackMessage)
//                    .font(.body)
//                    .multilineTextAlignment(.center)
//
//                Text(guidanceText)
//                    .font(.caption)
//                    .foregroundStyle(.secondary)
//                    .multilineTextAlignment(.center)
//            }
//        }
//        .padding(24)
//        .background(Color(.systemBackground))
//        .cornerRadius(24)
//        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
//    }
//
//    private var measurementGrid: some View {
//        HStack(spacing: 16) {
//            // 좌측: 펴진 각도, 무릎 가동범위
//            VStack(alignment: .leading, spacing: 16) {
//                measurementItem(
//                    title: "펴진 각도",
//                    value: formatAngle(vm.currentRecord?.extensionAngle ?? 0),
//                    previousValue: previousRecord?.extensionAngle,
//                    change: changeResult?.extenRomDiff,
//                    isPositiveGood: true
//                )
//
//                measurementItem(
//                    title: "무릎 가동범위",
//                    value: "\(romValue)°",
//                    previousValue: previousRecord?.ROM,
//                    change: hasComparison ? Double(romValue) - previousRecord!.ROM : nil,
//                    isPositiveGood: true
//                )
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//
//            // 우측: 굽혀진 각도, 통증 수준
//            VStack(alignment: .leading, spacing: 16) {
//                measurementItem(
//                    title: "굽혀진 각도",
//                    value: formatAngle(vm.currentRecord?.flexionAngle ?? 0),
//                    previousValue: previousRecord?.flexionAngle,
//                    change: changeResult?.flexRomDiff,
//                    isPositiveGood: false
//                )
//
//                measurementItem(
//                    title: "통증 수준",
//                    value: formatPainLevel(vm.currentRecord?.painLevel ?? 0),
//                    previousValue: previousRecord?.painLevel,
//                    change: changeResult?.painDiff,
//                    isPositiveGood: false
//                )
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//        }
//    }
//
//    private func measurementItem(
//        title: String,
//        value: String,
//        previousValue: Double?,
//        change: Double?,
//        isPositiveGood: Bool
//    ) -> some View {
//        VStack(alignment: .leading, spacing: 4) {
//            Text(title)
//                .font(.caption)
//                .foregroundStyle(.secondary)
//
//            HStack(alignment: .firstTextBaseline, spacing: 8) {
//                // 현재 값
//                Text(value)
//                    .font(.title2)
//                    .fontWeight(.bold)
//
//                // 변화 값
//                if let change = change, let previous = previousValue {
//                    HStack(spacing: 2) {
//                        Image(systemName: change > 0 ? "arrow.up" : change < 0 ? "arrow.down" : "minus")
//                            .font(.caption2)
//                        Text(formatChange(change))
//                            .font(.caption)
//                            .fontWeight(.medium)
//                    }
//                    .foregroundStyle(changeColor(for: change, isPositiveGood: isPositiveGood))
//                }
//            }
//        }
//    }
//
//    private var buttonStack: some View {
//        VStack(spacing: 12) {
//            Button {
//                onRemeasure()
//            } label: {
//                Text("다시 측정하기")
//                    .font(.headline)
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 50)
//                    .foregroundStyle(.primary)
//                    .background(Color(.systemGray5))
//                    .cornerRadius(25)
//            }
//
//            Button {
//                saveCurrentRecord()
//                onConfirm()
//            } label: {
//                Text("확인")
//                    .font(.headline)
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 50)
//                    .foregroundStyle(.white)
//                    .background(Color.blue)
//                    .cornerRadius(25)
//            }
//        }
//    }
//
//    // MARK: - Helper Methods
//
//    private func loadPreviousRecord() {
//        let descriptor = FetchDescriptor<MeasuredRecord>(
//            sortBy: [SortDescriptor(\.measuredDate, order: .reverse)]
//        )
//
//        if let records = try? modelContext.fetch(descriptor), !records.isEmpty {
//            previousRecord = records.first
//
//            // vm.currentRecord와 비교
//            if let currentRecord = vm.currentRecord {
//                changeResult = analyzeRecordChange(latest: currentRecord, previous: records.first!)
//            }
//        }
//    }
//
//    // MARK: - Message Generation
//
//    private var questionText: String {
//        if hasComparison {
//            return "산책해 보시는건 어떤가요?"
//        } else {
//            return "첫 측정을 완료했어요!"
//        }
//    }
//
//    private var feedbackMessage: String { // 추후 디벨롭 필요
//        guard let result = changeResult else {
//            return "오늘의 측정 결과가 기록되었습니다."
//        }
//
//        // ROM 변화 기준으로 메시지 생성
//        let flexState = result.flexRomDiffState
//        let extenState = result.extenRomDiffState
//        let painState = result.painDiffState
//
//        // 통증이 심각하게 증가한 경우
//        if case .visitRecommended = painState {
//            return "통증이 많이 증가했어요. 😰\n병원 방문을 권장드립니다."
//        }
//
//        // ROM 호전 + 통증 감소
//        if case .better = extenState, case .better = flexState, case .better = painState {
//            return "모든 지표가 좋아졌어요! 😊\n이대로 꾸준히 운동하세요."
//        }
//
//        // ROM 호전
//        if case .better = extenState {
//            return "지난번보다 가동범위가 늘어났어요! 👍\n꾸준한 운동이 효과를 보이고 있습니다."
//        }
//
//        // ROM 악화
//        if case .warning = extenState {
//            return "지난번보다 수치가 살짝 줄었지만,\n여전히 형상 범위예요. 😊\n몸의 컨디션에 따라 조금씩 달라질 수 있어요."
//        }
//
//        // 통증 증가
//        if case .warning = painState {
//            return "통증이 조금 증가했어요. 😣\n무리하지 마시고 천천히 진행하세요."
//        }
//
//        // 기본 메시지
//        return "오늘도 측정을 완료했어요. 😊\n꾸준한 기록이 회복에 도움이 됩니다."
//    }
//
//    private var guidanceText: String {
//        if hasComparison {
//            return "몸의 컨디션에 따라 조금씩 달라질 수 있어요."
//        } else {
//            return "다음 측정부터 비교 결과를 확인할 수 있어요."
//        }
//    }
//
//    // MARK: - Formatting
//
//    private func formatAngle(_ angle: Double) -> String {
//        return "\(Int(angle))°"
//    }
//
//    private func formatPainLevel(_ level: Double) -> String {
//        return String(format: "%.0f", level)
//    }
//
//    private func formatChange(_ change: Double) -> String {
//        let absChange = abs(change)
//        if absChange < 1 {
//            return String(format: "%.1f", absChange)
//        } else {
//            return "\(Int(absChange))"
//        }
//    }
//
//    private func changeColor(for change: Double, isPositiveGood: Bool) -> Color {
//        if abs(change) < 0.1 {
//            return .secondary
//        }
//
//        let isGoodChange = isPositiveGood ? change > 0 : change < 0
//        return isGoodChange ? .blue : .red
//    }
//}
//
//#Preview {
//    do {
//        let config = ModelConfiguration(isStoredInMemoryOnly: true)
//        let container = try ModelContainer(for: MeasuredRecord.self, configurations: config)
//
//        // 샘플 이전 기록 추가
//        let previousRecord = MeasuredRecord(
//            measuredDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
//            flexionAngle: 3.0,
//            extensionAngle: 100.0,
//            measuredMinutes: 30,
//            painLevel: 4.0
//        )
//        container.mainContext.insert(previousRecord)
//
//        let session = MeasureSession()
//        session.extensionAngle = 98.0
//        session.flexionAngle = 3.0
//        session.painLevel = 3.0
//
//        return ProgressDetailView(session: session)
//            .modelContainer(container)
//    } catch {
//        return Text("Preview error: \(error.localizedDescription)")
//    }
//}

#Preview {
    // 1. 메모리 전용 ModelContainer 생성
    let container = try! ModelContainer(
        for: MeasuredRecord.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    // 2. Repository 생성
    let repository = SwiftDataRecordRepository(
        modelContext: container.mainContext
    )

    // 3. ViewModel 생성
    let vm = MeasureViewModel(repository: repository)

    ProgressDetailView()
        .environmentObject(vm)
}
