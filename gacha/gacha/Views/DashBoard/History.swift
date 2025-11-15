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
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 32) {
                            // MARK: - Summary Cards
                            HStack(spacing: 14) {
                                // 무릎 굽힘 범위 카드
                                romSummaryCard(proxy: proxy)

                                // 통증 정도 카드
                                painSummaryCard(proxy: proxy)
                            }

                            // MARK: - 무릎 가동범위 추이
                            VStack(alignment: .leading, spacing: 16) {

                                VStack(alignment: .leading, spacing: 8) {
                                    // Title
                                    Text(Strings.History.chartRomTitle)
                                        .font(.displayTitle3Bold)
                                        .id("romChart")
                                    if vm.chartData.isEmpty {
                                        // 측정된 데이터가 없을 때
                                        Text(Strings.History.chartRomNoRecord)
                                            .frame(
                                                maxWidth: .infinity,
                                                alignment: .leading
                                            )
                                    } else {
                                        // SubTitle
                                        Text(vm.romSubtitle)

                                        romChart

                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(16)
                                .background(Color("White"))
                                .cornerRadius(24)
                            }

                            // MARK: - 통증 수준 추이
                            VStack(alignment: .leading, spacing: 16) {

                                VStack(alignment: .leading, spacing: 8) {
                                    // Title
                                    Text(Strings.History.chartPainTitle)
                                        .font(.displayTitle3Bold)
                                        .id("painChart")
                                    if vm.chartData.isEmpty {
                                        // 측정된 데이터가 없을 때
                                        Text(Strings.History.chartPainNoRecord)
                                            .frame(
                                                maxWidth: .infinity,
                                                alignment: .leading
                                            )
                                    } else {
                                        // SubTitle
                                        Text(vm.painSubtitle)

                                        painChart
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(16)
                                .background(Color("White"))
                                .cornerRadius(24)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 20)

                        // 크레딧
                        VStack(spacing: 4) {
                            Text("Team Anggle©")
                            Text("v2.0.1")
                        }
                        .padding(.vertical, 40)
                        .foregroundColor(.gray500)
                    }
                }

            }
        }
        .background(Color("BackgoundSecondary"))
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
                    width: .fixed(12)
                )
                .foregroundStyle(
                    Color("Blue500")
                )
                .cornerRadius(4)
            }

            if let selectedIndex = selectedIndex,
                selectedIndex >= 0 && selectedIndex < data.count
            {
                RuleMark(x: .value("Selected", selectedIndex))
                    .foregroundStyle(Color("Gray300"))
                    .zIndex(-1)
                    .annotation(
                        position: .top,
                        spacing: 8,
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
            AxisMarks(position: .bottom, values: vm.chartIndicesAsDouble) {
                value in
                if let doubleValue = value.as(Double.self) {
                    let index = Int(round(doubleValue))
                    // 정확한 인덱스 값인지 확인 (0.01 이내 오차 허용)
                    if abs(doubleValue - Double(index)) < 0.01,
                        index >= 0 && index < vm.recentRecords.count
                    {
                        let record = vm.recentRecords[index]
                        let dateStr = vm.formatShortDate(record.measuredDate)
                        AxisValueLabel {
                            Text(dateStr)
                                .offset(x: -17)
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
        .chartYScale(domain: 0...150)
        .chartXScale(domain: domain)
        .chartXSelection(value: $vm.selectedROMIndex)
        .frame(height: 361)
        .padding(.top, 20)
    }

    @ViewBuilder
    private var romAnnotation: some View {
        if let selectedIndex = vm.selectedROMIndex,
            selectedIndex >= 0 && selectedIndex < vm.recentRecords.count
        {
            let selectedRecord = vm.recentRecords[selectedIndex]
            VStack(alignment: .center, spacing: 4) {
                Text(Strings.History.chartRomTitle)
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
                .foregroundStyle(Color(.blue500))
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("index", item.index),
                    y: .value("pain", item.record.painLevel ?? 0)
                )
                .foregroundStyle(Color("Blue500"))
                .symbolSize(80)
            }

            if let selectedIndex = selectedIndex,
                selectedIndex >= 0 && selectedIndex < data.count
            {
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
            AxisMarks(position: .bottom, values: vm.chartIndicesAsDouble) {
                value in
                if let doubleValue = value.as(Double.self) {
                    let index = Int(round(doubleValue))
                    // 정확한 인덱스 값인지 확인 (0.01 이내 오차 허용)
                    if abs(doubleValue - Double(index)) < 0.01,
                        index >= 0 && index < vm.recentRecords.count
                    {
                        let record = vm.recentRecords[index]
                        let dateStr = vm.formatShortDate(record.measuredDate)
                        AxisValueLabel {
                            Text(dateStr)
                                .offset(x: -17)
                        }
                    } else {
                        AxisGridLine()
                    }
                }
            }
        }
        .chartYScale(domain: 0...10)
        .chartXScale(domain: domain)
        .chartXSelection(value: $vm.selectedPainIndex)
        .frame(height: 250)
        .padding(.top, 20)
    }

    @ViewBuilder
    private var painAnnotation: some View {
        if let selectedIndex = vm.selectedPainIndex,
            selectedIndex >= 0 && selectedIndex < vm.recentRecords.count
        {
            let selectedRecord = vm.recentRecords[selectedIndex]
            VStack(alignment: .leading, spacing: 4) {
                Text(Strings.History.chartPainTitle)
                    .font(.displayCaption1Semibold)
                    .foregroundStyle(Color("Gray700"))
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                Text(formatPainLevel(selectedRecord.painLevel))
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

    // MARK: - Summary Cards

    @ViewBuilder
    private func romSummaryCard(proxy: ScrollViewProxy) -> some View {
        VStack {
            VStack(alignment: .leading) {

                // 헤더
                HStack {
                    Text(Strings.History.romTitle)
                        .font(.displayBodyBold)
                        .foregroundColor(Color("Blue700"))
                    Spacer()
                    Button {
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color("Gray500"))
                    }
                }

                Spacer()

                // ROM 수치 표시
                HStack(spacing: 0) {
                    Spacer()
                    if vm.recentRecords.count < 2 {
                        Text("\(vm.recentRecords.count)일째")
                            .font(.displayTitle1Bold)
                    } else if let first = vm.firstROM, let latest = vm.latestROM
                    {
                        // 기록이 여러 개일 때
                        let change = latest - first
                        Text("\(change > 0 ? "+" : "")\(change)°")
                            .font(.roundedTitle1Bold)
                            .foregroundColor(Color("Gray900"))
                    }
                }

                Spacer()

                // 변화 설명 텍스트
                Text(
                    vm.recentRecords.count < 2
                        ? Strings.History.romUnder2Description
                        : vm.romChangeText
                )
                .font(
                    vm.recentRecords.count < 2
                        ? .displayFootnoteRegular : .displayCalloutRegular
                )
                .foregroundColor(Color("Gray700"))
                .lineLimit(3)

            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .frame(width: 173, height: 173)
        .background(Color.white)
        .cornerRadius(15)
        .onTapGesture {
            withAnimation {
                proxy.scrollTo("romChart", anchor: .top)
            }
        }
    }

    @ViewBuilder
    private func painSummaryCard(proxy: ScrollViewProxy) -> some View {
        VStack {
            VStack(alignment: .leading) {
                // 헤더
                HStack {
                    Text(Strings.History.painTitle)
                        .font(.displayBodyBold)
                        .foregroundColor(Color("Blue700"))
                    Spacer()
                    Button {
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color("Gray500"))
                    }
                }

                Spacer()

                // 통증 레벨 바 표시
                if vm.recentRecords.count < 2 {

                } else if let first = vm.firstPainLevel,
                    let latest = vm.latestPainLevel
                {
                    // 기록이 여러 개일 때
                    VStack(alignment: .leading, spacing: 0) {
                        // 첫 번째 통증 레벨
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(Color("Blue900"))
                                .frame(width: CGFloat(first) * 15, height: 3)
                                .cornerRadius(4)
                            Spacer()
                            Text("\(first)")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(Color("Gray900"))
                        }

                        // 최근 통증 레벨
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(Color("Blue700"))
                                .frame(width: CGFloat(latest) * 15, height: 3)
                                .cornerRadius(4)
                            Spacer()
                            Text("\(latest)")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(Color("Gray900"))
                        }
                    }

                }

                Spacer()

                // 변화 설명 텍스트
                Text(
                    vm.recentRecords.count < 2
                        ? Strings.History.painNoRecord
                        : vm.painChangeText
                )
                .font(
                    vm.recentRecords.count < 2
                        ? .displayFootnoteRegular : .displayCalloutRegular
                )
                .foregroundColor(Color("Gray700"))
                .lineLimit(3)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .frame(width: 173, height: 173)
        .background(Color.white)
        .cornerRadius(15)
        .onTapGesture {
            withAnimation {
                proxy.scrollTo("painChart", anchor: .top)
            }
        }
    }

    // MARK: - Helper Methods
    private func formatPainLevel(_ level: Int?) -> String {
        guard let level = level else { return "-" }
        return "\(level)"
    }
}

// MARK: - Previews

struct HistoryPreviewWrapper: View {
    @StateObject private var vm: HistoryViewModel

    init(scenario: MockRecordRepository.Scenario) {
        _vm = StateObject(
            wrappedValue: HistoryViewModel(
                repository: MockRecordRepository(scenario: scenario)
            )
        )
    }

    var body: some View {
        NavigationStack {
            History()
                .environmentObject(vm)
                .task {
                    await vm.loadRecentRecords()
                }
        }
    }
}

#Preview("No Record") {
    HistoryPreviewWrapper(scenario: .noRecord)
}

#Preview("Single Record") {
    HistoryPreviewWrapper(scenario: .singleRecord)
}

#Preview("Positive Progress (67° → 97°)") {
    HistoryPreviewWrapper(scenario: .multipleRecordsPositive)
}

#Preview("Negative Progress") {
    HistoryPreviewWrapper(scenario: .multipleRecordsNegative)
}

#Preview("23 Days - 7 Records") {
    HistoryPreviewWrapper(scenario: .sevenRecords23Days)
}

#Preview("No Change") {
    HistoryPreviewWrapper(scenario: .noChange)
}
