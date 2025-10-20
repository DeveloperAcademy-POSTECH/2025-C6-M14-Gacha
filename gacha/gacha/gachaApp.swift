//
//  gachaApp.swift
//  gacha
//
//  Created by Oh Seojin on 10/20/25.
//

import SwiftUI
import SwiftData

@main
struct gachaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [
                    MeasuredRecord.self,
                ])
        }
    }
}
