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
    let measureVM: MeasureViewModel

    init() {
        do {
            // 1. ModelContainer 생성
            modelContainer = try ModelContainer(for: MeasuredRecord.self)

            // 2. Repository 생성
            let repository = SwiftDataRecordRepository(
                modelContext: modelContainer.mainContext
            )

            // 3. ViewModel 생성
            measureVM = MeasureViewModel(repository: repository)
        } catch {
            fatalError("ModelContainer 초기화 실패: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            MeasureFlowView()
                .environmentObject(measureVM)
        }
        .modelContainer(modelContainer)
    }
}
