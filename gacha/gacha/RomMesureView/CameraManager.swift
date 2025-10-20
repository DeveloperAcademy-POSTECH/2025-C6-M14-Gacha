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
        // 1. 카메라 입력 설정
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("❌ 카메라를 찾을 수 없습니다")
            return
        }

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

            // 6. 비디오 연결 설정 (가로 방향)
            if let connection = videoOutput.connection(with: .video) {
                if connection.isVideoRotationAngleSupported(0) {
                    connection.videoRotationAngle = 0  // 가로 방향
                }
            }

            // 세션 설정 완료
            captureSession.commitConfiguration()

            // 7. 프리뷰 레이어 생성
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill
            self.previewLayer = previewLayer

        } catch {
            print("❌ 카메라 설정 에러: \(error.localizedDescription)")
        }
    }

    /// 카메라 세션 시작
    func startSession() {
        sessionQueue.async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    /// 카메라 세션 종료
    func stopSession() {
        sessionQueue.async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }
}

// MARK: - 비디오 프레임 처리
extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    /// 카메라에서 프레임이 캡처될 때마다 호출되는 함수
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        // 1. 프레임을 이미지로 변환
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        // 2. Vision 요청 핸들러 생성
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])

        // 3. 신체 감지 요청 실행
        do {
            try handler.perform([bodyPoseRequest])

            // 4. 감지된 결과 처리
            guard let observation = bodyPoseRequest.results?.first else { return }

//            processBodyPose(observation: observation)

        } catch {
            print("❌ Vision 요청 실패: \(error.localizedDescription)")
        }
    }
}













