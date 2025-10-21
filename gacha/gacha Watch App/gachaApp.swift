//
//  gachaApp.swift
//  gacha Watch App
//
//  Created by Oh Seojin on 10/20/25.
//

import SwiftUI

@main
struct gacha_Watch_AppApp: App {
    
    init() {
        // WatchConnectivity 초기화
        WatchLink.shared.start()
        print("✅ Watch 앱 시작 - WatchLink 초기화")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
