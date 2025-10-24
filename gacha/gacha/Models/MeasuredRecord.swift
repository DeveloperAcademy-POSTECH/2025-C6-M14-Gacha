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
    // flexionAngle과 extensionAngle의 차이를 계산하여 ROM을 계산할 수 있지 않나?
    //var ROM: Double = 0.0

    public var ROM: Double {
        return extensionAngle - flexionAngle
    }

    var measuredMinutes: Int = 0
    var painLevel: Double = 0.0
    
    init (
        id: UUID,
        flexionAngle:Double,
        measuredDate: Date,
        extensionAngle: Double,
        //ROM: Double,
        measuredMinutes: Int,
        painLevel: Double
    ){
        self.id = id
        self.flexionAngle = flexionAngle
        self.measuredDate = measuredDate
        self.extensionAngle = extensionAngle
        //self.ROM = ROM
        self.measuredMinutes = measuredMinutes
        self.painLevel = painLevel
    }
}
