//
//  ExtensionMeasureView.swift
//  gacha
//
//  Created by 차원준 on 10/26/25.
//
import SwiftUI

struct ExtensionMeasureView: View {
    @Bindable var session: MeasureSession

    @State private var selection = 0
    @State private var showHistorySheet = false
    let items = ["ExtensionLeg", "HoldGesture"]
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // 상단 영역
                VStack(alignment: .leading, spacing: 9) {
                    HStack {
                        Spacer()
                        Button {
                            showHistorySheet = true
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.3))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "chart.xyaxis.line")
                                    .frame(width: 44, height: 44)
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    
                    Text("무릎 펴짐정도 측정")
                        .font(.system(size: 34, weight: .bold))
                    Text("무릎이 최대로 펴지는 정도를 측정합니다.\n이후 이어지는 측정들을 통하여 추이를 확인할 수 있습니다.")
                        .font(.system(size: 15,weight: .medium))
                }
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
                session.moveToNextStep()
            }
            .sheet(isPresented: $showHistorySheet) {
                ProgressHistoryView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.hidden)
            }
        }
    }
}

