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
            if vm.isLoading {
                Text("Loading...")
            } else {

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
                    resultCardWithMeasurements

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
                                Text(Strings.Common.yes),
                                action: {
                                    vm.navigationPath.append(
                                        MeasureFlowStep.extensionMeasure
                                    )
                                }
                            ),
                            secondaryButton: .cancel(Text(Strings.Common.no))
                        )
                    }
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .top
                )
                .appBackground()

                .sheet(isPresented: $showHistorySheet) {
                    ProgressHistoryView()
                        .presentationDetents([.large])
                        .presentationDragIndicator(.hidden)
                }
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
    private var resultCardWithMeasurements: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(vm.cardTitle)
                .font(.title3)
                .fontWeight(.semibold)

            // 일러스트 영역 (모크 데이터 - 추후 이미지 에셋으로 교체 예정)
            HStack(spacing: 40) {
                VStack {
                    Image("ExtensionBody")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 115, height: 115)
                        .overlay(alignment: .topTrailing) {
                            Text(
                                vm.formatAngle(
                                    vm.currentRecord?.extensionAngle
                                )
                            )
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.top, 8)
                            .padding(.trailing, 8)
                        }
                }

                VStack(spacing: 8) {
                    Image("FlexionBody")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 115, height: 115)
                        .overlay(alignment: .topTrailing) {
                            Text(
                                vm.formatAngle(
                                    vm.currentRecord?.flexionAngle
                                )
                            )
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.top, 8)
                            .padding(.trailing, 8)
                        }
                }

            }
            .frame(maxWidth: .infinity, alignment: .center)

            VStack(alignment: .leading, spacing: 8) {
                Text(vm.feedbackMessage)
                    .font(.body)
            }

            // 측정값 그리드
            measurementGrid

        }
        .padding(24)
        .frame(width: 345, alignment: .topLeading)
        .background(.white)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 2)
    }

    private var measurementGrid: some View {
        HStack(spacing: 16) {
            // 좌측: 펴진 각도, 무릎 가동범위
            VStack(alignment: .leading, spacing: 16) {
                measurementItem(
                    title: Strings.Card.extensionAngle,
                    value: vm.formatAngle(vm.currentRecord?.extensionAngle),
                    changeValue: vm.hasComparison
                        ? Int(vm.changeResult?.extenRomDiff ?? 0) : 0,
                    isPositiveGood: false
                )

                measurementItem(
                    title: Strings.Card.kneeROM,
                    value: vm.formatAngle(vm.currentRecord?.ROM),
                    changeValue: vm.hasComparison
                        ? Int(vm.changeResult?.romDiff ?? 0) : 0,
                    isPositiveGood: true
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // 우측: 굽혀진 각도, 통증 수준
            VStack(alignment: .leading, spacing: 16) {
                measurementItem(
                    title: Strings.Card.flexionAngle,
                    value: vm.formatAngle(vm.currentRecord?.flexionAngle),
                    changeValue: vm.hasComparison
                        ? Int(vm.changeResult?.flexRomDiff ?? 0) : 0,
                    isPositiveGood: true
                )

                measurementItem(
                    title: Strings.Card.painLevel,
                    value: vm.formatPainLevel(vm.currentRecord?.painLevel),
                    changeValue: vm.hasComparison
                        ? (vm.changeResult?.painDiff ?? 0) : 0,
                    isPositiveGood: false
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func measurementItem(
        title: String,
        value: String,
        changeValue: Int,
        isPositiveGood: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                // 현재 값
                Text(value)
                    .font(.displayBodySemibold)

                // 변화 값
                if changeValue != 0 {
                    HStack(spacing: 2) {
                        Image(
                            systemName: changeValue > 0
                                ? "arrowtriangle.up.fill"
                                : changeValue < 0
                                    ? "arrowtriangle.down.fill" : "minus"
                        )
                        .font(.caption2)
                        Text("\(changeValue)°")
                            .font(.displayBodySemibold)
                    }
                    .foregroundStyle(
                        vm.changeColor(
                            for: changeValue,
                            isPositiveGood: isPositiveGood
                        )
                    )
                }
            }
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
