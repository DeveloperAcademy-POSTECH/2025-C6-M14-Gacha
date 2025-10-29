//
//  MeasureFlowView.swift
//  gacha
//
//  Created by 차원준 on 10/28/25.
//

import SwiftData
import SwiftUI

// MARK: - Wrapper View (Environment에서 modelContext 받아서 전달)
struct MeasureFlowViewWrapper: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        MeasureFlowView(modelContext: modelContext)
    }
}

struct MeasureFlowView: View {
    @StateObject private var vm: MeasureViewModel

    init(modelContext: ModelContext) {
        let repository = SwiftDataRecordRepository(modelContext: modelContext)
        _vm = StateObject(
            wrappedValue: MeasureViewModel(repository: repository)
        )
    }

    var body: some View {
        NavigationStack(path: $vm.navigationPath) {
            // 루트 화면: DailyMeasureStartView
            homeView()
                .navigationDestination(for: MeasureFlowStep.self) { step in
                    viewForStep(step)
                }
        }
        .onAppear() {
            vm.startMeasuring()
            Task {
                await vm.checkTodayRecord()
                await vm.printAllRecords()
            }
        }
        .onDisappear {
            vm.stopMeasuring()
        }
        .environmentObject(vm)  // 모든 하위 뷰에 VM 주입
    }

    // MARK: - View Builder
    @ViewBuilder
    private func homeView() -> some View {
        if vm.hasTodayRecord {
            DailyMeasureSummaryView()
        } else {
            DailyMeasureStartView()
        }
    }

    @ViewBuilder
    private func viewForStep(_ step: MeasureFlowStep) -> some View {
        switch step {
        case .home:
            homeView()

        case .extensionMeasure:
            ExtensionMeasureView()
                .navigationBarBackButtonHidden(true)

        case .measureChecked:
            MeasureCheckedView()
                .navigationBarHidden(true)

        case .flexionMeasure:
            FlexionMeasureView()
                .navigationBarBackButtonHidden(true)

        case .painLevel:
            PainLevelView()
                .navigationBarHidden(true)

        case .result:
            ProgressDetailView()
                .navigationBarHidden(true)

        case .summary:
            DailyMeasureSummaryView()
                .navigationBarHidden(true)
        }
    }
}
