//
//  ExtensionMeasureView.swift
//  gacha
//
//  Created by 차원준 on 10/26/25.
//
import SwiftUI

struct ExtensionMeasureView: View {
    @Bindable var session: MeasureSession
    let onNext: () -> Void
    let onBack: () -> Void

    @State private var selection = 0
    @State private var showHistorySheet = false
    let items = ["ExtensionLeg", "HoldGesture"]
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // 상단 영역
                VStack(alignment: .leading, spacing: 9) {
                    HStack {
                        Button {
                            onBack()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.3))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "chevron.left")
                                    .frame(width: 44, height: 44)
                                    .foregroundStyle(.white)
                            }
                        }
                        Spacer()
                    }
                    
                    Text("화면을 꾹 눌러서 측정을 시작해주세요")
                        .font(.system(size: 22, weight: .bold))                }
                .padding(.horizontal, 20)
                .frame(height: geo.size.height * 0.25)

                
                // 중간 영역 (캐러셀 + 인디케이터)
                VStack(spacing: 10) {
                    TabView(selection: $selection) {
                        ForEach(Array(items.enumerated()), id: \.offset) { index, imageName in
                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 353, height: 300)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: 280)
                    }
                .frame(height: geo.size.height * 0.45)
                
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.blue.opacity(0.2))
            .onTapGesture {
                onNext()
            }
            .sheet(isPresented: $showHistorySheet) {
                ProgressHistoryView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.hidden)
            }
        }
    }
}

