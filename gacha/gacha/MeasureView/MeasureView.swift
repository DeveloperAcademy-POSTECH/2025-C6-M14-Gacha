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
    @State private var navigateToDetail = false
    @State private var measuredRecord: MeasuredRecord?
    @State private var showKneeSelector = false
    // NotificationCenter 옵저버 관리
    @State private var notificationObservers: [NSObjectProtocol] = []

    var onDismissToHome: (() -> Void)? = nil

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

                // 1.5. 측정중이면 초록색 필터 씌우기
                if cameraManager.isMeasuring {
                    Color.green.opacity(0.3)
                }

                // 2. 감지된 신체 랜드마크와 각도를 그리는 오버레이
                BodyOverlayView(detectedBody: cameraManager.detectedBody)

                // 3. 원형 측정 버튼 (우측 중앙)
                VStack {
                    // 상단: 무릎 선택 버튼
                    VStack {
                        Button(action: {
                            showKneeSelector = true
                        }) {
                            HStack {
                                Image(systemName: "person.fill")
                                Text(cameraManager.selectedKnee.rawValue)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .padding()
                        .padding(.top, 20)

                        Spacer()

                        // 중앙: 준비 자세 안내
                        if !cameraManager.isMeasuring {
                            VStack(spacing: 16) {
                                if cameraManager.isInReadyPosition {
                                    // 준비 자세 진행률 표시
                                    VStack(spacing: 8) {
                                        Text("준비 자세 유지 중...")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)

                                        // 진행 바
                                        ProgressView(
                                            value: cameraManager
                                                .readyPositionProgress
                                        )
                                        .progressViewStyle(
                                            LinearProgressViewStyle(
                                                tint: .green
                                            )
                                        )
                                        .frame(width: 200)

                                        Text(
                                            "\(Int(cameraManager.readyPositionProgress * 100))%"
                                        )
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    }
                                    .padding()
                                    .background(Color.black.opacity(0.7))
                                    .cornerRadius(12)
                                } else {
                                    // 준비 자세 안내
                                    VStack(spacing: 8) {
                                        Text("다리를 펴고 앉아주세요")
                                            .font(.title3)
                                            .foregroundColor(.white)

                                        Text("150-180도 범위를 2초간 유지")
                                            .font(.caption)
                                            .foregroundColor(
                                                .white.opacity(0.8)
                                            )
                                    }
                                    .padding()
                                    .background(Color.black.opacity(0.7))
                                    .cornerRadius(12)
                                }
                            }
                            .transition(.opacity)
                        }

                        Spacer()

                        // 하단: 측정 버튼
                        if cameraManager.isMeasuring {
                            Button {
                                // 1. 측정 종료
                                if let result = cameraManager.stopMeasuring() {
                                    // 2. DB 저장
                                    saveToDatabase(result)

                                    // 3. 측정 결과 저장
                                    measuredRecord = result

                                    // 4. 카메라 세션 중지
                                    cameraManager.stopSession()

                                    // 5. DetailView로 이동
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        navigateToDetail = true
                                    }
                                }
                            } label: {
                                Circle()
                                    .fill(Color.clear)  // 투명한 원
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 4)
                                    )
                                    .overlay(
                                        Group {
                                            if cameraManager.isMeasuring {
                                                // 측정 중: 빨간 사각형 (정지 아이콘)
                                                RoundedRectangle(
                                                    cornerRadius: 4
                                                )
                                                .fill(Color.red)
                                                .frame(width: 30, height: 30)
                                            } 
                                        }
                                    )
                            }
                            .frame(width: 80, height: 80)
                            .padding(.trailing, 30)
                        }
                        Spacer()
                    }
                    .padding(.top, 40)
                }

                // ConfirmView로 네비게이션
                NavigationLink(
                    destination: measuredRecord != nil
                        ? ConfirmView(
                            record: measuredRecord!,
                            onConfirm: {
                                // 확인 버튼: DetailView로 이동
                                // (ConfirmView에서 직접 처리)
                            },
                            onRetake: {
                                // 다시 촬영 버튼: 카메라로 돌아가기
                                navigateToDetail = false
                                measuredRecord = nil
                            },
                            onDismissToHome: {
                                // DetailView에서 Home으로 이동
                                onDismissToHome?()
                            }
                        )
                        .navigationBarHidden(true) : nil,
                    isActive: $navigateToDetail
                ) {
                    EmptyView()
                }
                .hidden()
                .onChange(of: navigateToDetail) { _, isActive in
                    // ConfirmView에서 돌아왔을 때 카메라 재시작
                    if !isActive {
                        cameraManager.startSession()
                    }
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            cameraManager.startSession()

            // NotificationCenter 옵저버 등록
            setupNotificationObservers()
        }
        .task {
            // 탭 전환 시에도 확실하게 가로 회전
            rotateToLandscape()
        }
        .onDisappear {
            cameraManager.stopSession()

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

    // MARK: - Orientation 관련 메서드

    private func rotateToLandscape() {
        if #available(iOS 16.0, *) {
            guard
                let windowScene = UIApplication.shared.connectedScenes.first
                    as? UIWindowScene
            else { return }
            windowScene.requestGeometryUpdate(
                .iOS(interfaceOrientations: .landscapeRight)
            )
        } else {
            let value = UIInterfaceOrientation.landscapeRight.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
        print("📱 화면 가로 회전 요청")
    }

    private func rotateToPortrait() {
        if #available(iOS 16.0, *) {
            guard
                let windowScene = UIApplication.shared.connectedScenes.first
                    as? UIWindowScene
            else { return }
            windowScene.requestGeometryUpdate(
                .iOS(interfaceOrientations: .portrait)
            )
        } else {
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
        print("📱 화면 세로 회전 요청")
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

                    // DetailView로 네비게이션
                    measuredRecord = record
                    navigateToDetail = true
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
