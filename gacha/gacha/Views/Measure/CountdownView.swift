//
//  MeasureFlag.swift
//  gacha
//
//  Created by 차원준 on 10/28/25.
//

import SwiftData
import SwiftUI

struct CountdownView: View {
    @EnvironmentObject var vm: MeasureViewModel

    @State private var countdown: Int = 3
    @State private var showCancelAlert = false
    @State private var countdownTask: Task<Void, Never>?
    @State private var shouldNavigateToHome = false
    @State private var shouldRestartCountdown = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 30) {
                    Text(emphasisText)
                        .font(.displayTitle1Bold)
                        .foregroundStyle(Color(.blue800))
                        .padding(.horizontal, 5)
                    
                    CountdownNumber

                    
                    Image(postureImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 240, height: 210)
                    


                PostureInstructionComponent(
                    context: vm.currentMeasurementType == .extensionAngle ? .countdown : .mainViewBefore,
                    index: vm.currentMeasurementType == .extensionAngle ? 1 : 2
                )
                .padding(.horizontal, 20)

                CapsuleButtonComponent(
                    title: Strings.Common.cancel,
                    style: .light,
                    width: UIScreen.main.bounds.width - 40,
                    action: {
                        print("✅ 취소 버튼 클릭됨")
                        // 취소 버튼 클릭 시 카운트다운 일시 정지
                        countdownTask?.cancel()
                        countdownTask = nil
                        
                        // Task가 완전히 취소될 때까지 약간의 딜레이 후 Alert 표시
                        Task { @MainActor in
                            try? await Task.sleep(nanoseconds: 50_000_000) // 0.05초
                            showCancelAlert = true
                            print("✅ showCancelAlert = true로 설정됨")
                        }
                    }
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
        )
        .alert(cancelAlertTitle, isPresented: $showCancelAlert) {
            Button(Strings.Common.yes, role: .destructive) {
                print("✅ Alert: 네 선택됨")
                // "네" 선택 시 Task 취소 및 플래그 설정
                countdownTask?.cancel()
                countdownTask = nil
                vm.stopSensor()
                shouldNavigateToHome = true
                print("✅ shouldNavigateToHome = true로 설정됨")
            }
            Button(Strings.Common.no, role: .cancel) {
                print("✅ Alert: 아니요 선택됨")
                // "아니요" 선택 시 카운트다운 재시작 플래그 설정
                shouldRestartCountdown = true
                print("✅ shouldRestartCountdown = true로 설정됨")
            }
        } message: {
            Text(cancelAlertMessage)
        }
        .onChange(of: showCancelAlert) { isShowing in
            print("🔄 onChange(showCancelAlert): isShowing = \(isShowing)")
            // Alert이 닫힌 후 처리
            if !isShowing {
                print("🔄 Alert이 닫힘 - shouldNavigateToHome: \(shouldNavigateToHome), shouldRestartCountdown: \(shouldRestartCountdown)")
                if shouldNavigateToHome {
                    // "네"를 선택한 경우: 홈으로 이동
                    print("✅ 홈으로 이동 시작")
                    shouldNavigateToHome = false
                    vm.navigate(to: .home, from: .countdown)
                } else if shouldRestartCountdown {
                    // "아니요"를 선택한 경우: 현재 countdown 값부터 재개
                    print("✅ 카운트다운 재개 시작 (현재 값: \(countdown))")
                    shouldRestartCountdown = false
                    resumeCountdown()
                }
            }
        }
        .onAppear {
            // Start sensor early to warm up before actual measurement view
            vm.shouldAutoStartMeasure = true
            vm.startSensor()
            
            // 카운트다운 시작
            startCountdown()
        }
        .onDisappear {
            // 뷰가 사라질 때 task 취소
            countdownTask?.cancel()
            countdownTask = nil
        }
    }

    private var CountdownNumber: some View {
        Text("\(countdown)")
            .font(.roundedExtraLargeBold)
            .foregroundStyle(Color("Blue800"))
            .frame(width: 100, height: 100)
    }
    
    private var postureImageName: String {
        vm.currentMeasurementType == .extensionAngle ? "extensionLeg" : "flexionLeg"
    }
    
    private var emphasisText: String {
        vm.currentMeasurementType == .extensionAngle ? Strings.Countdown.extensionText : Strings.Countdown.flexion
    }
    
    private var cancelAlertTitle: String {
        vm.currentMeasurementType == .extensionAngle 
            ? Strings.Alert.cancelExtensionTitle 
            : Strings.Alert.cancelFlexionTitle
    }
    
    private var cancelAlertMessage: String {
        vm.currentMeasurementType == .extensionAngle 
            ? Strings.Alert.cancelExtensionMessage 
            : Strings.Alert.cancelFlexionMessage
    }
    
    /// 카운트다운을 처음부터 시작 (3부터)
    private func startCountdown() {
        countdown = 3
        resumeCountdown()
    }
    
    /// 현재 countdown 값부터 카운트다운 재개
    private func resumeCountdown() {
        // 기존 Task가 있으면 먼저 취소
        countdownTask?.cancel()
        
        let startNumber = countdown  // 현재 카운트다운 숫자 저장
        print("🔄 카운트다운 재개: \(startNumber)부터 시작")
        
        countdownTask = Task { @MainActor in
            // 현재 값부터 1까지 카운트다운
            for number in (1...startNumber).reversed() {
                if Task.isCancelled {
                    return
                }
                
                countdown = number
                print("⏱️ 카운트다운: \(number)")
                
                do {
                    try await Task.sleep(nanoseconds: 1_000_000_000)  // 1초
                } catch {
                    // Task 취소 시 에러 발생
                    return
                }
                
                if Task.isCancelled {
                    return
                }
            }
            
            guard !Task.isCancelled else { return }
            
            print("✅ 카운트다운 완료 - 측정 화면으로 이동")
            if vm.currentMeasurementType == .extensionAngle {
                vm.navigate(to: .extensionMeasure, from: .countdown)
            } else {
                vm.navigate(to: .flexionMeasure, from: .countdown)
            }
        }
    }
}

#Preview {
    // Preview용 임시 repository와 ViewModel 생성
    let container = try! ModelContainer(
        for: MeasuredRecord.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let repository = SwiftDataRecordRepository(
        modelContext: container.mainContext
    )
    let viewModel = MeasureViewModel(repository: repository)

    CountdownView()
        .environmentObject(viewModel)
}
