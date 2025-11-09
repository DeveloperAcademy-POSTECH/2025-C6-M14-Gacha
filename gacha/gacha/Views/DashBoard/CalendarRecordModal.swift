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
                .font(.displayBodyMedium)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(33)
            
            // Modal 내용
            resultCard
                .padding(.horizontal, 20)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Result Card
    
    private var resultCard: some View {
        VStack(spacing: 0) {
            // 1. 통계 섹션 (54px)
            statisticsSection
                .padding(.top, 24)
                .padding(.horizontal, 20)
                .border(Color.red)
            
            // 2. 일러스트 영역 (240px)
            illustrationSection
                .padding(.top, 22)
                .padding(.horizontal, 20)
                .border(Color.red)
            
        }
        .frame(width: 361)  // 너비만 고정, 높이는 내용에 맞게 자동 조정
        .background(Color("White"))
        .cornerRadius(15)
    }
    
    // MARK: - Statistics Section
    
    private var statisticsSection: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("굴곡 각도")
                    .font(.caption)
                    .foregroundColor(Color("Gray700"))
                Text(formatAngle(record.flexionAngle))
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 4) {
                Text("통증 레벨")
                    .font(.caption)
                    .foregroundColor(Color("Gray700"))
                Text("\(record.painLevel ?? 0)")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Spacer()
        }
        .frame(height: 54)
    }
    
    // MARK: - Illustration Section
    
    private var illustrationSection: some View {
        VStack(spacing: 8) {
            if let angle = record.flexionAngle {
                Image("angle/\(flexionImageName)")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 240, height: 240)
            } else {
                // 각도가 없는 경우 기본 이미지
                Image("angle/70")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 240, height: 240)
            }
        }
        .padding(.horizontal,24)
        .padding(.bottom,20)
    }
    
    
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter.string(from: date)
    }
    
    // MARK: - Helper Methods
    
    private func formatAngle(_ angle: Double?) -> String {
        guard let angle = angle else {
            return "-"
        }
        return "\(Int(angle))°"
    }
    
    private var flexionImageName: String {
        guard let angle = record.flexionAngle else {
            return "70"
        }
        
        switch angle {
        case ...70:
            return "70"
        case 70..<80:
            return "80"
        case 80..<90:
            return "90"
        case 90..<100:
            return "100"
        case 100..<110:
            return "110"
        case 110..<120:
            return "120"
        default:  // 120 이상
            return "130"
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var isPresented = true
        let record = MeasuredRecord(flexionAngle: 110, measuredSeconds: 10, painLevel: 3)
        
        var body: some View {
            CalendarRecordModal(record: record, isPresented: $isPresented)
        }
    }
    
    return PreviewWrapper()
}

