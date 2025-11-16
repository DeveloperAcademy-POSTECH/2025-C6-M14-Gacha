//
//  MainViewAfter.swift
//  gacha
//
//  Created by 차원준 on 10/28/25.
//

import SwiftData
import SwiftUI

struct MainViewAfter: View {
    @EnvironmentObject var vm: MeasureViewModel

    @State private var showingAlert = false

    var body: some View {
        Group {
            if vm.isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 0) {
                    Spacer()

                    // MARK: - 중간 영역: 측정 결과 카드
                    resultCard
                        .padding(.horizontal, 20)

                    Spacer()

                    // MARK: - 하단 버튼 영역 (MainViewBefore와 동일한 구조)
                    VStack(spacing: 16) {
                        CapsuleButtonComponent(
                            title: Strings.Button.retake,
                            style: .light,
                            width: 361,
                            height: 54,
                            fontStyle: .displayTitle3Bold,
                            cornerRadius: 100
                        ) {
                            showingAlert = true
                        }
                        .alert(isPresented: $showingAlert) {
                            Alert(
                                title: Text(Strings.Alert.remeasureTitle),
                                message: Text(Strings.Alert.remeasureMessage),
                                primaryButton: .destructive(
                                    Text(Strings.Common.yes),
                                    action: {
                                        Task {
                                            vm.isRemeasuring = true
                                            vm.prepareForNewMeasurement()
                                            vm.clearCurrentRecord()

                                            await vm.deleteTodayRecords()
                                            await vm.checkTodayRecord()

                                            vm.navigationPath = NavigationPath()
                                            vm.isRemeasuring = false
                                        }
                                    }
                                ),
                                secondaryButton: .cancel(
                                    Text(Strings.Common.no)
                                )
                            )
                        }
                    }
                    .frame(height: 92)  // MainViewBefore와 동일한 버튼 영역 높이
                    .padding(.bottom, 34)  // MainViewBefore와 동일한 하단 패딩
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle(Strings.Progress.title)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            Task {
                await vm.loadTodayRecord()
                await vm.loadYesterdayRecord()
                vm.calculateRecordChange()
            }
            vm.clearCurrentRecord()
        }
    }

    // MARK: - SubView
    /// 측정 결과 카드
    private var resultCard: some View {
        VStack(spacing: 0) {
            // 1. 통계 섹션 (54px)
            statisticsSection
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

            // 2. 일러스트 영역 (240px)
            illustrationSection
                .padding(.horizontal, 20)
                .padding(.bottom, 24)

            // 3. 피드백 박스 (auto)
            feedbackBox
                .padding(.top, 6)
        }
        .frame(height: 460)
        .background(Color("White"))
    }

    /// 통계 섹션
    var statisticsSection: some View {
        HStack(spacing: 16) {
            // 굴곡 각도
            VStack(alignment: .leading, spacing: 4) {
                Text(Strings.Progress.flexionAngle)
                    .font(.displayCalloutBold)
                    .foregroundColor(.blue700)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(vm.formatAngle(vm.currentRecord?.flexionAngle))
                        .font(.displayTitle2Bold)

                    // 어제 대비 변화량
                    if let trendText = vm.angleTrendText {
                        Text(trendText)
                            .font(.displayCaption1Regular)
                            .foregroundColor(.blue700)
                    }
                }
            }

            Spacer()

            // 통증 정도
            VStack(alignment: .leading, spacing: 4) {
                Text(Strings.Progress.painLevel)
                    .font(.displayCalloutBold)
                    .foregroundColor(.blue700)
                HStack (spacing: 4) {
                    Text(vm.formatPainLevel(vm.currentRecord?.painLevel))
                        .font(.displayTitle2Bold)

                    Text("(\(vm.painCategoryText))")
                        .font(.displayCaption1Regular)
                        .foregroundColor(.gray600)
                }
            }

            Spacer()
        }
        .frame(minHeight: 54)
    }

    /// 일러스트 영역
    var illustrationSection: some View {
        ZStack {
            Image(vm.flexionImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 320, height: 240)
            Text(vm.formatAngle(vm.currentRecord?.flexionAngle))
                .font(.displayCalloutBold)
                .offset(x: 70, y: -20)
        }
        .frame(height: 240)
    }

    /// 피드백 박스
    var feedbackBox: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(vm.cardTitle)
                .font(.displayTitle2Bold)
                .foregroundColor(.blue700)
            Text(vm.feedbackMessage)
                .font(.displayBodyRegular)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.blue100)
        .cornerRadius(12)
    }

}

#Preview("With Comparison") {
    // Preview용 임시 repository와 ViewModel 생성
    let container = try! ModelContainer(
        for: MeasuredRecord.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let repository = SwiftDataRecordRepository(
        modelContext: container.mainContext
    )
    let viewModel = MeasureViewModel(repository: repository)

    // 테스트용 오늘 레코드
    let todayRecord = MeasuredRecord()
    todayRecord.flexionAngle = 95
    todayRecord.painLevel = 4
    todayRecord.measuredDate = Date()
    viewModel.currentRecord = todayRecord

    // 테스트용 어제 레코드
    let yesterdayRecord = MeasuredRecord()
    yesterdayRecord.flexionAngle = 90
    yesterdayRecord.painLevel = 5
    yesterdayRecord.measuredDate = Calendar.current.date(
        byAdding: .day,
        value: -1,
        to: Date()
    )!
    viewModel.previousRecord = yesterdayRecord

    // 변화량 계산
    viewModel.calculateRecordChange()

    return NavigationStack {
        MainViewAfter()
            .environmentObject(viewModel)
    }
}

#Preview("First Record") {
    // Preview용 임시 repository와 ViewModel 생성
    let container = try! ModelContainer(
        for: MeasuredRecord.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let repository = SwiftDataRecordRepository(
        modelContext: container.mainContext
    )
    let viewModel = MeasureViewModel(repository: repository)

    // 테스트용 첫 번째 레코드 (비교 대상 없음)
    let todayRecord = MeasuredRecord()
    todayRecord.flexionAngle = 85
    todayRecord.painLevel = 6
    todayRecord.measuredDate = Date()
    viewModel.currentRecord = todayRecord

    return NavigationStack {
        MainViewAfter()
            .environmentObject(viewModel)
    }
}
