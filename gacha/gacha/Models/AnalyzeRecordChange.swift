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
    //최신 데이터
    let latestDate = latest.measuredDate
    let latestFlexionAngle = latest.flexionAngle
    let latestExtensionAngle = latest.extensionAngle
    let latestROM = latest.ROM
    let latestMeasuredTime = latest.measuredTime
    let latestPainLevel = latest.painLevel
    
    
    //과거 데이터
    let previousDate = previous.measuredDate
    let previousFlexionAngle = previous.flexionAngle
    let previousExtensionAngle = previous.extensionAngle
    let previousROM = previous.ROM
    let previousMeasuredTime = previous.measuredTime
    let previousPainLevel = previous.painLevel
    
    
    //계산 로직
    // ROM
    // 현재 rom과 과거 rom 차이값
    // 차이값에 따른 상태
        // 굴곡(Flexion) 상태에서 ROM 차이와 상태
    let flexRomDiffState = RomChangeState.calculate(latestAngle: latestFlexionAngle, previousAngle: previousFlexionAngle)
    let flexRomDiff = flexRomDiffState.delta
    
        // 신전(Extension) 상태에서 ROM 차이와 상태
    let extenRomDiffState = RomChangeState.calculate(latestAngle: latestExtensionAngle, previousAngle: previousExtensionAngle)
    let extenRomDiff = extenRomDiffState.delta
    
    // 통증
    // 현재 통증과 과거 통증 차이값
    // 차이값에 따른 상태
    let painDiffState = PainChangeState.calculate(latestPainLevel: latestPainLevel, previousPainLevel: previousPainLevel)
    let painDiff = painDiffState.delta
    
    
    
    return ChangeResult(flexRomDiff: flexRomDiff, flexRomDiffState: flexRomDiffState, extenRomDiff: extenRomDiff, extenRomDiffState: extenRomDiffState, painDiff: painDiff, painDiffState: painDiffState)
    
}
