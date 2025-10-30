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
        VStack(spacing: 20) {
            Text("측정이 완료되었습니다!")
                .font(.displayTitle1Bold)
        }
        .onAppear {

            // 1.5초 후 다음 단계로
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                vm.navigationPath.append(MeasureFlowStep.painLevel)
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
