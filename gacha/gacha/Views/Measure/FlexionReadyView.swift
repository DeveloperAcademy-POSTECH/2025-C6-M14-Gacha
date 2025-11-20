//
//  MeasureFlag.swift
//  gacha
//
//  Created by 차원준 on 10/28/25.
//

import SwiftData
import SwiftUI

struct FlexionReadyView: View {
    @EnvironmentObject var vm: MeasureViewModel

    @State private var showPainAlert = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // MARK: - 중앙 콘텐츠 영역
            VStack(spacing: 40) {
                Image("leg")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 240, height: 240)
                // 첫 번째 화면 안내 문구
                PostureInstructionComponent(
                    type: vm.currentMeasurementType,
                    index: 1
                )
                
                VStack(spacing: 20) {
                    HStack(spacing: 20) {
                        CapsuleButtonComponent(
                            title: Strings.Button.retake,
                            style: .light,
                            width: (UIScreen.main.bounds.width - 60) / 2
                        ) {
                            vm.currentMeasurementType = .extensionAngle
                            vm.navigate(to: .home, from: .flexionReady)
                        }
                        CapsuleButtonComponent(
                            title: Strings.Button.measureStart,
                            style: .primary,
                            width: (UIScreen.main.bounds.width - 60) / 2
                        ) {
                            vm.currentMeasurementType = .flexionAngle
                            vm.navigate(to: .countdown, from: .flexionReady)
                        }
                    }
                    Button(action: {
                        // 홈에서 직접 PainLevel로 이동
                        if vm.hasTodayRecord {
                            showPainAlert = true
                        } else {
                            vm.navigate(to: .painLevel, from: .flexionReady)
                        }
                    }) {
                        Text(Strings.Button.painOnly)
                            .font(.displayBodyRegular)
                            .foregroundStyle(.gray500)
                            .underline()
                    }
                    .alert(isPresented: $showPainAlert) {
                        Alert(
                            title: Text(Strings.Alert.rerecordPainTitle),
                            message: Text(Strings.Alert.rerecordPainMessage),
                            primaryButton: .destructive(
                                Text(Strings.Common.yes),
                                action: {
                                    Task {
                                        vm.navigate(to: .painLevel, from: .home)
                                    }
                                }
                            ),
                            secondaryButton: .cancel(
                                Text(Strings.Common.no)
                            )
                        )
                    }
                }
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)

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

    FlexionReadyView()
        .environmentObject(viewModel)
}
