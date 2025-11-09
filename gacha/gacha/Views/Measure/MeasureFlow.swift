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
            .task {
                // 샘플 데이터 생성 (기존 데이터가 없을 때만)
                do {
                    try await SampleDataGenerator.generateSampleRecords(context: modelContext)
                } catch {
                    print("❌ 샘플 데이터 생성 실패: \(error)")
                }
            }
    }
}

struct MeasureFlow: View {
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
            // 캘린더 탭으로 전환할 때만 데이터 새로고침
            if newValue == .calendar {
                Task {
                    await calendarVM.loadMeasuredDates()
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
    
    // MARK: - Tab Content View
    @ViewBuilder
    private func tabContentView() -> some View {
        ZStack {
            // 모든 탭 뷰를 미리 생성 (뷰 재생성 방지)
            calendarView()
                .opacity(selectedTab == .calendar ? 1 : 0)
                .allowsHitTesting(selectedTab == .calendar)
            
            homeView()
                .opacity(selectedTab == .measure ? 1 : 0)
                .allowsHitTesting(selectedTab == .measure)
            
            summaryView()
                .opacity(selectedTab == .summary ? 1 : 0)
                .allowsHitTesting(selectedTab == .summary)
        }
    }

    // MARK: - View Builder
    @ViewBuilder
    private func calendarView() -> some View {
        CalendarView()
            .padding(.bottom, 80)  // TabBar 높이만큼 여백
    }
    
    @ViewBuilder
    private func homeView() -> some View {
        if measureVM.isLoading {
            Text("Loading...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if measureVM.hasTodayRecord {
            // 오늘 측정을 한 상태: MainViewB 표시
            MainViewB()
                .padding(.bottom, 80)  // TabBar 높이만큼 여백
        } else {
            // 오늘 측정을 안한 상태: MainViewA 표시
            MainViewA()
                .padding(.bottom, 80)  // TabBar 높이만큼 여백
        }
    }
    
    @ViewBuilder
    private func summaryView() -> some View {
        History()
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
            FlexionMeasure()
                .navigationBarHidden(true)
            
        case .painLevel:
            PainLevel()
                .navigationBarHidden(true)


        case .summary:
            MainViewB()
                .navigationBarHidden(true)
        }
    }
}
