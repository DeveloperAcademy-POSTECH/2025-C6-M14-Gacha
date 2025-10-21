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

let FLEXION_BASIC_ANGLE: Double = 90.0
let EXTENSION_BASIC_ANGLE: Double = 0.0


// MARK: - 카메라 매니저
/// 카메라 세션을 관리하고 Vision을 이용해 신체를 감지하는 클래스
class CameraManager: NSObject, ObservableObject {

    // 카메라 관련
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")

    // Vision 관련
    private var bodyPoseRequest = VNDetectHumanBodyPoseRequest()

    // 감지된 데이터 - View에서 사용하기 위해 Publish
    @Published var detectedBody: DetectedBody?
    @Published var currentAngles: BodyAngles?

    @Published var isRecording: Bool = false
    @Published var flexionAngle: Double?
    @Published var extensionAngle: Double?

    private var currentPixelBuffer: CVPixelBuffer?  // ⭐ 현재 프레임의 pixelBuffer 저장용
    private var flexionAngleImage: UIImage?  // 굴곡 시 이미지
    private var extensionAngleImage: UIImage?  // 신전 시 이미지

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
                position: .back
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
            let previewLayer = AVCaptureVideoPreviewLayer(
                session: captureSession
            )
            previewLayer.videoGravity = .resizeAspectFill

            // (9) 프리뷰의 레이어 연결에서 방향을 가로 방향으로 설정 (Landscape Right)
            if let connection = previewLayer.connection {
                connection.videoRotationAngle = 0
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

    func startRecording() {
        isRecording = true
        flexionAngle = nil
        extensionAngle = nil

        print("📸 측정 시작")
    }

    func stopRecording() -> MeasuredRecord? {
        isRecording = false

        // image 인앱에 저장
        if let flexionImage = flexionAngleImage,
            let extensionImage = extensionAngleImage
        {
            let result = saveImage(flexionImage, extensionImage)
            
            if let result = result {
                return MeasuredRecord(
                    flexionAngle: Int(flexionAngle ?? FLEXION_BASIC_ANGLE),
                    extensionAngle: Int(extensionAngle ?? EXTENSION_BASIC_ANGLE),
                    isDeleted: false,
                    flexionImage_id: "\(result.0)",
                    extensionImage_id: "\(result.1)"
                )
            } else {
                print("🚨 이미지 저장 오류")
                return nil
            }
        } else {
            print("🚨 이미지 저장 오류")
            return nil
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

        if !isRecording { return }

        // 1. 프레임을 이미지로 변환
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        else { return }

        // ⭐ 2. 현재 pixelBuffer를 저장 (이미지 캡처용)
        if isRecording {
            self.currentPixelBuffer = pixelBuffer
        }

        // 3. Vision 요청 핸들러 생성
        let handler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            options: [:]
        )

        // 4. 신체 감지 요청 실행
        do {
            try handler.perform([bodyPoseRequest])

            guard let observation = bodyPoseRequest.results?.first else {
                return
            }

            // 5. 신체 포즈 처리 (각도 계산 및 이미지 저장)
            processBodyPose(observation: observation)

        } catch {
            print("❌ Vision 요청 실패: \(error.localizedDescription)")
        }
    }

    /// 감지된 신체 포즈를 처리하는 함수
    private func processBodyPose(observation: VNHumanBodyPoseObservation) {
        // 주요 관절 포인트 추출
        guard
            let recognizedPoints = try? observation.recognizedPoints(.rightLeg)
        else { return }

        // 신뢰도가 높은 포인트만 필터링 (0.3 이상으로 낮춤 - 더 많은 포인트 감지)
        let validPoints = recognizedPoints.filter { $0.value.confidence > 0.3 }

        // 디버그: 감지된 관절 정보 출력
//        #if DEBUG
//            let kneePoints = validPoints.filter {
//                $0.key == .leftKnee || $0.key == .rightKnee
//                    || $0.key == .leftHip || $0.key == .rightHip
//                    || $0.key == .leftAnkle || $0.key == .rightAnkle
//            }
//            if !kneePoints.isEmpty {
//                print("📍 감지된 하체 관절:")
//                for (joint, point) in kneePoints {
//                    print(
//                        "  \(joint.rawValue): 신뢰도 \(String(format: "%.2f", point.confidence))"
//                    )
//                }
//            }
//        #endif

        // DetectedBody 객체 생성
        let body = DetectedBody(points: validPoints)

        guard let angles = calculateAngles(from: validPoints) else {
            print("⚠️ 각도 계산 실패")
            return
        }

        // UI 업데이트 (메인 스레드에서)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.detectedBody = body
            self.currentAngles = angles

            guard let angle = angles.rightKnee ?? angles.leftKnee else {
                print("⚠️ 무릎 각도 감지 실패")
                return
            }

            let angleDifferenceThreshold = 30.0

            // 굴곡 각도(최소) 업데이트
            if self.flexionAngle == nil {
                self.flexionAngle = angle
                self.flexionAngleImage = self.captureCurrentFrame()  // ⭐ 이미지 캡처
                print("🔽 초기 굴곡 각도: \(String(format: "%.1f", angle))°")
            } else if angle < self.flexionAngle! {
                let difference = abs(angle - self.flexionAngle!)
                if difference < angleDifferenceThreshold {
                    self.flexionAngle = angle
                    self.flexionAngleImage = self.captureCurrentFrame()  // ⭐ 이미지 캡처
                    print(
                        "🔽 굴곡 각도 업데이트: \(String(format: "%.1f", angle))° (이미지 저장)"
                    )
                }
            }

            // 신전 각도(최대) 업데이트
            if self.extensionAngle == nil {
                self.extensionAngle = angle
                self.extensionAngleImage = self.captureCurrentFrame()  // ⭐ 이미지 캡처
                print("🔼 초기 신전 각도: \(String(format: "%.1f", angle))°")
            } else if angle > self.extensionAngle! {
                let difference = abs(angle - self.extensionAngle!)
                if difference < angleDifferenceThreshold {
                    self.extensionAngle = angle
                    self.extensionAngleImage = self.captureCurrentFrame()  // ⭐ 이미지 캡처
                    print(
                        "🔼 신전 각도 업데이트: \(String(format: "%.1f", angle))° (이미지 저장)"
                    )
                }
            }
        }
    }

    /// 관절 포인트들로부터 각도를 계산하는 함수
    private func calculateAngles(
        from points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]
    ) -> BodyAngles? {

        // 무릎 각도만 계산 (팔 각도는 nil로 설정)

        // 오른쪽 무릎 각도 계산 (엉덩이-무릎-발목)
        let rightKneeAngle = calculateAngle(
            point1: points[.rightHip],
            point2: points[.rightKnee],
            point3: points[.rightAnkle]
        )

        // 왼쪽 무릎 각도 계산
        let leftKneeAngle = calculateAngle(
            point1: points[.leftHip],
            point2: points[.leftKnee],
            point3: points[.leftAnkle]
        )

        // 디버그: 각도 계산 결과 출력
        #if DEBUG
            if let rightAngle = rightKneeAngle {
                print("  ✅ 오른쪽 무릎 각도: \(String(format: "%.1f", rightAngle))°")
            } else {
                print("  ❌ 오른쪽 무릎 각도 계산 실패")
            }

            if let leftAngle = leftKneeAngle {
                print("  ✅ 왼쪽 무릎 각도: \(String(format: "%.1f", leftAngle))°")
            } else {
                print("  ❌ 왼쪽 무릎 각도 계산 실패")
            }
        #endif

        return BodyAngles(
            rightKnee: rightKneeAngle,
            leftKnee: leftKneeAngle
        )
    }

    /// 세 점으로 각도를 계산하는 함수
    /// - Parameters:
    ///   - point1: 첫 번째 점 (예: 어깨)
    ///   - point2: 중간 점 (예: 팔꿈치) - 각도의 꼭짓점
    ///   - point3: 세 번째 점 (예: 손목)
    /// - Returns: 각도 (degree)
    private func calculateAngle(
        point1: VNRecognizedPoint?,
        point2: VNRecognizedPoint?,
        point3: VNRecognizedPoint?
    ) -> Double? {
        guard let p1 = point1, let p2 = point2, let p3 = point3 else {
            return nil
        }

        // 1. 벡터 생성
        let vector1 = CGPoint(
            x: p1.location.x - p2.location.x,
            y: p1.location.y - p2.location.y
        )
        let vector2 = CGPoint(
            x: p3.location.x - p2.location.x,
            y: p3.location.y - p2.location.y
        )

        // 2. 내적 계산
        let dotProduct = vector1.x * vector2.x + vector1.y * vector2.y

        // 3. 벡터 크기 계산
        let magnitude1 = sqrt(vector1.x * vector1.x + vector1.y * vector1.y)
        let magnitude2 = sqrt(vector2.x * vector2.x + vector2.y * vector2.y)

        // 4. 코사인 값 계산
        let cosine = dotProduct / (magnitude1 * magnitude2)

        // 5. 라디안을 각도로 변환
        let angleInRadians = acos(min(max(cosine, -1), 1))  // -1 ~ 1 사이로 제한
        let angleInDegrees = angleInRadians * 180 / .pi

        return angleInDegrees
    }

    /// 현재 저장된 pixelBuffer를 UIImage로 변환하여 반환
    private func captureCurrentFrame() -> UIImage? {
        guard let pixelBuffer = currentPixelBuffer else {
            print("⚠️ 저장된 pixelBuffer가 없음")
            return nil
        }

        guard var image = pixelBufferToUIImage(pixelBuffer) else { return nil }

        if let compressedData = image.jpegData(compressionQuality: 0.8) {
            image = UIImage(data: compressedData) ?? image
            print("📸 이미지 캡처 및 압축 완료")
        }

        return image
    }

    /// CVPixelBuffer를 UIImage로 변환
    private func pixelBufferToUIImage(_ pixelBuffer: CVPixelBuffer) -> UIImage?
    {
        // 1. CVPixelBuffer를 CIImage로 변환
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)

        // 2. CIContext 생성 (한 번만 생성해서 재사용하는 것이 좋음)
        let context = CIContext()

        // 3. CIImage를 CGImage로 변환
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
        else {
            print("❌ CGImage 변환 실패")
            return nil
        }

        // 4. CGImage를 UIImage로 변환
        // 회전 각도 고려 (카메라 방향에 맞춰 조정)
        let image = UIImage(cgImage: cgImage, scale: 1.0, orientation: .right)

        return image
    }
}
