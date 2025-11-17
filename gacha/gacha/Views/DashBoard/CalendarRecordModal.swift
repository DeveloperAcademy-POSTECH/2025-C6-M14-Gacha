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
        .presentationDetents([.medium])
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
        HStack(spacing: 16) {
            // 굴곡 각도
            VStack(alignment: .leading, spacing: 4) {
                Text(Strings.Progress.flexionAngle)
                    .font(.displayFootnoteBold)
                    .foregroundColor(.blue700)
                Text(formatAngle(record.flexionAngle))
                    .font(.displayTitle2Bold)
            }

            Spacer()

            // 통증 정도
            VStack(alignment: .leading, spacing: 4) {
                Text(Strings.Progress.painLevel)
                    .font(.displayFootnoteBold)
                    .foregroundColor(.blue700)
                HStack (spacing: 4) {
                    Text(formatPainLevelForDisplay(record.painLevel))
                        .font(.displayTitle2Bold)

                    if let painLevel = record.painLevel, !painCategoryText(for: painLevel).isEmpty {
                        Text("(\(painCategoryText(for: painLevel)))")
                            .font(.displayCaption1Regular)
                            .foregroundColor(.gray600)
                    }
                }
            }

            Spacer()
        }
        .frame(minHeight: 54)
    }

    /// 일러스트 영역
    private var illustrationSection: some View {
        ZStack {
            Image(flexionImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 320, height: 240)
            Text(formatAngle(record.flexionAngle))
                .font(.displayCalloutBold)
                .offset(x: 70, y: -20)
        }
        .frame(height: 240)
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
            return "result45"  // 기본값
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
