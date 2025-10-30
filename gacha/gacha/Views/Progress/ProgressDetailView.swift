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
        if vm.isLoading {
            Text("Loading...")
        } else {
            VStack(spacing: 24) {
                // 헤더
                Text("측정 결과")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 111)

                // 결과 카드 (측정값 포함)
                resultCardWithMeasurements

                Spacer()

                // 버튼들
                buttonStack
                    .padding(.horizontal, 39)
                    .padding(.bottom, 40)
            }
            .onAppear {
                Task {
                    await vm.loadPreviousRecord()
                    vm.calculateRecordChange()
                }
            }
        }
    }

    // MARK: - SubView
    private var resultCardWithMeasurements: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(vm.questionText)
                .font(.title3)
                .fontWeight(.semibold)


            // 일러스트 영역 (모크 데이터 - 추후 이미지 에셋으로 교체 예정)
            HStack(spacing: 40) {
                VStack {
                    Image("ExtensionBody")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 115, height: 115)
                        .overlay(alignment: .topTrailing) {
                            Text(vm.formatAngle(vm.currentRecord?.extensionAngle))
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.top, 8)
                                .padding(.trailing, 8)
                        }
                }
                
                VStack(spacing: 8) {
                    Image("FlexionBody")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 115, height: 115)
                         .overlay(alignment: .topTrailing) {
                            Text(vm.formatAngle(vm.currentRecord?.flexionAngle))
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.top, 8)
                                .padding(.trailing, 8)
                        }
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .center)


            VStack(alignment: .leading, spacing: 8) {
                Text(vm.feedbackMessage)
                    .font(.body)

                Text(vm.guidanceText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            
            // 측정값 그리드
            measurementGrid
        }
        .padding(24)
        .frame(width: 345, alignment: .topLeading)
        .background(.white)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 2)
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
                    isPositiveGood: false
                )

                measurementItem(
                    title: "무릎 가동범위",
                    value: vm.formatAngle(vm.currentRecord?.ROM),
                    changeValue: vm.hasComparison
                        ? Int(vm.changeResult?.romDiff ?? 0) : 0,
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
                    .font(.displayBodySemibold)


                // 변화 값
                if changeValue != 0 {
                    HStack(spacing: 2) {
                        Image(
                            systemName: changeValue > 0
                                ? "arrowtriangle.up.fill"
                                : changeValue < 0 ? "arrowtriangle.down.fill" : "minus"
                        )
                        .font(.caption2)
                        Text("\(changeValue)°")
                            .font(.displayBodySemibold)
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
            CapsuleButtonComponent(
                title: "다시 측정하기",
                style: .secondary
            ) {
                vm.navigationPath.removeLast(vm.navigationPath.count-1)
            }
            .frame(width: 315, height: 50)

            CapsuleButtonComponent(
                title: "확인",
                style: .primary
            ) {
                Task {
                    await vm.saveCurrentRecord()
                    vm.navigationPath.removeLast(vm.navigationPath.count)
                }
            }
            .frame(width: 315, height: 50)
        }
    }
}
