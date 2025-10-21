//
//  MainView.swift
//  gacha
//
//  Created by Oh Seojin on 10/22/25.
//

import SwiftData
import SwiftUI

struct MainView: View {
    var body: some View {
        ZStack {
            Image("mainViewImage")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()

        }
        .ignoresSafeArea()
    }

}

#Preview {
    MainView()
}
