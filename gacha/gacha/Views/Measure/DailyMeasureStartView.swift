//
//  DailyMeasureStartView.swift
//  gacha
//
//  Created by 차원준 on 10/28/25.
//

import SwiftData
import SwiftUI
import UIKit
import AVKit
import AVFoundation

struct DailyMeasureStartView2: View {
    @EnvironmentObject var vm: MeasureViewModel
    
    @State private var isPlaying = true
    @State private var selection = 0

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // MARK: - 상단 영역
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(Strings.DailyStart.title)
                            .font(.displayLargeBold)
                        Text(Strings.DailyStart.description)
                            .font(.displayTitle3Medium)
                    }
                }
                .padding(.horizontal, 16)

                Spacer()

                // MARK: - 중간 영역
                VStack(spacing: 16) {
                    VStack {
                        LoopingVideoPlayer(videoName: "guideVideo", isPlaying: $isPlaying)
                            .frame(width: 175, height: 175)
                            .cornerRadius(12)
                        Text("측정 시작하기를 누르면 최대한 다리를 굽히고, 2초동안 자세를 유지해주세요.")
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 32)
                }
                .frame(maxWidth: .infinity)
                .background(.white)
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 2)
                .padding(.horizontal, 20)

                Spacer()

                // MARK: - 측정 버튼
                CapsuleButtonComponent(
                    title: Strings.DailyStart.button,
                    style: .primary
                ) {
                    vm.shouldAutoStartMeasure = true  // 자동 시작 플래그 설정
                    vm.navigationPath.append(MeasureFlowStep.flexionMeasure)
                }
                .padding(.horizontal, 40)

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .appBackground()
        }
    }
}

struct LoopingVideoPlayer: UIViewControllerRepresentable {
    let videoName: String
    @Binding var isPlaying: Bool

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspect
        controller.view.backgroundColor = .white

        guard let path = Bundle.main.path(forResource: videoName, ofType: "mp4") else {
            return controller
        }

        let player = AVPlayer(url: URL(fileURLWithPath: path))
        player.isMuted = true
        controller.player = player

        // 반복 재생 설정
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            player.seek(to: .zero)
            if self.isPlaying {
                player.rate = 0.75
            }
        }

        if isPlaying {
            player.rate = 0.75
        }

        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        guard let player = uiViewController.player else { return }

        if isPlaying {
            player.rate = 0.6
        } else {
            player.pause()
        }
    }
}

#Preview {
    // 1. 메모리 전용 ModelContainer 생성
    let container = try! ModelContainer(
        for: MeasuredRecord.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    // 2. Repository 생성
    let repository = SwiftDataRecordRepository(
        modelContext: container.mainContext
    )

    // 3. ViewModel 생성
    let vm = MeasureViewModel(repository: repository)

    DailyMeasureStartView2()
        .environmentObject(vm)
}
