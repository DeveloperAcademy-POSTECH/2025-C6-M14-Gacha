//
//  PostureInstructionComponent.swift
//  gacha
//
//  Created by Oh Seojin on 11/15/25.
//

import SwiftUI

/// 사용 예시:
/// ```swift
/// PostureInstructionComponent(
///     index: 1
/// )
/// ```
///
/// - Parameters:
///   - index: 강조될 텍스트의 번호

struct PostureInstructionComponent: View {
    var type: MeasurementType
    var index: Int
    let emphasisFont: Font = .displayBodyBold
    let regularFont: Font = .displaySublineRegular
    
    var body: some View {
        VStack(spacing: 12) {
            // index 1
            HStack (spacing: 4) {
                Image(systemName: "1.circle")
                    .font(index == 1 ? emphasisFont : regularFont)
                Text(type == .extensionAngle ? Strings.DailyStart.instructionNo1 : Strings.Flexion.instructionNo1)
                    .font(index == 1 ? emphasisFont : regularFont)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .foregroundStyle(index == 1 ? Color(.blue800) : Color(.gray600))
            
            // index 2
            HStack {
                Image(systemName: "2.circle")
                    .font(index == 2 ? emphasisFont : regularFont)
                Text(Strings.DailyStart.instructionNo2)
                    .font(index == 2 ? emphasisFont : regularFont)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .foregroundStyle(index == 2 ? Color(.blue800) : Color(.gray600))
            
            // index 3
            HStack {
                Image(systemName: "3.circle")
                    .font(index == 3 ? emphasisFont : regularFont)
                Text(Strings.DailyStart.instructionNo3)
                    .font(index == 3 ? emphasisFont : regularFont)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .foregroundStyle(index == 3 ? Color(.blue800) : Color(.gray600))

        }
        .padding(.horizontal, 10)
        .padding(.vertical, 20)
        .background(index == 2 ? .blue100 : Color(.blue100.opacity(0.8)))
        .cornerRadius(20)
        .multilineTextAlignment(.leading)
    }
}

#Preview {
    PostureInstructionComponent(type: .extensionAngle, index: 1)
}
