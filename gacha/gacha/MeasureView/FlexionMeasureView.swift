//
//  FlexionMeasureView.swift
//  gacha
//
//  Created by Oh Seojin on 10/28/25.
//

import SwiftUI

struct FlexionMeasureView: View {
    @EnvironmentObject var vm: MeasureViewModel

    var body: some View {
        VStack {
            // 측정 결과 표시
            VStack(spacing: 10) {
                Text("측정된 ROM")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 8) {
                    Text(vm.kneeType.rawValue)
                        .font(.headline)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)

            Spacer()

            // 측정 버튼 (원형 프로그레스)
            ZStack {
                // 배경 원
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 15)
                    .frame(width: 200, height: 200)

                // 진행률 원
                Circle()
                    .trim(from: 0, to: vm.recordingProgress)
                    .stroke(
                        vm.isTouching ? Color.blue : Color.gray,
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
                    if vm.isTouching {
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
                        if !vm.isTouching {
                            vm.startRecording()
                        }
                    }
                    .onEnded { _ in
                        if !vm.isFinished {
                            vm.stopRecording()
                        }
                    }
            )

            Spacer()
            
            Button("뒤로가기") {
                vm.clearCurrentRecord()
            }
            
            Spacer()

            // 저장된 레코드 정보
            if let record = vm.currentRecord {
                VStack(alignment: .leading, spacing: 8) {
                    Text("최근 측정")
                        .font(.headline)
                    Text(
                        "신전: \(String(format: "%.1f", record.extensionAngle))°"
                    )
                    if let flexion = record.flexionAngle {
                        Text("굴곡: \(String(format: "%.1f", flexion))°")
                        Text("ROM: \(String(format: "%.1f", record.ROM ?? 0))°")
                    }
                }
                .font(.caption)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }

            // 에러 메시지
            if let errorMessage = vm.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .onAppear {
            vm.kneeType = .flexionRom
        }
    }
}

#Preview {
    FlexionMeasureView()
}
