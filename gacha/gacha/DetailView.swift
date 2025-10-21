import SwiftUI

struct DetailView: View {
    let record: MeasuredRecord


    @Environment(\.dismiss) private var dismiss
    
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
                        VStack {
                            // 굴곡 이미지
                            if let flexionImage = loadImage(fileName: record.flexionImage_id) {
                                Image(uiImage: flexionImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .rotationEffect(.degrees(-90)) // 90도 회전

                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 180)
                                    .overlay(
                                        VStack {
                                            Image(systemName: "photo")
                                                .font(.largeTitle)
                                                .foregroundColor(.gray)
                                            Text("굴곡 이미지")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    )
                            }
                            
                            // 신전 이미지
                            if let extensionImage = loadImage(fileName: record.extensionImage_id) {
                                Image(uiImage: extensionImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .rotationEffect(.degrees(-90)) // 90도 회전
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 180)
                                    .overlay(
                                        VStack {
                                            Image(systemName: "photo")
                                                .font(.largeTitle)
                                                .foregroundColor(.gray)
                                            
                                            Text("신전 이미지")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    )
                            }
                        }
                    )
            }
            .padding(.horizontal, 20)
            
            // 측정 결과 텍스트 영역

            VStack(alignment:.leading, spacing:20) {
                Text("측정 결과는 이렇게 나왔어요 ⚡")
                    .font(.title3)
                    .fontWeight(.semibold)
                HStack {
                    Text("굽힘 각도 :")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("\(record.flexionAngle)°")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                HStack {
                    Text("펴짐 각도 :")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("\(record.extensionAngle)°")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                HStack {
                    Text("총 가동 범위 :")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("\(record.extensionAngle - record.flexionAngle)°")
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
        
            
            Spacer()
            
            // 확인 버튼
            Button(action: {
                dismiss()
            }) {
                Text("확인")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black, lineWidth: 2)
                    )
                    .cornerRadius(8)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 80)
        }
        .navigationBarHidden(true)
    }
}
