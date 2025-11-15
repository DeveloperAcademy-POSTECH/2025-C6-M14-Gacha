//
//  MeasureFlow.swift
//  gacha
//
//  Created by 차원준 on 10/28/25.
//

import SwiftData
import SwiftUI

// MARK: - Wrapper View (Environment에서 modelContext 받아서 전달)
struct MeasureFlowWrapper: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        MeasureFlow(modelContext: modelContext)
    }
}

struct MeasureFlow: View {
    @StateObject private var measureVM: MeasureViewModel
    @StateObject private var historyVM: HistoryViewModel
    @StateObject private var calendarVM: CalendarViewModel
    @State private var selectedTab = 1  // 기본 탭: 1 = 측정 탭

    init(modelContext: ModelContext) {
        let repository = SwiftDataRecordRepository(modelContext: modelContext)
        _measureVM = StateObject(
            wrappedValue: MeasureViewModel(repository: repository)
        )
        _historyVM = StateObject(wrappedValue: HistoryViewModel(repository: repository))
        _calendarVM = StateObject(wrappedValue: CalendarViewModel(repository: repository))
    }

    // 측정 플로우가 진행 중인지 확인
    private var isInMeasureFlow: Bool {
        return measureVM.showMeasureFlow
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // 캘린더 탭
            NavigationStack {
                CalendarView()
                    .navigationTitle(Strings.Tabbar.calendar)
                    .navigationBarTitleDisplayMode(.large)
                    .environmentObject(calendarVM)
            }
            .tag(0)
            .tabItem {
                Label(Strings.Tabbar.calendar, systemImage: "calendar")
            }
            .environmentObject(calendarVM)

            // 측정 탭 (메인)
            NavigationStack {
                homeView()
                    .fullScreenCover(isPresented: $measureVM.showMeasureFlow) {
                        NavigationStack(path: $measureVM.navigationPath) {
                            // 빈 초기 화면 (navigationPath에 의해 즉시 대체됨)
                            Color.clear
                                .navigationDestination(for: MeasureFlowStep.self) { step in
                                    viewForStep(step)
                                }
                        }
                        .interactiveDismissDisabled()
                        .environmentObject(measureVM)
                    }
            }
            .tag(1)
            .tabItem {
                Label(Strings.Tabbar.measure, systemImage: "ruler")
            }
            .environmentObject(measureVM)

            // 요약 탭
            NavigationStack {
                History()
                    .navigationTitle(Strings.Tabbar.summary)
                    .navigationBarTitleDisplayMode(.large)
            }
            .tag(2)
            .tabItem {
                Label(Strings.Tabbar.summary, systemImage: "chart.bar")
            }
            .environmentObject(historyVM)
        }
        .toolbar(isInMeasureFlow ? .hidden : .visible, for: .tabBar)
        .onChange(of: measureVM.showMeasureFlow) { oldValue, newValue in
            // 홈으로 돌아왔을 때 (modal이 닫혔을 때)
            if !newValue {
                Task {
                    await measureVM.checkTodayRecord()
                }
            }
        }
        .task {
            // 앱 시작 시 초기 데이터 로드
            await measureVM.checkTodayRecord()
            await calendarVM.loadMeasuredDates()
        }
        .environmentObject(measureVM)
        .environmentObject(historyVM)
        .environmentObject(calendarVM)
    }

    
    // MARK: - View Builder
    @ViewBuilder
    private func homeView() -> some View {
        if measureVM.isLoading {
            Text("Loading...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if measureVM.hasTodayRecord {
            // 오늘 측정을 한 상태: MainViewAfter 표시
            MainViewAfter()
        } else {
            // 오늘 측정을 안한 상태: MainViewBefore 표시
            MainViewBefore()
        }
    }

    @ViewBuilder
    private func viewForStep(_ step: MeasureFlowStep) -> some View {
        switch step {
        case .home:
            homeView()

        case .measureLoading:
            MeasureLoading()
                .navigationBarBackButtonHidden(true)

        case .flexionCheck:
            FlexionMeasure()
                .navigationBarHidden(true)
            
        case .painLevel:
            PainLevel()
                .navigationBarHidden(true)


        case .summary:
            MainViewAfter()
                .navigationBarHidden(true)
        }
    }
}
