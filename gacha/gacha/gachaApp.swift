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
        do {
            modelContainer = try ModelContainer(for: MeasuredRecord.self)

        } catch {
            fatalError("ModelContainer 초기화 실패: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            MeasureFlowViewWrapper()
                .preferredColorScheme(.light)
        }
        .modelContainer(modelContainer)
    }              
}
