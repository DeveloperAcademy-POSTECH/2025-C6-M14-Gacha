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
                    Image("Before1")
                        .frame(width: 300, height: 300)
                    // 첫 번째 화면 안내 문구
                    instructionTextPage1
                } else {
                    
                    Image("Before2")
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
                if currentPage == 0 {
                    // 첫 번째 화면: "다음" 버튼 (light style, 100px cornerRadius)
                    CapsuleButtonComponent(
                        title: Strings.DailyStart.buttonNext,
                        style: .light,
                        width: 361,
                        height: 54,
                        fontSize: 20,
                        cornerRadius: 100
                    ) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage = 1
                        }
                    }
                } else {
                    // 두 번째 화면: "측정하기" 버튼 (primary style, 100px cornerRadius)
                    CapsuleButtonComponent(
                        title: Strings.DailyStart.buttonMeasure,
                        style: .primary,
                        width: 361,
                        height: 54,
                        fontSize: 20,
                        cornerRadius: 100
                    ) {
                        vm.shouldAutoStartMeasure = true
                        vm.navigationPath.append(MeasureFlowStep.flexionMeasure)
                    }
                }
                
                // 보조 링크: "고통수치만 입력하기" (16px, 밑줄, Gray500)
                Button(action: {
                    vm.navigationPath.append(MeasureFlowStep.painLevel)
                }) {
                    Text(Strings.DailyStart.buttonPainOnly)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(Color("Gray500"))
                        .underline()
                }
            }
            .frame(height: 92)  // 버튼 영역 높이: 92px
            .padding(.bottom, 34)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
         
    }
    
    // MARK: - Instruction Text Views
    
    private var instructionTextPage1: some View {
        Group {
            Text("벽에 등을 대고, ")
                .font(.displayTitle3Regular)
                .foregroundStyle(Color("Primary900"))  // 강조 색상
            + Text("평평한 곳")
                .font(.displayTitle3Regular)
                .foregroundStyle(Color("Primary900"))  // 강조 색상
            + Text("에 앉아주세요")
                .font(.displayTitle3Regular)
                .foregroundStyle(Color("Gray900"))
        }
        .multilineTextAlignment(.center)
        .frame(height: 56)
    }
    
    private var instructionTextPage2: some View {
        Group {
            Text("최대한 다리를 굽히고,")
                .font(.displayTitle3Regular)
                .foregroundStyle(Color("Primary500"))  // 강조 색상
            + Text("\n2초동안 ")
                .font(.displayTitle3Regular)
                .foregroundStyle(Color("Gray900"))
            + Text("자세를 유지")
                .font(.displayTitle3Regular)
                .foregroundStyle(Color("Primary500"))  // 강조 색상
            + Text("해주세요!")
                .font(.displayTitle3Regular)
                .foregroundStyle(Color("Gray900"))
        }
        .multilineTextAlignment(.center)
        .frame(height: 56)
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


