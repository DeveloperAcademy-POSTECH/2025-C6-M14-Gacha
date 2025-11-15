//
//  FlexionMeasure.swift
//  gacha
//
//  Created by 차원준 on 10/26/25.
//

import SwiftData
import SwiftUI

struct CompleteMeasureView: View {
    @EnvironmentObject var vm: MeasureViewModel
    @State private var showingAlert = false

    var body: some View {
        GeometryReader { geometry in
            VStack {
                VStack(spacing: 60) {
                    Text(Strings.Flexion.flexionMeasured)
                        .font(.roundedExtraLargeBold)
                        .foregroundStyle(Color(.blue800))

                    // MARK: - 측정 결과
                    Text("\(Int(vm.measuredRom))°")
                        .font(.roundedExtraLargeBold)
                }
                .offset(y: geometry.size.height * 0.3)

                Spacer()

                VStack(spacing: 20) {
                    CapsuleButtonComponent(
                        title: Strings.Button.retake,
                        style: .light,
                        width: geometry.size.width - 40,
                        action: {
                            showingAlert = true
                        }
                    )
                    CapsuleButtonComponent(
                        title: Strings.Button.save,
                        style: .primary,
                        width: geometry.size.width - 40,
                        action: {
                            vm.navigate(to: .painLevel, from: .completeMeasure)
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(.bottom, 40)
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text(Strings.Alert.remeasureTitle),
                message: Text(Strings.Alert.remeasureMessage),
                primaryButton: .destructive(
                    Text(Strings.Common.yes),
                    action: {
                        Task {
                            vm.isRemeasuring = true
                            vm.prepareForNewMeasurement()
                            vm.clearCurrentRecord()

                            await vm.deleteTodayRecords()
                            await vm.checkTodayRecord()

                            // 다시 LoadingMeasure로 이동
                            await MainActor.run {
                                vm.shouldAutoStartMeasure = true
                                vm.navigationPath = NavigationPath()
                                vm.navigationPath.append(
                                    MeasureFlowStep.countdown
                                )
                            }
                            vm.isRemeasuring = false
                        }
                    }
                ),
                secondaryButton: .cancel(
                    Text(Strings.Common.no)
                )
            )
        }
        .navigationBarHidden(true)
        .onAppear {
            // 자동 시작 플래그 확인
            if vm.shouldAutoStartMeasure {
                vm.shouldAutoStartMeasure = false

                // 0.5초 후 자동 시작
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    vm.startFlexionMeasure()
                }
            }
        }
        .onDisappear {
            if vm.isMeasuring {
                vm.cancelFlexionMeasure()
            }
            vm.stopSensor()
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: MeasuredRecord.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let repository = SwiftDataRecordRepository(
        modelContext: container.mainContext
    )
    let viewModel = MeasureViewModel(repository: repository)

    return CompleteMeasureView()
        .environmentObject(viewModel)
}
