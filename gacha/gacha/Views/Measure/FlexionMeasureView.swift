//
//  FlextionMeasureView.swift
//  gacha
//
//  Created by 차원준 on 10/26/25.
//



import SwiftUI

struct FlexionMeasureView: View {
    @Bindable var session: MeasureSession

    @State private var showingAlert = false

    
    @State private var selection = 0

    let items = ["FlexionLeg"]
        
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // 상단 영역
                VStack(alignment: .leading, spacing: 9) {
                    
                    Text("무릎 굽힘정도 측정")
                        .font(.system(size: 34, weight: .bold))
                    Text("무릎이 최대로 굽혀지는 정도를 측정합니다.\n통증이 너무 심할 경우 통증수준 기록으로 넘어갈 수 있습니다.")
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
                    
                    FCustomIndicator(count: items.count, selectedIndex: selection)
                }
                .frame(height: geo.size.height * 0.45)
                
                
                // 하단 영역
                VStack {
                    Text("측정을 시작하려면 화면을 꼭 눌러주세요")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.black)
                    
                    
                    Button(action: {
                        self.showingAlert.toggle()
                    }, label: {
                        Text("측정 건너뛰기")
                            .font(.system(size: 15, weight: .semibold))
                    })
                    .padding(.bottom, 20)
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("측정을 건너뛰시겠습니까?\n통증수준 기록으로 바로 넘어갑니다"), message: nil,primaryButton: .destructive(Text("네"), action: {
                            session.moveToNextStep()
                            
                        }), secondaryButton: .cancel(Text("아니요")))
                    }
                    
                }
                .frame(height: geo.size.height * 0.3)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.blue.opacity(0.2))
            .onTapGesture {
                session.moveToNextStep()
            }
        }
    }
}

    
struct FCustomIndicator : View {
    let count: Int
    let selectedIndex: Int

    var body: some View{
        HStack{
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(index == selectedIndex ? Color.black : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: selectedIndex)
            }
        }
        
    }
}

