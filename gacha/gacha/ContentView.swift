//
//  ContentView.swift
//  gacha
//
//  Created by Oh Seojin on 10/20/25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Query var allRecords: [MesuredRecord]
    @Environment(\.modelContext) private var context
    
    var body: some View {
        VStack {
            Text("총 레코드 개수: \(allRecords.count)")
                .font(.headline)
                .padding()

            HStack {
                Button("데이터 추가") {
                    addRecord()
                }
                .buttonStyle(.borderedProminent)

                Button("전체 삭제") {
                    deleteAllRecords()
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .disabled(allRecords.isEmpty)
            }
            .padding()

            // 데이터 목록 표시
            List {
                ForEach(allRecords) { record in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("ID: \(record.id.uuidString.prefix(8))...")
                            Text("Angle: \(record.minAngle)° - \(record.maxAngle)°")
                            Text("Date: \(record.date.formatted())")
                        }

                        Spacer()

                        Button(action: {
                            deleteRecord(record)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
    }
    
    func addRecord() {
        let record = MesuredRecord(
            minAngle: 0,
            maxAngle: 90,
            isDeleted: false,
            image_id: "/"
        )
        
        context.insert(record)
        try? context.save()
        
        print("추가 후 레코드 개수: \(allRecords.count)")
    }
    
    func deleteRecord(_ record: MesuredRecord) {
        context.delete(record)
        try? context.save()
        print("레코드 삭제됨: \(record.id)")
    }

    private func deleteAllRecords() {
        for record in allRecords {
            context.delete(record)
        }
        try? context.save()
        print("모든 레코드 삭제됨")
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [MesuredRecord.self])
}
