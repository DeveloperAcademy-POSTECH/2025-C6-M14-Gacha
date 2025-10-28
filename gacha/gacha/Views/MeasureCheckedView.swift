//
//  MeasureCheckedView.swift
//  gacha
//
//  Created by 차원준 on 10/28/25.
//

import SwiftUI

struct MeasureCheckedView:View {
    var body: some View {
        ZStack{
            Circle()
                .frame(width: 234, height: 234)
                .foregroundStyle(.green)
            Image(systemName: "checkmark")
                .font(Font.system(size: 150))
                .foregroundStyle(.white)

        }
    }
}

#Preview {
    MeasureCheckedView()
}
