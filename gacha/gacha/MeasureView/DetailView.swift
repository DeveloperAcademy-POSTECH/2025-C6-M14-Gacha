import SwiftUI

struct DetailView: View {
    let record: MeasuredRecord

    @Environment(\.dismiss) private var dismiss
    var onDismiss: () -> Void

    var body: some View {
        
        VStack(spacing: 20) {
            // 상단 헤더 영역
            
            VStack(alignment: .leading) {
//                HStack{
                    Text("2025-10-22")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Joint Range of Motion Test Results")
                        .font(.title2)
                        .fontWeight(.bold)
//                }
                Text("You've improved by 5° compared to last time.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("You're doing great just as you are! 💪")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 80)
            
            
            
            // 이미지 표시 영역
            VStack(spacing: 16) {
                Rectangle()
                    .stroke(Color.black, lineWidth: 2)
                    .frame(height: 350)
                    .overlay(
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
                        
                    )
            }
            .padding(.horizontal, 20)
            
            // 측정 결과 텍스트 영역

            VStack(alignment:.leading, spacing:10) {
                Text("Here are your test results ⚡")
                    .font(.body)
                    .fontWeight(.semibold)
                HStack {
                    Text("Flexion Angle:")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("\(record.flexionAngle)°")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                HStack {
                    Text("Extension Angle:")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("\(record.extensionAngle)°")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                HStack {
                    Text("Total Range of Motion:")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("\(record.extensionAngle - record.flexionAngle)°")
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
        
            // Confirm button
            Button(action: {
                onDismiss()
            }) {
                Text("Confirm")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 120)
        }
        .navigationBarHidden(true)
    }
}
