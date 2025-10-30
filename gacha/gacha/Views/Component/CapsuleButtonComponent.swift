//
//  CapsuleButtonComponent.swift
//  gacha
//
//  Created by 차원준 on 10/30/25.
//

import SwiftUI

/// `CapsuleButtonComponent`
///
/// 재사용 가능한 캡슐 형태의 버튼 컴포넌트
/// 고정된 크기(313x50)와 폰트(17pt semibold)를 사용합니다.
///
/// 사용 예시:
/// ```swift
/// CapsuleButtonComponent(
///     title: "측정시작하기",
///     style: .primary
/// ) {
///     print("버튼 클릭")
/// }
/// ```
///
/// - Parameters:
///   - title: 버튼에 표시될 텍스트
///   - style: 버튼 스타일 (`.primary` 또는 `.secondary`)
///   - isEnabled: 버튼 활성화 여부. 기본값은 `true`
///   - action: 버튼이 눌렸을 때 실행되는 클로저

struct CapsuleButtonComponent: View {
    
    // MARK: - Properties
    
    // 텍스트
    var title: String
    
    // 스타일
    enum ButtonStyle {
        case primary    // Primary500 배경, White 텍스트
        case secondary  // Gray100 배경, Gray900 텍스트
        
        var backgroundColor: Color {
            switch self {
            case .primary: return Color("Primary500")
            case .secondary: return Color("Gray100")
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary: return Color("White")
            case .secondary: return Color("Gray900")
            }
        }
    }
    
    var style: ButtonStyle = .primary
    
    // 활성화 여부
    var isEnabled: Bool = true
    
    // 액션
    var action: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(style.foregroundColor)
                .frame(width: 313, height: 50)
                .background(style.backgroundColor)
                .clipShape(Capsule())
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.5)
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 20) {
        CapsuleButtonComponent(
            title: "Primary Button",
            style: .primary
        ) {
            print("Primary clicked")
        }
        
        CapsuleButtonComponent(
            title: "Secondary Button",
            style: .secondary
        ) {
            print("Secondary clicked")
        }
        
        CapsuleButtonComponent(
            title: "Disabled Button",
            style: .primary,
            isEnabled: false
        ) {
            print("This won't be called")
        }
    }
    .padding()
}

