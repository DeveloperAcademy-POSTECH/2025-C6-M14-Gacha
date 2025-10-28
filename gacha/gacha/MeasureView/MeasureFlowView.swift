//
//  MeasureFlowView.swift
//  gacha
//
//  Created by Claude on 10/28/25.
//

import SwiftUI

/// 측정 플로우를 관리하는 루트 View
/// Extension → Flexion → PainLevel 순서로 네비게이션
struct MeasureFlowView: View {
    @EnvironmentObject var vm: MeasureViewModel

    var body: some View {
        NavigationStack(path: $vm.navigationPath) {
            // 1단계: Extension 측정
            ExtensionMeasureView()
                .navigationTitle("신전 측정")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: MeasureStep.self) { step in
                    switch step {
                    case .flexionMeasure:
                        FlexionMeasureView()
                            .navigationTitle("굴곡 측정")
                            .navigationBarTitleDisplayMode(.inline)

                    case .painLevel:
                        PainLevelView()
                            .navigationTitle("통증 레벨")
                            .navigationBarTitleDisplayMode(.inline)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        // 현재 단계 표시
                        Text("\(vm.currentStepNumber)/3")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
        }
        .onAppear {
            vm.startMeasuring()
        }
        .onDisappear {
            vm.stopMeasuring()
        }
    }
}

/// 측정 단계 정의
enum MeasureStep: Hashable {
    
    case flexionMeasure
    case painLevel
}

#Preview {
    MeasureFlowView()
}
