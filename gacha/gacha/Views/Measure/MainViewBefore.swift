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
            Spacer()

            // MARK: - 중앙 콘텐츠 영역
            VStack(spacing: 40) {
                // 안내 문구 영역
                if currentPage == 0 {
                    Image("before3")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 240, height: 240)
                    // 첫 번째 화면 안내 문구
                    PostureInstructionComponent(index: 1)
                } else {

                    Image("leg")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 240, height: 240)
                    // 두 번째 화면 안내 문구
                    PostureInstructionComponent(index: 2)
                }

                // MARK: - 버튼 영역 (92px height, 16px gap)
                VStack(spacing: 20) {
                    if currentPage == 0 {
                        // 첫 번째 화면: "다음" 버튼 (light style, 100px cornerRadius)
                        HStack(spacing: 20) {
                            CapsuleButtonComponent(
                                title: "뒤로",
                                style: .light,
                                width: (UIScreen.main.bounds.width - 60) / 2
                            ) {
                                vm.stopSensor()
                                vm.dismissMeasureFlow()
                            }
                            CapsuleButtonComponent(
                                title: Strings.Button.next,
                                style: .primary,
                                width: (UIScreen.main.bounds.width - 60) / 2
                            ) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentPage = 1
                                }
                            }
                        }
                    } else {
                        // 두 번째 화면: "측정하기" 버튼 (primary style, 100px cornerRadius)
                        HStack(spacing: 20) {
                            CapsuleButtonComponent(
                                title: "뒤로",
                                style: .light,
                                width: (UIScreen.main.bounds.width - 60) / 2
                            ) {
                                currentPage -= 1
                            }
                            CapsuleButtonComponent(
                                title: Strings.Button.next,
                                style: .primary,
                                width: (UIScreen.main.bounds.width - 60) / 2
                            ) {
                                vm.shouldAutoStartMeasure = true
                                vm.navigate(to: .countdown, from: .home)
                            }
                        }
                    }

                    // 보조 링크: "고통수치만 입력하기" (16px, 밑줄, Gray500)
                    Button(action: {
                        // 홈에서 직접 PainLevel로 이동
                        vm.navigate(to: .painLevel, from: .home)
                    }) {
                        Text(Strings.Button.painOnly)
                            .font(.displayBodyRegular)
                            .foregroundStyle(.gray500)
                            .underline()
                    }
                }
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle(Strings.DailyStart.title)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            // 화면이 나타날 때마다 첫 번째 화면으로 초기화
            currentPage = 0
        }
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
