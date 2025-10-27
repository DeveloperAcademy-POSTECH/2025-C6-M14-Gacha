//
//  MeasureView.swift
//  gacha
//
//  Created by Oh Seojin on 10/26/25.
//

import SwiftData
import SwiftUI

struct MeasureView: View {
    @EnvironmentObject var vm: MeasureViewModel

    var body: some View {
        VStack(spacing: 30) {
            // 측정 타입 선택
            Picker("측정 타입", selection: $vm.kneeType) {
                Text("굴곡").tag(KneeMotionType.flexionRom)
                Text("신전").tag(KneeMotionType.extensionRom)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            Spacer()

            // 측정 결과 표시
            VStack(spacing: 10) {
                Text("측정된 ROM")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 8) {
                    Text(vm.kneeType.rawValue)
                        .font(.headline)
                        .foregroundColor(.blue)

                    Text("\(String(format: "%.1f", vm.measuredRom))°")
                        .font(.system(size: 48, weight: .bold))
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
                        vm.isRecording ? Color.blue : Color.gray,
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
                    if vm.isRecording {
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
                        if !vm.isRecording {
                            vm.startRecording()
                        }
                    }
                    .onEnded { _ in
                        if vm.isRecording {
                            vm.cancleRecording()
                        }
                    }
            )

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
        .padding()
        .onAppear {
            vm.startMeasuring()
        }
        .onDisappear {
            vm.stopMeasuring()
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: MeasuredRecord.self)
    let repository = SwiftDataRecordRepository(
        modelContext: container.mainContext
    )
    let viewModel = MeasureViewModel(repository: repository)
    return MeasureView()
        .environmentObject(viewModel)
        .modelContainer(container)
}
