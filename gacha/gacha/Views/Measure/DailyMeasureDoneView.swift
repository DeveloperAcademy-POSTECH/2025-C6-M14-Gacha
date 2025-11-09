//
//  MeasureCheckedView.swift
//  gacha
//
//  Created by 차원준 on 10/28/25.
//

import SwiftData
import SwiftUI

struct DailyMeasureDoneView: View {
    @EnvironmentObject var vm: MeasureViewModel

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        VStack(spacing: 16) {
            Text(Strings.MeasureDone.title)
                .font(.displayTitle1Bold)
            Text(Strings.MeasureDone.subtitle)
                .font(.displayBodyMedium)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
        )
         
        .task {
            // 1.5초 후 다음 단계로
            try? await Task.sleep(nanoseconds: 1_500_000_000)

            // Task가 취소되지 않았을 때만 실행
            if !Task.isCancelled {
                vm.navigationPath.append(MeasureFlowStep.flexionCheck)
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

    DailyMeasureDoneView()
        .environmentObject(viewModel)
}
