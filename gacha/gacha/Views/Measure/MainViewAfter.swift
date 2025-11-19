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
                    VStack (spacing: 20){
                        CapsuleButtonComponent(
                            title: Strings.Button.summary,
                            style: .primary,
                            width: UIScreen.main.bounds.width - 40
                        ) {
                            vm.dismissMeasureFlow(navigateToTab: 2)
                        }
                        CapsuleButtonComponent(
                            title: Strings.Button.calendar,
                            style: .secondary,
                            width: UIScreen.main.bounds.width - 40
                        ) {
                            vm.dismissMeasureFlow(navigateToTab: 0)
                        }
                    }
                    .padding(.bottom, 40)


                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            // 프리뷰에서는 이미 데이터가 설정되어 있으므로 로드 건너뛰기
            if vm.currentRecord == nil {
                Task {
                    await vm.loadTodayRecord()
                    await vm.loadYesterdayRecord()
                    vm.calculateRecordChange()
                }
            }
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

    /// 통계 섹션 (2x2 배열)
    var statisticsSection: some View {
        VStack(spacing: 12) {
            // 첫 번째 행: 신전 - 굴곡
            HStack(spacing: 12) {
                // 신전
                MainResultCell(
                    title: "신전",
                    value: vm.currentRecord?.extensionAngle.map { Int($0) },
                    showDegree: true
                )

                // 굴곡
                MainResultCell(
                    title: "굴곡",
                    value: vm.currentRecord?.flexionAngle.map { Int($0) },
                    showDegree: true,
                    trendText: vm.angleTrendText
                )
            }

            // 두 번째 행: ROM - 고통
            HStack(spacing: 12) {
                // ROM
                MainResultCell(
                    title: "ROM",
                    value: vm.currentRecord?.ROM.map { Int($0) },
                    showDegree: true
                )

                // 고통
                MainResultCell(
                    title: "고통",
                    value: vm.currentRecord?.painLevel,
                    showDegree: false,
                    subtitle: vm.painCategoryText
                )
            }
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

// MARK: - 메인 결과 셀 컴포넌트
struct MainResultCell: View {
    let title: String
    let value: Int?
    var showDegree: Bool = true
    var trendText: String? = nil
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.displayCalloutBold)
                .foregroundColor(.blue700)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                if let value = value {
                    Text(showDegree ? "\(value)°" : "\(value)")
                        .font(.displayTitle2Bold)
                } else {
                    Text(showDegree ? "--°" : "--")
                        .font(.displayTitle2Bold)
                }

                // 변화량 텍스트 (굴곡에만 표시)
                if let trendText = trendText {
                    Text(trendText)
                        .font(.displayCaption1Regular)
                        .foregroundColor(.blue700)
                }

                // 서브타이틀 (고통 레벨에만 표시)
                if let subtitle = subtitle {
                    Text("(\(subtitle))")
                        .font(.displayCaption1Regular)
                        .foregroundColor(.gray600)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color("Blue50"))
        .cornerRadius(8)
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
    todayRecord.extensionAngle = 5
    todayRecord.flexionAngle = 95
    todayRecord.painLevel = 4
    todayRecord.measuredDate = Date()
    viewModel.currentRecord = todayRecord

    // 테스트용 어제 레코드
    let yesterdayRecord = MeasuredRecord()
    yesterdayRecord.extensionAngle = 8
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

    // 로딩 상태 해제
    viewModel.isLoading = false

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
    todayRecord.extensionAngle = 10
    todayRecord.flexionAngle = 85
    todayRecord.painLevel = 6
    todayRecord.measuredDate = Date()
    viewModel.currentRecord = todayRecord

    // 변화량 계산
    viewModel.calculateRecordChange()

    // 로딩 상태 해제
    viewModel.isLoading = false

    return NavigationStack {
        MainViewAfter()
            .environmentObject(viewModel)
    }
}
