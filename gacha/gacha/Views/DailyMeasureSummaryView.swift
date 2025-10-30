//
//  SecondDailyMeasureStartView.swift
//  gacha
//
//  Created by 차원준 on 10/28/25.
//

import SwiftData
import SwiftUI

struct DailyMeasureSummaryView: View {
    @EnvironmentObject var vm: MeasureViewModel

    @State private var showingAlert = false
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
                    Text("다시 측정할 경우 기존 기록은 정리됩니다.")
                        .font(.roundedTitle3Medium)
                }
                .padding(.horizontal, 20)
                .frame(height: geo.size.height * 0.25)

                // 중간 영역 (캐러셀 + 인디케이터)
                VStack(spacing: 10) {
                    Rectangle()
                        .fill(Color("White"))
                }
                .frame(height: geo.size.height * 0.45)

                Spacer()

                CapsuleButtonComponent(
                    title: "다시 측정하기",
                    style: .primary
                ) {
                    showingAlert = true
                }
                .alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text("다시 측정하시겠습니까?\n오늘 측정한 기록은 삭제됩니다."),
                        message: nil,
                        primaryButton: .destructive(
                            Text("네"),
                            action: {
                                vm.navigationPath.append(
                                    MeasureFlowStep.extensionMeasure
                                )
                            }
                        ),
                        secondaryButton: .cancel(Text("아니요"))
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color("BackgroundBase"))

            .sheet(isPresented: $showHistorySheet) {
                ProgressHistoryView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.hidden)
            }
        }
        .onAppear {
            vm.clearCurrentRecord()
        }
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

    return DailyMeasureSummaryView()
        .environmentObject(viewModel)
}
