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
    private let emphasisFont: Font = .displayBodyBold
    private let regularFont: Font = .displaySublineRegular
    
    private struct Instruction: Identifiable {
        let id: Int
        let text: String
    }
    
    private var highlightIndex: Int {
        if (1...2).contains(index) {
            return index
        }
        return type == .extensionAngle ? 1 : 2
    }
    
    private var instructions: [Instruction] {
        [
            Instruction(id: 1, text: Strings.PostureInstruction.extensionInstruction),
            Instruction(id: 2, text: Strings.PostureInstruction.flexionInstruction),
        ]
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(instructions) { instruction in
                HStack(spacing: 4) {
                    Image(systemName: "\(instruction.id).circle")
                        .font(font(for: instruction.id))
                    Text(instruction.text)
                        .font(font(for: instruction.id))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .foregroundStyle(foregroundColor(for: instruction.id))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color(.blue100).opacity(0.9))
        .cornerRadius(20)
        .multilineTextAlignment(.leading)
    }
    
    private func font(for instructionId: Int) -> Font {
        instructionId == highlightIndex ? emphasisFont : regularFont
    }
    
    private func foregroundColor(for instructionId: Int) -> Color {
        instructionId == highlightIndex ? Color(.blue800) : Color(.gray600)
    }
}

#Preview {
    PostureInstructionComponent(type: .extensionAngle, index: 1)
}
