//
//  MeasureCheckedView.swift
//  gacha
//
//  Created by 차원준 on 10/28/25.
//

import SwiftData
import SwiftUI

struct MeasureCheckedView: View {
    @EnvironmentObject var vm: MeasureViewModel

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        VStack(spacing: 20) {
            // 체크마크 애니메이션
            ZStack {
                Circle()
                    .frame(width: 234, height: 234)
                    .foregroundStyle(.green)
                Image(systemName: "checkmark")
                    .font(Font.system(size: 150))
                    .foregroundStyle(.white)
            }
            .scaleEffect(scale)
            .opacity(opacity)

        }
        .onAppear {
            // 스프링 애니메이션
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }

            // 1.5초 후 다음 단계로
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                switch vm.kneeType{
                case .extensionRom:
                    vm.navigationPath.append(MeasureFlowStep.flexionMeasure)
                case .flexionRom:
                    vm.navigationPath.append(MeasureFlowStep.painLevel)
                }
            }
        }
    }
}

#Preview {
    // Preview용 임시 repository와 ViewModel 생성
    let container = try! ModelContainer(
        for: MeasuredRecord.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let repository = SwiftDataRecordRepository(
        modelContext: container.mainContext
    )
    let viewModel = MeasureViewModel(repository: repository)

    MeasureCheckedView()
        .environmentObject(viewModel)
}
