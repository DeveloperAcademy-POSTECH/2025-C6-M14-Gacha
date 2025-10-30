//
//  IndicatorComponent.swift
//  gacha
//
//  Created by Oh Seojin on 10/30/25.
//

import SwiftUI

struct IndicatorComponent: View {
    let currentStep: KneeMotionType

    var body: some View {
        HStack(spacing: 8) {
            // Step 1: Extension
            stepCircle(
                number: "1",
                isActive: currentStep == .extensionRom
            )

            Image(systemName: "arrow.right")
                .font(.displayCaption1Semibold)
                .foregroundStyle(Color("Gray500"))

            // Step 2: Flexion
            stepCircle(
                number: "2",
                isActive: currentStep == .flexionRom
            )
        }
    }

    @ViewBuilder
    private func stepCircle(number: String, isActive: Bool) -> some View {
        ZStack {
            Circle()
                .fill(isActive ? Color(.step500) : Color(.step300))
                .frame(
                    width: isActive ? 44 : 32,
                    height: isActive ? 44 : 32
                )

            Text(number)
                .font(.roundedTitle3Semibold)
                .foregroundStyle(
                    isActive ? Color(.textonPrimary) : Color(.gray500)
                )
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        IndicatorComponent(currentStep: .extensionRom)
        IndicatorComponent(currentStep: .flexionRom)
    }
}
