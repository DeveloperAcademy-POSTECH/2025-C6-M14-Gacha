//
//  MeasuredRecord.swift
//  gacha
//
//  Created by 차원준 on 10/23/25.
//
import SwiftData
import Foundation

@Model
class MeasuredRecord {
    var id: UUID = UUID()
    var measuredDate: Date = Date.now
    var flexionAngle: Double = 0.0
    var extensionAngle: Double = 0.0
    var ROM: Double = 0.0
    var measuredTime: Int = 0
    var painLevel: Int = 0
    
    init (
        id: UUID,
        flexionAngle:Double,
        measuredDate: Date,
        extensionAngle: Double,
        ROM: Double,
        measuredTime: Int,
        painLevel: Int
    ){
        self.id = id
        self.flexionAngle = flexionAngle
        self.measuredDate = measuredDate
        self.extensionAngle = extensionAngle
        self.ROM = ROM
        self.measuredTime = measuredTime
        self.painLevel = painLevel
    }
}
