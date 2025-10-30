//
//  ExtensionMeasureView.swift
//  gacha
//
//  Created by 차원준 on 10/26/25.
//
import SwiftUI
import SwiftData

struct ExtensionMeasureView: View {
    @EnvironmentObject var vm: MeasureViewModel

    @State private var selection = 0
    let items = ["ExtensionLeg", "HoldGesture"]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack(spacing: 0) {
                    // 상단 영역
                    VStack(alignment: .leading, spacing: 9) {
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

                        Text("화면을 꾹 눌러서 측정을 시작해주세요")
                            .font(.displayTitle2Bold)
                    }
                    .padding(.horizontal, 20)
                    .frame(height: geo.size.height * 0.25)

                    // 중간 영역 (캐러셀 + 인디케이터)
                    VStack(spacing: 10) {
                        TabView(selection: $selection) {
                            ForEach(Array(items.enumerated()), id: \.offset) {
                                index,
                                imageName in
                                Image(imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 353, height: 300)
                                    .tag(index)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(height: 280)
                    }
                    .frame(height: geo.size.height * 0.45)

                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .top
                )
                .appBackground()

                ZStack {
                    // 배경 원
                    Circle()
                        .stroke(Color("Gray300"), lineWidth: 15)
                        .frame(width: 200, height: 200)

                    // 진행률 원
                    Circle()
                        .trim(from: 0, to: vm.recordingProgress)
                        .stroke(
                            vm.recordingProgress > 0 ? Color("Primary500") : Color("Gray500"),
                            lineWidth: 15
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .animation(
                            .linear(duration: 0.1),
                            value: vm.recordingProgress
                        )

                    // 버튼 텍스트
                    VStack(spacing: 8) {
                        if vm.recordingProgress > 0 {
                            Text(
                                "\(String(format: "%.1f", (1.0 - vm.recordingProgress) * 3.0))초"
                            )
                            .font(.title)
                            .fontWeight(.bold)
                            Text("측정 중...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text("측정하기")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("3초간 터치")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
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
