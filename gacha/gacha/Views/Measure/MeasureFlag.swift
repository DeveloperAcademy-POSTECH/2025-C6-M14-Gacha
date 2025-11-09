//
//  MeasureFlag.swift
//  gacha
//
//  Created by 차원준 on 10/28/25.
//

import SwiftData
import SwiftUI

struct MeasureFlag: View {
    @EnvironmentObject var vm: MeasureViewModel

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var currentLoadingIndex: Int = 1

    var body: some View {
        VStack(spacing: 16) {
            LoadingImage
            Text(Strings.MeasureDone.title)
                .font(.displayTitle2Bold)
            Text(Strings.MeasureDone.subtitle)
                .font(.displayTitle3Regular)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
        )

        .task {
            // 1.5초 동안 Loading 이미지 변경 (1 -> 5)
            for index in 1...5 {
                currentLoadingIndex = index
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3초씩 (총 1.5초)

                if Task.isCancelled {
                    return
                }
            }

            // Task가 취소되지 않았을 때만 실행
            if !Task.isCancelled {
                vm.navigationPath.append(MeasureFlowStep.flexionCheck)
            }
        }
    }

    private var LoadingImage: some View {
        Image("Loading\(currentLoadingIndex)")
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
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

    MeasureFlag()
        .environmentObject(viewModel)
}

