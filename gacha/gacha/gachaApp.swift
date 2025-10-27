//
//  gachaApp.swift
//  gacha
//
//  Created by Oh Seojin on 10/20/25.
//

import SwiftData
import SwiftUI

@main
struct gachaApp: App {
    let modelContainer: ModelContainer

    init() {
            modelContainer = try ModelContainer(for: MeasuredRecord.self)
        }

    var body: some Scene {
        WindowGroup {
            MeasureView()
        }
        .modelContainer(modelContainer)
    }
}
