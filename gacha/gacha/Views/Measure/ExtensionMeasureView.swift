import SwiftData
//
//  ExtensionMeasureView.swift
//  gacha
//
//  Created by 차원준 on 10/26/25.
//
import SwiftUI

struct ExtensionMeasureView: View {
    @EnvironmentObject var vm: MeasureViewModel

    @State private var selection = 0
    let items = ["ExtensionLeg", "HoldGesture"]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack(spacing: 0) {
                    // MARK: - 상단 영역
                    HStack {
                        ButtonComponent(
                            background: Color("Primary300"),
                            systemImageName: "chevron.left",
                            weight: .semibold,
                            color: Color("White")
                        ) {
                            vm.navigationPath.removeLast()
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)

                    // MARK: - 인디케이터
                    IndicatorComponent(currentStep: vm.kneeType)
                        .padding(.top, 24)

                    // MARK: - 측정 영역
                    ZStack {
                        // 300x300 이미지 원
                        ZStack {
                            Circle()
                                .fill(.white)
                                .stroke(.gray100, lineWidth: 1)
                                .frame(width: 300, height: 300)

                            VStack(spacing: 16) {
                                Image("extension_leg")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 300)
                                // 텍스트
                                Text(Strings.Extension.instruction)
                                    .multilineTextAlignment(.center)
                            }
                        }

                        // 진행률 원
                        ZStack {
                            Circle()
                                .stroke(.white, lineWidth: 27)
                                .frame(width: 327, height: 327)
                                .shadow(
                                    color: .black.opacity(0.15),
                                    radius: 2,
                                    x: 0,
                                    y: 2
                                )

                            Circle()
                                .trim(from: 0, to: vm.recordingProgress)
                                .stroke(.primary700, style: StrokeStyle( lineWidth: 27, lineCap: .round))
                                .frame(width: 327, height: 327)
                                .rotationEffect(.degrees(-90))
                                .animation(.linear(duration: 0.1), value: vm.recordingProgress)
                                .shadow(
                                    color: .black.opacity(0.15),
                                    radius: 2,
                                    x: 0,
                                    y: 2
                                )
                        }
                        .contentShape(Circle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    if vm.recordingProgress == 0 {
                                        vm.startRecording()
                                    }
                                }
                                .onEnded { _ in
                                    if !vm.isFinished {
                                        vm.stopRecording()
                                    }
                                }
                        )
                    }
                    .padding(.top, 48)
                    
                    //MARK: - Text
                    Text(vm.recordingProgress > 0 ? Strings.Extension.measuring : Strings.Extension.instructionEmphasis)
                        .font(.roundedTitle2Bold)
                        .padding(.top, 40)
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .top
                )
                .appBackground()
            }
        }
        .onAppear {
            vm.kneeType = .extensionRom
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

    return ExtensionMeasureView()
        .environmentObject(viewModel)
}
