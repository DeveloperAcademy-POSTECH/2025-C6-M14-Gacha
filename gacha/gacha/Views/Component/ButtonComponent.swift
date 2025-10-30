//
//  BackButton.swift
//  gacha
//
//  Created by 차원준 on 10/30/25.
//

import SwiftUI

/// `ButtonComponent`
///
/// 재사용 가능한 커스텀 버튼 컴포넌트로,
/// SF Symbol 아이콘과 함께 다양한 크기, 색상, 활성화 상태를 지정할 수 있습니다.
///
/// 사용 예시:
/// ```swift
/// ButtonComponent(
///     systemImageName: "globe",
///     size: 20,
///     weight: .medium,
///     color: .black,
///     isActivate: true
/// ) {
///     print("hello")
/// }
/// ```
///
/// - Parameters:
///   - background: 버튼 배경 색. 기본값은 `.clear`
///   - systemImageName: 표시할 SF Symbol 이미지 이름 (예: `"globe"`)
///   - size: 아이콘의 폰트 크기. 기본값은 `17`
///   - weight: 아이콘의 폰트 두께(`.regular`, `.medium`, `.bold` 등). 기본값은 `.medium`
///   - color: 아이콘 색상. 기본값은 `.black`
///   - isActivate: 버튼 활성화 여부. `false`이면 투명해지고 터치가 비활성화됨
///   - action: 버튼이 눌렸을 때 실행되는 클로저
///

struct ButtonComponent: View {
    
    // 배경 색
    var background: Color = .clear
    
    // 이미지 이름
    var systemImageName: String

    // 폰트 (크기, weight, 색깔)
    var size: CGFloat = 22
    var weight: Font.Weight = .medium
    var color: Color = .black
    // 비활성화 여부
    var isActivate: Bool = true
    // action
    var action: () -> Void
    
    
    var body: some View {
        Button(action: action){
            ZStack{
                Circle()
                    .fill(background)
                    .frame(width: 44, height: 44)
                
                Image(systemName: "\(systemImageName)")
                    .frame(width: 44, height: 44)
                    .font(Font.system(size: size, weight: weight))
                    .foregroundStyle(color)

            }
        }
        .opacity(isActivate ? 1 : 0)
        .allowsHitTesting(isActivate)
        .buttonStyle(.plain)
    }
}


#Preview {
    ButtonComponent(systemImageName: "globe", size: 20, weight: .medium, isActivate: true, action: {print("hello")})
}
