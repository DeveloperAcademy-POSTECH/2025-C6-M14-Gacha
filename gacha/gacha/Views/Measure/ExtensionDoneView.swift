//
//  MeasureFlag.swift
//  gacha
//
//  Created by 차원준 on 10/28/25.
//

import SwiftData
import SwiftUI

struct ExtensionDoneView: View {
    @EnvironmentObject var vm: MeasureViewModel

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 40) {
                Spacer()
                VStack(spacing: 40) {
                    Spacer()
                    Text(Strings.Extension.extensionMeasured)
                        .font(.roundedExtraLargeBold)
                        .foregroundStyle(Color("Blue800"))
                    VStack(spacing: 8) {
                        Text(Strings.Extension.angle)
                            .font(.displayTitle2Regular)
                            .foregroundStyle(Color("Gray600"))
                        Text("  \(Int(vm.currentRecord?.extensionAngle ?? 0))°")
                            .font(.roundedExtraLargeBold)
                            .foregroundStyle(Color("Gray700"))
                    }
                    .padding(16)
                    .frame(height: 144)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color("Blue300"), lineWidth: 2)
                    )

                }
                .frame(height: 240)

                // MARK: - 측정 가이드
                PostureInstructionComponent(
                    type: vm.currentMeasurementType,
                    index: 3
                )
                .padding(.horizontal, 20)
                .opacity(0)

                Spacer()
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
        )
        .task {
            // Task가 취소되지 않았을 때만 실행
            if !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2초 대기
                if !Task.isCancelled {
                    vm.navigate(to: .flexionReady, from: .extensionDone)
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

    ExtensionDoneView()
        .environmentObject(viewModel)
}
