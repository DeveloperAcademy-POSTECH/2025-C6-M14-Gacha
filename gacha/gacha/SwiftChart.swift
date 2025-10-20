//
//  SwiftChart.swift
//  VisionTest
//
//  Created by 차원준 on 10/20/25.
//

import SwiftUI
import Charts
import SwiftData

struct WeightChartView: View {
    /// sort: 데이터를 어떤 속성으로 정렬할지 지정
    /// order: 정렬 방식 forward(과거->현재), reverse(최근->과거)
    @Query(sort: \MesuredRecord.date, order: .forward) private var items: [MesuredRecord]
    
    /// Y축 범위
    /// ClosedRange<Double>: 시작과 끝이 모두 포함된 범위 타입
    let yRange: ClosedRange<Double> = 60.0 ... 140.0
    /// 눈금 개수
    let desiredYTickCount: Int = 5  // 60, 80, 100, 120, 140

    var body: some View {
        // 마지막 데이터(표시용)
        let last = items.last

        Chart {
            // 1) 라인
            ForEach(items) { e in
                LineMark(
                    x: .value("Date", e.date),
                    y: .value("Range", Double(e.extensionAngle - e.flexionAngle))
                )
                .interpolationMethod(.monotone) // 부드러운 라인
                .foregroundStyle(.gray.opacity(0.5))
            }

            // 2) 포인트
            ForEach(items) { e in
                PointMark(
                    x: .value("Date", e.date),
                    y: .value("Range", Double(e.extensionAngle - e.flexionAngle))
                )
                .symbol(.circle)
                .foregroundStyle(Color.green)
            }

            // 3) 우측 점선 Rule + 말풍선(마지막 값 기준)
            if let last {
                /// x축의 위치에 세로선(룰마크)를 그린다.
                /// "sel"은 축 값의 설명용 이름
                RuleMark(x: .value("Sel", last.date))
                    /// lineWidth: 선 굵기
                    /// dash: [선, 공백]을 반복하는 점선 패턴
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4,4]))
                    .foregroundStyle(.gray.opacity(0.6))
                    /// 룰마크 근처에 보조 뷰(말풍선 등)를 배치
                    .annotation(position: .top, alignment: .center) {
                        // 우상단 말풍선
                        let value = Double(last.extensionAngle - last.flexionAngle)
                        let dateStr = last.date.formatted(.dateTime.hour().minute())
                        VStack{
                            Text("\(dateStr)")
                                .font(.footnote)
                            Text("\(value, format: .number.precision(.fractionLength(0)))°")
                                .font(.footnote)
                        }
                    }
            }
        }
        .frame(height: 260)
        // Y축 범위 고정 (예: 79~85)
        .chartYScale(domain: yRange) // 축 범위 수동 설정.  [oai_citation:3‡Apple Developer](https://developer.apple.com/documentation/charts/customizing-axes-in-swift-charts?utm_source=chatgpt.com)
        
        // X/Y 축 커스터마이즈
        /// X축과 관련된 설정들을 다룬다.
        .chartXAxis {
            let xValues = items.map(\.date)
            /// AxisMarks는 각 데이터의 축 값마다 반복한다
            /// values는 눈금 위치들을 결정하는 인자인다.
            /// .automatic : 데이터 범위에 따라 자동으로 적절한 눈금 간격 계산
            /// .stride : 특정 간격마다 눈금을 찍겠다
            AxisMarks(values: .stride(by: .day, count: 1)) { value in
                /// X축 눈금 위치에 맞춰 세로선(격자선) 을 그린다.
                //AxisGridLine()
                /// X축 눈금 위치에 표시될 라벨(텍스트)을 정의한다.
                AxisValueLabel {
                    if let d = value.as(Date.self) {
                        VStack{
                            // 필요에 맞게 포맷 조정
//                            Text(d.formatted(.dateTime.month()))
                            Text(d.formatted(.dateTime.day()))
                        }
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic(desiredCount: desiredYTickCount)) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let v = value.as(Double.self) {
                        Text("\(v, format: .number.precision(.fractionLength(1)))")
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
