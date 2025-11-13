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

    @State private var countdown: Int = 3

    var body: some View {
        VStack(spacing: 60) {
            CountdownNumber
            VStack(spacing: 12) {
                Text(Strings.Measure.instructionNo1)
                    .font(.displayTitle3Regular)
                Text(Strings.Measure.instructionNo2Emphasis)
                    .font(.displayTitle3Regular)
            }
            VStack(spacing: 16) {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "1.circle")
                        .font(.displayBodyRegular)
                        .foregroundStyle(Color(.gray500))

                    Text(Strings.Measure.instructionNo1)
                        .font(.displayBodyRegular)
                        .foregroundStyle(Color(.gray500))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "2.circle")
                        .font(.displayTitle3Bold)
                        .foregroundStyle(Color(.blue800))

                    Text(Strings.Measure.instructionNo2Emphasis)
                        .font(.displayTitle3Bold)
                        .foregroundStyle(Color(.blue800))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "3.circle")
                        .font(.displayBodyRegular)
                        .foregroundStyle(Color(.gray500))

                    Text(Strings.Measure.instructionNo3Countdown)
                        .font(.displayBodyRegular)
                        .foregroundStyle(Color(.gray500))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            VStack(spacing: 16) {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "1.circle")
                        .font(.displayBodyRegular)
                        .foregroundStyle(Color(.gray500))
                    
                    Text("한 쪽 다리를 최대한 굽히고 앉아\n주세요")
                        .font(.displayBodyRegular)
                        .foregroundStyle(Color(.gray500))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "2.circle")
                        .font(.displayTitle3Bold)
                        .foregroundStyle(Color(.blue800))
                    
                    Text("iPhone을 허벅지 위에 올려주세요")
                        .font(.displayTitle3Bold)
                        .foregroundStyle(Color(.blue800))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "3.circle")
                        .font(.displayBodyRegular)
                        .foregroundStyle(Color(.gray500))
                    
                    Text("자세를 3초 동안 유지해주세요")
                        .font(.displayBodyRegular)
                        .foregroundStyle(Color(.gray500))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(20)
            .background(.backgoundSecondary)
            .cornerRadius(20)
            .padding(.horizontal, 20)
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
                vm.navigationPath.append(MeasureFlowStep.flexionCheck)
            }
        }
    }

    private var CountdownNumber: some View {
        Text("\(countdown)")
            .font(.system(size: 100, weight: .bold))
            .foregroundStyle(Color("Blue700"))
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

