//
//  ContentView.swift
//  gacha Watch App
//
//  Created by Oh Seojin on 10/20/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var watchLink = WatchLink.shared
    
    var body: some View {
        VStack(spacing: 20) {
            // 상단: iPhone 상태 표시
            Text(watchLink.cameraReady ? "카메라 준비됨" : "카메라 준비 중...")
                .font(.caption)
                .foregroundColor(watchLink.cameraReady ? .green : .gray)
            
            // 중앙: 큰 원형 측정 버튼
            Button(action: {
                print("⌚️ Watch 버튼 클릭 - cameraReady: \(watchLink.cameraReady)")
                if !watchLink.cameraReady {
                    // 카메라 준비 안됨 - MeasureView로 이동 + 측정 시작
                    print("⌚️ 네비게이션 명령 전송 시도")
                    watchLink.navigateAndStartMeasuring()
                } else {
                    // 카메라 준비됨 - 토글
                    print("⌚️ 측정 토글 시도")
                    watchLink.toggleMeasuring()
                }
            }) {
                ZStack {
                    Circle()
                        .stroke(Color.white, lineWidth: 4)
                        .frame(width: 80, height: 80)
                    
                    if watchLink.isMeasuring {
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
            .buttonStyle(.plain)
            
            // 하단: 상태 텍스트
            Text(watchLink.isMeasuring ? "측정 중..." : "탭하여 측정")
                .font(.caption2)
                .foregroundColor(.white)
            
            // 연결 상태 표시
            if !watchLink.reachable {
                Text("iPhone 연결 끊김")
                    .font(.caption2)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .onAppear {
            print("⌚️ Watch ContentView appeared")
            // WatchLink는 이미 앱 초기화 시 시작되었으므로 여기서는 상태만 확인
            print("⌚️ 연결 상태: \(watchLink.reachable ? "연결됨" : "연결 안됨")")
        }
    }
}

#Preview {
    ContentView()
}
