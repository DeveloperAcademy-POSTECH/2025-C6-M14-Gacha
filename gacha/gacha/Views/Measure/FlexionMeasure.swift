//
//  FlexionMeasure.swift
//  gacha
//
//  Created by 차원준 on 10/26/25.
//

import SwiftData
import SwiftUI

struct FlexionMeasure: View {
    @EnvironmentObject var vm: MeasureViewModel

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
                        .scaleEffect(y: max(0.001, vm.overallProgress), anchor: .bottom)
                        .animation(.easeOut(duration: 0.2), value: vm.measurementState)
                        .animation(.easeOut(duration: 0.2), value: vm.stabilizingProgress)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            }
            
            // MARK: - 메인 콘텐츠
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // MARK: - 네비게이션 바
                    HStack {
                        Button(action: {
                            // MainViewBefore로 이동 (측정 취소)
                            if vm.isMeasuring {
                                vm.cancelFlexionMeasure()
                            }
                            vm.navigationPath = NavigationPath()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.displayCalloutRegular)
                                Text("취소")
                                    .font(.displayBodyRegular)
                            }
                            .foregroundStyle(.blue800)
                        }
                        
                        Spacer()
                        
                        Text("ROM 측정")
                            .font(.displayBodySemibold)

                        Spacer()
                        
                        Button(action: {
                        }) {
                            Text("취소")
                        }
                        .disabled(true)
                        .opacity(0)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .frame(height: 44)
                    .zIndex(2)  // 물 위에 표시
                    
                    Spacer()
                    
                    // MARK: - 일러스트 영역
                    ZStack {
                        Image("Measure")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                    }
                    .frame(maxWidth: .infinity)
                    .zIndex(2)  // 물 위에 표시
                    
                    Spacer()
                    
                    // MARK: - 하단 텍스트 (항상 검은색, 완료 시 "측정 완료")
                    Text(vm.measurementState == .completed ? "측정 완료" : "측정 중...")
                        .font(.displayTitle3Regular)
                        .foregroundStyle(Color("Gray900"))
                        .padding(.bottom, 100)
                        .zIndex(2)  // 물 위에 표시
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            vm.startSensor()
            
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
                Color("Green200"),
                Color("Green200").opacity(0.9)
            ]
        case 20..<40:
            colors = [
                Color("Green300"),
                Color("Green300").opacity(0.9)
            ]
        case 40..<60:
            colors = [
                Color("Green400"),
                Color("Green400").opacity(0.9)
            ]
        case 60..<80:
            colors = [
                Color("Green500"),
                Color("Green500").opacity(0.9)
            ]
        default:  // 80~100
            colors = [
                Color("Green700"),
                Color("Green700").opacity(0.9)
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

    return FlexionMeasure()
        .environmentObject(viewModel)
}
