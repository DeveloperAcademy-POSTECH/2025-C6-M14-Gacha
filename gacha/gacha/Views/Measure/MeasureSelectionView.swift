//
//  MeasureSelectionView.swift
//  gacha
//
//  Created by Oh Seojin on 11/16/25.
//

import SwiftUI

struct MeasureSelectionView: View {
    @State private var showAlert: Bool = false
    @EnvironmentObject var vm: MeasureViewModel

    var body: some View {
        ScrollView {
            VStack (spacing: 16) {
                CardView(
                    title: Strings.SelectType.Knee.Flexion.title,
                    description: Strings.SelectType.Knee.Flexion.description,
                    isActive: true,
                    action: {
                        // Knee Card 선택 시 modal flow 시작
                        vm.startMeasureFlow(
                            initialStep: .home,
                            from: .select
                        )
                    }
                )
                CardView(
                    title: Strings.SelectType.Shoulder.Flexion.title,
                    description: Strings.SelectType.Shoulder.Flexion.description,
                    isActive: false,
                    action: { showAlert = true }
                )
                CardView(
                    title: Strings.SelectType.Elbow.Extension.title,
                    description: Strings.SelectType.Elbow.Extension.description,
                    isActive: false,
                    action: { showAlert = true }
                )
                CardView(
                    title: Strings.SelectType.Hip.Adduction.title,
                    description: Strings.SelectType.Hip.Adduction.description,
                    isActive: false,
                    action: { showAlert = true }
                )
            }
            .padding(.top, 32)
            .padding(.horizontal, 16)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(Strings.Alert.notyetTitle),
            message: Text(Strings.Alert.notyetMessage),
            dismissButton: .default(Text("닫기")))
        }
    }
    
    struct CardView: View {
        var title: String
        var description: String
        var isActive: Bool
        var action: () -> Void

        var body: some View {
            Button(action: action) {
                VStack (spacing: 16) {
                    HStack {
                        Text(title)
                            .font(.displayTitle3Bold)
                            .foregroundColor(isActive ? .blue700 : .gray500)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.displayTitle3Bold)
                            .foregroundColor(isActive ? .black : .gray900)
                    }
                    Text(description)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(isActive ? .black : .gray900)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(isActive ? .blue200 : .gray300)
                .cornerRadius(25)
            }
            .buttonStyle(.plain)
            .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 2)

        }
    }
}

#Preview {
    MeasureSelectionView()
}
