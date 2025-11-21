//
//  MeasureFlag.swift
//  gacha
//
//  Created by 차원준 on 10/28/25.
//

import SwiftData
import SwiftUI

struct CountdownView: View {
    @EnvironmentObject var vm: MeasureViewModel

    @State private var countdown: Int = 3

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 30) {
                
                    Text(Strings.Countdown.emphasisText)
                        .font(.displayTitle1Bold)
                        .foregroundStyle(Color(.blue800))
                    
                    CountdownNumber

                    
                    Image(postureImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 240, height: 210)
                    


                PostureInstructionComponent(
                    type: vm.currentMeasurementType,
                    index: vm.currentMeasurementType == .extensionAngle ? 1 : 2
                )
                .padding(.horizontal, 20)

                CapsuleButtonComponent(
                    title: Strings.Common.cancel,
                    style: .light,
                    width: UIScreen.main.bounds.width - 40,
                    action: {
                        vm.stopSensor()
                        vm.navigate(to: .home, from: .countdown)
                    }
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }

        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
        )
        .onAppear {
            // Start sensor early to warm up before actual measurement view
            vm.shouldAutoStartMeasure = true
            vm.startSensor()
        }
        .task {
            // 3-2-1 카운트다운 (각 1초씩, 총 3초)
            for number in (1...3).reversed() {
                countdown = number
                try? await Task.sleep(nanoseconds: 1_000_000_000)  // 1초

                if Task.isCancelled {
                    return
                }
            }

            // Task가 취소되지 않았을 때만 실행
            if !Task.isCancelled {
                if vm.currentMeasurementType == .extensionAngle {
                    vm.navigate(to: .extensionMeasure, from: .countdown)
                } else {
                    vm.navigate(to: .flexionMeasure, from: .countdown)
                }
            }
        }
    }

    private var CountdownNumber: some View {
        Text("\(countdown)")
            .font(.roundedExtraLargeBold)
            .foregroundStyle(Color("Blue800"))
            .frame(width: 100, height: 100)
    }
    
    private var postureImageName: String {
        vm.currentMeasurementType == .extensionAngle ? "extensionLeg" : "flexionLeg"
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

    CountdownView()
        .environmentObject(viewModel)
}
