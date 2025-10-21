import SwiftUI
import Charts
import SwiftData

struct HistoryView: View {
    @Query(sort: \MeasuredRecord.date, order: .forward) private var records: [MeasuredRecord]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 제목
                    VStack(alignment: .leading, spacing: 8) {

                        Text("나의 ROM 추이")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal)
                    
                    // 범위 꺾은선 그래프
                    ROMRangeChartView(records: records)
                    
                    // 신전/굴곡 막대 그래프
                    FlexionExtensionChartView(records: records)
                    
                    // 과거 정보 리스트
                    PastRecordsListView(records: records)
                }
                .padding(.bottom, 100) // 하단 네비게이션 바 공간 확보
            }
        }
    }
}

// MARK: - ROM 범위 꺾은선 그래프
struct ROMRangeChartView: View {
    let records: [MeasuredRecord]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 범례
            HStack {
                Circle()
                    .fill(Color.black)
                    .frame(width: 8, height: 8)
                Text("ROM")
                    .font(.caption)
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(.horizontal, 16)
            
            // 차트
            Chart {
                ForEach(records) { record in
                    LineMark(
                        x: .value("Date", record.date),
                        y: .value("Range", Double(record.extensionAngle - record.flexionAngle))
                    )
                    .interpolationMethod(.monotone)
                    .foregroundStyle(.black)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                }
                
                ForEach(records) { record in
                    PointMark(
                        x: .value("Date", record.date),
                        y: .value("Range", Double(record.extensionAngle - record.flexionAngle))
                    )
                    .symbol(.circle)
                    .foregroundStyle(.gray)
                    .symbolSize(60)
                }
                
                // 마지막 데이터에 점선과 날짜 표시
                if let last = records.last {
                    RuleMark(x: .value("Sel", last.date))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4,4]))
                        .foregroundStyle(.gray.opacity(0.6))
//                        .annotation(position: .topTrailing, alignment: .trailing) {
//                            // 우상단 말풍선
//                            let value = Double(last.extensionAngle - last.flexionAngle)
//                            let dateStr = last.date.formatted(.dateTime.year().month(.twoDigits).day(.twoDigits).hour().minute())
//                            Text("\(dateStr)  ROM \(value, format: .number.precision(.fractionLength(0)))°")
//                                .font(.footnote)
//                                .padding(.horizontal, 10).padding(.vertical, 6)
//                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
//                        }
                }
            }
            .frame(height: 200)
//            .chartXAxis {
//                if records.isEmpty {
//                    // 데이터가 없을 때
//                    AxisMarks(values: .automatic) { value in
//                        AxisValueLabel {
//                            Text("데이터 없음")
//                                .font(.caption)
//                                .foregroundColor(.gray)
//                        }
//                    }
//                } else {
//                    // 가장 최신 데이터의 날짜만 표시
//                    if let latestDate = records.last?.date {
//                        AxisMarks(values: [latestDate]) { value in
//                            AxisValueLabel {
//                                if let date = value.as(Date.self) {
//                                    Text(date.formatted(.dateTime.month(.twoDigits).day(.twoDigits)))
//                                        .font(.caption)
//                                        .foregroundColor(.black)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//            .chartYAxis(.hidden)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .stroke(Color.black, lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

// MARK: - 신전/굴곡 막대 그래프
struct FlexionExtensionChartView: View {
    let records: [MeasuredRecord]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 범례
            HStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
                Text("굴곡")
                    .font(.caption)
                    .foregroundColor(.black)
                
                
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                Text("신전")
                    .font(.caption)
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 16)
            
            // 차트
            Chart {
                ForEach(records) { record in
                    // 굴곡 (양수, 위쪽)
                    BarMark(
                        x: .value("Date", record.date),
                        y: .value("Flexion", Double(record.flexionAngle))
                    )
                    .foregroundStyle(.blue)
                    
                    // 신전 (음수로 표시, 아래쪽)
                    BarMark(
                        x: .value("Date", record.date),
                        y: .value("Extension", -Double(record.extensionAngle))
                    )
                    .foregroundStyle(.red)
                }
                
                // 마지막 데이터에 점선과 날짜 표시
                if let last = records.last {
                    RuleMark(x: .value("Sel", last.date))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4,4]))
                        .foregroundStyle(.gray.opacity(0.6))
//                        .annotation(position: .topTrailing, alignment: .trailing) {
//                            // 우상단 말풍선
//                            let flexionValue = Double(last.flexionAngle)
//                            let extensionValue = Double(last.extensionAngle)
//                            let dateStr = last.date.formatted(.dateTime.year().month(.twoDigits).day(.twoDigits).hour().minute())
//                            Text("\(dateStr)\n굴곡 \(flexionValue, format: .number.precision(.fractionLength(0)))°\n신전 \(extensionValue, format: .number.precision(.fractionLength(0)))°")
//                                .font(.footnote)
//                                .padding(.horizontal, 10).padding(.vertical, 6)
//                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
//                        }
                }
            }
            .frame(height: 200)
//            .chartXAxis {
//                if records.isEmpty {
//                    // 데이터가 없을 때
//                    AxisMarks(values: .automatic) { value in
//                        AxisValueLabel {
//                            Text("데이터 없음")
//                                .font(.caption)
//                                .foregroundColor(.gray)
//                        }
//                    }
//                } else {
//                    // 가장 최신 데이터의 날짜만 표시
//                    if let latestDate = records.last?.date {
//                        AxisMarks(values: [latestDate]) { value in
//                            AxisValueLabel {
//                                if let date = value.as(Date.self) {
//                                    Text(date.formatted(.dateTime.month(.twoDigits).day(.twoDigits)))
//                                        .font(.caption)
//                                        .foregroundColor(.black)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//            .chartYAxis(.hidden)
            .chartYScale(domain: -200...200) // 신전을 음수로 표시하기 위한 범위
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .stroke(Color.black, lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

// MARK: - 과거 정보 리스트
struct PastRecordsListView: View {
    let records: [MeasuredRecord]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("과거 기록")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVStack(spacing: 8) {
                ForEach(records.reversed()) { record in
                    HStack {
                        Text(record.date.formatted(.dateTime.year().month(.twoDigits).day(.twoDigits)))
                            .font(.body)
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Text("ROM \(record.extensionAngle - record.flexionAngle)")
                            .font(.body)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .stroke(Color.black, lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: [MeasuredRecord.self])
}
