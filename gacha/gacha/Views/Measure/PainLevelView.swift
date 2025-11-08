//  PainLevelView.swift
//  gacha
//
//  Created by 차원준 on 10/26/25.
//

import SwiftData
import SwiftUI

struct PainLevelView: View {
    @EnvironmentObject var vm: MeasureViewModel

    @State private var value: Double = 5.0  // 0~10 범위
    @State private var showingAlert = false


    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .center, spacing: 0) {
                // MARK: - 네비게이션 바
                HStack {
                    Button(action: {
                        showingAlert = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                            Text("취소")
                                .font(.system(size: 17, weight: .regular))
                        }
                        .foregroundStyle(Color("Primary500"))
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(
                            title: Text(Strings.Alert.Remeasure.title), //무릎 움직임 측정을 취소하겠어요?
                            message: Text(Strings.Alert.Remeasure.message), //측정된 기록이 저장되지 않고 처음 화면으로 되돌아가요
                            primaryButton: .destructive(
                                Text(Strings.Common.yes),
                                action: {
                                    // MeasureView로 이동 (측정 취소)
                                    vm.cancelFlexionMeasure()
                                    vm.navigationPath.removeLast()

                                }
                            ),
                            secondaryButton: .cancel(Text(Strings.Common.no))
                        )
                    }
                    
                    Spacer()
                    
                    Text("ROM 측정")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color("Gray900"))

                    Spacer()
                    
                    Button(action: {
                    }) {
                        Text("취소")
                    }
                    .disabled(true)
                    .opacity(0)
                    
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .frame(height: 44)

                Spacer()
                
                
                Text(Strings.Pain.level(Int(value)))
                    .font(.displayTitle1Bold)
                    .foregroundStyle(Color("Gray700"))

                // MARK: - 이모지
                Image(painImageName(for: Int(value)))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 136, height: 136)

                Spacer()

                // MARK: - 반원형 슬라이더
                ArcSlider(value: $value)
                    .frame(height: 250)

                CapsuleButtonComponent(
                    title: Strings.Common.confirm,
                    style: .primary
                ) {
                    Task {
                        if vm.hasTodayRecord {
                            await vm.deleteTodayRecords()
                        }
                        await vm.finishPainLevel(level: Int(value))
                        await vm.saveCurrentRecord()  // 레코드 저장
                        await vm.checkTodayRecord()   // 상태 업데이트 (hasTodayRecord = true)
                        // 네비게이션 스택을 모두 비워서 메인 화면으로 돌아가기
                        // 메인 화면에서 hasTodayRecord를 체크하여 MeasureView_After를 표시
                        vm.navigationPath = NavigationPath()
                    }
                }
                .padding(.horizontal, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
             

        }
    }

    private func painImageName(for value: Int) -> String {
        switch value {
        case 0:
            return "level0"
        case 1...3:
            return "level1"
        case 4...6:
            return "level4"
        case 7...9:
            return "level7"
        case 10:
            return "level10"
        default:
            return "level1"
        }
    }

}

struct ArcSlider: View {
    @Binding var value: Double
    @State private var lastIntValue: Int = 5

    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)

    private let totalSegments = 10  // 10개 칸
    private let startAngle: Double = 160
    private let totalAngle: Double = 220
    private let segmentAngle: Double = 220.0 / 10.0  // 22도

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = size.width / 3
            let arcCenter = CGPoint(x: size.width / 2, y: size.height / 2)

            ZStack {
                // MARK: - 배경 세그먼트들 (10개)
                ForEach(0..<totalSegments, id: \.self) { index in
                    SegmentedArcShape(
                        segmentIndex: index,
                        totalSegments: totalSegments,
                        startAngle: .degrees(startAngle),
                        segmentAngle: segmentAngle,
                        center: arcCenter,
                        radius: radius
                    )
                    .stroke(
                        Color("Gray300"),
                        style: StrokeStyle(lineWidth: 40, lineCap: .round)
                    )
                }
                
                // MARK: - 채워진 세그먼트들 (value에 따라)
                // value 0 → 0개 칸, value 1 → 1개 칸, ..., value 10 → 10개 칸 모두 채움
                let filledSegments = min(Int(value), totalSegments)
                ForEach(0..<filledSegments, id: \.self) { index in
                    SegmentedArcShape(
                        segmentIndex: index,
                        totalSegments: totalSegments,
                        startAngle: .degrees(startAngle),
                        segmentAngle: segmentAngle,
                        center: arcCenter,
                        radius: radius
                    )
                    .stroke(
                        Color.red,
                        style: StrokeStyle(lineWidth: 40, lineCap: .round)
                    )
                    .animation(.easeInOut(duration: 0.2), value: value)
                }
                
                // MARK: - 구분선 (11개: 0~10 위치, 10개의 세그먼트 구분) - 세그먼트 위에 표시
                ForEach(0...totalSegments, id: \.self) { index in
                    DividerLineShape(
                        angle: startAngle + Double(index) * segmentAngle,
                        center: arcCenter,
                        radius: radius,
                        lineLength: 40
                    )
                    .stroke(Color("Gray700"), lineWidth: 1.5)
                }

                // 중앙 텍스트 (값 + 상태)
                VStack(spacing: 16) {
                    Text("\(Int(value))")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(Color("Gray900"))
                }
                .position(
                    x: size.width / 2,
                    y: size.height / 2
                )
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        let vector = CGVector(
                            dx: drag.location.x - center.x,
                            dy: drag.location.y - center.y
                        )
                        let angle = atan2(vector.dy, vector.dx)
                        var degrees = angle * 180 / .pi
                        
                        // 각도를 0~360 범위로 정규화
                        if degrees < 0 {
                            degrees += 360
                        }
                        
                        // 원호 범위: 160° ~ 380° (360°+20° = 0°+20°)
                        // 각도를 원호 내부의 상대 각도로 변환
                        let normalizedDegrees: Double
                        if degrees >= 160 && degrees <= 360 {
                            // 160° ~ 360° 범위
                            normalizedDegrees = degrees - 160
                        } else if degrees >= 0 && degrees <= 20 {
                            // 0° ~ 20° 범위 (360° ~ 380°와 동일)
                            normalizedDegrees = degrees + 200  // 360 - 160 = 200
                        } else {
                            // 원호 밖: 가장 가까운 끝점으로 스냅
                            if degrees < 90 {
                                value = 10  // 20도 쪽 (끝점)
                            } else {
                                value = 0  // 160도 쪽 (시작점)
                            }
                            let newIntValue = Int(value)
                            if newIntValue != lastIntValue {
                                impactFeedback.impactOccurred()
                                lastIntValue = newIntValue
                            }
                            return
                        }
                        
                        // 각도를 칸 인덱스로 변환 (10개 칸에 11단계 매핑)
                        // 칸 n의 범위: [n * segmentAngle, (n + 1) * segmentAngle)
                        // 각 칸의 중앙에 스냅하도록 조정
                        let segmentIndex = Int((normalizedDegrees + segmentAngle / 2) / segmentAngle)
                        
                        // segmentIndex를 value 0~10으로 매핑
                        // 칸 0 → value 0~1, 칸 1 → value 1~2, ..., 칸 9 → value 9~10
                        // 각 칸의 중앙에 스냅: 칸 n의 중앙 → value = n + 0.5
                        // 하지만 정수로 스냅하려면: 칸 n의 중앙 → value = n 또는 n+1
                        // 더 자연스럽게: 칸 n의 전반부 → value = n, 후반부 → value = n+1
                        let mappedValue: Double
                        if segmentIndex < totalSegments {
                            // 칸 내부 위치에 따라 value 결정
                            let positionInSegment = (normalizedDegrees - Double(segmentIndex) * segmentAngle) / segmentAngle
                            if positionInSegment < 0.5 {
                                // 칸의 전반부 → value = segmentIndex
                                mappedValue = Double(segmentIndex)
                            } else {
                                // 칸의 후반부 → value = segmentIndex + 1
                                mappedValue = Double(min(segmentIndex + 1, 10))
                            }
                        } else {
                            // 마지막 칸을 넘어섬 → value = 10
                            mappedValue = 10
                        }
                        
                        value = min(max(mappedValue, 0), 10)
                        
                        let newIntValue = Int(round(value))
                        if newIntValue != lastIntValue {
                            impactFeedback.impactOccurred()
                            lastIntValue = newIntValue
                        }
                    }
                    .onEnded { _ in
                        // 드래그가 끝났을 때, value를 가장 가까운 정수로 스냅
                        let roundedValue = Double(Int(round(value)))
                        withAnimation(.spring()) {
                            value = roundedValue
                        }
                    }
            )
            .onChange(of: value) { oldValue, newValue in
                let newIntValue = Int(round(newValue))
            }

        }
    }

    private func levelDescription(for value: Double) -> String {
        return Strings.Pain.level(Int(value))
    }
}

// MARK: - 세그먼트 원호 Shape
struct SegmentedArcShape: Shape {
    let segmentIndex: Int
    let totalSegments: Int
    let startAngle: Angle
    let segmentAngle: Double
    let center: CGPoint
    let radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let segmentStartAngle = startAngle.degrees + Double(segmentIndex) * segmentAngle
        let segmentEndAngle = segmentStartAngle + segmentAngle
        
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(segmentStartAngle),
            endAngle: .degrees(segmentEndAngle),
            clockwise: false
        )
        
        return path
    }
}

// MARK: - 구분선 Shape
struct DividerLineShape: Shape {
    let angle: Double
    let center: CGPoint
    let radius: CGFloat
    let lineLength: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let angleRadians = angle * .pi / 180
        
        // 원호의 안쪽 끝점
        let innerRadius = radius - lineLength / 2
        let innerX = center.x + innerRadius * cos(angleRadians)
        let innerY = center.y + innerRadius * sin(angleRadians)
        
        // 원호의 바깥쪽 끝점
        let outerRadius = radius + lineLength / 2
        let outerX = center.x + outerRadius * cos(angleRadians)
        let outerY = center.y + outerRadius * sin(angleRadians)
        
        path.move(to: CGPoint(x: innerX, y: innerY))
        path.addLine(to: CGPoint(x: outerX, y: outerY))
        
        return path
    }
}

struct ArcShape: Shape {
    var startAngle: Angle
    var endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.maxY / 2),
            radius: rect.width / 3,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        return path
    }
}

#Preview {
    let container = try! ModelContainer(
        for: MeasuredRecord.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let repository = SwiftDataRecordRepository(
        modelContext: container.mainContext
    )
    let viewModel = MeasureViewModel(repository: repository)

    return PainLevelView()
        .environmentObject(viewModel)
}
