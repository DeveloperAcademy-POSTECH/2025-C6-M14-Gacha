//
//  MeasureFlag.swift
//  gacha
//
//  Created by 차원준 on 10/28/25.
//

import SwiftData
import SwiftUI

struct MeasureLoading: View {
    @EnvironmentObject var vm: MeasureViewModel

    @State private var countdown: Int = 3

    var body: some View {
        VStack {
            
            Spacer()
            
            VStack(spacing: 40) {
                CountdownNumber
                
                VStack(spacing: 20) {
                    Text(Strings.Measure.instructionNo1)
                        .font(.displayTitle1Bold)
                        .foregroundStyle(Color(.blue800))
                    Text(Strings.Measure.instructionNo2Emphasis)
                        .font(.displayTitle3Regular)
                }
            }
            
            Spacer()
            
            CapsuleButtonComponent(
                title: Strings.Common.cancel,
                style: .light,
                action: {
                    vm.stopSensor()
                    vm.dismissMeasureFlow()
                }
            )
            .padding(.bottom, 40)
            
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
        )
        .onAppear {
            // Start sensor early to warm up before actual measurement view
            vm.startSensor()
        }
        .task {
            // 3-2-1 카운트다운 (각 1초씩, 총 3초)
            for number in (1...3).reversed() {
                countdown = number
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1초

                if Task.isCancelled {
                    return
                }
            }

            // Task가 취소되지 않았을 때만 실행
            if !Task.isCancelled {
                vm.navigate(to: .flexionMeasure, from: .measureLoading)
            }
        }
    }

    private var CountdownNumber: some View {
        Text("\(countdown)")
            .font(.roundedExtraLargeBold)
            .foregroundStyle(Color("Blue800"))
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

    MeasureLoading()
        .environmentObject(viewModel)
}

