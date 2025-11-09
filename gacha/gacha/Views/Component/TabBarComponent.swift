//
//  TabBarComponent.swift
//  gacha
//
//  Created by 차원준 on 10/30/25.
//

import SwiftUI

/// TabBarItem 타입
enum TabBarItem: CaseIterable {
    case calendar
    case measure
    case summary
    
    var systemImageName: String {
        switch self {
        case .calendar: return "calendar"
        case .measure: return "ruler"
        case .summary: return "chart.bar"
        }
    }
    
    var title: String {
        switch self {
        case .calendar: return Strings.Tabbar.calendar
        case .measure: return Strings.Tabbar.measure
        case .summary: return Strings.Tabbar.summary
        }
    }
}

/// `TabBarComponent`
///
/// 하단 탭 바 컴포넌트
/// 캘린더, 측정, 요약 탭을 포함하며 확장 가능한 구조입니다.
struct TabBarComponent: View {
    @Binding var selectedTab: TabBarItem
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabBarItem.allCases, id: \.self) { tab in
                Button(action: {
                    selectedTab = tab
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.systemImageName)
                            .font(.displayTitle3Bold)
                        Text(tab.title)
                            .font(.displayCaption1Regular)
                    }
                    .foregroundStyle(
                        selectedTab == tab
                            ? Color("Blue800")  // 활성 색상
                            : Color("Gray500")  // 비활성 색상
                    )
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(height: 80)
        .background(Color("White"))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundStyle(Color("Gray300")),
            alignment: .top
        )
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedTab: TabBarItem = .measure
        
        var body: some View {
            VStack {
                Spacer()
                TabBarComponent(selectedTab: $selectedTab)
            }
        }
    }
    
    return PreviewWrapper()
}

