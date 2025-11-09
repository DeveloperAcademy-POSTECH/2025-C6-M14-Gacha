//
//  AnalyzeRecordChange.swift
//  gacha
//
//  Created by 차원준 on 10/23/25.
//

/**
MeasuredRecord
var id: UUID = UUID()
var measuredDate: Date = Date.now
var flexionAngle: Double = 0.0
var extensionAngle: Double = 0.0
var ROM: Double = 0.0
var measuredTime: Int = 0
var painLevel: Double = 0.0
 
ChangeResult
- RomDiff: Double
- RomDiffState: `enum` ROM 측정값 변화 상태
- PainDiff: Double
- PainDiffState: `enum` 고통 점수 변화 상태
**/


func analyzeRecordChange(latest:MeasuredRecord, previous:MeasuredRecord) -> ChangeResult {
    // MARK: - 데이터
    //최신 데이터
    let latestDate = latest.measuredDate
    let latestFlexionAngle = latest.flexionAngle ?? 0.0
    let latestROM = latest.ROM ?? 0.0
    let latestMeasuredMinutes = latest.measuredSeconds ?? 0
    let latestPainLevel = latest.painLevel ?? 0
    
    
    //과거 데이터
    let previousDate = previous.measuredDate
    let previousFlexionAngle = previous.flexionAngle ?? 0.0
    let previousROM = previous.ROM ?? 0.0
    let previousMeasuredMinutes = previous.measuredSeconds ?? 0
    let previousPainLevel = previous.painLevel ?? 0
    
    
    //MARK: - 계산 로직
    // 굴곡(Flexion) 상태에서 ROM 차이와 상태
    let flexRomDiffState = RomChangeState.calculate(latestAngle: latestFlexionAngle, previousAngle: previousFlexionAngle)
    let flexRomDiff = flexRomDiffState.delta
    
    // Rom(굴곡)의 차이와 상태
    let romDiffState = RomChangeState.calculate(latestAngle: latestROM, previousAngle: previousROM)
    let romDiff = romDiffState.delta
    
    // 통증
    let painDiffState = PainChangeState.calculate(latestPainLevel: latestPainLevel, previousPainLevel: previousPainLevel)
    let painDiff = painDiffState.delta
    
    return ChangeResult(flexRomDiff: flexRomDiff, flexRomDiffState: flexRomDiffState, extenRomDiff: 0, extenRomDiffState: .normal(delta: 0.0), romDiff: romDiff, romDiffState: romDiffState, painDiff: painDiff, painDiffState: painDiffState)
    
}
