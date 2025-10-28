//
//  PainLevelView.swift
//  gacha
//
//  Created by Oh Seojin on 10/28/25.
//

import SwiftUI

struct PainLevelView: View {
    @EnvironmentObject var vm: MeasureViewModel
    @State private var selectedPainLevel: Int = 0

    var body: some View {
        VStack(spacing: 30) {
            // 제목
            VStack(spacing: 8) {
                Text("운동 후 통증 정도")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("0 (통증 없음) ~ 10 (극심한 통증)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top)

            // 선택된 통증 레벨 표시
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            painLevelColor(for: selectedPainLevel).opacity(0.2)
                        )
                        .frame(width: 120, height: 120)

                    VStack(spacing: 4) {
                        Text("\(selectedPainLevel)")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(
                                painLevelColor(for: selectedPainLevel)
                            )

                        Text(painLevelDescription(for: selectedPainLevel))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Text(painLevelEmoji(for: selectedPainLevel))
                    .font(.system(size: 50))
            }
            .padding()

            // 통증 레벨 선택 버튼 (0-10)
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    ForEach(0...5, id: \.self) { level in
                        painLevelButton(level: level)
                    }
                }

                HStack(spacing: 8) {
                    ForEach(6...10, id: \.self) { level in
                        painLevelButton(level: level)
                    }
                }
            }
            .padding(.horizontal)

            // 저장 버튼
            Button(action: {
                vm.finishPainLevel(level: selectedPainLevel)
            }) {
                Text("통증 레벨 저장")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .disabled(vm.currentRecord == nil)
            .opacity(vm.currentRecord == nil ? 0.5 : 1.0)

            Spacer()
            
            Button("뒤로가기") {
                vm.clearCurrentRecord()
            }
            Button("오늘 기록 지우기") {
                Task {
                    try? await vm.deleteTodayRecords()
                }
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
        .padding()
    }

    // MARK: - Helper Functions

    /// 통증 레벨 버튼
    @ViewBuilder
    private func painLevelButton(level: Int) -> some View {
        Button(action: {
            selectedPainLevel = level
        }) {
            Text("\(level)")
                .font(.title2)
                .fontWeight(selectedPainLevel == level ? .bold : .regular)
                .foregroundColor(
                    selectedPainLevel == level
                        ? .white : painLevelColor(for: level)
                )
                .frame(width: 50, height: 50)
                .background(
                    selectedPainLevel == level
                        ? painLevelColor(for: level)
                        : painLevelColor(for: level).opacity(0.2)
                )
                .cornerRadius(10)
        }
    }

    /// 통증 레벨별 색상
    private func painLevelColor(for level: Int) -> Color {
        switch level {
        case 0...2:
            return .green
        case 3...4:
            return .yellow
        case 5...6:
            return .orange
        case 7...8:
            return .red
        case 9...10:
            return .purple
        default:
            return .gray
        }
    }

    /// 통증 레벨별 설명
    private func painLevelDescription(for level: Int) -> String {
        switch level {
        case 0:
            return "통증 없음"
        case 1...2:
            return "경미한 통증"
        case 3...4:
            return "불편함"
        case 5...6:
            return "중간 통증"
        case 7...8:
            return "심한 통증"
        case 9...10:
            return "극심한 통증"
        default:
            return ""
        }
    }

    /// 통증 레벨별 이모티콘
    private func painLevelEmoji(for level: Int) -> String {
        switch level {
        case 0:
            return "😊"
        case 1...2:
            return "🙂"
        case 3...4:
            return "😐"
        case 5...6:
            return "😣"
        case 7...8:
            return "😖"
        case 9...10:
            return "😫"
        default:
            return "😐"
        }
    }
}

#Preview {
    PainLevelView()
}
