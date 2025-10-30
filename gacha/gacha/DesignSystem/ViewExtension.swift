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
    /// .appBackground()
    /// ```
    func appBackground() -> some View {
        self
            .background(
                LinearGradient(
                        colors: [Color("Primary500"), Color("Primary100")],
                        startPoint: .top,
                        endPoint: .bottom
                            )
                    .ignoresSafeArea()  // 배경만 Safe Area 무시
            )
    }

}
