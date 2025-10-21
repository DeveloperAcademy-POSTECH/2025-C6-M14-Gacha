//
//  ContentView.swift
//  gacha
//
//  Created by Oh Seojin on 10/20/25.
//

import SwiftData
import SwiftUI

struct ContentView: View {

    @Query(sort: \MeasuredRecord.date, order: .forward) var allRecords: [MeasuredRecord]
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            Text("총 레코드 개수: \(allRecords.count)")
                .font(.headline)
                .padding()

            HStack {
                Button("데이터 추가") {
                    addRecord()
                    print("추가 버튼 누르기")
                }
                .buttonStyle(.borderedProminent)

                Button("전체 삭제") {
                    deleteAllRecords()
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .disabled(allRecords.isEmpty)
                NavigationLink("측정하기") {
                    MeasureView()
                }
            }
            .padding()

            // 데이터 목록 표시
            List {
                ForEach(allRecords) { record in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("ID: \(record.id.uuidString.prefix(8))...")
                            Text("Flexion: \(record.flexionAngle)° Extension: \(record.extensionAngle)°")
                            Text("Range: \(record.extensionAngle - record.flexionAngle)°")
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
        print("=== 레코드 추가 시작 ===")
        print("현재 레코드 개수: \(allRecords.count)")
        
        // flexion: 110~45 범위의 랜덤값 (감소하는 값)
        let flexion = Int.random(in: 45...110)
        // extension: 175~180 범위의 랜덤값 (증가하는 값)
        let extensionValue = Int.random(in: 175...180)
        
        print("생성할 데이터 - Flexion: \(flexion), Extension: \(extensionValue)")
        
        let record = MeasuredRecord(
            flexionAngle: flexion,
            extensionAngle: extensionValue,
            isDeleted: false,
            image_id: "/"
        )
        
        print("레코드 생성됨: ID = \(record.id)")
        
        context.insert(record)
        print("context.insert 완료")
        
        do {
            try context.save()
            print("✅ 저장 성공!")
            
            // 저장 후 컨텍스트에서 직접 fetch해서 확인
            let descriptor = FetchDescriptor<MeasuredRecord>()
            let fetchedRecords = try context.fetch(descriptor)
            print("📊 컨텍스트에서 직접 fetch한 레코드 개수: \(fetchedRecords.count)")
            for (index, rec) in fetchedRecords.enumerated() {
                print("  [\(index)] ID: \(rec.id), Flexion: \(rec.flexionAngle), Extension: \(rec.extensionAngle)")
            }
        } catch {
            print("❌ 저장 실패: \(error.localizedDescription)")
            print("상세 에러: \(error)")
        }
        
        print("저장 후 @Query 레코드 개수: \(allRecords.count)")
        print("=== 레코드 추가 완료 ===\n")
    }
    
    func deleteRecord(_ record: MeasuredRecord) {
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

//
//#Preview {
//    ContentView()
//        .modelContainer(for: [MeasuredRecord.self])
//}

