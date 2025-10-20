//
//  CameraManager.swift
//  gacha
//
//  Created by Oh Seojin on 10/20/25.
//

import AVFoundation
import Combine
import SwiftUI
import UIKit
import Vision

// MARK: - 카메라 매니저
/// 카메라 세션을 관리하고 Vision을 이용해 신체를 감지하는 클래스
class CameraManager: NSObject, ObservableObject {

    // 카메라 관련
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")

    // Vision 관련
    private var bodyPoseRequest = VNDetectHumanBodyPoseRequest()

    var previewLayer: AVCaptureVideoPreviewLayer?

    override init() {
        super.init()
        setupCamera()
    }

    /// 카메라 초기 설정
    private func setupCamera() {
        print("🎥 카메라 설정 시작")

        // 카메라 권한 확인
        checkCameraPermission()

        // 1. 카메라 입력 설정
        guard
            let camera = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: .front
            )
        else {
            print("❌ 카메라를 찾을 수 없습니다")
            return
        }

        print("✅ 카메라 디바이스 찾음")

        do {
            let input = try AVCaptureDeviceInput(device: camera)

            // 세션 설정 시작
            captureSession.beginConfiguration()

            // 2. 입력을 세션에 추가
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }

            // 3. 세션 품질 설정 (720p - 성능과 정확도 균형)
            if captureSession.canSetSessionPreset(.hd1280x720) {
                captureSession.sessionPreset = .hd1280x720
            }

            // 4. 비디오 출력 설정
            videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)

            // 5. 출력을 세션에 추가
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }

            // 6. 비디오 출력 연결 설정 (가로 방향)
            if let connection = videoOutput.connection(with: .video) {
                connection.videoRotationAngle = 90  // Landscape Right
            }

            // 세션 설정 완료
            captureSession.commitConfiguration()

            // 7. 프리뷰 레이어 생성
            let previewLayer = AVCaptureVideoPreviewLayer(
                session: captureSession
            )
            previewLayer.videoGravity = .resizeAspectFill

            // 프리뷰를 가로 방향으로 설정 (Landscape Right)
            if let connection = previewLayer.connection {
                connection.videoRotationAngle = 180
                print("✅ 프리뷰 레이어 회전 설정: 180도")
            } else {
                print("⚠️ 프리뷰 레이어 연결을 찾을 수 없음")
            }

            self.previewLayer = previewLayer
            print("✅ 카메라 설정 완료")

        } catch {
            print("❌ 카메라 설정 에러: \(error.localizedDescription)")
        }
    }

    /// 카메라 권한 확인
    private func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        print("📹 카메라 권한 상태: \(status.rawValue)")

        switch status {
        case .authorized:
            print("✅ 카메라 권한 승인됨")
        case .notDetermined:
            print("⚠️ 카메라 권한 요청 필요")
            AVCaptureDevice.requestAccess(for: .video) { granted in
                print(granted ? "✅ 카메라 권한 승인됨" : "❌ 카메라 권한 거부됨")
            }
        case .denied:
            print("❌ 카메라 권한 거부됨 - 설정에서 변경 필요")
        case .restricted:
            print("❌ 카메라 권한 제한됨")
        @unknown default:
            print("❌ 알 수 없는 카메라 권한 상태")
        }
    }

    /// 카메라 세션 시작
    func startSession() {
        print("▶️ 카메라 세션 시작 요청")
        sessionQueue.async { [weak self] in
            self?.captureSession.startRunning()
            print("▶️ 카메라 세션 실행 중")
        }
    }

    /// 카메라 세션 종료
    func stopSession() {
        print("⏹️ 카메라 세션 종료 요청")
        sessionQueue.async { [weak self] in
            self?.captureSession.stopRunning()
            print("⏹️ 카메라 세션 종료됨")
        }
    }
}

// MARK: - 비디오 프레임 처리
extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    /// 카메라에서 프레임이 캡처될 때마다 호출되는 함수
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {

        // 1. 프레임을 이미지로 변환
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        else { return }

        // 2. Vision 요청 핸들러 생성
        let handler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            options: [:]
        )

        // 3. 신체 감지 요청 실행
        do {
            try handler.perform([bodyPoseRequest])

            // 4. 감지된 결과 처리
            guard let observation = bodyPoseRequest.results?.first else {
                return
            }

            //            processBodyPose(observation: observation)

        } catch {
            print("❌ Vision 요청 실패: \(error.localizedDescription)")
        }
    }
}
