//
//  PainLevelView.swift
//  gacha
//
//  Created by 차원준 on 10/26/25.
//


import SwiftUI
import SwiftData

struct PainLevelView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var session: MeasureSession
    let onComplete: () -> Void

    @State private var value: Double = 5.0   // 0~10 범위
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // 상단 영역
                VStack(alignment: .leading, spacing: 9) {
                    Text("통증수준 기록")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(Color.black)
                    
                    Text("측정 중 느낀 통증의 수준을 선택해주세요\n이후 오늘의 측정 결과를 확인할 수 있습니다")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.black.opacity(0.7))
                        .lineSpacing(4)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                
                Spacer()
                
                // 중간 영역 고통 표정
                VStack {
                    Text(painEmoji(for: value))
                        .font(.system(size: 120))
                }
                .padding(.vertical, 20)
                
                Spacer()
                
                // 하단 영역
                    // 반원형 슬라이더
                    ArcSlider(value: $value)
                    
                    Button("확인") {
                        session.painLevel = value
                        saveToDatabase()
                        onComplete()
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 315, height: 50)
                    .background(
                        Color(red: 0.33, green: 0.64, blue: 0.98)
                    )
                    .clipShape(Capsule())

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Color(red: 0.85, green: 0.92, blue: 0.98)
            )

        }
        .onAppear {
            loadLastPainLevel()
        }
    }
    
    private func loadLastPainLevel() {
        var descriptor = FetchDescriptor<MeasuredRecord>(
            sortBy: [SortDescriptor(\.measuredDate, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        
        do {
            let records = try modelContext.fetch(descriptor)
            if let lastRecord = records.first {
                value = lastRecord.painLevel
                print("✅ 마지막 통증 수준 로드: \(lastRecord.painLevel)")
            } else {
                print("ℹ️ 이전 기록 없음, 기본값 5.0 사용")
            }
        } catch {
            print("❌ 기록 조회 실패: \(error.localizedDescription)")
        }
    }
    
    private func saveToDatabase() {
            // 오늘 날짜 범위 계산
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: Date())
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            // 오늘 날짜의 기록 조회
            let predicate = #Predicate<MeasuredRecord> { record in
                record.measuredDate >= startOfDay && record.measuredDate < endOfDay
            }
            
            let descriptor = FetchDescriptor<MeasuredRecord>(predicate: predicate)
            
            do {
                let existingRecords = try modelContext.fetch(descriptor)
                
                if let existingRecord = existingRecords.first {
                    // 덮어쓰기
                    existingRecord.extensionAngle = session.extensionAngle
                    existingRecord.flexionAngle = session.flexionAngle
                    existingRecord.painLevel = session.painLevel
                    existingRecord.measuredDate = Date()
                    print("✅ 기존 기록 업데이트")
                } else {
                    // 새로 생성
                    let newRecord = MeasuredRecord(
                        measuredDate: Date(),
                        flexionAngle: session.flexionAngle,
                        extensionAngle: session.extensionAngle,
                        measuredMinutes: 30,
                        painLevel: session.painLevel
                    )
                    modelContext.insert(newRecord)
                    print("✅ 새 기록 생성")
                }
                
                try modelContext.save()
            } catch {
                print("❌ 저장 실패: \(error.localizedDescription)")
            }
        }
    
    private func painEmoji(for value: Double) -> String {
        switch value {
        case 0..<2: return "😁"
        case 2..<4: return "🤔"
        case 4..<7: return "😕"
        default: return "😩"
        }
    }

}

    
struct ArcSlider: View {
    @Binding var value: Double

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let center = CGPoint(x: size.width / 2, y: size.height / 2)

            ZStack {
                // 배경 원호
                ArcShape(startAngle: .degrees(160),
                         endAngle: .degrees(20))
                    .stroke(
                           Color.gray.opacity(0.3),
                           style: StrokeStyle(lineWidth: 40, lineCap: .round)
                       )
                
                // 채워진 원호 (value 0→160°, value 10→380°/20°)
                ArcShape(startAngle: .degrees(160),
                         endAngle: .degrees(160 + (value / 10) * 220))
                    .stroke(
                            Color(red: 0.33, green: 0.64, blue: 0.98),
                            style: StrokeStyle(lineWidth: 40, lineCap: .round)
                        )
                    .animation(.easeInOut(duration: 0.2), value: value)

                // 핸들 원 — Arc 경로를 따라 움직임
                Circle()
                    .fill(Color.white)
                    .frame(width: 40, height: 40)
                    .shadow(radius: 3)
                    .position(circlePosition(for: value, in: geo.size))
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { drag in
                                let vector = CGVector(dx: drag.location.x - center.x, dy: drag.location.y - center.y)
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
                                        mappedValue = 10 // 20도 쪽 (끝점)
                                    } else {
                                        mappedValue = 0 // 160도 쪽 (시작점)
                                    }
                                }
                                
                                value = min(max(mappedValue, 0), 10)
                            }
                    )
                
                // 중앙 텍스트 (값 + 상태)
                VStack(spacing: 6) {
                    Text("\(Int(value))")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(Color.black)
                    
                    Text(levelDescription(for: value))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.black.opacity(0.7))
                    
                }
                .position(
                    x: size.width / 2,
                    y: size.height / 2
                )
                
                HStack{
                    // 왼쪽 라벨 (0)
                    Text("0")
                        .font(.system(size: 23, weight: .medium))
                        .foregroundStyle(Color.black.opacity(0.6))
                    
                        Spacer()
                    
                    // 오른쪽 라벨 (10)
                    Text("10")
                        .font(.system(size: 23, weight: .medium))
                        .foregroundStyle(Color.black.opacity(0.6))
                }
                .frame(width: size.width*0.65)
                
                .position(
                    x: size.width / 2,
                    y: size.height*0.75
                )
                
            }
            
        }
    }
    
    
    private func levelDescription(for value: Double) -> String {
        switch value {
        case 0..<2: return "통증 없음" // 😁
        case 2..<4: return "조금 아프다" // 🤔
        case 4..<7: return "꽤 아프다" // 😕
        default: return "매우 아프다" // 😩
        }
    }

    // 반원 경로상의 좌표 계산
    private func circlePosition(for value: Double, in size: CGSize) -> CGPoint {
        let radius = size.width / 3
        let center = CGPoint(x: size.width / 2, y: size.height/2)
        
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
        path.addArc(center: CGPoint(x: rect.midX, y: rect.maxY/2),
                    radius: rect.width / 3,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false)
        return path
    }
}

