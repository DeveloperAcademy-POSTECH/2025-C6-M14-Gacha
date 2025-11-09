//  PainLevel.swift
//  gacha
//
//  Created by 차원준 on 10/26/25.
//

import SwiftData
import SwiftUI

struct PainLevel: View {
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
                                .font(.displayCalloutMedium)
                            Text(Strings.Common.cancel)
                                .font(.displayBodySemibold)
                        }
                        .foregroundStyle(.blue800)
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(
                            title: Text(Strings.Alert.cancelPainHeadline), //무릎 움직임 측정을 취소하겠어요?
                            message: Text(Strings.Alert.cancelPainMessage), //측정된 기록이 저장되지 않고 처음 화면으로 되돌아가요
                            primaryButton: .destructive(
                                Text(Strings.Common.yes),
                                action: {
                                    // MainViewBefore로 이동 (측정 취소)
                                    vm.prepareForNewMeasurement()  // 측정 상태 초기화
                                    vm.clearCurrentRecord()        // 현재 레코드 클리어
                                    Task {
                                        // 오늘 기록이 있다면 삭제 (이미 저장된 기록이 있을 수 있음)
                                        await vm.deleteTodayRecords()
                                        // 상태 업데이트 (hasTodayRecord = false)
                                        await vm.checkTodayRecord()
                                    }
                                    // 네비게이션 스택 전체 비우기
                                    vm.navigationPath = NavigationPath()
                                }
                            ),
                            secondaryButton: .cancel(Text(Strings.Common.no))
                        )
                    }
                    
                    Spacer()
                    
                    Text(Strings.Pain.title)
                        .font(.displayBodySemibold)
                    Spacer()
                    
                    Button(action: {
                    }) {
                        Text(Strings.Common.cancel)
                    }
                    .disabled(true)
                    .opacity(0)
                    
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .frame(height: 44)

                Spacer()
                
                // MARK: - 이모지
                VStack (spacing: 16) {
                    Image(painImageName(for: Int(value)))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 136, height: 136)
                    VStack (spacing: 8) {
                        Text(Strings.PainCategory.category(for: Int(value)))
                            .font(.displayTitle1Bold)
                            .foregroundStyle(Color("Gray700"))
                        Text(Strings.PainLevel.level(for: Int(value)))
                            .font(.displayBodyRegular)
                            .foregroundStyle(Color("Gray700"))
                            .frame(height: 44)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.bottom, 40)
                
                Spacer()

                // MARK: - 반원형 슬라이더
                VStack(spacing: 16) {
                    ArcSlider(value: $value)
                        .frame(height: 250)
                    Text(Strings.Pain.description)
                }
                
                Spacer()

                CapsuleButtonComponent(
                    title: Strings.Button.save,
                    style: .primary
                ) {
                    Task {
                        if vm.hasTodayRecord {
                            await vm.deleteTodayRecords()
                        }
                        
                        // currentRecord가 있으면 기존 레코드에 통증 레벨 추가 (측정 후)
                        // 없으면 통증 레벨만 있는 새 레코드 생성 (통증만 입력)
                        if vm.currentRecord != nil {
                            await vm.finishPainLevel(level: Int(value))
                        } else {
                            await vm.finishPainLevelOnly(level: Int(value))
                        }
                        
                        await vm.saveCurrentRecord()  // 레코드 저장
                        await vm.checkTodayRecord()   // 상태 업데이트 (hasTodayRecord = true)
                        // 네비게이션 스택을 모두 비워서 메인 화면으로 돌아가기
                        // 메인 화면에서 hasTodayRecord를 체크하여 MainViewB를 표시
                        vm.navigationPath = NavigationPath()
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
             
        }
    }

    private func painImageName(for value: Int) -> String {
        switch value {
        case 0:
            return "painlevel0"
        case 1...3:
            return "painlevel1"
        case 4...6:
            return "painlevel4"
        case 7...9:
            return "painlevel7"
        case 10:
            return "painlevel10"
        default:
            return "painlevel1"
        }
    }
    
    private func painLevelTitle(for index: Int) -> String {
        switch index {
        case 0:
            return Strings.PainCategory.none
        case 1...3:
            return Strings.PainCategory.mild
        case 4...6:
            return Strings.PainCategory.moderate
        case 7...9:
            return Strings.PainCategory.severe
        case 10:
            return Strings.PainCategory.extreme
        default:
            return Strings.PainCategory.mild
        }
    }

}

struct ArcSlider: View {
    @Binding var value: Double
    @State private var lastIntValue: Int = 5
    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    private let totalSegments = 10  // 10개 칸
    private let startAngle: Double = 160  // 원호 시작 각도
    private let totalAngle: Double = 220  // 원호 총 각도
    private let segmentAngle: Double = 220.0 / 10.0  // 각 칸의 각도 (정확히 22도, 220/10)
    
    // MARK: - 세그먼트별 색상 반환
    /// 세그먼트 인덱스에 따른 배경색 반환
    /// 기본 배경은 모두 회색 (채워지지 않은 세그먼트)
    private func segmentColor(for index: Int) -> Color {
        // 모든 배경 세그먼트는 회색
        return Color("Gray300")
    }
    
    // MARK: - 세그먼트별 채워진 색상 반환
    /// 세그먼트 인덱스에 따른 채워진 색상 반환 (Index 폴더의 색상 사용)
    /// - 인덱스 0~3: Index/1 색상
    /// - 인덱스 4~6: Index/4 색상
    /// - 인덱스 7~9: Index/7 색상 (단, value가 10이고 인덱스가 9일 때는 Index/10)
    private func filledSegmentColor(for index: Int, value: Double) -> Color {
        switch index {
        case 0...2:
            return Color("1")
        case 3...5:
            return Color("4")
        case 6...8:
            return Color("7")
        case 9:
            // value가 10일 때만 Index/10 사용
            if value >= 10 {
                return Color("10")
            } else {
                return Color("7")
            }
        default:
            return Color("Gray500")
        }
    }
    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = size.width / 3
            let arcCenter = CGPoint(x: size.width / 2, y: size.height / 2)
            ZStack {
                // MARK: - 배경 세그먼트들 (정확히 10개, 모두 회색)
                // 원호를 정확히 10등분한 세그먼트
                // 기본 배경은 모두 회색 (채워지지 않은 세그먼트)
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
                        style: StrokeStyle(lineWidth: 40, lineCap: .butt, lineJoin: .miter)
                    )
                }
                
                // MARK: - 채워진 세그먼트들 (value에 따라, 정확히 10개 중에서)
                // value 0 → 0개 칸, value 1 → 1개 칸, ..., value 10 → 10개 칸 모두 채움
                // 각 세그먼트는 해당 인덱스에 맞는 색상으로 채워짐
                // - 인덱스 0~3: Index/1 색상
                // - 인덱스 4~6: Index/4 색상
                // - 인덱스 7~9: Index/7 색상 (단, value가 10이고 인덱스가 9일 때는 Index/10)
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
                        filledSegmentColor(for: index, value: value),
                        style: StrokeStyle(lineWidth: 40, lineCap: .butt, lineJoin: .miter)
                    )
                    // 애니메이션 비활성화
                    // .animation(.easeInOut(duration: 0.2), value: value)
                }
                
                // MARK: - 구분선 (11개: 각 칸의 경계에 정확히 배치)
                // 원호를 정확히 1/10로 나눈 구분선
                // 구분선 0: startAngle (160°)
                // 구분선 1: startAngle + segmentAngle (182°)
                // 구분선 2: startAngle + 2*segmentAngle (204°)
                // ...
                // 구분선 10: startAngle + 10*segmentAngle (380° = 20°)
                ForEach(0...totalSegments, id: \.self) { index in
                    // 각 구분선의 각도 = 시작각도 + (인덱스 * 칸당각도)
                    // 정확히 원호를 10등분한 위치
                    let dividerAngle = startAngle + (Double(index) * segmentAngle)
                    DividerLineShape(
                        angle: dividerAngle,
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
                        
                        // 각도를 칸 인덱스로 변환 (한 칸 = 하나의 value)
                        // 칸 n의 범위: [n * segmentAngle, (n + 1) * segmentAngle)
                        // 드래그한 칸의 인덱스가 바로 value가 됨
                        let segmentIndex = Int(normalizedDegrees / segmentAngle)
                        
                        // 칸 인덱스를 value로 직접 매핑
                        // 칸 0 → value = 0, 칸 1 → value = 1, ..., 칸 10 → value = 10
                        let mappedValue = Double(min(segmentIndex, 10))
                        
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
    return PainLevel()
        .environmentObject(viewModel)
}
