import SwiftUI

struct DetailView: View {
    let record: MeasuredRecord

    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        
        VStack(spacing: 20) {
            // 상단 헤더 영역
            
            VStack(alignment: .leading) {
                HStack{
                    Text("2025-10-22")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("관절 가동 범위 측정 결과")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                Text("지난번보다 5° 더 좋아졌어요.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("지금처럼만 해도 충분히 잘하고 있어요 💪")
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
                Text("측정 결과는 이렇게 나왔어요 ⚡")
                    .font(.body)
                    .fontWeight(.semibold)
                HStack {
                    Text("굽힘 각도 :")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("\(record.flexionAngle)°")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                HStack {
                    Text("펴짐 각도 :")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("\(record.extensionAngle)°")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                HStack {
                    Text("총 가동 범위 :")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("\(record.extensionAngle - record.flexionAngle)°")
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
        
            // 확인 버튼
            Button(action: {
                // DetailView → ConfirmView 닫기
                presentationMode.wrappedValue.dismiss()

                // ConfirmView → MeasureView 닫기 (0.1초 후)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    presentationMode.wrappedValue.dismiss()
                }
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
            .padding(.horizontal, 20)
            .padding(.bottom, 120)
        }
        .navigationBarHidden(true)
    }
}
