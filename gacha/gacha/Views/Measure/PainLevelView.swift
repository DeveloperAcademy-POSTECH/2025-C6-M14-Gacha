//
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

    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .center, spacing: 0) {
                // MARK: - 상단 영역
                VStack(alignment: .leading, spacing: 8) {
                    Text(Strings.Pain.title)
                        .font(.displayLargeBold)
                    Text(Strings.Pain.description)
                        .font(.displayTitle3Medium)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.blue)
                .padding(.leading, 16)
                .padding(.top, 52)

                Spacer()

                // MARK: - 이모지
                Text(painEmoji(for: value))
                    .font(.system(size: 136))

                Spacer()

                // MARK: - 반원형 슬라이더
                ArcSlider(value: $value)
                    .frame(height: 250)

                CapsuleButtonComponent(
                    title: "확인",
                    style: .primary
                ) {
                    Task {
                        if vm.hasTodayRecord {
                            await vm.deleteTodayRecords()
                        }
                        await vm.finishPainLevel(level: Int(value))
                    }
                    vm.navigationPath.append(MeasureFlowStep.result)
                }
                .padding(.horizontal, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .appBackground()

        }
    }

    private func painEmoji(for value: Double) -> String {
        switch value {
        case 0: return "😁"  // 완전히 편안함
        case 1: return "🙂"  // 약간의 이완
        case 2: return "😊"  // 거의 통증 없음
        case 3: return "😐"  // 약간 불편함
        case 4: return "😕"  // 가벼운 통증
        case 5: return "🙁"  // 눈에 띄는 통증
        case 6: return "😣"  // 꽤 아픔
        case 7: return "😖"  // 심한 통증
        case 8: return "😫"  // 매우 아픔
        case 9: return "😩"  // 극심한 통증
        case 10: return "😭"  // 견딜 수 없는 통증
        default: return "😕"
        }
    }

}

struct ArcSlider: View {
    @Binding var value: Double
    @State private var lastIntValue: Int = 5

    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let center = CGPoint(x: size.width / 2, y: size.height / 2)

            ZStack {
                // 배경 원호
                ArcShape(
                    startAngle: .degrees(160),
                    endAngle: .degrees(20)
                )
                .stroke(
                    Color(.gray300),
                    style: StrokeStyle(lineWidth: 40, lineCap: .round)
                )

                // 채워진 원호 (value 0→160°, value 10→380°/20°)
                ArcShape(
                    startAngle: .degrees(160),
                    endAngle: .degrees(160 + (value / 10) * 220)
                )
                .stroke(
                    Color(.primary900),
                    style: StrokeStyle(lineWidth: 40, lineCap: .round)
                )
                .animation(.easeInOut(duration: 0.2), value: value)

                // 핸들 원 — Arc 경로를 따라 움직임
                Circle()
                    .fill(Color("White"))
                    .frame(width: 40, height: 40)
                    .shadow(radius: 3)
                    .position(circlePosition(for: value, in: geo.size))
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { drag in
                                let vector = CGVector(
                                    dx: drag.location.x - center.x,
                                    dy: drag.location.y - center.y
                                )
                                let angle = atan2(vector.dy, vector.dx)
                                let degrees = angle * 180 / .pi

                                // 원호 범위: 160° ~ 20° (반시계방향, 총 220°)
                                var mappedValue: Double = 0

                                if degrees >= 160 {
                                    // 160° ~ 180° 범위 (시작 부분)
                                    mappedValue = (degrees - 160) / 220 * 10
                                } else if degrees <= 20 {
                                    // -180° ~ 20° 범위 (끝 부분)
                                    mappedValue = (200 + degrees) / 220 * 10
                                } else {
                                    // 21° ~ 159° 범위 (원호 밖): 가까운 끝점으로
                                    if degrees < 90 {
                                        mappedValue = 10  // 20도 쪽 (끝점)
                                    } else {
                                        mappedValue = 0  // 160도 쪽 (시작점)
                                    }
                                }

                                value = min(max(mappedValue, 0), 10)
                            }
                    )

                // 중앙 텍스트 (값 + 상태)
                VStack(spacing: 16) {
                    Text("\(Int(value))")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(Color("Gray900"))

                    Text(levelDescription(for: value))
                        .font(.displayTitle1Bold)
                        .foregroundStyle(Color("Gray700"))

                }
                .position(
                    x: size.width / 2,
                    y: size.height / 2
                )
            }
            .onChange(of: value) { oldValue, newValue in
                let newIntValue = Int(round(newValue))
                if newIntValue != lastIntValue {
                    impactFeedback.impactOccurred()
                    lastIntValue = newIntValue
                }
            }

        }
    }

    private func levelDescription(for value: Double) -> String {
        return Strings.Pain.level(Int(value))
    }

    // 반원 경로상의 좌표 계산
    private func circlePosition(for value: Double, in size: CGSize) -> CGPoint {
        let radius = size.width / 3
        let center = CGPoint(x: size.width / 2, y: size.height / 2)

        // value 0 → 160°, value 10 → 20° (380°)
        let angle = Angle(degrees: 160 + (value / 10) * 220)
        let x = center.x + radius * cos(angle.radians)
        let y = center.y + radius * sin(angle.radians)
        return CGPoint(x: x, y: y)
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
