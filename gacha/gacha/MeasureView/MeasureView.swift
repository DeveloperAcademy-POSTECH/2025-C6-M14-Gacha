//
//  CameraView.swift
//  gacha
//
//  Created by Oh Seojin on 10/20/25.
//

import AVFoundation
import SwiftData
import SwiftUI
import UIKit

// MARK: - 메인 뷰
/// Vision을 이용하여 사람의 신체를 인식하고 각도를 측정하는 뷰
struct MeasureView: View {
    @StateObject private var cameraManager = CameraManager()
    @Environment(\.modelContext) private var context
    @State private var showKneeSelector = false

    // NotificationCenter 옵저버 관리
    @State private var notificationObservers: [NSObjectProtocol] = []

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
                
                // 3. 원형 측정 버튼 (우측 중앙)
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        Button(action: {
                            if cameraManager.isMeasuring {
                                // 측정 종료
                                let result = cameraManager.stopMeasuring()
                                if let record = result {
                                    context.insert(record)
                                }
                                
                                do {
                                    try context.save()
                                    print("✅ 저장 성공!")
                                    
                                    // 저장 후 컨텍스트에서 직접 fetch해서 확인
                                    let descriptor = FetchDescriptor<MeasuredRecord>()
                                    let fetchedRecords = try context.fetch(descriptor)
                                    print("📊 컨텍스트에서 직접 fetch한 레코드 개수: \(fetchedRecords.count)")
                                    for (index, rec) in fetchedRecords.enumerated() {
                                        print("  [\(index)] ID: \(rec.id), Flexion: \(rec.flexionAngle), Extension: \(rec.extensionAngle)")
                                    }
                                } catch {
                                    print("❌ 저장 실패: \(error.localizedDescription)")
                                    print("상세 에러: \(error)")
                                }
                            } else {
                                // 측정 시작
                                cameraManager.startMeasuring()
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .stroke(Color.white, lineWidth: 4)
                                    .frame(width: 80, height: 80)
                                
                                if cameraManager.isMeasuring {
                                    // 측정 중: 빨간 사각형 (정지 아이콘)
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.red)
                                        .frame(width: 30, height: 30)
                                } else {
                                    // 측정 전: 빨간 원
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 60, height: 60)
                                }
                            }
                        }
                        .frame(width: 80, height: 80)
                        .padding(.trailing, 30)
                        Spacer()
                    }
                    .padding(.top, 40)

                    Spacer()

                    // 하단: 측정 버튼 (기존 코드 유지)
                    Button(action: {
                        if cameraManager.isRecording {
                            if let result = cameraManager.stopRecording() {
                                saveToDatabase(result)
                            }
                        } else {
                            cameraManager.startRecording()
                        }
                    }) {
                        Text(cameraManager.isRecording ? "측정 종료" : "측정 시작")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                cameraManager.isRecording
                                    ? Color.red : Color.green
                            )
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 40)
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
            
            // NotificationCenter 옵저버 등록
            setupNotificationObservers()
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
            
            // NotificationCenter 옵저버 해제
            removeNotificationObservers()
        }
        .sheet(isPresented: $showKneeSelector) {
            KneeSelectionView(selectedKnee: $cameraManager.selectedKnee)
        }
    }

    func saveToDatabase(_ result: MeasuredRecord) {
        do {
            try context.insert(result)
            try context.save() 
            print("✅ 저장 성공!")

            // 저장 후 컨텍스트에서 직접 fetch해서 확인
            let descriptor = FetchDescriptor<MeasuredRecord>()
            let fetchedRecords = try context.fetch(descriptor)
            print(
                "📊 컨텍스트에서 직접 fetch한 레코드 개수: \(fetchedRecords.count)"
            )
            for (index, rec) in fetchedRecords.enumerated() {
                print(
                    "  [\(index)] ID: \(rec.id), Flexion: \(rec.flexionAngle), Extension: \(rec.extensionAngle)"
                )
            }
        } catch {
            print("❌ 저장 실패: \(error.localizedDescription)")
            print("상세 에러: \(error)")
        }
    }
    
    // MARK: - NotificationCenter 관련 메서드
    
    private func setupNotificationObservers() {
        // Watch로부터 측정 시작 명령
        let startObserver = NotificationCenter.default.addObserver(
            forName: .watchStartMeasuring,
            object: nil,
            queue: .main
        ) { [self] _ in
            cameraManager.startMeasuring()
        }
        
        // Watch로부터 측정 종료 명령
        let stopObserver = NotificationCenter.default.addObserver(
            forName: .watchStopMeasuring,
            object: nil,
            queue: .main
        ) { [self] _ in
            let result = cameraManager.stopMeasuring()
            if let record = result {
                context.insert(record)
                do {
                    try context.save()
                    print("✅ Watch 명령으로 측정 종료 및 저장 성공")
                } catch {
                    print("❌ 저장 실패: \(error.localizedDescription)")
                }
            }
        }
        
        // queryStatus 옵저버는 제거됨 (WatchLink가 직접 상태 반환)
        
        notificationObservers = [startObserver, stopObserver]
    }
    
    private func removeNotificationObservers() {
        notificationObservers.forEach { observer in
            NotificationCenter.default.removeObserver(observer)
        }
        notificationObservers.removeAll()
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

struct KneeSelectionView: View {
    @Binding var selectedKnee: KneeSelection
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List {
                ForEach(KneeSelection.allCases, id: \.self) {
                    knee in
                    Button(action: {
                        selectedKnee = knee
                        dismiss()
                    }) {
                        HStack {
                            Text(knee.rawValue)
                                .foregroundColor(.primary)

                            Spacer()

                            if selectedKnee == knee {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("측정할 무릎 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.height(300)])
    }
}

#Preview {
    MeasureView()
        .modelContainer(for: [MeasuredRecord.self])
}
