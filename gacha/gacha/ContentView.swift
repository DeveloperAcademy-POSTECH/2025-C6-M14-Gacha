//
//  ContentView.swift
//  gacha
//
//  Created by Oh Seojin on 10/20/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var motionManager = MotionMeasureManager()

    var body: some View {
        VStack {
            Text("Content View")
        }
    }
}

#Preview {
    ContentView()
}
