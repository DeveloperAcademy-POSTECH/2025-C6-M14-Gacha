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
        // (1) 카메라 디바이스 설정: 전면
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

        do {
            let input = try AVCaptureDeviceInput(device: camera)

            // (2) 세션 설정 시작
            captureSession.beginConfiguration()

            // (3) 입력을 세션에 추가
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }

            // (4) 세션 품질 설정
            if captureSession.canSetSessionPreset(.hd1280x720) {
                captureSession.sessionPreset = .hd1280x720
            }

            // (5) 비디오 출력 설정
            videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)

            // (6) 출력을 세션에 추가
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }

            // (7) 레이어 설정 완료
            captureSession.commitConfiguration()

            // (8) 프리뷰 레이어 생성
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill

            // (9) 프리뷰의 레이어 연결에서 방향을 가로 방향으로 설정 (Landscape Right)
            if let connection = previewLayer.connection {
                connection.videoRotationAngle = 180
                print("✅ 프리뷰 레이어 회전 설정: 180도")
            } else {
                print("⚠️ 프리뷰 레이어 연결을 찾을 수 없음")
            }
            
            // (10) 프리뷰 설정 완료
            self.previewLayer = previewLayer
            print("✅ 카메라 설정 완료")

        } catch {
            print("❌ 카메라 설정 에러: \(error.localizedDescription)")
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
