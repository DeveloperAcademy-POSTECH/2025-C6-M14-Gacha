//
//  PconnectDelegate.swift
//  gacha
//
//  Apple Watch 연결을 위한 iOS 측 WatchConnectivity 구현
//

import Foundation
import WatchConnectivity
import Combine

/// iPhone 측 Watch 연결 관리 클래스
final class WatchLink: NSObject, ObservableObject {
    
    static let shared = WatchLink()
    
    // 전역 상태 관리 (Single Source of Truth)
    @Published var isCameraReady = false      // 카메라 준비 상태
    @Published var isMeasuring = false        // 측정 중 상태
    
    // 네비게이션 트리거
    @Published var shouldNavigateToMeasure = false
    @Published var shouldStartMeasuringAfterNav = false
    
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
        print("✅ WatchLink iOS 세션 활성화 시작")
    }
    
    /// 카메라 준비 상태 업데이트 (상태 저장 + 브로드캐스트)
    func setCameraReady(_ isReady: Bool) {
        DispatchQueue.main.async {
            self.isCameraReady = isReady
            print("📱 카메라 상태 업데이트: \(isReady)")
            self.broadcastCameraStatusToWatch(isReady: isReady)
        }
    }
    
    /// 측정 상태 업데이트 (상태 저장 + 브로드캐스트)
    func setMeasuring(_ measuring: Bool) {
        DispatchQueue.main.async {
            self.isMeasuring = measuring
            print("📱 측정 상태 업데이트: \(measuring)")
            self.broadcastMeasuringStatusToWatch(isMeasuring: measuring)
        }
    }
    
    /// 모든 상태를 워치로 브로드캐스트 (통합 버전)
    private func broadcastAllStatusToWatch() {
        let session = WCSession.default
        
        // 세션 활성화 상태 먼저 확인
        guard session.activationState == .activated else {
            print("⚠️ WCSession이 아직 활성화되지 않음 (activationState: \(session.activationState.rawValue))")
            return
        }
        
        // 디버그 정보 출력
        #if os(iOS)
        print("📊 Watch 연결 상태:")
        print("  - isPaired: \(session.isPaired)")
        print("  - isWatchAppInstalled: \(session.isWatchAppInstalled)")
        print("  - isReachable: \(session.isReachable)")
        print("  - activationState: \(session.activationState.rawValue)")
        
        // isPaired 체크를 제거하고 바로 전송 시도
        // 실제 기기에서는 isPaired가 false로 나올 수 있음
        #endif
        
        // 모든 상태를 하나의 context로 전송 (덮어쓰기 방지)
        do {
            let context: [String: Any] = [
                "cameraReady": self.isCameraReady,
                "isMeasuring": self.isMeasuring,
                "timestamp": Date().timeIntervalSince1970
            ]
            try session.updateApplicationContext(context)
            print("📡 상태 전송 성공: cameraReady=\(self.isCameraReady), isMeasuring=\(self.isMeasuring)")
        } catch {
            print("❌ 상태 브로드캐스트 실패: \(error.localizedDescription)")
            if let wcError = error as? WCError {
                print("   WCError code: \(wcError.code.rawValue)")
            }
        }
    }
    
    /// 카메라 준비 상태를 워치로 브로드캐스트
    func broadcastCameraStatusToWatch(isReady: Bool) {
        broadcastAllStatusToWatch()
    }
    
    /// 측정 중 상태를 워치로 브로드캐스트
    func broadcastMeasuringStatusToWatch(isMeasuring: Bool) {
        broadcastAllStatusToWatch()
    }
}

// MARK: - WCSessionDelegate
extension WatchLink: WCSessionDelegate {
    
    /// 워치로부터 메시지 수신 (요청-응답 방식)
    func session(_ session: WCSession,
                 didReceiveMessage message: [String : Any],
                 replyHandler: @escaping ([String : Any]) -> Void) {
        
        guard let cmd = message["cmd"] as? String else {
            replyHandler(["result": "no_cmd"])
            return
        }
        
        print("📥 워치로부터 명령 수신: \(cmd)")
        
        switch cmd {
        case "startMeasuring":
            handleStartMeasuring(replyHandler: replyHandler)
            
        case "stopMeasuring":
            handleStopMeasuring(replyHandler: replyHandler)
            
        case "queryStatus":
            handleQueryStatus(replyHandler: replyHandler)
            
        case "navigateToMeasureView":
            handleNavigateToMeasureView(replyHandler: replyHandler)
            
        default:
            replyHandler(["result": "unknown_cmd"])
        }
    }
    
    /// 측정 시작 명령 처리
    private func handleStartMeasuring(replyHandler: @escaping ([String : Any]) -> Void) {
        // CameraManager에 접근하여 측정 시작
        // Note: CameraManager는 MeasureView에서 관리되므로, 
        // NotificationCenter를 통해 명령 전달
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .watchStartMeasuring, object: nil)
            replyHandler(["result": "ok"])
        }
    }
    
    /// 측정 종료 명령 처리
    private func handleStopMeasuring(replyHandler: @escaping ([String : Any]) -> Void) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .watchStopMeasuring, object: nil)
            replyHandler(["result": "ok"])
        }
    }
    
    /// 상태 질의 명령 처리
    private func handleQueryStatus(replyHandler: @escaping ([String : Any]) -> Void) {
        // 저장된 상태를 즉시 반환 (NotificationCenter 불필요)
        DispatchQueue.main.async {
            replyHandler([
                "cameraReady": self.isCameraReady,
                "isMeasuring": self.isMeasuring
            ])
            print("📱 상태 질의 응답: cameraReady=\(self.isCameraReady), isMeasuring=\(self.isMeasuring)")
        }
    }
    
    /// MeasureView로 네비게이션 후 측정 시작
    private func handleNavigateToMeasureView(replyHandler: @escaping ([String : Any]) -> Void) {
        print("📥 네비게이션 명령 수신됨")
        DispatchQueue.main.async {
            print("📱 shouldNavigateToMeasure = true 설정")
            self.shouldNavigateToMeasure = true
            self.shouldStartMeasuringAfterNav = true
            print("📱 현재 shouldNavigateToMeasure 값: \(self.shouldNavigateToMeasure)")
            replyHandler(["result": "ok"])
            print("📱 네비게이션 명령 응답 전송 완료")
        }
    }
    
    // MARK: - iOS 전용 Delegate 메서드
    
    #if os(iOS)
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("📱 WCSession이 비활성 상태가 됨")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("📱 WCSession이 비활성화됨 - 재활성화 시도")
        WCSession.default.activate()
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("📱 워치 연결 상태 변화: \(session.isReachable ? "연결됨" : "연결 끊김")")
    }
    
    #endif
    
    // MARK: - 공통 Delegate 메서드
    
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        if let error = error {
            print("❌ WCSession 활성화 오류: \(error.localizedDescription)")
        } else {
            print("✅ WCSession 활성화 완료: \(activationState.rawValue)")
            
            #if os(iOS)
            // 활성화 완료 후 디버그 정보 출력
            print("📊 활성화 후 상태:")
            print("  - isPaired: \(session.isPaired)")
            print("  - isWatchAppInstalled: \(session.isWatchAppInstalled)")
            print("  - isReachable: \(session.isReachable)")
            
            // 활성화 직후 현재 상태를 Watch로 전송
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                print("📡 활성화 후 초기 상태 전송")
                self.broadcastAllStatusToWatch()
            }
            #endif
        }
    }
    
    /// Application Context 수신 (백그라운드 명령 처리)
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("📥 iPhone: Application Context 수신됨")
        print("   내용: \(applicationContext)")
        
        DispatchQueue.main.async {
            // 새로운 명령 형식 처리 (Watch → iPhone)
            if let command = applicationContext["command"] as? String {
                print("📥 명령 수신: \(command)")
                
                switch command {
                case "navigateToMeasureView":
                    print("📥 네비게이션 명령 수신")
                    self.shouldNavigateToMeasure = true
                    self.shouldStartMeasuringAfterNav = true
                    print("📱 네비게이션 트리거 설정 완료")
                    
                case "startMeasuring":
                    print("📥 측정 시작 명령 수신")
                    NotificationCenter.default.post(name: .watchStartMeasuring, object: nil)
                    
                case "stopMeasuring":
                    print("📥 측정 중지 명령 수신")
                    NotificationCenter.default.post(name: .watchStopMeasuring, object: nil)
                    
                default:
                    print("⚠️ 알 수 없는 명령: \(command)")
                }
            }
            
            // 카메라 상태 업데이트 (iPhone → Watch)
            if let cameraReady = applicationContext["cameraReady"] as? Bool {
                self.isCameraReady = cameraReady
                print("📥 카메라 상태 업데이트: \(cameraReady)")
            }
            
            // 측정 상태 업데이트 (iPhone → Watch)
            if let measuring = applicationContext["isMeasuring"] as? Bool {
                self.isMeasuring = measuring
                print("📥 측정 상태 업데이트: \(measuring)")
            }
        }
    }
}

// MARK: - NotificationCenter Extension
extension Notification.Name {
    static let watchStartMeasuring = Notification.Name("watchStartMeasuring")
    static let watchStopMeasuring = Notification.Name("watchStopMeasuring")
    static let watchQueryStatus = Notification.Name("watchQueryStatus")
    static let cameraStatusChanged = Notification.Name("cameraStatusChanged")
    static let measuringStatusChanged = Notification.Name("measuringStatusChanged")
}

