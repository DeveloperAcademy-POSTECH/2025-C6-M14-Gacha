//
//  MeasureFinishedView.swift
//  gacha
//
//  Created by 차원준 on 10/28/25.
//

import SwiftUI

struct MeasureFinishedView: View {
    let onComplete: () -> Void
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("측정이 완료되었습니다!")
                .font(Font.system(size: 30, weight: .bold))
                .opacity(opacity)
        }
        .onAppear {
            // 스프링 애니메이션
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
            
            // 1.5초 후 다음 단계로
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                onComplete()
            }
        }
    }
}

#Preview {
    MeasureFinishedView(onComplete: {
        print("완료!")
    })
}
