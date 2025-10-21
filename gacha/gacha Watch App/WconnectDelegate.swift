//
//  WconnectDelegate.swift
//  gacha Watch App
//
//  Apple Watch 측 WatchConnectivity 구현
//

import Foundation
import WatchConnectivity
import Combine
import SwiftUI

#if os(watchOS)
import WatchKit
#endif

/// Watch 측 iPhone 연결 관리 클래스
final class WatchLink: NSObject, ObservableObject {
    
    static let shared = WatchLink()
    
    // Published 프로퍼티 - UI가 관찰
    @Published var cameraReady = false        // iPhone 카메라 준비 여부
    @Published var reachable = false          // iPhone 연결 가능 여부
    @Published var isMeasuring = false        // 현재 측정 중 여부
    
    private override init() {
        super.init()
    }
    
    /// WCSession 초기화 및 활성화
    func start() {
        guard WCSession.isSupported() else {
            print("⚠️ WatchConnectivity가 지원되지 않는 기기입니다")
            return
        }
        
        let session = WCSession.default
        session.delegate = self
        session.activate()
        
        reachable = session.isReachable
        print("✅ WatchLink Watch 세션 활성화 시작")
        
        // ℹ️ queryStatus()는 세션이 완전히 활성화된 후 
        // activationDidCompleteWith 델리게이트 메서드에서 호출됨
    }
    
    /// iPhone에 현재 상태 질의
    func queryStatus() {
        let session = WCSession.default
        
        // 세션 활성화 상태 먼저 확인
        guard session.activationState == .activated else {
            print("⚠️ WCSession이 아직 활성화되지 않음")
            return
        }
        
        guard session.isReachable else {
            print("⚠️ iPhone에 연결할 수 없음")
            return
        }
        
        session.sendMessage(["cmd": "queryStatus"],
                                       replyHandler: { [weak self] reply in
            DispatchQueue.main.async {
                if let ready = reply["cameraReady"] as? Bool {
                    self?.cameraReady = ready
                    print("📥 카메라 준비 상태: \(ready)")
                }
                if let measuring = reply["isMeasuring"] as? Bool {
                    self?.isMeasuring = measuring
                    print("📥 측정 상태: \(measuring)")
                }
            }
        }, errorHandler: { error in
            print("❌ 상태 질의 실패: \(error.localizedDescription)")
        })
    }
    
    /// 측정 시작 명령 전송
    func startMeasuring() {
        let session = WCSession.default
        
        // 세션 활성화 상태 먼저 확인
        guard session.activationState == .activated else {
            print("⚠️ WCSession이 아직 활성화되지 않음")
            return
        }
        
        // 이미 측정 중이면 무시
        guard !isMeasuring else {
            print("⚠️ 이미 측정 중입니다")
            return
        }
        
        print("⌚️ 측정 시작 명령 전송 (백그라운드)")
        
        // 실제 기기에서는 updateApplicationContext가 더 안정적
        do {
            try session.updateApplicationContext([
                "command": "startMeasuring",
                "timestamp": Date().timeIntervalSince1970
            ])
            print("✅ 측정 시작 명령 전송됨")
            // UI 즉시 업데이트 (낙관적 업데이트)
            DispatchQueue.main.async {
                self.isMeasuring = true
            }
            #if os(watchOS)
            WKInterfaceDevice.current().play(.start)
            #endif
        } catch {
            print("❌ 측정 시작 명령 전송 실패: \(error.localizedDescription)")
            #if os(watchOS)
            WKInterfaceDevice.current().play(.failure)
            #endif
        }
    }
    
    /// 측정 중지 명령 전송
    func stopMeasuring() {
        let session = WCSession.default
        
        // 세션 활성화 상태 먼저 확인
        guard session.activationState == .activated else {
            print("⚠️ WCSession이 아직 활성화되지 않음")
            return
        }
        
        // 측정 중이 아니면 무시
        guard isMeasuring else {
            print("⚠️ 측정 중이 아닙니다")
            return
        }
        
        print("⌚️ 측정 중지 명령 전송 (백그라운드)")
        
        // 실제 기기에서는 updateApplicationContext가 더 안정적
        do {
            try session.updateApplicationContext([
                "command": "stopMeasuring",
                "timestamp": Date().timeIntervalSince1970
            ])
            print("✅ 측정 중지 명령 전송됨")
            // UI 즉시 업데이트 (낙관적 업데이트)
            DispatchQueue.main.async {
                self.isMeasuring = false
            }
            #if os(watchOS)
            WKInterfaceDevice.current().play(.stop)
            #endif
        } catch {
            print("❌ 측정 중지 명령 전송 실패: \(error.localizedDescription)")
            #if os(watchOS)
            WKInterfaceDevice.current().play(.failure)
            #endif
        }
    }
    
    /// 측정 토글 (시작/중지)
    func toggleMeasuring() {
        if isMeasuring {
            stopMeasuring()
        } else {
            startMeasuring()
        }
    }
    
    /// MeasureView로 네비게이션 후 측정 시작
    func navigateAndStartMeasuring() {
        let session = WCSession.default
        
        // 세션 활성화 상태 먼저 확인
        guard session.activationState == .activated else {
            print("⚠️ WCSession이 아직 활성화되지 않음")
            return
        }
        
        print("⌚️ 네비게이션 명령 전송 (백그라운드 방식)")
        
        // 실제 기기에서는 sendMessage가 불안정하므로 처음부터 updateApplicationContext 사용
        do {
            try session.updateApplicationContext([
                "command": "navigateToMeasureView",
                "timestamp": Date().timeIntervalSince1970
            ])
            print("✅ 네비게이션 명령 전송됨")
            #if os(watchOS)
            WKInterfaceDevice.current().play(.start)
            #endif
        } catch {
            print("❌ 네비게이션 명령 전송 실패: \(error.localizedDescription)")
            #if os(watchOS)
            WKInterfaceDevice.current().play(.failure)
            #endif
        }
    }
}

// MARK: - WCSessionDelegate
extension WatchLink: WCSessionDelegate {
    
    /// iPhone으로부터 Application Context 수신 (상태 브로드캐스트)
    func session(_ session: WCSession,
                 didReceiveApplicationContext applicationContext: [String : Any]) {
        print("📥 Watch: Application Context 수신됨")
        print("   내용: \(applicationContext)")
        
        DispatchQueue.main.async { [weak self] in
            var updated = false
            
            if let ready = applicationContext["cameraReady"] as? Bool {
                self?.cameraReady = ready
                print("📥 카메라 준비 상태 업데이트: \(ready)")
                updated = true
            }
            if let measuring = applicationContext["isMeasuring"] as? Bool {
                self?.isMeasuring = measuring
                print("📥 측정 상태 업데이트: \(measuring)")
                updated = true
            }
            
            if updated {
                print("✅ Watch UI 상태 갱신됨 - cameraReady: \(self?.cameraReady ?? false), isMeasuring: \(self?.isMeasuring ?? false)")
            } else {
                print("⚠️ 유효한 상태 업데이트 없음")
            }
        }
    }
    
    /// 연결 상태 변화 감지
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async { [weak self] in
            self?.reachable = session.isReachable
            print("⌚️ iPhone 연결 상태 변화: \(session.isReachable ? "연결됨" : "연결 끊김")")
            
            // iPhone과 연결되면 잠시 대기 후 상태 질의 (타임아웃 방지)
            if session.isReachable && session.activationState == .activated {
                print("📲 iPhone 재연결 - 2초 후 상태 질의 시작")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    self?.queryStatus()
                }
            }
        }
    }
    
    /// 세션 활성화 완료
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        DispatchQueue.main.async { [weak self] in
            self?.reachable = session.isReachable
            
            if let error = error {
                print("❌ Watch 세션 활성화 오류: \(error.localizedDescription)")
            } else {
                print("✅ Watch 세션 활성화 완료: \(activationState.rawValue)")
                print("📊 Watch 연결 상태:")
                print("  - isReachable: \(session.isReachable)")
                print("  - activationState: \(activationState.rawValue)")
                
                // 세션이 정상적으로 활성화되고 iPhone과 연결 가능하면 초기 상태 질의
                if activationState == .activated && session.isReachable {
                    print("📲 iPhone 연결됨 - 2초 후 초기 상태 질의 시작")
                    // 타이밍 여유를 더 줌
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                        print("📲 초기 상태 질의 실행")
                        self?.queryStatus()
                    }
                } else if activationState == .activated {
                    print("⏳ 세션은 활성화되었으나 iPhone 연결 대기 중...")
                    print("   iPhone 앱이 실행 중인지 확인하세요")
                }
            }
        }
    }
}

