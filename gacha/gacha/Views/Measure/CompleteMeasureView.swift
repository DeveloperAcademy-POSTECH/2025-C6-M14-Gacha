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
                    Text(Strings.Extension.extensionMeasured)
                        .font(.roundedExtraLargeBold)
                        .foregroundStyle(Color("Blue800"))
                    VStack(spacing: 8) {
                        Text(Strings.Flexion.angle)
                            .font(.displayTitle2Regular)
                            .foregroundStyle(Color("Gray600"))
                        Text("  \(Int(vm.currentRecord?.flexionAngle ?? 0))°")
                            .font(.roundedExtraLargeBold)
                            .foregroundStyle(Color("Gray700"))
                    }
                    .padding(16)
                    .frame(height: 144)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color("Blue300"), lineWidth: 2)
                    )
                    
                }
                .frame(height: 240)
                Spacer()

                HStack(spacing: 20) {
                    CapsuleButtonComponent(
                        title: Strings.Button.retake,
                        style: .light,
                        width: (geometry.size.width - 60) / 2,
                        action: {
                            showingAlert = true
                        }
                    )
                    CapsuleButtonComponent(
                        title: Strings.Common.confirm,
                        style: .primary,
                        width: (geometry.size.width - 60) / 2,
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
