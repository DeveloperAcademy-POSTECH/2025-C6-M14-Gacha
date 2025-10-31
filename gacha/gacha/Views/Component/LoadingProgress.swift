//
//  LoadingProgress.swift
//  gacha
//
//  Created by Oh Seojin on 10/31/25.
//

import Combine
import SwiftUI

struct LoadingProgress: View {
    @State private var rotation: Double = 0
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            Image("LoadingProgress")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(rotation))
                .onReceive(timer) { _ in
                    rotation += 45
                }
        }
    }
}

#Preview {
    LoadingProgress()
}
