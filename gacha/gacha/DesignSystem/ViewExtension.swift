//
//  ViewExtension.swift
//  gacha
//
//  Created by 차원준 on 10/30/25.
//

import SwiftUI

// MARK: - Background Extensions

extension View {
    
    /// 전체 화면 배경 (배경만 Safe Area 무시, 콘텐츠는 Safe Area 존중)
    ///
    /// 일반 화면에서 사용 - 상단 버튼, 하단 버튼이 Safe Area 내에 배치됨
    ///
    /// ```swift
    /// VStack {
    ///     Text("Hello")
    ///     Spacer()
    ///     Button("확인") { }
    /// }
    /// .appBackground()  // ✅ 권장
    /// ```
    func appBackground() -> some View {
        self
            .background(
                Color("BackgroundBase")
                    .ignoresSafeArea()  // 배경만 Safe Area 무시
            )
    }
    
    /// 전체 영역 배경 (콘텐츠도 Safe Area 무시)
    ///
    /// 이미지 뷰어, 풀스크린 비디오 등 특수한 경우에만 사용
    ///
    /// ```swift
    /// Image("background")
    ///     .resizable()
    ///     .appBackgroundFullScreen()  // ⚠️ 특수 상황만
    /// ```
    func appBackgroundFullScreen() -> some View {
        self
            .background(Color("BackgroundBase"))
            .ignoresSafeArea()  // 전체 무시
    }
    
    /// 커스텀 Safe Area 설정
    ///
    /// 특정 영역만 Safe Area를 무시하고 싶을 때
    ///
    /// ```swift
    /// ScrollView {
    ///     // ...
    /// }
    /// .appBackground(ignoringSafeAreaEdges: .bottom)  // 하단만 무시
    /// ```
    func appBackground(ignoringSafeAreaEdges edges: Edge.Set) -> some View {
        self
            .background(
                Color("BackgroundBase")
                    .ignoresSafeArea(edges: edges)
            )
    }
}
