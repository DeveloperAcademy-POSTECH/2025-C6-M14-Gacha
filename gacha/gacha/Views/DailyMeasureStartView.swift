//
//  DailyMeasureStartView.swift
//  gacha
//
//  Created by 차원준 on 10/28/25.
//

import SwiftData
import SwiftUI

struct DailyMeasureStartView: View {
    @EnvironmentObject var vm: MeasureViewModel

    @State private var selection = 0
    @State private var showHistorySheet = false
    let items = ["ExtensionLeg", "HoldGesture"]  // 임시 데이터

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // 상단 영역
                VStack(alignment: .leading, spacing: 9) {
                    HStack {
                        Spacer()

                        ButtonComponent(
                            background: Color("Primary300"),
                            systemImageName: "chart.xyaxis.line",
                            weight: .semibold,
                            color: Color("White")
                        ) {
                            showHistorySheet = true
                        }

                    }

                    Text("오늘의 측정")
                        .font(.displayLargeBold)
                    Text("일일 기록을 측정합니다.")
                        .font(.roundedTitle3Medium)
                }
                .padding(.horizontal, 20)
                .frame(height: geo.size.height * 0.25)

                // 중간 영역 (캐러셀 + 인디케이터)
                VStack(spacing: 10) {
                    TabView(selection: $selection) {
                        ForEach(Array(items.enumerated()), id: \.offset) {
                            index,
                            imageName in
                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 353, height: 300)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: 280)
                }
                .frame(height: geo.size.height * 0.45)

                Spacer()
                
                CapsuleButtonComponent(
                    title: "측정시작하기",
                    style: .primary
                ) {
                    vm.navigationPath.append(MeasureFlowStep.extensionMeasure)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .appBackground()

            .sheet(isPresented: $showHistorySheet) {
                ProgressHistoryView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.hidden)
            }
        }
    }
}
//
//#Preview {
//    // 1. 메모리 전용 ModelContainer 생성
//    let container = try! ModelContainer(
//        for: MeasuredRecord.self,
//        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
//    )
//
//    // 2. Repository 생성
//    let repository = SwiftDataRecordRepository(
//        modelContext: container.mainContext
//    )
//
//    // 3. ViewModel 생성
//    let vm = MeasureViewModel(repository: repository)
//
//    DailyMeasureStartView()
//        .environmentObject(vm)
//}
