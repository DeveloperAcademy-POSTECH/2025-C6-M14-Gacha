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
                        Text(Strings.DailyStart.title)
                            .font(.displayLargeBold)
                        Text(Strings.DailyStart.description)
                            .font(.displayTitle3Medium)
                    }
                }
                .padding(.horizontal, 16)

                Spacer()

                // MARK: - 중간 영역
                VStack(spacing: 16) {
                    VStack {
                        Image("extension_person")
                            .resizable()
                            .scaledToFit()
                            .tabViewStyle(.page(indexDisplayMode: .never))
                            .frame(width: 175, height: 175)
                        Text(Strings.DailyStart.instruction)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 32)
                }
                .frame(maxWidth: .infinity)
                .background(Color("White"))
                .cornerRadius(24)
                .shadow(color: Color("Gray300").opacity(0.15), radius: 2, x: 0, y: 2)
                .padding(.horizontal, 20)

                Spacer()
                
                // MARK: - 측정 버튼
                CapsuleButtonComponent(
                    title: Strings.DailyStart.button,
                    style: .primary
                ) {
                    vm.navigationPath.append(MeasureFlowStep.extensionMeasure)
                }
                .padding(.horizontal, 40)

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

    DailyMeasureStartView()
        .environmentObject(vm)
}
