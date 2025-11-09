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
    @StateObject private var historyVM: HistoryViewModel
    @StateObject private var calendarVM: CalendarViewModel
    @State private var selectedTab: TabBarItem = .measure

    init(modelContext: ModelContext) {
        let repository = SwiftDataRecordRepository(modelContext: modelContext)
        _measureVM = StateObject(
            wrappedValue: MeasureViewModel(repository: repository)
        )
        _historyVM = StateObject(wrappedValue: HistoryViewModel(repository: repository))
        _calendarVM = StateObject(wrappedValue: CalendarViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack(path: $measureVM.navigationPath) {
            ZStack(alignment: .bottom) {
                // 메인 콘텐츠
                tabContentView()
                    .navigationDestination(for: MeasureFlowStep.self) { step in
                        viewForStep(step)
                    }
                
                // TabBar (메인 화면일 때만 표시)
                if measureVM.navigationPath.isEmpty {
                    TabBarComponent(selectedTab: $selectedTab)
                }
            }
            .ignoresSafeArea(edges: .bottom)

        }
        .onChange(of: measureVM.navigationPath.count) { oldValue, newValue in
            // 홈으로 돌아왔을 때 (path가 비었을 때)
            if newValue == 0 {
                Task {
                    await measureVM.checkTodayRecord()
                }
            }
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            // 캘린더 탭으로 전환할 때 데이터 새로고침
            if newValue == .calendar {
                Task {
                    await calendarVM.loadMeasuredDates()
                }
            }
        }
        .onAppear {
            Task {
                await measureVM.checkTodayRecord()
                await calendarVM.loadMeasuredDates()
            }
        }
        .environmentObject(measureVM)
        .environmentObject(historyVM)
        .environmentObject(calendarVM)
    }
    
    // MARK: - Tab Content View
    @ViewBuilder
    private func tabContentView() -> some View {
        switch selectedTab {
        case .calendar:
            calendarView()
                
        case .measure:
            homeView()
            
        case .summary:
            summaryView()
                 
        }
    }

    // MARK: - View Builder
    @ViewBuilder
    private func calendarView() -> some View {
        CalendarView()
    }
    
    @ViewBuilder
    private func homeView() -> some View {
        if measureVM.isLoading {
            Text("Loading...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if measureVM.hasTodayRecord {
            // 오늘 측정을 한 상태: MeasureView_After 표시
            MeasureView_After()
                .padding(.bottom, 80)  // TabBar 높이만큼 여백
        } else {
            // 오늘 측정을 안한 상태: MainView 표시
            MainView()
                .padding(.bottom, 80)  // TabBar 높이만큼 여백
        }
    }
    
    @ViewBuilder
    private func summaryView() -> some View {
        HistoryView()
            .padding(.bottom, 80)  // TabBar 높이만큼 여백
            .toolbar(.hidden, for: .navigationBar)  // 탭 뷰에서는 네비게이션 바 숨김
    }

    @ViewBuilder
    private func viewForStep(_ step: MeasureFlowStep) -> some View {
        switch step {
        case .home:
            homeView()

        case .flexionMeasure:
            MeasureFlag()
                .navigationBarBackButtonHidden(true)

        case .flexionCheck:
            FlexionMeasureView()
                .navigationBarHidden(true)
            
        case .painLevel:
            PainLevelView()
                .navigationBarHidden(true)


        case .summary:
            MeasureView_After()
                .navigationBarHidden(true)
        }
    }
}
