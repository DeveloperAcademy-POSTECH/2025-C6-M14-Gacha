//
//  MeasureView.swift
//  gacha
//
//  Created by Oh Seojin on 10/26/25.
//

import SwiftUI

struct MeasureView: View {
    @StateObject var vm = MeasureViewModel()
    
    var body: some View {
        VStack(spacing: 30) {
            // 측정 타입 선택
            Picker("측정 타입", selection: $motionManager.kneeMotion) {
                Text("굴곡").tag(MotionMeasureManager.KneeMotionType.flexionRom)
                Text("신전").tag(MotionMeasureManager.KneeMotionType.extensionRom)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            // 현재 각도
            Text("\(String(format: "%.1f", motionManager.currentAngle))°")
                .font(.system(size: 60, weight: .bold))

            // 측정 버튼
            ZStack {
                // 배경 원
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 15)
                    .frame(width: 200, height: 200)

                // 진행률 원
                Circle()
                    .trim(from: 0, to: motionManager.recordingProgress)
                    .stroke(
                        motionManager.isRecording ? Color.blue : Color.gray,
                        lineWidth: 15
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(
                        .linear(duration: 0.1),
                        value: motionManager.recordingProgress
                    )

                // 텍스트
                VStack {
                    if motionManager.isRecording {
                        Text(
                            "\(String(format: "%.1f", (1.0 - motionManager.recordingProgress) * 3.0))초"
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
                        if !motionManager.isRecording {
                            motionManager.startRecording()
                        }
                    }
                    .onEnded { _ in
                        if motionManager.isRecording {
                            motionManager.stopRecording()
                        }
                    }
            )

            // 측정 결과 표시
            VStack(spacing: 10) {
                Text("측정된 ROM")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 8) {
                    Text(motionManager.kneeMotion.rawValue)
                        .font(.headline)
                        .foregroundColor(.blue)

                    Text("\(String(format: "%.1f", motionManager.measuredROM))°")
                        .font(.system(size: 36, weight: .bold))
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
        .onAppear {
            motionManager.startMeasuring()  // 센서 시작
        }
        .onDisappear {
            motionManager.stopMeasuring()  // 센서 중지
        }    }
}

#Preview {
    MeasureView()
}
