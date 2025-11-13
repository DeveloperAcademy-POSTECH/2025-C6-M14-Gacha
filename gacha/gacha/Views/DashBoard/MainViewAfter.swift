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
                    // MARK: - 상단 영역
                    HStack {
                        Text(Strings.Progress.title)
                            .font(.displayLargeBold)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 54)
                    
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
                            fontSize: 20,
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
                                        print("🔴 [MainViewAfter Alert] 다시 측정하기 버튼 클릭")

                                        Task {
                                            vm.isRemeasuring = true  // 재측정 플래그 설정
                                            vm.prepareForNewMeasurement()  // 새 측정 준비
                                            vm.clearCurrentRecord()  // 현재 레코드 클리어

                                            print("🔴 [MainViewAfter Alert] deleteTodayRecords 호출")
                                            await vm.deleteTodayRecords()  // 오늘 기록 삭제

                                            print("🔴 [MainViewAfter Alert] checkTodayRecord 호출")
                                            await vm.checkTodayRecord()    // 상태 업데이트 (hasTodayRecord = false)

                                            print("🔴 [MainViewAfter Alert] hasTodayRecord = \(vm.hasTodayRecord)")
                                            print("🔴 [MainViewAfter Alert] navigationPath 초기화")

                                            // 네비게이션 스택 초기화 (홈으로 이동)
                                            vm.navigationPath = NavigationPath()
                                            vm.isRemeasuring = false  // 플래그 해제
                                        }
                                    }
                                ),
                                secondaryButton: .cancel(Text(Strings.Common.no))
                            )
                        }
                    }
                    .frame(height: 92)  // MainViewBefore와 동일한 버튼 영역 높이
                    .padding(.bottom, 34)  // MainViewBefore와 동일한 하단 패딩
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle(Strings.Progress.titleLarge)
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
    private var statisticsSection: some View {
        HStack(spacing: 16) {
            // TODO: 통계 데이터 표시
            VStack(alignment: .leading, spacing: 4) {
                Text(Strings.Progress.flexionAngle)
                    .font(.displayCalloutBold)
                    .foregroundColor(.blue700)
                Text(vm.formatAngle(vm.currentRecord?.flexionAngle))
                    .font(.displayTitle2Bold)
            }

            Spacer()

            VStack(alignment: .leading, spacing: 4) {
                Text(Strings.Progress.painLevel)
                    .font(.displayCalloutBold)
                    .foregroundColor(.blue700)
                Text(vm.formatPainLevel(vm.currentRecord?.painLevel))
                    .font(.displayTitle2Bold)
            }

            Spacer()
        }
        .frame(height: 54)
    }

    /// 일러스트 영역
    private var illustrationSection: some View {
        ZStack {
            Image(vm.flexionImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 320, height: 240)
            Text(vm.formatAngle(vm.currentRecord?.flexionAngle))
                .font(.displayCalloutBold)
                .offset(x: 70, y:-20)
        }
        .frame(height: 240)
    }

    /// 피드백 박스
    private var feedbackBox: some View {
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

#Preview {
    // Preview용 임시 repository와 ViewModel 생성
    let container = try! ModelContainer(
        for: MeasuredRecord.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let repository = SwiftDataRecordRepository(
        modelContext: container.mainContext
    )
    let viewModel = MeasureViewModel(repository: repository)

    return MainViewAfter()
        .environmentObject(viewModel)
}

