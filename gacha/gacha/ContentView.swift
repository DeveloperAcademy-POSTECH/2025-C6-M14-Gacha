//
//  ContentView.swift
//  gacha
//
//  Created by Oh Seojin on 10/20/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: MeasureViewModel
    let motionType: KneeMotionType

    var body: some View {
        VStack(spacing: 30) {
            //            // 측정 타입 선택
            //            Picker("측정 타입", selection: $motionManager.kneeMotion) {
            //                Text("굴곡").tag(MotionMeasureManager.KneeMotionType.flexionRom)
            //                Text("신전").tag(MotionMeasureManager.KneeMotionType.extensionRom)
            //            }
            //            .pickerStyle(.segmented)
            //            .padding(.horizontal)

            // 측정 버튼
            ZStack {
                // 배경 원
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 15)
                    .frame(width: 200, height: 200)

                // 진행률 원
                Circle()
                    .trim(from: 0, to: vm.recordingProgress)
                    .stroke(
                        vm.recordingProgress > 0 ? Color.blue : Color.gray,
                        lineWidth: 15
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(
                        .linear(duration: 0.1),
                        value: vm.recordingProgress
                    )

                // 텍스트
                VStack {
                    if vm.recordingProgress > 0 {
                        Text(
                            "\(String(format: "%.1f", (1.0 - vm.recordingProgress) * 3.0))초"
                        )
                        .font(.title)
                        .fontWeight(.bold)
                    } else {
                        Text("측정")
                            .font(.title)
                            .fontWeight(.bold)
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
                        if vm.isFinished {
                            vm.stopRecording()
                        }
                    }
            )

            // 측정 결과 표시
            VStack(spacing: 10) {
                Text("측정된 ROM")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 8) {
                    Text(vm.kneeType.rawValue)
                        .font(.headline)
                        .foregroundColor(.blue)

                    Text(
                        "\(String(format: "%.1f", vm.measuredRom))°"
                    )
                    .font(.system(size: 36, weight: .bold))
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
        .onAppear {
            vm.kneeType = motionType
            vm.startMeasuring()  // 센서 시작
        }
        .onDisappear {
            vm.stopMeasuring()  // 센서 중지
        }
        .onChange(of: vm.measuredRom) { oldValue, newValue in
            // 측정이 완료되면 (0보다 크고, 녹화 중이 아닐 때)
            //                    if newValue > 0 && !motionManager.isRecording {
            //                        // 세션에 저장
            //                        switch motionType {
            //                        case .extensionRom:
            //                            extensionAngle = newValue
            //                        case .flexionRom:
            //                            flexionAngle = newValue
            //                        }

            // 1초 후 다음 단계로 (사용자가 결과를 볼 시간 제공)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                onComplete()
            }
        }

    }
}
