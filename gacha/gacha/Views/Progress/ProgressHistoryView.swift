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
                                .font(.system(size: 20, weight: .bold))
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("평균")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                    Text("\(vm.romAverage)°")
                                        .font(.system(size: 32, weight: .bold))
                                }
                                Spacer()
                            }

                            Text(vm.dateRangeText)
                                .font(.system(size: 12))
                                .foregroundColor(.gray)

                            romChart
                        }

                        // MARK: - 통증 수준 추이
                        VStack(alignment: .leading, spacing: 16) {
                            Text("통증 수준 추이")
                                .font(.system(size: 20, weight: .bold))

                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("최소~최대")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)

                                    Text("\(vm.painMin)~\(vm.painMax)")
                                        .font(.system(size: 32, weight: .bold))
                                }

                                Spacer()
                            }

                            Text(vm.dateRangeText)
                                .font(.system(size: 12))
                                .foregroundColor(.gray)

                            painChart
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                    .padding(.bottom, 20)
                }
                .background(Color.blue.opacity(0.2))

                // MARK: - Close Button

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.blue.opacity(0.5))
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
                    colors: [Color.blue.opacity(0.7), Color.blue],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(4)

            if let selectedROMDate = vm.selectedROMDate {
                RuleMark(x: .value("Selected", selectedROMDate, unit: .day))
                    .foregroundStyle(Color.gray.opacity(0.3))
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
                    .font(.system(size: 11, weight: .medium))

                HStack {
                    Text("\(Int(selectedRecord.flexionAngle ?? 0))° ~")
                        .font(.system(size: 24, weight: .semibold))

                    Text("\(Int(selectedRecord.extensionAngle))°")
                        .font(.system(size: 24, weight: .semibold))
                }
                Text(vm.formatDate(selectedRecord.measuredDate))
                    .font(.system(size: 11, weight: .semibold))
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
            .foregroundStyle(Color.purple)
            .interpolationMethod(.catmullRom)

            PointMark(
                x: .value("날짜", record.measuredDate, unit: .day),
                y: .value("통증", record.painLevel ?? 0)
            )
            .foregroundStyle(Color.purple)
            .symbolSize(60)

            if let selectedPainDate = vm.selectedPainDate {
                RuleMark(x: .value("Selected", selectedPainDate, unit: .day))
                    .foregroundStyle(Color.gray.opacity(0.3))
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
                    .font(.system(size: 12))

                Text(
                    "\(selectedRecord.painLevel ?? 0)"
                )
                .font(.system(size: 18, weight: .semibold))

                Text(vm.formatDate(selectedRecord.measuredDate))
                    .font(.system(size: 11, weight: .semibold))
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
