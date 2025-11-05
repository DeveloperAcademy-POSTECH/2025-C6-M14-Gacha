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
    @StateObject private var measureVM: MeasureViewModel
    @StateObject private var historyVM: ProgressHistoryViewModel

    init(modelContext: ModelContext) {
        let repository = SwiftDataRecordRepository(modelContext: modelContext)
        _measureVM = StateObject(
            wrappedValue: MeasureViewModel(repository: repository)
        )
        _historyVM = StateObject(wrappedValue: ProgressHistoryViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack(path: $measureVM.navigationPath) {
            // 루트 화면: DailyMeasureStartView
            homeView()
                .navigationDestination(for: MeasureFlowStep.self) { step in
                    viewForStep(step)
                }
        }
        .onChange(of: measureVM.navigationPath.count) { oldValue, newValue in
            // 홈으로 돌아왔을 때 (path가 비었을 때)
            if newValue == 0 {
                Task {
                    await measureVM.checkTodayRecord()
                }
            }
        }
        .onAppear {
            Task {
                await measureVM.checkTodayRecord()
            }
        }
        .environmentObject(measureVM)
        .environmentObject(historyVM)

    }

    // MARK: - View Builder
    @ViewBuilder
    private func homeView() -> some View {
        if measureVM.isLoading {
            Text("Loading...")
        } else {
            if measureVM.hasTodayRecord {
                DailyMeasureSummaryView()
            } else {
                DailyMeasureStartView2()
            }
        }
    }

    @ViewBuilder
    private func viewForStep(_ step: MeasureFlowStep) -> some View {
        switch step {
        case .home:
            homeView()

        case .flexionMeasure:
            FlexionMeasureView()
                .navigationBarBackButtonHidden(true)

        case .flexionCheck:
            DailyMeasureDoneView()
                .navigationBarHidden(true)
            
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
