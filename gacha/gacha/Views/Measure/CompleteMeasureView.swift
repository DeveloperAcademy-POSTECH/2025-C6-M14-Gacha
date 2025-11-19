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
            VStack(spacing: 40) {
                Spacer()
                VStack(spacing: 40) {
                    Spacer()
                    Text("측정 완료!")
                        .font(.roundedExtraLargeBold)
                        .foregroundStyle(Color(.blue800))

                    // MARK: - 측정 결과 (2x2 배열)
                    VStack(spacing: 20) {
                        // 첫 번째 행: 신전 - 굴곡
                        HStack(spacing: 20) {
                            MeasurementResultCell(
                                title: "신전",
                                value: vm.currentRecord?.extensionAngle.map { Int($0) } ?? nil
                            )
                            MeasurementResultCell(
                                title: "굴곡",
                                value: vm.currentRecord?.flexionAngle.map { Int($0) } ?? nil
                            )
                        }

                        // 두 번째 행: ROM - 고통
                        HStack(spacing: 20) {
                            MeasurementResultCell(
                                title: "ROM",
                                value: vm.currentRecord?.ROM.map { Int($0) } ?? nil
                            )
                            MeasurementResultCell(
                                title: "고통",
                                value: vm.currentRecord?.painLevel,
                                showDegree: false
                            )
                        }
                    }
                }
                .frame(height: 240)

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
                        title: Strings.Common.confirm,
                        style: .primary,
                        width: geometry.size.width - 40,
                        action: {
                            vm.navigate(to: .painLevel, from: .completeMeasure)
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .center
            )
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
        }
    }
}

// MARK: - 측정 결과 셀 컴포넌트
struct MeasurementResultCell: View {
    let title: String
    let value: Int?
    var showDegree: Bool = true

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.roundedLargeBold)
                .foregroundStyle(Color("Gray600"))

            if let value = value {
                Text(showDegree ? "\(value)°" : "\(value)")
                    .font(.roundedExtraLargeBold)
                    .foregroundStyle(Color("Blue800"))
            } else {
                Text(showDegree ? "--°" : "--")
                    .font(.roundedExtraLargeBold)
                    .foregroundStyle(Color("Blue800"))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color("Blue50"))
        .cornerRadius(12)
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
