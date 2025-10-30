//
//  ProgressDetailView.swift
//  gacha
//
//  Created by 차원준 on 10/26/25.
//

import SwiftData
import SwiftUI

struct ProgressDetailView: View {
    @EnvironmentObject var vm: MeasureViewModel

    // MARK: - Body
    var body: some View {
        ScrollView {
            if vm.isLoading {
                Text("Loading...")
            } else {
                VStack(spacing: 24) {
                    // 헤더
                    VStack(spacing: 8) {
                        Text("측정 결과")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("지난 측정과 비교한 결과가 제공됩니다")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 40)

                    // 결과 카드
                    resultCard
                        .padding(.horizontal, 20)

                    // 측정값 그리드
                    measurementGrid
                        .padding(.horizontal, 20)

                    Spacer()

                    // 버튼들
                    buttonStack
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            Task {
                await vm.loadPreviousRecord()
                vm.calculateRecordChange()
            }
        }
    }

    // MARK: - SubView
    private var resultCard: some View {
        VStack(spacing: 16) {
            Text(vm.questionText)
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            // 일러스트 영역 (추후 추가)
            Rectangle()
                .fill(Color("Gray100"))
                .frame(height: 180)
                .cornerRadius(12)

            VStack(spacing: 8) {
                Text(vm.feedbackMessage)
                    .font(.body)
                    .multilineTextAlignment(.center)

                Text(vm.guidanceText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }

    private var measurementGrid: some View {
        HStack(spacing: 16) {
            // 좌측: 펴진 각도, 무릎 가동범위
            VStack(alignment: .leading, spacing: 16) {
                measurementItem(
                    title: "펴진 각도",
                    value: vm.formatAngle(vm.currentRecord?.extensionAngle),
                    changeValue: vm.hasComparison
                        ? Int(vm.changeResult?.extenRomDiff ?? 0) : 0,
                    isPositiveGood: true
                )

                measurementItem(
                    title: "무릎 가동범위",
                    value: vm.formatAngle(vm.currentRecord?.ROM),
                    changeValue: vm.hasComparison
                        ? Int(vm.changeResult?.extenRomDiff ?? 0) : 0,
                    isPositiveGood: true
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // 우측: 굽혀진 각도, 통증 수준
            VStack(alignment: .leading, spacing: 16) {
                measurementItem(
                    title: "굽혀진 각도",
                    value: vm.formatAngle(vm.currentRecord?.flexionAngle),
                    changeValue: vm.hasComparison
                        ? Int(vm.changeResult?.flexRomDiff ?? 0) : 0,
                    isPositiveGood: true
                )

                measurementItem(
                    title: "통증 수준",
                    value: vm.formatPainLevel(vm.currentRecord?.painLevel),
                    changeValue: vm.hasComparison
                        ? (vm.changeResult?.painDiff ?? 0) : 0,
                    isPositiveGood: false
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func measurementItem(
        title: String,
        value: String,
        changeValue: Int,
        isPositiveGood: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                // 현재 값
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)

                // 변화 값
                if changeValue != 0 {
                    HStack(spacing: 2) {
                        Image(
                            systemName: changeValue > 0
                                ? "arrow.up"
                                : changeValue < 0 ? "arrow.down" : "minus"
                        )
                        .font(.caption2)
                        Text("\(changeValue)°")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(
                        vm.changeColor(
                            for: changeValue,
                            isPositiveGood: isPositiveGood
                        )
                    )
                }
            }
        }
    }

    private var buttonStack: some View {
        VStack(spacing: 12) {
            Button {
                vm.navigationPath.removeLast(vm.navigationPath.count)
            } label: {
                Text("다시 측정하기")
                    .font(.displayHeadlineSemibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundStyle(Color("Gray900"))
                    .background(Color("Gray100"))
                    .cornerRadius(25)
            }

            Button {
                Task {
                    await vm.saveCurrentRecord()
                    vm.navigationPath.removeLast(vm.navigationPath.count)
                }
            } label: {
                Text("확인")
                    .font(.displayHeadlineSemibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundStyle(Color("White"))
                    .background(Color("Primary500"))
                    .cornerRadius(25)
            }
        }
    }
}

#Preview {
    // 1. 메모리 전용 ModelContainer 생성
    let container = try! ModelContainer(
        for: MeasuredRecord.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    // 2. Repository 생성
    let repository = SwiftDataRecordRepository(
        modelContext: container.mainContext
    )

    // 3. ViewModel 생성
    let vm = MeasureViewModel(repository: repository)

    ProgressDetailView()
        .environmentObject(vm)
}
