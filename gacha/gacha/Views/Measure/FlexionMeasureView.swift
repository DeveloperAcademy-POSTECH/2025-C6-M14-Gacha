//
//  FlextionMeasureView.swift
//  gacha
//
//  Created by 차원준 on 10/26/25.
//

import SwiftData
import SwiftUI

struct FlexionMeasureView: View {
    @EnvironmentObject var vm: MeasureViewModel

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 60)
                
                // MARK: - 측정 영역
                VStack(spacing: 40) {
                    // 이미지 + 프로그레스 바
                    ZStack {
                        // 배경 원 (흰색 테두리) - 항상 표시
                        Circle()
                            .stroke(.white, lineWidth: 27)
                            .frame(width: 327, height: 327)
                            .shadow(
                                color: Color("Gray300").opacity(0.15),
                                radius: 2,
                                x: 0,
                                y: 2
                            )
                        
                        // 진행률 원 - 안정화 중일 때만 표시
                        if vm.measurementState == .stabilizing {
                            Circle()
                                .trim(from: 0, to: vm.stabilizingProgress)
                                .stroke(
                                    Color("Primary700"),
                                    style: StrokeStyle(
                                        lineWidth: 27,
                                        lineCap: .round
                                    )
                                )
                                .frame(width: 327, height: 327)
                                .rotationEffect(.degrees(-90))
                                .animation(
                                    .linear(duration: 0.1),
                                    value: vm.stabilizingProgress
                                )
                                .shadow(
                                    color: Color("Gray300").opacity(0.15),
                                    radius: 2,
                                    x: 0,
                                    y: 2
                                )
                        }
                        
                        // 내부 이미지 영역
                        ZStack {
                            Circle()
                                .fill(.white)
                                .stroke(.gray100, lineWidth: 1)
                                .frame(width: 300, height: 300)
                            
                            Image("flexion_leg")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300)
                        }
                        .clipShape(Circle())
                    }
                    .contentShape(Circle())
                    
                    // 상태별 텍스트
                    VStack(spacing: 12) {
                        Text(statusText)
                            .font(.roundedTitle2Bold)
                            .multilineTextAlignment(.center)
                        
                        
                    }
                    
                    // 측정 시작/취소 버튼
                    if !vm.isMeasuring {
                        Button(action: {
                            vm.startFlexionMeasure()
                        }) {
                            Text("측정 시작하기")
                                .font(.displayBodyBold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color("Primary500"))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 16)
                    } else {
                        Button(action: {
                            vm.cancelFlexionMeasure()
                        }) {
                            Text("측정 취소")
                                .font(.displayBodyBold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color("Gray500"))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 16)
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .appBackground()
        }
        .onAppear {
            vm.startSensor()
            
            // 자동 시작 플래그 확인
            if vm.shouldAutoStartMeasure {
                vm.shouldAutoStartMeasure = false  // 플래그 리셋
                
                // 0.5초 후 자동 시작 (화면 전환 애니메이션 대기)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                    if vm.measurementState == .idle {  // idle 상태일 때만
                        vm.startFlexionMeasure()
//                    }
                }
            }
            else{
                print("shouldAutoStartMeasure false임")
            }
        }
        .onDisappear {
            if vm.isMeasuring {
                vm.cancelFlexionMeasure()
            }
            vm.stopSensor()
        }
    }
    
    private var statusText: String {
        switch vm.measurementState {
        case .idle:
            return "무릎을 굽혀주세요"
        case .started:
            return "움직임을 시작하세요"
        case .moving:
            return "최대한 굽혀주세요"
        case .stabilizing:
            return "자세를 유지하세요"
        case .completed:
            return "측정 완료!"
        }
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
