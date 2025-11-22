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
///     context: .mainViewBefore,
///     index: 1
/// )
/// ```
///
/// - Parameters:
///   - context: 뷰 컨텍스트 (어떤 뷰에서 사용되는지)
///   - index: 강조될 텍스트의 번호

enum InstructionContext {
    case mainViewBefore
    case countdown
}

struct PostureInstructionComponent: View {
    var context: InstructionContext
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
        return 1
    }
    
    private var instructions: [Instruction] {
        switch context {
        case .mainViewBefore:
            return [
                Instruction(id: 1, text: Strings.PostureInstruction.mainViewBefore1),
                Instruction(id: 2, text: Strings.PostureInstruction.mainViewBefore2),
            ]
        case .countdown:
            return [
                Instruction(id: 1, text: Strings.PostureInstruction.extensionCountdown1),
                Instruction(id: 2, text: Strings.PostureInstruction.extensionCountdown2),
            ]
        }
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
    PostureInstructionComponent(context: .mainViewBefore, index: 1)
}
