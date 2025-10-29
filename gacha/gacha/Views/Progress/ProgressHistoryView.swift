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
    var body: some View {
        VStack {
            Text("ProgressHistoryView")
        }
    }
}

//struct ProgressHistoryView: View {
//    @Query(
//        sort: \MeasuredRecord.measuredDate,
//        order: .reverse
//    )
//    private var allRecords: [MeasuredRecord]
//    
//    @Environment(\.dismiss) private var dismiss
//    
//    // MARK: - Selection States
//    
//    @State private var selectedROMDate: Date? = nil
//    @State private var selectedPainDate: Date? = nil
//    
//    // MARK: - Computed Properties
//    
//    private var recentRecords: [MeasuredRecord] {
//        Array(allRecords.prefix(7)).reversed()
//    }
//    
//    private var romAverage: Int {
//        guard !recentRecords.isEmpty else { return 0 }
//        let sum = recentRecords.map { Int($0.ROM) }.reduce(0, +)
//        return sum / recentRecords.count
//    }
//
//    private var painMin: Int {
//        guard let min = recentRecords.compactMap({ $0.painLevel }).min() else { return 0 }
//        return min
//    }
//
//    private var painMax: Int {
//        guard let max = recentRecords.compactMap({ $0.painLevel }).max() else { return 0 }
//        return max
//    }
//    
//    private var dateRangeText: String {
//        guard let startDate = recentRecords.first?.measuredDate,
//              let endDate = recentRecords.last?.measuredDate else {
//            return ""
//        }
//        
//        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "ko_KR")
//        formatter.dateFormat = "yyyy년 M월 d일"
//        
//        let start = formatter.string(from: startDate)
//        formatter.dateFormat = "d일"
//        let end = formatter.string(from: endDate)
//        
//        return "\(start)~\(end)"
//    }
//    
//    // MARK: - Helper Methods
//    
//    private func formatDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy. M. d"
//        return formatter.string(from: date)
//    }
//    
//    private func formatShortDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "M.d"
//        return formatter.string(from: date)
//    }
//    
//    // MARK: - Chart Views
//
//    private var romChart: some View {
//        Chart(recentRecords) { record in
//            BarMark(
//                x: .value("날짜", record.measuredDate, unit: .day),
//                yStart: .value("최소", record.flexionAngle),
//                yEnd: .value("최대", record.extensionAngle),
//                width: .fixed(6)
//            )
//            .foregroundStyle(
//                LinearGradient(
//                    colors: [Color.blue.opacity(0.7), Color.blue],
//                    startPoint: .top,
//                    endPoint: .bottom
//                )
//            )
//            .cornerRadius(4)
//
//            if let selectedROMDate {
//                RuleMark(x: .value("Selected", selectedROMDate, unit: .day))
//                    .foregroundStyle(Color.gray.opacity(0.3))
//                    .zIndex(-1)
//                    .annotation(
//                        position: .top,
//                        spacing: 0,
//                        overflowResolution: .init(x: .fit(to: .chart), y: .disabled)
//                    ) {
//                        romAnnotation
//                    }
//            }
//        }
//        .chartXAxis {
//            AxisMarks(values: .stride(by: .day)) { value in
//                if let date = value.as(Date.self) {
//                    AxisValueLabel {
//                        Text(formatShortDate(date))
//                    }
//                }
//            }
//        }
//        .chartYAxis {
//            AxisMarks { value in
//                AxisValueLabel {
//                    if let angle = value.as(Double.self) {
//                        Text("\(Int(angle))")
//                    }
//                }
//                AxisGridLine()
//            }
//        }
//        .chartYScale(domain: 0...190)
//        .chartXSelection(value: $selectedROMDate)
//        .frame(height: 250)
//    }
//
//    @ViewBuilder
//    private var romAnnotation: some View {
//        if let selectedROMDate,
//           let selectedRecord = recentRecords.first(where: {
//               Calendar.current.isDate($0.measuredDate, inSameDayAs: selectedROMDate)
//           }) {
//            VStack(alignment: .leading) {
//                Text("무릎 가동범위")
//                    .font(.system(size: 11, weight: .medium))
//
//                HStack {
//                    Text("\(Int(selectedRecord.flexionAngle))° ~")
//                        .font(.system(size: 24, weight: .semibold))
//
//                    Text("\(Int(selectedRecord.extensionAngle))°")
//                        .font(.system(size: 24, weight: .semibold))
//                }
//                Text(formatDate(selectedRecord.measuredDate))
//                    .font(.system(size: 11, weight: .semibold))
//            }
//            .padding(12)
//            .background(.thinMaterial)
//            .clipShape(RoundedRectangle(cornerRadius: 8))
//        }
//    }
//
//    private var painChart: some View {
//        Chart(recentRecords) { record in
//            LineMark(
//                x: .value("날짜", record.measuredDate, unit: .day),
//                y: .value("통증", record.painLevel)
//            )
//            .foregroundStyle(Color.purple)
//            .interpolationMethod(.catmullRom)
//
//            PointMark(
//                x: .value("날짜", record.measuredDate, unit: .day),
//                y: .value("통증", record.painLevel)
//            )
//            .foregroundStyle(Color.purple)
//            .symbolSize(60)
//
//            if let selectedPainDate {
//                RuleMark(x: .value("Selected", selectedPainDate, unit: .day))
//                    .foregroundStyle(Color.gray.opacity(0.3))
//                    .zIndex(-1)
//                    .annotation(
//                        position: .top,
//                        spacing: 0,
//                        overflowResolution: .init(x: .fit(to: .chart), y: .disabled)
//                    ) {
//                        painAnnotation
//                    }
//            }
//        }
//        .chartXAxis {
//            AxisMarks(values: .stride(by: .day)) { value in
//                if let date = value.as(Date.self) {
//                    AxisValueLabel {
//                        Text(formatShortDate(date))
//                    }
//                }
//            }
//        }
//        .chartYScale(domain: 0...10)
//        .chartXSelection(value: $selectedPainDate)
//        .frame(height: 250)
//    }
//
//    @ViewBuilder
//    private var painAnnotation: some View {
//        if let selectedPainDate,
//           let selectedRecord = recentRecords.first(where: {
//               Calendar.current.isDate($0.measuredDate, inSameDayAs: selectedPainDate)
//           }) {
//            VStack(alignment: .leading, spacing: 4) {
//                Text("통증 수준(VAS)")
//                    .font(.system(size: 12))
//
//                Text("\(selectedRecord.painLevel.formatted(.number.precision(.fractionLength(1))))")
//                    .font(.system(size: 18, weight: .semibold))
//
//                Text(formatDate(selectedRecord.measuredDate))
//                    .font(.system(size: 11, weight: .semibold))
//            }
//            .padding(12)
//            .background(.thinMaterial)
//            .clipShape(RoundedRectangle(cornerRadius: 8))
//        }
//    }
//
//    // MARK: - Body
//
//    var body: some View {
//        ZStack(alignment: .topTrailing) {
//            ScrollView {
//                VStack(spacing: 32) {
//                    // MARK: - 무릎 가동범위 추이
//                    
//                    VStack(alignment: .leading, spacing: 16) {
//                        Text("무릎 가동범위 추이")
//                            .font(.system(size: 20, weight: .bold))
//                        
//                        HStack(alignment: .top) {
//                            VStack(alignment: .leading, spacing: 4) {
//                                Text("평균")
//                                    .font(.system(size: 14))
//                                    .foregroundColor(.gray)
//                                
//                                Text("\(romAverage)°")
//                                    .font(.system(size: 32, weight: .bold))
//                            }
//                            
//                            Spacer()
//                        }
//                        
//                        Text(dateRangeText)
//                            .font(.system(size: 12))
//                            .foregroundColor(.gray)
//                        
//                        Chart(recentRecords) { record in
//                            BarMark(
//                                x: .value("날짜", record.measuredDate, unit: .day),
//                                yStart: .value("최소", record.flexionAngle),
//                                yEnd: .value("최대", record.extensionAngle),
//                                width: .fixed(6)  // 막대 너비 (픽셀)
//                            )
//                            .foregroundStyle(
//                                LinearGradient(
//                                    colors: [Color.blue.opacity(0.7), Color.blue],
//                                    startPoint: .top,
//                                    endPoint: .bottom
//                                )
//                            )
//                            .cornerRadius(4)
//                            
//                            // 선택된 날짜에 대한 RuleMark와 annotation
//                            if let selectedROMDate {
//                                RuleMark(x: .value("Selected", selectedROMDate, unit: .day))
//                                    .foregroundStyle(Color.gray.opacity(0.3))
//                                    .zIndex(-1)
//                                    .annotation(
//                                        position: .top,
//                                        spacing: 0,
//                                        overflowResolution: .init(
//                                            x: .fit(to: .chart),
//                                            y: .disabled
//                                        )
//                                    ) {
//                                        if let selectedRecord = recentRecords.first(where: {
//                                            Calendar.current.isDate($0.measuredDate, inSameDayAs: selectedROMDate)
//                                        }) {
//                                            VStack(alignment:.leading){
//                                                Text("무릎 가동범위")
//                                                    .font(.system(size: 11, weight: .medium))
//
//                                                HStack {
//                                                    Text("\(Int(selectedRecord.flexionAngle))° ~")
//                                                        .font(.system(size: 24, weight: .semibold))
//                                                    
//                                                    Text("\(Int(selectedRecord.extensionAngle))°")
//                                                        .font(.system(size: 24, weight: .semibold))
//                                                }
//                                                Text(formatDate(selectedRecord.measuredDate))
//                                                    .font(.system(size: 11, weight: .semibold))
//                                            }
//                                            .padding(12)
//                                            .background(.thinMaterial)
//                                            .clipShape(RoundedRectangle(cornerRadius: 8))
//                                            
//                                        }
//                                    }
//                            }
//                        }
//                        .chartXAxis {
//                            AxisMarks(values: .stride(by: .day)) { value in
//                                if let date = value.as(Date.self) {
//                                    AxisValueLabel {
//                                        Text(formatShortDate(date))
//                                    }
//                                }
//                            }
//                        }
//                        .chartYAxis {
//                            AxisMarks { value in
//                                AxisValueLabel {
//                                    if let angle = value.as(Double.self) {
//                                        Text("\(Int(angle))")
//                                    }
//                                }
//                                AxisGridLine()
//                            }
//                        }
//                        .chartYScale(domain: 0...190)
//                        .chartXSelection(value: $selectedROMDate)
//                        .frame(height: 250)
//                    }
//                    
//                    // MARK: - 통증 수준 추이
//                    
//                    VStack(alignment: .leading, spacing: 16) {
//                        Text("통증 수준 추이")
//                            .font(.system(size: 20, weight: .bold))
//                        
//                        HStack(alignment: .top) {
//                            VStack(alignment: .leading, spacing: 4) {
//                                Text("최소~최대")
//                                    .font(.system(size: 14))
//                                    .foregroundColor(.gray)
//                                
//                                Text("\(painMin)~\(painMax)")
//                                    .font(.system(size: 32, weight: .bold))
//                            }
//                            
//                            Spacer()
//                        }
//                        
//                        Text(dateRangeText)
//                            .font(.system(size: 12))
//                            .foregroundColor(.gray)
//                        
//                        Chart(recentRecords) { record in
//                            LineMark(
//                                x: .value("날짜", record.measuredDate, unit: .day),
//                                y: .value("통증", record.painLevel)
//                            )
//                            .foregroundStyle(Color.purple)
//                            .interpolationMethod(.catmullRom)
//                            
//                            PointMark(
//                                x: .value("날짜", record.measuredDate, unit: .day),
//                                y: .value("통증", record.painLevel)
//                            )
//                            .foregroundStyle(Color.purple)
//                            .symbolSize(60)
//                            
//                            // 선택된 날짜에 대한 RuleMark와 annotation
//                            if let selectedPainDate {
//                                RuleMark(x: .value("Selected", selectedPainDate, unit: .day))
//                                    .foregroundStyle(Color.gray.opacity(0.3))
//                                    .zIndex(-1)
//                                    .annotation(
//                                        position: .top,
//                                        spacing: 0,
//                                        overflowResolution: .init(
//                                            x: .fit(to: .chart),
//                                            y: .disabled
//                                        )
//                                    ) {
//                                        if let selectedRecord = recentRecords.first(where: {
//                                            Calendar.current.isDate($0.measuredDate, inSameDayAs: selectedPainDate)
//                                        }) {
//                                            VStack(alignment: .leading, spacing: 4) {
//                                                
//                                                Text("통증 수준(VAS)")
//                                                    .font(.system(size: 12))
//                                                
//                                                Text("\(selectedRecord.painLevel.formatted(.number.precision(.fractionLength(1))))")
//                                                    .font(.system(size: 18, weight: .semibold))
//                                                
//                                                Text(formatDate(selectedRecord.measuredDate))
//                                                    .font(.system(size: 11, weight: .semibold))
//
//                                            }
//                                            .padding(12)
//                                            .background(.thinMaterial)
//                                            .clipShape(RoundedRectangle(cornerRadius: 8))
//                                        }
//                                    }
//                            }
//                        }
//                        .chartXAxis {
//                            AxisMarks(values: .stride(by: .day)) { value in
//                                if let date = value.as(Date.self) {
//                                    AxisValueLabel {
//                                        Text(formatShortDate(date))
//                                    }
//                                }
//                            }
//                        }
//                        .chartYScale(domain: 0...10)
//                        .chartXSelection(value: $selectedPainDate)
//                        .frame(height: 250)
//                    }
//                }
//                .padding(.horizontal, 20)
//                .padding(.top, 60)
//                .padding(.bottom, 20)
//            }
//            .background(Color.blue.opacity(0.2))
//            
//            // MARK: - Close Button
//            
//            Button {
//                dismiss()
//            } label: {
//                Image(systemName: "xmark")
//                    .font(.system(size: 22, weight: .semibold))
//                    .foregroundColor(.white)
//                    .frame(width: 44, height: 44)
//                    .background(
//                        Circle()
//                            .fill(Color.blue.opacity(0.5))
//                    )
//            }
//            .padding(.top, 8)
//            .padding(.trailing, 16)
//        }
//        .navigationTitle("기록")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}
//
//#Preview {
//    let container = try! ModelContainer(
//        for: MeasuredRecord.self,
//        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
//    )
//    
//    
//    // 샘플 데이터 생성 (10개)
//    let sampleData = [
//        (days: -9, flexion: 50.0, extension: 140.0, pain: 4.0),
//        (days: -8, flexion: 25.0, extension: 105.0, pain: 5.0),
//        (days: -7, flexion: 28.0, extension: 98.0, pain: 5.0),
//        (days: -6, flexion: 22.0, extension: 125.0, pain: 4.0),
//        (days: -5, flexion: 50.0, extension: 80.0, pain: 3.0),
//        (days: -4, flexion: 18.0, extension: 135.0, pain: 5.0),
//        (days: -3, flexion: 55.0, extension: 120.0, pain: 6.0),
//        (days: -2, flexion: 0.0, extension: 0.0, pain: 0.0),
//        (days: -1, flexion: 0.0, extension: 108.0, pain: 4.0),
//        (days: 0, flexion: 8.0, extension: 132.0, pain: 7.0)
//    ]
//    
//    let calendar = Calendar.current
//    for data in sampleData {
//        let date = calendar.date(byAdding: .day, value: data.days, to: Date())!
//        let record = MeasuredRecord(
//            extensionAngle: data.extension,
//            flexionAngle: data.flexion,
//            measuredSeconds: 30,
//            painLevel: Int(data.pain)
//        )
//        record.measuredDate = date
//        container.mainContext.insert(record)
//    }
//
//    return ProgressHistoryView()
//        .modelContainer(container)
//}

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
    
    ProgressHistoryView()
        .environmentObject(vm)
}
