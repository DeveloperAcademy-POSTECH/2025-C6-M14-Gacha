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
            Image(systemName: "checkmark.circle.fill")
                .font(Font.system(size: 295))
                .foregroundStyle(Color(.buttonGreen))

                .padding(.top, 160)
                .scaleEffect(scale)
                .opacity(opacity)

        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .top
        )
        .appBackground()
        .onAppear {
            // 스프링 애니메이션
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
        }
        .task {
            // 1.5초 후 다음 단계로
            try? await Task.sleep(nanoseconds: 1_500_000_000)

            // Task가 취소되지 않았을 때만 실행
            if !Task.isCancelled {
                vm.navigationPath.append(MeasureFlowStep.flexionMeasure)
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
