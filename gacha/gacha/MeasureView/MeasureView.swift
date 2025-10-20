//
//  CameraView.swift
//  gacha
//
//  Created by Oh Seojin on 10/20/25.
//

import AVFoundation
import SwiftUI
import UIKit

// MARK: - 메인 뷰
/// Vision을 이용하여 사람의 신체를 인식하고 각도를 측정하는 뷰
struct MeasureView: View {
    @StateObject private var cameraManager = CameraManager()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 1. 카메라 프리뷰 레이어 (배경)
                CameraPreview(cameraManager: cameraManager)
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .ignoresSafeArea()

                // 2. 감지된 신체 랜드마크와 각도를 그리는 오버레이
                BodyOverlayView(detectedBody: cameraManager.detectedBody)
                
                // 3. 측정 버튼
                HStack {
                    Button("측정") {
                        cameraManager.startRecording()
                    }
                    Button("종료") {
                        print(">>>",cameraManager.stopRecording())
                    }
                }
                
                
            }
        }
        .ignoresSafeArea()
        .onAppear {
            // 화면 가로로 바꾸기
            if #available(iOS 16.0, *) {
                let windowScene =
                    UIApplication.shared.connectedScenes.first as? UIWindowScene
                windowScene?.requestGeometryUpdate(
                    .iOS(interfaceOrientations: .landscapeRight)
                )
            } else {
                let value = UIInterfaceOrientation.landscapeRight.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
            }

            cameraManager.startSession()
        }
        .onDisappear {
            cameraManager.stopSession()

            // 화면 세로로 되돌리기
            if #available(iOS 16.0, *) {
                let windowScene =
                    UIApplication.shared.connectedScenes.first as? UIWindowScene
                windowScene?.requestGeometryUpdate(
                    .iOS(interfaceOrientations: .portrait)
                )
            } else {
                let value = UIInterfaceOrientation.portrait.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
            }
        }
    }
}

// MARK: - 카메라 프리뷰 뷰
/// 카메라 화면을 보여주는 UIView를 SwiftUI로 감싸는 뷰
struct CameraPreview: UIViewRepresentable {
    let cameraManager: CameraManager

    func makeUIView(context: Context) -> PreviewView {
        print("🖼️ CameraPreviewView makeUIView 호출")
        let view = PreviewView()
        view.backgroundColor = .black
        view.previewLayer = cameraManager.previewLayer

        if let previewLayer = cameraManager.previewLayer {
            view.layer.addSublayer(previewLayer)
            print("✅ 프리뷰 레이어 추가됨")
        } else {
            print("❌ 프리뷰 레이어가 없음")
        }

        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        // updateUIView는 레이아웃 변경 시 자동으로 호출됨
        print("🔄 updateUIView 호출: \(uiView.bounds)")
    }
}

// 프리뷰 레이어 자동 크기 조정을 위한 커스텀 UIView
class PreviewView: UIView {
    var previewLayer: AVCaptureVideoPreviewLayer?

    override func layoutSubviews() {
        super.layoutSubviews()

        // 레이아웃이 변경될 때마다 프리뷰 레이어 크기 자동 조정
        if let previewLayer = previewLayer {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            previewLayer.frame = bounds
            CATransaction.commit()
            print("📐 프리뷰 레이어 layoutSubviews: \(bounds)")
        }
    }
}

#Preview {
    MeasureView()
}
