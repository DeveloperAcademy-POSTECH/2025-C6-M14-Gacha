//
//  History.swift
//  gacha
//
//  Created by 차원준 on 10/26/25.
//

import Charts
import SwiftData
import SwiftUI

struct History: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var vm: HistoryViewModel

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
                            Text(Strings.History.romTitle)
                                .font(.displayTitle3Bold)
                            
                            VStack(alignment: .leading) {

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(Strings.History.average)
                                            .font(.displayCaption1Semibold)
                                            .foregroundColor(Color("Gray500"))
                                        Text("\(vm.romAverage)°")
                                            .font(.displayTitle1Bold)
                                    }
                                Text(vm.dateRangeText)
                                    .font(.displayCaption1Semibold)
                                    .foregroundColor(Color("Gray500"))
                                romChart
                                    
                            }
                            .padding(16)
                            .background(Color("White"))
                            .cornerRadius(24)
                        }
                


                        // MARK: - 통증 수준 추이
                        VStack(alignment: .leading, spacing: 16) {
                            Text(Strings.History.painTitle)
                                .font(.displayTitle3Bold)
                            
                            VStack(alignment: .leading) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(vm.painLevelLabel)
                                        .font(.displayCaption1Semibold)
                                        .foregroundColor(Color("Gray500"))

                                    Text(vm.painLevelValue)
                                        .font(.displayTitle1Bold)
                                }
                                
                                Text(vm.dateRangeText)
                                    .font(.displayCaption1Semibold)
                                    .foregroundColor(Color("Gray500"))

                                painChart
                            }
                            .padding(16)
                            .background(Color("White"))
                            .cornerRadius(24)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                    .padding(.bottom, 20)
                }
                 
            }
        }
        .background(Color("BackgoundSecondary"))
        .navigationTitle(Strings.History.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await vm.loadRecentRecords()
        }
    }

    // MARK: - Chart Views

    private var romChart: some View {
        let data = vm.chartData
        let domain = vm.xAxisDomain
        let selectedIndex = vm.selectedROMIndex
        
        return Chart {
            ForEach(data, id: \.record.id) { item in
                BarMark(
                    x: .value("index", item.index),
                    y: .value("flexion", item.record.flexionAngle ?? 0),
                    width: .fixed(6)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color("Blue600"), Color("Blue400")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(4)
            }
            
            if let selectedIndex = selectedIndex,
               selectedIndex >= 0 && selectedIndex < data.count {
                RuleMark(x: .value("Selected", selectedIndex))
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
            AxisMarks(position: .bottom, values: vm.chartIndicesAsDouble) { value in
                if let doubleValue = value.as(Double.self) {
                    let index = Int(round(doubleValue))
                    // 정확한 인덱스 값인지 확인 (0.01 이내 오차 허용)
                    if abs(doubleValue - Double(index)) < 0.01,
                       index >= 0 && index < vm.recentRecords.count {
                        let record = vm.recentRecords[index]
                        let dateStr = vm.formatShortDate(record.measuredDate)
                        AxisValueLabel {
                            Text(dateStr)
                                .offset(x:-17)
                        }
                    } else {
                        AxisGridLine()
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
        .chartYScale(domain: 0...vm.romMaxValue)
        .chartXScale(domain: domain)
        .chartXSelection(value: $vm.selectedROMIndex)
        .frame(height: 361)
    }

    @ViewBuilder
    private var romAnnotation: some View {
        if let selectedIndex = vm.selectedROMIndex,
           selectedIndex >= 0 && selectedIndex < vm.recentRecords.count {
            let selectedRecord = vm.recentRecords[selectedIndex]
            VStack(alignment: .center, spacing: 4) {
                Text(Strings.Card.flexionAngle)
                    .font(.displayCaption1Semibold)
                    .foregroundStyle(Color("Gray700"))
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    

                Text("\(Int(selectedRecord.flexionAngle ?? 0))°")
                    .font(.displayTitle2Semibold)
                    .foregroundStyle(Color("Gray900"))
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                


                Text(vm.formatDate(selectedRecord.measuredDate))
                    .font(.displayCaption1Semibold)
                    .foregroundStyle(Color("Gray700"))
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .frame(width: 125, alignment: .center)
            .background(Color("Gray100"))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private var painChart: some View {
        let data = vm.chartData
        let domain = vm.xAxisDomain
        let selectedIndex = vm.selectedPainIndex
        
        return Chart {
            ForEach(data, id: \.record.id) { item in
                LineMark(
                    x: .value("index", item.index),
                    y: .value("pain", item.record.painLevel ?? 0)
                )
                .foregroundStyle(Color("GraphSecondary"))
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("index", item.index),
                    y: .value("pain", item.record.painLevel ?? 0)
                )
                .foregroundStyle(Color("GraphSecondary"))
                .symbolSize(60)
            }
            
            if let selectedIndex = selectedIndex,
               selectedIndex >= 0 && selectedIndex < data.count {
                RuleMark(x: .value("Selected", selectedIndex))
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
            AxisMarks(position: .bottom, values: vm.chartIndicesAsDouble) { value in
                if let doubleValue = value.as(Double.self) {
                    let index = Int(round(doubleValue))
                    // 정확한 인덱스 값인지 확인 (0.01 이내 오차 허용)
                    if abs(doubleValue - Double(index)) < 0.01,
                       index >= 0 && index < vm.recentRecords.count {
                        let record = vm.recentRecords[index]
                        let dateStr = vm.formatShortDate(record.measuredDate)
                        AxisValueLabel {
                            Text(dateStr)
                                .offset(x:-17)
                        }
                    } else {
                        AxisGridLine()
                    }
                }
            }
        }
        .chartYScale(domain: 0...vm.painMaxValue)
        .chartXScale(domain: domain)
        .chartXSelection(value: $vm.selectedPainIndex)
        .frame(height: 250)
    }

    @ViewBuilder
    private var painAnnotation: some View {
        if let selectedIndex = vm.selectedPainIndex,
           selectedIndex >= 0 && selectedIndex < vm.recentRecords.count {
            let selectedRecord = vm.recentRecords[selectedIndex]
            VStack(alignment: .leading, spacing: 4) {
                Text(Strings.Card.painLevel)
                    .font(.displayCaption1Semibold)
                    .foregroundStyle(Color("Gray700"))
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                Text("\(selectedRecord.painLevel ?? 0)")
                .font(.displayTitle2Semibold)
                    .foregroundStyle(Color("Gray900"))
                    .frame(maxWidth: .infinity, alignment: .topLeading)


                Text(vm.formatDate(selectedRecord.measuredDate))
                    .font(.displayCaption1Semibold)
                    .foregroundStyle(Color("Gray700"))
                    .frame(maxWidth: .infinity, alignment: .topLeading)

            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .frame(width: 120, alignment: .center)
            .background(Color("Gray100"))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}
