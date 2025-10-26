//
//  RecordRepository.swift
//  gacha
//
//  Created by 차원준 on 10/23/25.
//

protocol RecordRepository {
    // @discardableResult은 프로토콜에 구현된 함수의 반환값을 사용하지 않아도 오류가 나지 않게 합니다!
    @discardableResult
    func saveRecord (flexion: Double, extension: Double, painLevel: Double) -> Bool
    func loadRecords() -> [MeasuredRecord]
    func loadLatestRecord() -> MeasuredRecord?
    func loadPreviousRecord() -> MeasuredRecord?

}

