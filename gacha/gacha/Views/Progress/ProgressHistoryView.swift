//
//  ProgressHistoryView.swift
//  gacha
//
//  Created by 차원준 on 10/26/25.
//

import Charts
import SwiftData
import SwiftUI

struct ProgressHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var vm: ProgressHistoryViewModel

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if vm.isLoading {
                Text("Loading...")
            } else {
                ScrollView {
                    VStack(spacing: 32) {

                        // MARK: - 무릎 가동범위 추이
                        VStack(alignment: .leading, spacing: 16) {
                            Text("무릎 가동범위 추이")
                                .font(.displayTitle3Bold)
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("평균")
                                        .font(.displayCaption1Semibold)
                                        .foregroundColor(Color("Gray500"))
                                    Text("\(vm.romAverage)°")
                                        .font(.displayTitle1Bold)
                                }
                                Spacer()
                            }

                            Text(vm.dateRangeText)
                                .font(.displayCaption1Semibold)
                                .foregroundColor(Color("Gray500"))

                            romChart
                        }

                        // MARK: - 통증 수준 추이
                        VStack(alignment: .leading, spacing: 16) {
                            Text("통증 수준 추이")
                                .font(.displayTitle3Bold)

                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("최소~최대")
                                        .font(.displayCaption1Semibold)
                                        .foregroundColor(Color("Gray500"))

                                    Text("\(vm.painMin)~\(vm.painMax)")
                                        .font(.displayTitle1Bold)
                                }

                                Spacer()
                            }

                            Text(vm.dateRangeText)
                                .font(.displayCaption1Semibold)
                                .foregroundColor(Color("Gray500"))

                            painChart
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                    .padding(.bottom, 20)
                }
                .background(Color("BackgroundBase"))

                // MARK: - Close Button

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.displayTitle2Bold)
                        .foregroundColor(Color("White"))
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color("Primary500"))
                        )
                }
                .padding(.top, 8)
                .padding(.trailing, 16)
            }
        }
        .navigationTitle("기록")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await vm.loadRecentRecords()
        }
    }

    // MARK: - Chart Views

    private var romChart: some View {
        Chart(vm.recentRecords) { record in
            BarMark(
                x: .value("날짜", record.measuredDate, unit: .day),
                yStart: .value("최소", record.flexionAngle ?? 0),
                yEnd: .value("최대", record.extensionAngle),
                width: .fixed(6)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [Color("Primary300"), Color("Primary500")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(4)

            if let selectedROMDate = vm.selectedROMDate {
                RuleMark(x: .value("Selected", selectedROMDate, unit: .day))
                    .foregroundStyle(Color("Gray300"))
                    .zIndex(-1)
                    .annotation(
                        position: .top,
                        spacing: 0,
                        overflowResolution: .init(
                            x: .fit(to: .chart),
                            y: .disabled
                        )
                    ) {
                        romAnnotation
                    }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                if let date = value.as(Date.self) {
                    AxisValueLabel {
                        Text(vm.formatShortDate(date))
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let angle = value.as(Double.self) {
                        Text("\(Int(angle))")
                    }
                }
                AxisGridLine()
            }
        }
        .chartYScale(domain: 0...190)
        .chartXSelection(value: $vm.selectedROMDate)
        .frame(height: 250)
    }

    @ViewBuilder
    private var romAnnotation: some View {
        if let selectedROMDate = vm.selectedROMDate,
            let selectedRecord = vm.recentRecords.first(where: {
                Calendar.current.isDate(
                    $0.measuredDate,
                    inSameDayAs: selectedROMDate
                )
            })
        {
            VStack(alignment: .leading) {
                Text("무릎 가동범위")
                    .font(.displayCaption1Semibold)

                HStack {
                    Text("\(Int(selectedRecord.flexionAngle ?? 0))° ~")
                        .font(.displayTitle2Semibold)

                    Text("\(Int(selectedRecord.extensionAngle))°")
                        .font(.displayTitle2Semibold)
                }
                Text(vm.formatDate(selectedRecord.measuredDate))
                    .font(.displayCaption1Semibold)
            }
            .padding(12)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private var painChart: some View {
        Chart(vm.recentRecords) { record in
            LineMark(
                x: .value("날짜", record.measuredDate, unit: .day),
                y: .value("통증", record.painLevel ?? 0)
            )
            .foregroundStyle(Color("GraphSecondary"))
            .interpolationMethod(.catmullRom)

            PointMark(
                x: .value("날짜", record.measuredDate, unit: .day),
                y: .value("통증", record.painLevel ?? 0)
            )
            .foregroundStyle(Color("GraphSecondary"))
            .symbolSize(60)

            if let selectedPainDate = vm.selectedPainDate {
                RuleMark(x: .value("Selected", selectedPainDate, unit: .day))
                    .foregroundStyle(Color("Gray300"))
                    .zIndex(-1)
                    .annotation(
                        position: .top,
                        spacing: 0,
                        overflowResolution: .init(
                            x: .fit(to: .chart),
                            y: .disabled
                        )
                    ) {
                        painAnnotation
                    }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                if let date = value.as(Date.self) {
                    AxisValueLabel {
                        Text(vm.formatShortDate(date))
                    }
                }
            }
        }
        .chartYScale(domain: 0...10)
        .chartXSelection(value: $vm.selectedPainDate)
        .frame(height: 250)
    }

    @ViewBuilder
    private var painAnnotation: some View {
        if let selectedPainDate = vm.selectedPainDate,
            let selectedRecord = vm.recentRecords.first(where: {
                Calendar.current.isDate(
                    $0.measuredDate,
                    inSameDayAs: selectedPainDate
                )
            })
        {
            VStack(alignment: .leading, spacing: 4) {
                Text("통증 수준(VAS)")
                    .font(.displayCaption1Semibold)

                Text(
                    "\(selectedRecord.painLevel ?? 0)"
                )
                .font(.displayHeadlineSemibold)

                Text(vm.formatDate(selectedRecord.measuredDate))
                    .font(.displayCaption1Semibold)
            }
            .padding(12)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8))
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
    let vm = ProgressHistoryViewModel(repository: repository)

    ProgressHistoryView()
        .environmentObject(vm)
}
