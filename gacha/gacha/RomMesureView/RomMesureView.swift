//
//  CameraView.swift
//  gacha
//
//  Created by Oh Seojin on 10/20/25.
//

import SwiftUI
import UIKit

// MARK: - 메인 뷰
/// Vision을 이용하여 사람의 신체를 인식하고 각도를 측정하는 뷰
struct RomMesureView: View {
    @StateObject private var cameraManager = CameraManager()

    var body: some View {
        ZStack {
            // 1. 카메라 프리뷰 레이어 (배경)
            CameraPreviewView(cameraManager: cameraManager)
                .ignoresSafeArea()
        }
        .onAppear {
            cameraManager.startSession()
        }
        .onDisappear {
            cameraManager.stopSession()
        }
    }
}

// MARK: - 카메라 프리뷰 뷰
/// 카메라 화면을 보여주는 UIView를 SwiftUI로 감싸는 뷰
struct CameraPreviewView: UIViewRepresentable {
    let cameraManager: CameraManager

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black

        if let previewLayer = cameraManager.previewLayer {
            previewLayer.frame = view.bounds
            view.layer.addSublayer(previewLayer)
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = cameraManager.previewLayer {
            DispatchQueue.main.async {
                previewLayer.frame = uiView.bounds
            }
        }
    }
}

#Preview {
    RomMesureView()
}
