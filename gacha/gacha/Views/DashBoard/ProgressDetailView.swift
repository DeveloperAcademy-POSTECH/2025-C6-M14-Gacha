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
    @State var showingRetakeAlert = false

    // MARK: - Body
    var body: some View {
        if vm.isLoading {
            Text("Loading...")
        } else {
            VStack(alignment:.leading, spacing: 24) {
                // MARK: - 상단 영역

                VStack(alignment: .leading, spacing: 8) {
                    Text(Strings.Progress.title)
                        .font(.displayLargeBold)
                }
                .padding(.horizontal, 16)
                .padding(.top, 48)
                
                Spacer()

                // 결과 카드 (측정값 포함)
                resultCardWithMeasurements
                    .padding(.horizontal, 24)

                Spacer()

                // 버튼들
                buttonStack
                    .padding(.horizontal, 40)
            }
            .appBackground()
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
            Text(vm.cardTitle)
                .font(.title3)
                .fontWeight(.semibold)

            // 일러스트 영역 - Flexion 각도별 이미지
            VStack(spacing: 8) {
                Image(vm.flexionImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: vm.flexionImageName)
                    .overlay(alignment: .topTrailing) {
                        Text(vm.formatAngle(vm.currentRecord?.flexionAngle))
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top, 8)
                            .padding(.trailing, 8)
                    }
            }
            .frame(maxWidth: .infinity, alignment: .center)

            VStack(alignment: .leading, spacing: 8) {
                let _ = print(vm.feedbackMessage)
                Text(vm.feedbackMessage)
                    .font(.displayBodyMedium)
                    .multilineTextAlignment(.leading)  // 줄바꿈 정렬 방식 지정 (선택)
                    .lineLimit(3)  // 최대 3줄까지 표시
                    .fixedSize(horizontal: false, vertical: true)  // 줄바꿈 강제 활성화
            }

            // 측정값 그리드
            measurementGrid
        }
        .padding(24)
        .frame(width: 345, alignment: .topLeading)
        .background(Color("White"))
        .cornerRadius(24)
        .shadow(color: Color("Gray300").opacity(0.15), radius: 2, x: 0, y: 2)
    }

    private var measurementGrid: some View {
        HStack(spacing: 16) {
            // 좌측: 굽혀진 각도, 무릎 가동범위
            VStack(alignment: .leading, spacing: 16) {
                measurementItem(
                    title: Strings.Card.flexionAngle,
                    value: vm.formatAngle(vm.currentRecord?.flexionAngle),
                    changeValue: vm.hasComparison
                        ? Int(vm.changeResult?.flexRomDiff ?? 0) : 0,
                    isPositiveGood: true
                )

                measurementItem(
                    title: Strings.Card.kneeROM,
                    value: vm.formatAngle(vm.currentRecord?.ROM),
                    changeValue: vm.hasComparison
                        ? Int(vm.changeResult?.romDiff ?? 0) : 0,
                    isPositiveGood: true
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // 우측: 통증 수준
            VStack(alignment: .leading, spacing: 16) {
                measurementItem(
                    title: Strings.Card.painLevel,
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
                                : changeValue < 0
                                    ? "arrowtriangle.down.fill" : "minus"
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
                title: Strings.Common.retake,
                style: .secondary
            ) {
                showingRetakeAlert = true
            }
            .frame(width: 315, height: 50)
            .alert(isPresented: $showingRetakeAlert) {
                Alert(
                    title: Text(
                        Strings.Alert.Remeasure.title
                    ),
                    message: Text(
                        Strings.Alert.Remeasure.message
                    ),
                    primaryButton: .destructive(
                        Text(Strings.Common.yes),
                        action: {
                            // 새 측정 준비
                            vm.prepareForNewMeasurement()
                            
                            // 자동 시작 플래그 설정
                            vm.shouldAutoStartMeasure = true
                            
                            // 새로운 NavigationPath로 교체
                            vm.navigationPath = NavigationPath()
                            vm.navigationPath.append(MeasureFlowStep.flexionMeasure)
                        }
                    ),
                    secondaryButton: .cancel(Text(Strings.Common.no))
                )
            }

            CapsuleButtonComponent(
                title: Strings.Common.confirm,
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
