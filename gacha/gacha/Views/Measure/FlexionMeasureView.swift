//
//  FlexionMeasure.swift
//  gacha
//
//  Created by 차원준 on 10/26/25.
//

import SwiftData
import SwiftUI

struct FlexionMeasureView: View {
    @EnvironmentObject var vm: MeasureViewModel
    @State private var showingAlert = false

    var body: some View {
        ZStack {
            // MARK: - 배경 (흰색)
            Color("White")
                .ignoresSafeArea()

            // MARK: - 물이 차오르는 애니메이션 (측정 중일 때만)
            if vm.isMeasuring || vm.measurementState == .completed {
                ZStack {
                    // 하단 고정, 상단이 위로 커지는 채움 (레이아웃은 고정, 렌더만 스케일)
                    Rectangle()
                        .fill(progressGradient)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .scaleEffect(
                            y: max(0.001, vm.overallProgress),
                            anchor: .bottom
                        )
                        .animation(
                            .easeOut(duration: 0.2),
                            value: vm.measurementState
                        )
                        .animation(
                            .easeOut(duration: 0.2),
                            value: vm.stabilizingProgress
                        )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            }
            
            // MARK: - 메인 콘텐츠
            GeometryReader { geometry in
                VStack(spacing: 60) {
                    ZStack {
                        Text(Strings.Flexion.flexionMeasuring)
                            .font(.roundedExtraLargeBold)
                            .foregroundStyle(Color("Blue800"))
                    }
                    .frame(maxWidth: .infinity)
                    .zIndex(2)  // 물 위에 표시


                    // MARK: - 측정 가이드
                    PostureInstructionComponent(index: 3)
                        .padding(.horizontal, 20)
                }
                .offset(y: geometry.size.height * 0.3)
            }
        }
        .onAppear {
            // 자동 시작 플래그 확인
            if vm.shouldAutoStartMeasure {
                vm.shouldAutoStartMeasure = false
            
                // 0.5초 후 자동 시작
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    vm.startFlexionMeasure()
                }
            }
        }
        .onDisappear {
            if vm.isMeasuring {
                vm.cancelFlexionMeasure()
            }
            vm.stopSensor()
        }
    }
    
    // MARK: - 진행률에 따른 그라데이션 색상
    private var progressGradient: LinearGradient {
        let progress = vm.overallProgress * 100  // 0~100으로 변환
        let colors: [Color]
        
        switch progress {
        case 0..<20:
            colors = [
                Color("Blue100"),
                Color("Blue100").opacity(0.9)
            ]
        case 20..<40:
            colors = [
                Color("Blue200"),
                Color("Blue200").opacity(0.9)
            ]
        case 40..<60:
            colors = [
                Color("Blue300"),
                Color("Blue300").opacity(0.9)
            ]
        case 60..<80:
            colors = [
                Color("Blue400"),
                Color("Blue400").opacity(0.9)
            ]
        default:  // 80~100
            colors = [
                Color("Blue500"),
                Color("Blue500").opacity(0.9)
            ]
        }
        
        return LinearGradient(
            colors: colors,
            startPoint: .bottom,
            endPoint: .top
        )
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

    return FlexionMeasureView()
        .environmentObject(viewModel)
}
