//
//  gachaApp.swift
//  gacha
//
//  Created by Oh Seojin on 10/20/25.
//

import SwiftData
import SwiftUI

@main
struct gachaApp: App {

    /// swiftData에서 데이터를 저장, 읽기 위해서 ModelContainer 필요
    /// ModelContainer는 앱이 시작될 때 한 번만 설정되어야 해서 init( ) 에서 초기화한다.
    let modelContainer: ModelContainer

    init() {
        do {
            /// swiftData가 저장할 모델 목록 정의
            let schema = Schema([MeasuredRecord.self])
            /// 실제 저장 위치와 설정 정의
            /// schema: 모델 목록
            /// isStoredInMemoryOnly: false(앱 종료 후에도 유지), true(앱 종료 시 데이터 삭제)
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )

            /// 최종 컨테이너 생성
            /// for: SwiftData가 관리할 모델
            /// configurations: 여러 데이터 저장소 설정을 배열로 받는다.
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            print("✅ ModelContainer 초기화 성공")
        } catch {
            /// 에러 처리
            fatalError("ModelContainer 초기화 실패: \(error)")
        }

        // WatchConnectivity 초기화
        #if os(iOS)
            WatchLink.shared.start()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .onAppear {
                    // 앱 시작 시 목업 데이터 생성 (데이터가 없을 때만)
                    MockDataGenerator.generateMockData(context: modelContainer.mainContext)
                }
        }
        .modelContainer(modelContainer)
    }
}

struct RootTabView: View {
    @State private var selectedTab = 0
    @State private var navigationID = UUID()  // NavigationStack 재생성용 ID

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house", value: 0) {
                MainView()
            }
            Tab("History", systemImage: "book.closed", value: 1) {
                HistoryView()
            }
            Tab("Camera", systemImage: "camera", value: 2, role: .search) {
                NavigationStack {
                    MeasureView(onDismissToHome: {
                        selectedTab = 1  // History 탭으로 이동
                    })
                }
                .id(navigationID)  // ID로 NavigationStack 재생성
            }
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            // Camera 탭으로 전환될 때마다 NavigationStack 초기화
            if newValue == 2 {
                navigationID = UUID()
            }
        }
    }
}
