//
//  ConfirmView.swift
//  gacha
//
//  Created by Oh Seojin on 10/22/25.
//

import SwiftUI

struct ConfirmView: View {
    let record: MeasuredRecord

    @Environment(\.dismiss) private var dismiss
    @State private var navigateToDetail = false

    var onConfirm: () -> Void
    var onRetake: () -> Void
    var onDismissToHome: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // 상단 헤더
            HStack {
                if let flexionImage = loadImage(fileName: record.flexionImage_id) {
                    Image(uiImage: flexionImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
                if let extensionImage = loadImage(fileName: record.extensionImage_id) {
                    Image(uiImage: extensionImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
            }
            .padding()
            .background(Color(.systemBackground))


            // 하단 버튼 영역
            HStack {
                // 다시 촬영 버튼
                Button(action: {
                    dismiss()
                    onRetake()
                }) {
                    Text("재촬영")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                        .cornerRadius(12)
                }
                Spacer()
                // 확인 버튼
                Button(action: {
                    navigateToDetail = true
                    onConfirm()
                }) {
                    Text("확인")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.1), radius: 5, y: -2)

            // DetailView로 네비게이션
            NavigationLink(
                destination: DetailView(
                    record: record,
                    onDismiss: {
                        onDismissToHome()
                    }
                )
                .navigationBarHidden(true),
                isActive: $navigateToDetail
            ) {
                EmptyView()
            }
            .hidden()
        }
        .navigationBarHidden(true)
    }
}
