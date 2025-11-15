//
//  FlexionMeasure.swift
//  gacha
//
//  Created by 차원준 on 10/26/25.
//

import SwiftData
import SwiftUI

struct CompleteMeasure: View {
    @EnvironmentObject var vm: MeasureViewModel
    @State private var showingAlert = false

    var body: some View {
        GeometryReader { geometry in
            VStack {
                VStack(spacing: 60) {
                    ZStack {
                        Text(Strings.Flexion.measured)
                            .font(.roundedExtraLargeBold)
                            .foregroundStyle(Color("Blue800"))
                    }
                    .frame(maxWidth: .infinity)
                    .zIndex(2)  // 물 위에 표시

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
                        action: {
                            showingAlert = true
                        }
                    )
                    CapsuleButtonComponent(
                        title: Strings.Button.save,
                        style: .primary,
                        action: {
                            vm.navigate(to: .painLevel, from: .completeMeasure)
                        }
                    )
                }
                .padding(.bottom, 40)

            }
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

                            vm.navigationPath = NavigationPath()
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

    // MARK: - 진행률에 따른 그라데이션 색상
    private var progressGradient: LinearGradient {
        let progress = vm.overallProgress * 100  // 0~100으로 변환
        let colors: [Color]

        switch progress {
        case 0..<20:
            colors = [
                Color("Blue200"),
                Color("Blue200").opacity(0.9),
            ]
        case 20..<40:
            colors = [
                Color("Blue300"),
                Color("Blue300").opacity(0.9),
            ]
        case 40..<60:
            colors = [
                Color("Blue400"),
                Color("Blue400").opacity(0.9),
            ]
        case 60..<80:
            colors = [
                Color("Blue500"),
                Color("Blue500").opacity(0.9),
            ]
        default:  // 80~100
            colors = [
                Color("Blue700"),
                Color("Blue700").opacity(0.9),
            ]
        }

        return LinearGradient(
            colors: colors,
            startPoint: .bottom,
            endPoint: .top
        )
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

    return CompleteMeasure()
        .environmentObject(viewModel)
}
