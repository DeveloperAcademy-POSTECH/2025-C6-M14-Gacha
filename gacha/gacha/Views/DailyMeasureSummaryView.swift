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
    @State private var showHistorySheet = false

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // MARK: - 상단 영역
                VStack(alignment: .leading, spacing: 8) {
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

                    VStack(alignment: .leading, spacing: 8) {
                        Text(Strings.Summary.title)
                            .font(.displayLargeBold)
                        Text(Strings.Summary.description)
                            .font(.displayTitle3Medium)
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer()

                // MARK: - 중간 영역
                VStack(spacing: 16) {
                    VStack {
                        Text("원준띠니 코드 받아올 예정")
                    }
                    .padding(24)
                }
                .frame(maxWidth: .infinity)
                .background(.white)
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 2)
                .padding(.horizontal, 20)

                Spacer()

                CapsuleButtonComponent(
                    title: Strings.Summary.button,
                    style: .primary
                ) {
                    showingAlert = true
                }
                .alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text(Strings.Alert.Remeasure.title),
                        message: Text(Strings.Alert.Remeasure.message),
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
            .appBackground()

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
