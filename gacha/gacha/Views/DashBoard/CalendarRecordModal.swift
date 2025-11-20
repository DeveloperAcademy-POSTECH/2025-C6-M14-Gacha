//
//  CalendarRecordModal.swift
//  gacha
//
//  Created by 차원준 on 10/30/25.
//

import SwiftUI

struct CalendarRecordModal: View {
    let record: MeasuredRecord
    @Binding var isPresented: Bool

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {

            Text(formatDate(record.measuredDate))
                .font(.displayBodySemibold)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(height: 44)

            // Modal 내용
            resultCard
                .padding(.top, 22)
                .padding(.horizontal, 32)
        }
        .presentationDetents([.height(50
                                      0)])
        .presentationDragIndicator(.visible)
    }

    /// MARK: - SubView
    /// 측정 결과 카드
    private var resultCard: some View {
        VStack(spacing: 0) {
            // 1. 통계 섹션 (54px)
            statisticsSection
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

            // 2. 일러스트 영역 (240px)
            illustrationSection
                .padding(.horizontal, 20)
        }
        .padding(.vertical, 20)
        .background(Color("White"))
        .cornerRadius(24)
    }
    
    /// 통계 섹션
    var statisticsSection: some View {
        VStack(spacing: 16) {
            // 첫 번째 행: 신전 - 굴곡
            HStack(spacing: 16) {
                // 신전
                MainResultCell(
                    title: Strings.Extension.angle,
                    value: record.extensionAngle.map { Int($0) },
                    showDegree: true
                )

                // 굴곡
                MainResultCell(
                    title: Strings.Flexion.angle,
                    value: record.flexionAngle.map { Int($0) },
                    showDegree: true,
                )
            }

            // 두 번째 행: ROM - 고통
            HStack(spacing: 16) {
                // ROM
                MainResultCell(
                    title: "ROM",
                    value: record.ROM.map { Int($0) },
                    showDegree: true
                )

                // 고통
                MainResultCell(
                    title: "고통",
                    value: record.painLevel,
                    showDegree: false,
                    subtitle: painCategoryText(for: record.painLevel ?? 0)
                )
            }
        }
    }

    var illustrationSection: some View {
        ZStack {
            Image(flexionImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 320, height: 240)
            if record.extensionAngle != nil {
                Text(formatAngle(record.extensionAngle))
                    .font(.displayCalloutBold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color("Gray500"), lineWidth: 2)
                    )
                    .offset(x: 130, y: -50)
            }
            if record.flexionAngle != nil {
                Text(formatAngle(record.flexionAngle))
                    .font(.displayCalloutBold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color("Gray500"), lineWidth: 2)
                    )
                    .offset(calculateFlexionOffset())
            }
        }
    }

    /// Flexion 각도에 따라 offset 계산 (15도 단위로 다르게)
    private func calculateFlexionOffset() -> CGSize {
        guard let flexionAngle = record.flexionAngle else {
            return CGSize(width: 0, height: 120)
        }

        // 60도부터 135도까지 15도 단위로 offset 조정
        let normalizedAngle = max(60, min(135, flexionAngle)) // 60~135 범위로 제한

        // Y offset: 60도: 30, 75도: 50, 90도: 70, 105도: 70, 120도: 50, 135도: 30
        let step = Int((normalizedAngle - 60) / 15)
        let yOffset = 30 + min(step, 5 - step) * 20

        // X offset: 각도에 따라 조정 (60도: 70(오른쪽), 135도: -70(왼쪽))
        let xOffset = 70 - ((normalizedAngle - 60) / 75) * 140

        return CGSize(width: CGFloat(xOffset), height: CGFloat(yOffset))
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    // MARK: - Helper Methods

    private func formatAngle(_ angle: Double?) -> String {
        guard let angle = angle else {
            return "측정값 없음"
        }
        return "\(Int(angle))°"
    }
    
    private func formatPainLevelForDisplay(_ level: Int?) -> String {
        guard let level = level else { return "-" }
        return "\(level)"
    }

    /// 통증 카테고리 텍스트 반환
    private func painCategoryText(for painLevel: Int) -> String {
        return Strings.PainCategory.category(for: painLevel)
    }

    private var flexionImageName: String {
        guard let angle = record.flexionAngle else {
            return "noRecord"  // 기본값
        }

        switch angle {
        case ...60:
            return "result45"
        case 60..<75:
            return "result60"
        case 75..<90:
            return "result75"
        case 90..<105:
            return "result90"
        case 105..<120:
            return "result105"
        case 120..<135:
            return "result120"
        default:  // 135 이상
            return "result135"
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var isPresented = true
        let record = MeasuredRecord(
            flexionAngle: 110,
            measuredSeconds: 10,
            painLevel: 3
        )

        var body: some View {
            CalendarRecordModal(record: record, isPresented: $isPresented)
        }
    }

    return PreviewWrapper()
}
