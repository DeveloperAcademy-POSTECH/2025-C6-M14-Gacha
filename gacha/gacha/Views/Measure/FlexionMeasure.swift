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
                VStack(spacing: 0) {
                    // MARK: - 네비게이션 바
                    HStack {
                        Button(action: {
                            showingAlert = true
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.displayCalloutRegular)
                                Text(Strings.Common.cancel)
                                    .font(.displayBodyRegular)
                            }
                            .foregroundStyle(.blue800)
                        }
                        .alert(isPresented: $showingAlert) {
                            Alert(
                                title: Text(Strings.Alert.cancelFlexionTitle),
                                message: Text(Strings.Alert.cancelFlexionMessage),
                                primaryButton: .destructive(
                                    Text(Strings.Common.yes),
                                    action: {
                                        vm.prepareForNewMeasurement()  // 측정 상태 초기화
                                        vm.clearCurrentRecord()  // 현재 레코드 클리어

                                        if vm.isMeasuring {
                                            vm.cancelFlexionMeasure()
                                        }

                                        Task {
                                            // 오늘 기록이 있다면 삭제 (이미 저장된 기록이 있을 수 있음)
                                            await vm.deleteTodayRecords()
                                            // 상태 업데이트 (hasTodayRecord = false)
                                            await vm.checkTodayRecord()
                                        }

                                        // 네비게이션 스택 전체 비우기 (Task 밖에서 동기적으로 실행)
                                        vm.navigationPath = NavigationPath()
                                    }
                                ),
                                secondaryButton: .cancel(
                                    Text(Strings.Common.no)
                                )
                            )
                        }

                        Spacer()

                        Text(vm.measurementState == .completed ? Strings.Flexion.titleMeasured : Strings.Flexion.titleMeasuring)
                            .font(.displayBodySemibold)

                        Spacer()
                        
                        Button(action: {
                        }) {
                            Text(Strings.Common.cancel)
                        }
                        .disabled(true)
                        .opacity(0)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .frame(height: 44)
                    .zIndex(2)  // 물 위에 표시
                    
                    Spacer()
                    
                    // MARK: - 실시간 각도 표시
                    ZStack {
                        Text("\(Int(vm.measurementState == .completed ? vm.measuredRom : vm.currentAngle * 2))°")
                            .font(.system(size: 80, weight: .bold))
                            .foregroundStyle(Color("Gray900"))
                    }
                    .frame(maxWidth: .infinity)
                    .zIndex(2)  // 물 위에 표시
                    
                    
                    Spacer()
                    
                    // MARK: - 하단 텍스트 (항상 검은색, 완료 시 "측정 완료")
                    VStack(spacing: 16) {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "1.circle")
                                .font(.displayBodyRegular)
                                .foregroundStyle(Color(.gray500))
                            
                            Text("한 쪽 다리를 최대한 굽히고 앉아\n주세요")
                                .font(.displayBodyRegular)
                                .foregroundStyle(Color(.gray500))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "2.circle")
                                .font(.displayBodyRegular)
                                .foregroundStyle(Color(.gray500))
                            
                            Text("iPhone을 허벅지 위에 올려주세요")
                                .font(.displayBodyRegular)
                                .foregroundStyle(Color(.gray500))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "3.circle")
                                .font(.displayTitle3Bold)
                                .foregroundStyle(Color(.blue800))
                            
                            Text("자세를 3초 동안 유지해주세요")
                                .font(.displayTitle3Bold)
                                .foregroundStyle(Color(.blue800))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(20)
                    .background(.backgoundSecondary.opacity(0.8))
                    .cornerRadius(20)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                    
                    Text(vm.measurementState == .completed ? Strings.Flexion.measured : Strings.Flexion.measuring)
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
                Color("Blue200"),
                Color("Blue200").opacity(0.9)
            ]
        case 20..<40:
            colors = [
                Color("Blue300"),
                Color("Blue300").opacity(0.9)
            ]
        case 40..<60:
            colors = [
                Color("Blue400"),
                Color("Blue400").opacity(0.9)
            ]
        case 60..<80:
            colors = [
                Color("Blue500"),
                Color("Blue500").opacity(0.9)
            ]
        default:  // 80~100
            colors = [
                Color("Blue700"),
                Color("Blue700").opacity(0.9)
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
