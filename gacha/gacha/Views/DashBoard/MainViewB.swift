//
//  MainViewB.swift
//  gacha
//
//  Created by 차원준 on 10/28/25.
//

import SwiftData
import SwiftUI

struct MainViewB: View {
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
                        Text(Strings.Summary.title)
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
                    
                    // MARK: - 하단 버튼 영역 (MainViewA와 동일한 구조)
                    VStack(spacing: 16) {
                        CapsuleButtonComponent(
                            title: Strings.Summary.button,
                            style: .primary,
                            width: 361,
                            height: 54,
                            fontSize: 20,
                            cornerRadius: 100
                        ) {
                            showingAlert = true
                        }
                        .alert(isPresented: $showingAlert) {
                            Alert(
                                title: Text(Strings.Alert.Remeasure.title),
                                message: Text(Strings.Alert.Remeasure.message),
                                primaryButton: .destructive(
                                    Text(Strings.Common.yes),
                                    action: {
                                        vm.prepareForNewMeasurement()  // 새 측정 준비
                                        vm.shouldAutoStartMeasure = true  // 자동 시작 플래그
                                        vm.navigationPath.append(
                                            MeasureFlowStep.flexionMeasure
                                        )
                                    }
                                ),
                                secondaryButton: .cancel(Text(Strings.Common.no))
                            )
                        }
                    }
                    .frame(height: 92)  // MainViewA와 동일한 버튼 영역 높이
                    .padding(.bottom, 34)  // MainViewA와 동일한 하단 패딩
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
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
                .padding(.top, 24)
                .padding(.horizontal, 20)
            
            // 2. 일러스트 영역 (240px)
            illustrationSection
                .padding(.top, 22)
                .padding(.horizontal, 20)
            
            // 3. 피드백 박스 (auto)
            feedbackBox
                .padding(.horizontal, 10)  // 주의: 10px!
                .padding(.top, 6)
                .padding(.bottom, 24)  // 하단 여백 추가
        }
        .frame(width: 361)  // 너비만 고정, 높이는 내용에 맞게 자동 조정
        .background(Color("White"))
        .cornerRadius(15)
    }
    
    /// 통계 섹션
    private var statisticsSection: some View {
        HStack(spacing: 16) {
            // TODO: 통계 데이터 표시
            VStack(alignment: .leading, spacing: 4) {
                Text("굴곡 각도")
                    .font(.caption)
                    .foregroundColor(Color("Gray700"))
                Text(vm.formatAngle(vm.currentRecord?.flexionAngle))
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 4) {
                Text("통증 레벨")
                    .font(.caption)
                    .foregroundColor(Color("Gray700"))
                Text("\(vm.currentRecord?.painLevel ?? 0)")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Spacer()
        }
        .frame(height: 54)
    }
    
    /// 일러스트 영역
    private var illustrationSection: some View {
        VStack(spacing: 8) {
            Image(vm.flexionImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 240, height: 240)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: vm.flexionImageName)
        }
        .frame(height: 240)
    }
    
    /// 피드백 박스
    private var feedbackBox: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(vm.feedbackMessage)
                .font(.displayBodyMedium)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color("Gray100"))
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

    return MainViewB()
        .environmentObject(viewModel)
}

