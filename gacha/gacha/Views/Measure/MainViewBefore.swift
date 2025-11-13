//
//  MainViewBefore.swift
//  gacha
//
//  Created by 차원준 on 10/28/25.
//

import SwiftData
import SwiftUI

struct MainViewBefore: View {
    @EnvironmentObject var vm: MeasureViewModel
    
    @State private var currentPage = 0  // 0: 첫 화면, 1: 두 번째 화면

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Navigation Bar
            HStack {
                Text(Strings.DailyStart.title)
                    .font(.displayLargeBold)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 54)
            
            Spacer()
            
            // MARK: - 중앙 콘텐츠 영역
            VStack(spacing: 40) {
                // 안내 문구 영역
                if currentPage == 0 {
                    Image("before1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                    // 첫 번째 화면 안내 문구
                    instructionTextPage1
                } else {
                    
                    Image("before2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                    // 두 번째 화면 안내 문구
                    instructionTextPage2
                }
            }
            .frame(width: 361)
            .frame(maxWidth: .infinity)
            
            Spacer()
            
            // MARK: - 버튼 영역 (92px height, 16px gap)
            VStack(spacing: 16) {
                // "측정하러 가기" 버튼 (primary style, 100px cornerRadius)
                CapsuleButtonComponent(
                    title: Strings.Button.measure,
                    style: .primary,
                    width: 361,
                    height: 54,
                    cornerRadius: 100
                ) {
                    vm.shouldAutoStartMeasure = true
                    // 홈에서 FlexionMeasure로 이동하는 경우 소스 기록
                    vm.navigate(to: MeasureFlowStep.flexionMeasure, from: NavigationSource.home)
                }

                // 보조 링크: "통증 수치만 입력하기" (16px, 밑줄, Gray500)
                Button(action: {
                    // 홈에서 직접 PainLevel로 이동하는 경우 소스 기록
                    vm.navigate(to: MeasureFlowStep.painLevel, from: NavigationSource.home)
                }) {
                    Text(Strings.Button.painOnly)
                        .font(.displayBodyRegular)
                        .foregroundStyle(.gray500)
                        .underline()
                }
            }
            .frame(height: 92)  // 버튼 영역 높이: 92px
            .padding(.bottom, 34)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            vm.startSensor()
            // 화면이 나타날 때마다 첫 번째 화면으로 초기화
            currentPage = 0
        }
    }
    
    // MARK: - Instruction Text Views

    private var instructionTextPage1: some View {
        VStack(spacing: 8) {
            Text(Strings.DailyStart.instructionNo1Emphasis)
                .font(.displayTitle3Regular)
            Text(Strings.DailyStart.instructionNo2)
                .font(.displayTitle3Regular)
            Text(Strings.DailyStart.instructionNo3)
                .font(.displayTitle3Regular)
        }
        .multilineTextAlignment(.center)
    }

    private var instructionTextPage2: some View {
        VStack(spacing: 8) {
            Text(Strings.DailyStart.instructionNo1Emphasis)
                .font(.displayTitle3Regular)
            Text(Strings.DailyStart.instructionNo2)
                .font(.displayTitle3Regular)
            Text(Strings.DailyStart.instructionNo3)
                .font(.displayTitle3Regular)
        }
        .multilineTextAlignment(.center)
    }
}

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

    MainViewBefore()
        .environmentObject(vm)
}


